# claude-skills
Reusable Claude Code skills, subagents, commands and hooks.

All assets live under `.claude/` — the directory is the distributable unit.

## Quickstart

### 1. Clone

```bash
git clone https://github.com/<your-username>/claude-skills.git <your-clone-path>
```

### 2. Link commands into your project

Inside any project you want to use these skills:

**macOS / Linux**
```bash
ln -s <your-clone-path>/.claude/commands .claude/commands/claude-skills
```

**Windows (PowerShell, run as Administrator)**
```powershell
New-Item -ItemType Junction -Path ".claude\commands\claude-skills" -Target "<your-clone-path>\.claude\commands"
```

This makes every command in this repo available as `/claude-skills/<command-name>` inside that project's Claude Code sessions.

### 3. Start a new Claude Code session

```bash
claude
```

Commands are loaded at session start. Type `/` to browse available commands.

---

## Using other asset types

**Rules** — Copy the content of any `.claude/rules/*.md` file into your project's `CLAUDE.md`.

**Hooks** — Merge the JSON from `.claude/hooks/` into your project's `.claude/settings.json` under the `hooks` key.

**Subagents** — Reference the prompt content from `.claude/subagents/` when spawning an agent via the `Agent` tool.
