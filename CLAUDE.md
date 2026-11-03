# claude-skills

A personal library of reusable Claude Code assets: rules that other projects import from their
`CLAUDE.md`, and git hooks installed machine-wide via `core.hooksPath`. See `README.md` for usage.

## Repo structure

```
.claude/
└── rules/                 # Markdown rules, imported by relative path from a project's CLAUDE.md
    ├── commits.md
    ├── pullrequests.md
    └── privacy.md
githooks/                  # git hooks for every repo on the PC (core.hooksPath points here)
├── pre-commit             # gitleaks on staged changes + personal-data file checks
├── pre-push               # gitleaks on outgoing commits + `claude -p` privacy review
├── gitleaks.toml          # gitleaks default rules + extra rules (RapidAPI, Anthropic)
├── privacy-review-prompt.md
└── lib/common.sh          # shared helpers (sourced by both hooks)
```

## Rules active in this repo

@.claude/rules/commits.md
@.claude/rules/pullrequests.md
@.claude/rules/privacy.md

## Working on the hooks

- The hooks are bash; Git for Windows runs them with its own bash, so keep to POSIX tools plus
  bash builtins (no Python).
- They're live on every repo on this PC. Test changes in a scratch repo first, with
  `git -c core.hooksPath=<this folder>/githooks ...` or a local `git config core.hooksPath`,
  against a local bare repo as the remote.
- Keep them failing closed: when a check can't run, stop the commit/push with a clear message
  and the bypass variable.
- Never print a matched secret: gitleaks runs with `--redact`, and the review prompt forbids
  repeating values.

## Open TODOs

- Convert to a Claude Code plugin so commands/agents can be shared without relative imports.
