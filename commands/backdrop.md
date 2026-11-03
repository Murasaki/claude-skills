---
description: Generate a scene backdrop image (or animated WebP) via ComfyUI from a plain-English prompt
allowed-tools: Bash, AskUserQuestion
---

# /backdrop — Generate a Scene Backdrop

Takes a plain-English image prompt (e.g. `/backdrop a dusty tavern interior with candlelight`).
Optionally add `--animate` at the end to generate a looping animated WebP instead of a still.

## Step 1 — Parse arguments

`$ARGUMENTS` is the raw input. Split it on ` --animate` to detect the animate flag:
- If `--animate` is present anywhere in the arguments, set `animate = true` and strip it from the prompt.
- The remaining text is the image prompt.

If the prompt is empty, use `AskUserQuestion` to ask the user for one before continuing.

Derive a scene `--name` from the prompt: take the first 3–4 meaningful words, lowercase, joined with underscores (e.g. "a dusty tavern interior" → `dusty_tavern_interior`).

## Step 2 — Assess prompt quality

A good backdrop prompt includes most of these dimensions:
- **Location type** — interior or exterior, what kind of space
- **Lighting / time of day** — candlelit, overcast, golden hour, moonlit, fluorescent
- **Mood / atmosphere** — cozy, eerie, grand, derelict, magical, tense
- **Key details** — notable props, architectural features, weather, foliage

If the prompt is missing two or more of these dimensions (e.g. just "a tavern" or "forest"), use `AskUserQuestion` to gather what's missing. Ask all questions in a single call. Examples:

- "Is this interior or exterior?"
- "What time of day or lighting? (e.g. candlelit, overcast dawn, bright midday, moonlit)"
- "What mood or atmosphere? (e.g. cozy and warm, eerie and abandoned, grand and imposing)"
- "Any specific details to include? (e.g. a fireplace, barrels, mist, rain on windows)"
- If `animate = true`: "What should move in the scene? (e.g. candle flames, water rippling, curtains, drifting clouds)"

Once the user responds, fold their answers into a richer prompt before proceeding.

## Step 3 — Verify ComfyUI is reachable

Run this health check silently:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8188/system_stats
```

- If the response is `200`, ComfyUI is up — proceed immediately to Step 4 without asking the user anything.
- If the request fails or returns a non-200 status, tell the user:

> ComfyUI is not reachable at http://localhost:8188.
> Start it with `run_nvidia_gpu.bat` in the ComfyUI portable folder, then run `/backdrop` again.

If `animate = true` and ComfyUI is not up, also note:

> Animation requires **ComfyUI-AnimateDiff-Evolved** and a motion module. If not yet installed:
> 1. Open ComfyUI → Manager → Install Custom Nodes → search "AnimateDiff Evolved" → Install
> 2. Download the SDXL motion module: `guoyww/animatediff-motion-adapter-sdxl-beta` from Hugging Face
>    Place `mm_sdxl_v10_beta.ckpt` in `ComfyUI/models/animatediff_models/`
> 3. Restart ComfyUI

Stop here if ComfyUI was not reachable.

## Step 4 — Generate

If `tools/generate_backdrop.py` does not exist in the current project, tell the user it needs to be set up and stop.

Run the generation script using the ComfyUI embedded Python:

The ComfyUI portable install differs per PC, so its embedded Python comes from the `COMFYUI_PYTHON`
environment variable (the full path to `ComfyUI_windows_portable\python_embeded\python.exe`; the PC's
`CLAUDE.local.md` records where it is). If `COMFYUI_PYTHON` is unset or the file doesn't exist, tell
the user to set it and stop.

**Still image:**
```bash
"$COMFYUI_PYTHON" tools/generate_backdrop.py "<prompt>" --name <name>
```

**Animated WebP:**
```bash
"$COMFYUI_PYTHON" tools/generate_backdrop.py "<prompt>" --name <name> --animate
```

Stream the output so the user can see progress dots.

## Step 5 — Report result

When the script exits successfully, tell the user:

- The output path (`assets/backgrounds/<name>/<timestamp>.png` or `.webp`)
- The seed used (printed by the script) — so they can pin it with `--seed` to reproduce
- For stills: offer to regenerate with a different seed, or with `--steps 40` for higher quality
- For animations: offer to adjust `--frames` (default 16) or `--fps` (default 8), or add `--steps 40`
- For stills: offer to re-run with `--animate` if they want a looping version
