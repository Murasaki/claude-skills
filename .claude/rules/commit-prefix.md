# Rule: Commit Message Prefix

Always prefix every commit message with `[claude]`.

**Example:** `[claude] add security review skill`

**Applies to:** all `git commit` calls made by Claude in this project.

This makes AI-authored commits visually distinct in git history and easy to filter with `git log --grep='\[claude\]'`.
