# Rule: Secrets and Privacy

Before staging, committing or pushing anything, check it for secrets and personal data. The git
hooks in this repo's `githooks/` back this up (gitleaks on commit and push, plus a Claude privacy
review on push), but they are a safety net, not the first line of defence.

**Never commit:**
- Secrets: API keys, tokens, passwords, private keys, connection strings with credentials. Use
  environment variables, .NET user-secrets or a gitignored local config instead, and commit only
  empty placeholders.
- Other people's personal data: pupils or children (names with reports, attainment, SEN or welfare
  notes), customers, colleagues, candidates, contact details, dates of birth, health, financial or
  legal-settlement details. Real data exports (CSV/JSON/XLSX of people, database dumps, logs with
  user data) count, even in a private repo.
- Machine-local files: `.env`, `settings.local.json`, `CLAUDE.local.md`, key and certificate files.
- In a public repo, also the owner's own private details (address, phone, salary, settlement
  terms) and anything an employer would treat as confidential.

**Before staging:**
- Stage files by name, not with `git add -A` / `git add .`, unless you've just checked
  `git status` and every file is expected.
- Check the repo's `.gitignore` covers any data, output or local-config folders, and add to it
  first if not.
- Look inside data files before committing them. A file called `test.csv` or `example.docx` can
  still hold real people's data.

**When unsure, ask** rather than committing. Never use `SKIP_SECRET_SCAN=1` or
`SKIP_PRIVACY_REVIEW=1` without the user's explicit go-ahead for that specific commit or push.

**If a secret was committed:** don't just delete it in a new commit. Tell the user. Before it's
pushed, rewrite the commit; after it's pushed, treat it as leaked and rotate it.

**Allowing a deliberate exception:** list the path in `.privacy-allow` at the repo root (file
checks), or add a gitleaks fingerprint to `.gitleaksignore` / a `gitleaks:allow` comment
(secret patterns). Keep allow entries to specific files, not broad globs.
