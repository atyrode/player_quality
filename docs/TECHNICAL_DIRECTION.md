# Technical Direction

Status: initial direction recorded from operator answers on 2026-05-29, with official API notes checked the same day.

## Current Research Snapshot

Date: 2026-05-29.

Known stable Factorio mod shape:

- `info.json` declares mod metadata, version, dependencies, and supported Factorio version.
- Data-stage files such as `data.lua`, `data-updates.lua`, and `data-final-fixes.lua` change prototypes.
- Runtime files such as `control.lua` handle events and persistent game state.
- `settings.lua` defines startup, map, or per-player settings.
- `locale/` holds player-facing translations.
- `graphics/`, `sound/`, and similar folders hold assets when needed.
- `migrations/` handles save-state transitions after released persistent data changes.

Official docs checked:

- Runtime docs version 2.0.77: https://lua-api.factorio.com/latest/
- Prototype docs version 2.0.76: https://lua-api.factorio.com/latest/prototypes.html
- `LuaControl::begin_crafting` accepts a `RecipeID`, starts normal player crafting, and raises `on_pre_player_crafted_item`: https://lua-api.factorio.com/latest/classes/LuaControl.html#begin_crafting
- `on_pre_player_crafted_item` exposes the recipe and removed ingredient inventory when crafting is queued: https://lua-api.factorio.com/latest/events.html#on_pre_player_crafted_item
- `on_player_crafted_item` exposes the crafted item stack before insertion: https://lua-api.factorio.com/latest/events.html#on_player_crafted_item
- Equipment grids support equipment quality and content inspection: https://lua-api.factorio.com/latest/classes/LuaEquipmentGrid.html
- Module prototypes expose module effects, and item prototypes expose module effects by quality: https://lua-api.factorio.com/latest/prototypes/ModulePrototype.html
- Quality formula reference: https://wiki.factorio.com/Quality

Confirm exact API names, lifecycle events, prototype formats, dependency syntax, and packaging rules against the installed Factorio version before implementation.

## Target Game Version

- Target Factorio 2.0+.
- The user is targeting Space Age because quality was added there.
- The implementation should depend on the `quality` mod if sufficient, rather than requiring the full `space-age` mod.
- Local install path is not known yet.
- The VPS has Steam CLI available and enough `/mnt` storage; downloading a Factorio test install is a setup task.

## Dependency Policy

- Required: `base`.
- Expected required: `quality`.
- Avoid third-party dependencies for V1.
- Do not require `space-age` unless the game or mod portal rejects a quality-only dependency for this behavior.

## Expected Repository Shape

Initial likely shape:

```text
.
|-- AGENTS.md
|-- README.md
|-- docs/
|-- info.json
|-- control.lua
|-- settings.lua
|-- data.lua
|-- locale/
`-- scripts/
```

Only add files that the chosen feature actually needs.

Likely V1 shape:

```text
.
|-- info.json
|-- data.lua
|-- control.lua
|-- locale/
|   `-- en/
|       `-- player-quality.cfg
`-- scripts/
    |-- check.sh
    `-- package.sh
```

## Build And Package Direction

Likely eventual helpers:

- `scripts/package.sh`: create a mod zip with the correct top-level folder name.
- `scripts/check.sh`: run syntax checks and lightweight packaging validation.
- `scripts/release.sh`: publish a release only from clean, pushed source if release automation is needed.

GitHub releases come first. Factorio mod portal packaging comes after the first locally validated build.

## Validation Direction

Useful checks may include:

- Lua syntax checks for changed files.
- Loading the mod in a local Factorio install.
- Starting a new save.
- Loading an existing save if persistent state or migrations exist.
- Headless server test for multiplayer-sensitive behavior.
- Verifying the zip loads from the Factorio mods directory.
- Testing add-to-existing-save and remove-from-save behavior.

## Technical Risks

- Runtime event handlers can affect performance if they run too often or scan too broadly.
- Prototype changes can break compatibility with other mods if they assume base-game values.
- Persistent state requires migration discipline after release.
- GUI changes can conflict with player expectations or other mods if not scoped carefully.
- Multiplayer behavior must be deterministic and avoid per-client-only assumptions.
- `begin_crafting` only accepts `RecipeID`, not a documented recipe quality parameter, so quality ingredient selection likely requires custom crafting logic.
- The native player crafting GUI may not expose a direct relative GUI target for injecting an ingredient quality selector.
- Inert armor equipment needs a valid equipment prototype subtype; validate which subtype can be used without unwanted gameplay effects.
- Reimplementing recipe handling can get complex for fluids, multiple products, catalysts, recursive prerequisites, and unlock gating. V1 should restrict eligible recipes until each case is proven.
