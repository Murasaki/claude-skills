# Rule: Commit Messages

All commits must follow conventional commits format and be prefixed with `[claude]`.

**Format:** `[claude] <type>: <description>`

**Types:**
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation changes
- `refactor` — restructuring without behaviour change
- `chore` — maintenance, dependencies, config
- `test` — adding or updating tests
- `style` — formatting, no logic change

**Examples:**
```
[claude] feat: add godot scene backdrop skill
[claude] fix: resolve hook path on Windows
[claude] docs: update quickstart symlink instructions
[claude] chore: add settings.local.json to gitignore
```

Filter AI-authored commits with: `git log --grep='\[claude\]'`
