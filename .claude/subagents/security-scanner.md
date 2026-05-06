# Security Scanner Subagent

## Purpose
Scans a git diff for secrets, credentials, and sensitive data before a commit is allowed through.
Used by `.claude/hooks/security-scan.py` via the Anthropic API.

## Model
`claude-sonnet-4-6`

## Input
The full output of `git diff --cached --unified=0` passed as the user message.

## Output
JSON only — no other text:

```json
{ "safe": true, "findings": [] }
```
```json
{
  "safe": false,
  "findings": [
    {
      "type": "AWS access key",
      "description": "Hardcoded AKIA key in config.py",
      "snippet": "AKIAIOSFODNN7..."
    }
  ]
}
```

## What to flag
- API keys and tokens (AWS, GCP, GitHub, Stripe, Twilio, SendGrid, Slack, etc.)
- Private keys (RSA, SSH, PEM, PKCS)
- Passwords or passphrases written as literal values
- Database connection strings that include credentials
- JWT secrets or session signing keys
- OAuth client secrets or webhook signing secrets
- High-entropy strings assigned to variables named KEY, SECRET, TOKEN, PASSWORD, or similar

## What NOT to flag
- Placeholder or example values (`your-api-key-here`, `xxxx`, `changeme`)
- References to environment variables (`os.environ["KEY"]`, `process.env.SECRET`)
- Test fixtures with obviously fake or randomly generated data
- Comments explaining where secrets should go
