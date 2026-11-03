---
description: Create or edit a Blender asset via a re-runnable Python script, export GLB, optionally wire it into a Godot scene
---

# /blender — Blender Asset Pipeline

You are entering the Blender asset pipeline. Detect the mode from the user's prompt:

- **Create mode** — no existing script for this asset, or the user said "make", "create", "new"
- **Edit mode** — asset already exists, or the user said "edit", "update", "change", "fix", "add to"

---

## Create Mode

Ask these clarifying questions before writing any script (adapt/skip as relevant):

1. What is this asset? (building, prop, character, terrain piece, etc.)
2. Approximate real-world dimensions?
3. Standalone object or modular/tileable?
4. Does it need an armature/rig? If so, what animations are expected?
5. Materials/textures, or geometry only?
6. Any specific details to include or omit?
7. **Express mode:** Wire it into a scene automatically after export? If yes, which scene?

Once answered, write the script to `assets/scripts/blender/[asset_name].py`.

---

## Edit Mode

Before writing anything:

1. Identify the existing script — check `assets/scripts/blender/` and read it.
2. Ask clarifying questions about the change:
   - What specifically needs to change? (geometry, materials, lighting, layout, dimensions)
   - Should existing objects be replaced, adjusted in-place, or added to?
   - Does the change affect the GLB export or Godot import in any way?
   - Are there any objects that must not be touched?
   - **Express mode:** Re-wire the updated GLB into a scene? If yes, which scene?

Edit the existing script in place. Do not create a new file unless fully replacing the scene.

---

## Script Conventions (always apply)

- Target **Blender 5.1** Python API
- Export format: **GLB** (via Python `bpy.ops.export_scene.gltf`, not manual)
- Poly budget: **2,000–8,000 triangles** for props/buildings; **5,000–15,000** for characters — flag if over
- Scripts must be **self-contained and re-runnable**: delete objects with the same name prefix before recreating
- Export path must be derived from `__file__` so it works in both GUI and headless:

```python
import os
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_REPO_ROOT  = os.path.abspath(os.path.join(_SCRIPT_DIR, "..", "..", ".."))
OUT_PATH    = os.path.join(_REPO_ROOT, "assets", "models", "...", "asset_name.glb")
```

- GLB export settings: apply modifiers, Y-up, include animations if present
- Print `[AssetName] Exported → <path>` at end so headless run confirms success

### Armature conventions (characters/rigs only)

- Bone names must use the **Godot/Mixamo humanoid convention**:
  `Hips`, `Spine`, `Chest`, `UpperChest`, `Neck`, `Head`,
  `LeftShoulder`, `LeftUpperArm`, `LeftLowerArm`, `LeftHand`,
  `RightShoulder`, `RightUpperArm`, `RightLowerArm`, `RightHand`,
  `LeftUpperLeg`, `LeftLowerLeg`, `LeftFoot`, `RightUpperLeg`, `RightLowerLeg`, `RightFoot`
- Animation action names must match `CharacterAnimationConfig` logical names (e.g. `idle`, `walk`, `run`, `jump`)
- After pushing all actions to NLA, clear the active action: `rig.animation_data.action = None`
- **Never call `frame_set` inside a keyframe-insert loop** — it wipes the pose. Use `keyframe_insert(frame=N)` directly.

### Known bone rotation directions (from `ClaudeAssetGuide.md`)

- Arm bones (T-pose along ±X): negative X rotation → arms hang down; positive X → arms up
- Spine/Chest (along +Y): negative X → forward lean; positive X → backward arch
- To reach natural hang from T-pose: `LeftUpperArm: (-0.87, 0, 0.15)`, `RightUpperArm: (-0.87, 0, -0.15)`

---

## Pipeline Steps (in order)

1. **Write or edit** the script at `assets/scripts/blender/[asset_name].py`
2. **Run headlessly** immediately after saving — do not wait to be asked:
   ```bash
   "C:/Program Files/Blender Foundation/Blender 5.1/blender.exe" --background --python "assets/scripts/blender/[asset_name].py"
   ```
3. Check console output for the `Exported →` confirmation line. If the run fails, fix the script and re-run.
4. **Express mode only:** Wire the exported GLB into the specified Godot scene following `docs/guides/assets/0006-BlenderToGodotCharacterPipeline.md`.

---

## Reference docs

- `docs/guides/assets/0005-BlenderScriptingGotchas.md` — animation pitfalls
- `docs/guides/assets/0006-BlenderToGodotCharacterPipeline.md` — GLB → Godot wiring
- `ClaudeAssetGuide.md` — bone rotation directions, NLA export, AnimationPlayer path
