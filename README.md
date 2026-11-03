# claude-skills

Reusable Claude Code rules, commands (as the `murasaki` plugin) and git hooks.

## Plugin: commands (`commands/`)

This repo is also a Claude Code plugin marketplace (`murasaki-plugins`) holding one plugin, `murasaki`.

| Command | What it does | Run from |
|---|---|---|
| `/murasaki:blender` | Create or edit a Blender asset through a re-runnable Python script, export GLB, optionally wire it into a Godot scene | a Godot game repo |
| `/murasaki:gamedev <task>` | Run a `docs/tasks` task end to end: clarify, plan, trace file, implement, manual test, merge to `dev` | a Godot game repo |
| `/murasaki:backdrop <prompt>` | Generate a scene backdrop (still or animated WebP) via ComfyUI | a repo with `tools/generate_backdrop.py`; needs `COMFYUI_PYTHON` set |

Install:

```
claude plugin install murasaki --marketplace Murasaki/claude-skills
```

Or enable it for a project in its tracked `.claude/settings.json`, so every PC that clones the project gets it:

```json
{
  "extraKnownMarketplaces": {
    "murasaki-plugins": { "source": { "source": "github", "repo": "Murasaki/claude-skills" } }
  },
  "enabledPlugins": { "murasaki@murasaki-plugins": true }
}
```

The plugin is served from GitHub's `main`, so changes here reach other projects once merged and the
marketplace is updated (`claude plugin marketplace update murasaki-plugins`).

## Rules (`.claude/rules/`)

| Rule | What it covers |
|------|----------------|
| `commits.md` | Conventional commits with a `[claude]` prefix |
| `pullrequests.md` | PR description template (What changed / How it was tested / Decisions) |
| `privacy.md` | Never commit secrets or personal data; how to check, ask and allow exceptions |

Use a rule by importing it from a project's `CLAUDE.md` with a relative path, for example:

```markdown
- Commits: @projects/claude-skills/.claude/rules/commits.md
```

## Git hooks (`githooks/`)

Secret and privacy checks for **every** git repo on the machine, not only commits Claude makes.

| Hook | Checks | Bypass once |
|------|--------|-------------|
| `pre-commit` | [gitleaks](https://github.com/gitleaks/gitleaks) over staged changes (with `githooks/gitleaks.toml`); blocks `.env`, key and certificate files, `settings.local.json`, `CLAUDE.local.md`, and CSV/TSV files with a personal-data column (name, email, DOB, ...) and at least one data row | `SKIP_SECRET_SCAN=1` |
| `pre-push` | gitleaks over every outgoing commit; for non-private repos, an **identity check** on commit author/committer metadata (see below); then a **privacy review by `claude -p`** of the outgoing diff, told whether the GitHub repo is public or private. Fails closed: if the review can't run, the push stops | `SKIP_PRIVACY_REVIEW=1` (review only), `SKIP_SECRET_SCAN=1` (all) |

**Identity check:** commit metadata isn't part of the diff, so neither gitleaks nor the review sees
it. List names and emails that must never reach a public repo in your **local** git config (not
in any repo), and pushes to public or unknown-visibility repos are blocked if an outgoing commit
carries one:

```powershell
git config --global --add hooks.blockedIdentity "Real Name"
git config --global --add hooks.blockedIdentity "real.email@example.com"
```

Per-repo exceptions:
- `.privacy-allow` at the repo root: glob patterns, one per line, let files past the pre-commit
  file checks (for example a fictional `template.csv`). The push review still sees them.
- `.gitleaksignore` (fingerprints) or a `gitleaks:allow` comment silences a gitleaks false positive.

A repo's own `.git/hooks/pre-commit` / `pre-push` still runs: the hooks chain to it.

**Employer or other third-party code:** the privacy review sends the outgoing diff to Claude under
your login. Turn it off where that isn't allowed (gitleaks still runs locally):

```ini
# e.g. in ~/.gitconfig-work, included for every repo under C:\src\work
[hooks]
    privacyReview = false
```

### Install (once per PC)

```powershell
winget install --id Gitleaks.Gitleaks --exact
git config --global core.hooksPath "<path-to>/claude-skills/githooks"
```

The privacy review needs Claude Code (`claude`) on `PATH`, signed in; it uses that login, not an
API key. Each review is one Sonnet call of a few seconds.

On a workspace with `clone-all.ps1`, the script sets `core.hooksPath` for you.

## Conventions

- Every asset starts with a header explaining its purpose and usage.
- Rules are plain Markdown, written to be imported as-is.
