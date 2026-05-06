#!/usr/bin/env python3
"""
PreToolUse hook — blocks git commits that contain secrets or sensitive data.
Calls Claude Sonnet via the Anthropic API. Fails open: if the API call errors,
the commit is allowed through rather than blocked.

Usage in settings.json:
  {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": "python3 /path/to/security-scan.py" }]
    }]
  }

Requires: anthropic Python package  (pip install anthropic)
"""
import json
import subprocess
import sys

SYSTEM_PROMPT = """You are a security scanner. Analyze the provided git diff for secrets, credentials, and sensitive data.

Flag:
- API keys and tokens (AWS, GCP, GitHub, Stripe, Twilio, SendGrid, Slack, etc.)
- Private keys (RSA, SSH, PEM, PKCS)
- Passwords or passphrases as literal values
- Database connection strings containing credentials
- JWT secrets, session signing keys, OAuth client secrets, webhook secrets
- High-entropy strings assigned to names like KEY, SECRET, TOKEN, PASSWORD, CREDENTIAL

Do NOT flag:
- Placeholder values (your-api-key-here, xxxx, changeme, example.com)
- Environment variable references (os.environ["KEY"], process.env.SECRET)
- Test fixtures with obviously fake data
- Comments explaining where secrets belong

Respond with JSON only, no other text:
{"safe": true, "findings": []}

Or if issues found:
{"safe": false, "findings": [{"type": "...", "description": "...", "snippet": "first ~20 chars only"}]}"""


def main():
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    command = hook_input.get("tool_input", {}).get("command", "")
    if "git commit" not in command:
        sys.exit(0)

    diff = subprocess.run(
        ["git", "diff", "--cached", "--unified=0"],
        capture_output=True, text=True
    ).stdout.strip()

    if not diff:
        sys.exit(0)

    try:
        import anthropic
        client = anthropic.Anthropic()
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": diff}]
        )
        result = json.loads(response.content[0].text.strip())
    except Exception as e:
        print(f"[security-scan] warning: scan skipped ({e})", file=sys.stderr)
        sys.exit(0)

    if not result.get("safe", True):
        print("\n[security-scan] Commit blocked — sensitive data detected:\n", file=sys.stderr)
        for f in result.get("findings", []):
            print(f"  • {f.get('type', 'Issue')}: {f.get('description', '')}", file=sys.stderr)
            if f.get("snippet"):
                print(f"    {f['snippet']}", file=sys.stderr)
        print("\nRemove sensitive data before committing.\n", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
