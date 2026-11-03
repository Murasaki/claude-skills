---
description: Run a game-dev task end to end from docs/tasks (clarify, plan, trace, implement, test, merge to dev)
argument-hint: <task number, e.g. 0011>
---

# /gamedev — Game Dev Task Runner

Takes a task number (e.g. `/gamedev 0011` or `/gamedev TASK-0011`).

## Step 1 — Load task context

Run this from the game repo's root. Normalise the argument to `TASK-XXXX` format, then find the
task file by recursive search: `docs/tasks/**/TASK-XXXX*.md`. This covers both layouts in use:
flat (`docs/tasks/TASK-0011.md`) and phase subfolders
(`docs/tasks/phase-0/TASK-0020-walk-manager.md`).
If no file matches, tell the user and stop.

## Step 2 — Clarify before starting

Read the task acceptance criteria and any open questions in the file, then use `AskUserQuestion` to resolve anything ambiguous:

- Is the scope clear, or are there design choices not covered by the task?
- Are there dependencies on other tasks that aren't done yet?
- Does this task require a Blender asset to be created or modified?
- Any constraints on approach (performance, style, API surface)?

Ask all questions in a single `AskUserQuestion` call. Do not start implementation until the user responds.

## Step 3 — Plan (for complex tasks)

If the task touches more than one system, introduces a new autoload/signal contract, requires a schema change, or is otherwise non-trivial, enter plan mode with `EnterPlanMode` before writing any code. Present the plan and wait for approval. Exit plan mode before implementing.

For simple single-file changes (tweaks, bug fixes, small additions) skip plan mode and implement directly.

## Step 4 — Create trace file

Before writing any code, create a trace file at:
`docs/trace/TASK-XXXX/[ISO_timestamp].md` (use dashes instead of colons in the timestamp, e.g. `2026-04-30T14-22-00.md`)

Include:
- **Prompt** — what was asked
- **Plan** — the approach decided on
- **Notes** — leave this section open; fill in decisions and deviations as you implement

## Step 5 — Implement

Work on a feature branch. Branch naming: `feat/task-XXXX-short-description` cut from `dev`.

If the task requires a Blender asset, invoke the `/murasaki:blender` command at this point before continuing with code work.

Follow all conventions in `CLAUDE.md`: input abstraction, asset-swappable design, signal contracts defined upfront, no hardcoded paths.

Commit at logical units of work using Conventional Commits. Do not make one giant commit at the end.

## Step 6 — Request manual test

When implementation is complete, tell the user:

> Implementation done. Please test in Godot:
> - [list the specific things to exercise based on the task acceptance criteria]
>
> Let me know when it's good (or describe what's broken).

Wait for the user's response. If something is broken, fix it and ask them to retest. Repeat until they confirm it's good.

## Step 7 — Merge to dev

Once the user confirms everything is good:

1. Mark the task as done in the task file found in Step 1 (update status and acceptance criteria checkboxes)
2. Update the backlog table in `docs/tasks/README.md`
3. Update the trace file Notes section with any final decisions
4. Commit the docs updates
5. Merge the feature branch into `dev` and push

```bash
git checkout dev
git merge --no-ff feat/task-XXXX-short-description
git push
```

Tell the user the branch has been merged and the task is closed.
