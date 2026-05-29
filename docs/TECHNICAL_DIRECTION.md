# Technical Direction

Status: V0.1.5 personal assembler direction recorded on 2026-05-29, with official API notes checked the same day.

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
- `LuaRecipe::has_category` is available for recipe category checks: https://lua-api.factorio.com/latest/classes/LuaRecipe.html#has_category
- `LuaForce::unlock_quality` and `LuaForce::is_quality_unlocked` are available for quality gating: https://lua-api.factorio.com/latest/classes/LuaForce.html#is_quality_unlocked
- `LuaControl::begin_crafting` accepts a `RecipeID`, starts normal player crafting, and raises `on_pre_player_crafted_item`: https://lua-api.factorio.com/latest/classes/LuaControl.html#begin_crafting
- `on_pre_player_crafted_item` exposes the recipe and removed ingredient inventory when crafting is queued: https://lua-api.factorio.com/latest/events.html#on_pre_player_crafted_item
- `on_player_crafted_item` exposes the crafted item stack before insertion: https://lua-api.factorio.com/latest/events.html#on_player_crafted_item
- Equipment grids support equipment quality and content inspection: https://lua-api.factorio.com/latest/classes/LuaEquipmentGrid.html
- Module prototypes expose module effects, and item prototypes expose module effects by quality: https://lua-api.factorio.com/latest/prototypes/ModulePrototype.html
- `LuaQualityPrototype::next` and `next_probability` expose the vanilla quality roll chain: https://lua-api.factorio.com/latest/classes/LuaQualityPrototype.html
- `LuaInventory::get_item_count` accepts item-with-quality filters for exact-quality ingredient checks: https://lua-api.factorio.com/latest/classes/LuaInventory.html#get_item_count
- `LuaEntity::get_recipe`, `set_recipe`, `get_output_inventory`, and `get_module_inventory` cover the linked assembler runtime surface: https://lua-api.factorio.com/latest/classes/LuaEntity.html
- Quality formula reference: https://wiki.factorio.com/Quality

Confirm exact API names, lifecycle events, prototype formats, dependency syntax, and packaging rules against the installed Factorio version before implementation.

## Target Game Version

- Target Factorio 2.0+.
- The user is targeting Space Age because quality was added there.
- The implementation now depends on `space-age` explicitly because current balancing and quality progression are tested against Space Age.
- A Factorio 2.0.76 headless test install is available on the VPS under `/mnt/HC_Volume_105232828/shared/games/factorio-headless/factorio`.
- GUI testing still requires a real Factorio client.

## Dependency Policy

- Required: `base`.
- Expected required: `space-age`.
- Avoid third-party dependencies for V1.
- Revisit a quality-only dependency only after a dedicated compatibility pass.

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

Current implementation matches this shape. Normal play uses a bottom-right personal assembler panel, debug tooling uses a separate GUI, and crafting is owned by linked hidden assemblers using vanilla assembler behavior.

## Build And Package Direction

Likely eventual helpers:

- `scripts/package.sh`: create a mod zip with the correct top-level folder name.
- `scripts/check.sh`: run syntax checks and lightweight packaging validation.
- `scripts/release.sh`: publish a release only from clean, pushed source if release automation is needed.

GitHub releases and Factorio Mod Portal uploads are both used now: GitHub for direct zip fallback, Mod Portal for fast in-game updates.

Current release direction:

- Use `scripts/release.sh` to build the zip and create or update a GitHub release for the current `info.json` version.
- Use `scripts/publish-portal.sh` to publish or update the Factorio Mod Portal release. It requires `FACTORIO_MOD_PORTAL_API_KEY` from `https://factorio.com/profile` with publish, upload, and edit permissions.
- Use `docs/PLAYTEST.md` as the operator-facing install and test guide.
- Prefer the Factorio Mod Portal for tester installs.
- The mod is published on the Factorio Mod Portal at `https://mods.factorio.com/mod/player_quality`.

## Validation Direction

Useful checks may include:

- Lua syntax checks for changed files.
- Loading the mod in a local Factorio install.
- Starting a new save.
- Loading an existing save if persistent state or migrations exist.
- Headless server test for multiplayer-sensitive behavior.
- Verifying the zip loads from the Factorio mods directory.
- Testing add-to-existing-save and remove-from-save behavior.

Current local checks:

- `scripts/check.sh`: validates `info.json` and runs `luac -p` when `luac` is installed.
- `scripts/package.sh`: runs checks and writes `dist/player_quality_<version>.zip`.
- Factorio 2.0.76 headless successfully created and benchmark-loaded a new save with `quality`, `space-age`, and `player_quality` enabled, which validated data-stage loading, `control.lua` compilation, and save reload.
- V0.1.1 also passed a temporary headless API smoke test covering the dot-call signatures for `LuaRecipe::has_category`, `LuaForce::is_quality_unlocked`, and `LuaItemPrototype::get_module_effects`.
- V0.1.2 passed a temporary headless equipment-grid smoke test covering insertion of `player-quality-quality-module-3-equipment` into power armor.
- V0.1.3 passed a headless create/reload check with Factorio 2.0.76. A temporary helper mod also validated the `standalone_character_gui` right-side relative GUI anchor.
- V0.1.4 passed a headless create/reload check with Factorio 2.0.76 after changing dependencies, settings, GUI lifecycle, equipment footprint, and runtime events.
- V0.1.5 passed a headless create and 120-tick benchmark check with Factorio 2.0.76 after replacing custom hand-crafting with personal assembler equipment and hidden linked assembler prototypes.

## Technical Risks

- Runtime event handlers can affect performance if they run too often or scan too broadly.
- Prototype changes can break compatibility with other mods if they assume base-game values.
- Persistent state requires migration discipline after release.
- GUI changes can conflict with player expectations or other mods if not scoped carefully.
- Multiplayer behavior must be deterministic and avoid per-client-only assumptions.
- `begin_crafting` only accepts `RecipeID`, not a documented recipe quality parameter, so V0.1.5 avoids custom player hand-crafting and reuses vanilla assembler quality controls.
- Hidden linked assemblers must be tested in a real client because headless checks cannot click/open the assembler GUI.
- Personal assembler equipment uses `battery-equipment` so energy state is visible and script-controllable.
- The inventory-transfer layer currently handles item ingredients and item outputs. Fluid recipes need a separate design.
