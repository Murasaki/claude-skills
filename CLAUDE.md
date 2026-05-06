# claude-skills

A personal library of reusable Claude Code assets. All assets live under `.claude/` so the whole directory can be linked into consuming projects.

## Repo structure

```
.claude/
├── commands/    # Slash commands (Claude Code standard location)
├── rules/       # Standalone rules to paste into a project's CLAUDE.md
├── hooks/       # Hook JSON snippets to merge into settings.json
└── subagents/   # Agent prompt definitions
```

## Rules active in this repo

**Commits** — Follow conventional commits format with a `[claude]` prefix, e.g. `[claude] feat: add security review skill`. Defined in `.claude/rules/commits.md`.

## Conventions

- Every asset has a header explaining its purpose and usage
- Commands use `verb-noun.md` naming (e.g. `review-security.md`, `init-project.md`)
- Subagents use `noun-role.md` naming (e.g. `docs-guardian.md`, `code-explorer.md`)
- Hook snippets document the event they target (`PreToolUse`, `PostToolUse`, `Stop`, etc.)

## Adding a new asset

| Type | Location | Notes |
|------|----------|-------|
| Skill / command | `.claude/commands/` | Available as a slash command |
| Rule | `.claude/rules/` | Copy content into consuming project's `CLAUDE.md` |
| Hook | `.claude/hooks/` | Merge into consuming project's `.claude/settings.json` |
| Subagent | `.claude/subagents/` | Reference prompt when using the `Agent` tool |
