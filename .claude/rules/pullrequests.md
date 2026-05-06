# Rule: Pull Requests

All pull requests must use the following template.

**Template:**
```
## What changed
<clear description of the change and why it was made>

## How it was tested
<what was run, checked, or verified — be specific>

## Decisions
<non-obvious choices made and the reasoning behind them; omit if none>
```

**Example:**
```
## What changed
Added a pre-commit security scanner hook that calls Claude Sonnet to detect
secrets in staged diffs before allowing a git commit through.

## How it was tested
Staged a file containing a fake AWS key and confirmed the hook blocked the
commit with a clear error message. Verified clean diffs pass without delay.

## Decisions
Fails open on API errors — a network blip should never lock a developer out
of committing. Snippet in findings is capped at ~20 chars to avoid echoing
the secret back into logs.
```
