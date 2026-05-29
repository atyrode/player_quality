# Architecture Notes

Status: initial direction recorded from operator answers on 2026-05-29.

## Current Repository Shape

- `AGENTS.md`: persistent workflow rules for future agents and contributors.
- `README.md`: repository entry point and documentation map.
- `docs/`: planning, design, architecture, and checklist documents.

Runtime mod files are not scaffolded yet.

Expected first runtime shape:

- `data.lua`: declare quality-module armor equipment, items, recipes, shortcut/custom input if needed.
- `control.lua`: GUI lifecycle, quality crafting logic, equipment scanning, craft completion, and save/load hooks.
- `locale/en/player-quality.cfg`: player-facing names, descriptions, GUI captions, and messages.

## Ownership Boundaries

Use these ownership boundaries once implementation begins:

- `info.json`: mod identity, Factorio version, dependencies, and mod portal metadata.
- `settings.lua`: startup, map, and per-player settings.
- `data*.lua`: prototype creation or modification.
- `control.lua`: runtime events, global state, GUI behavior, commands, remote interfaces, and migrations hooks.
- `locale/`: all player-facing strings.
- `graphics/` and `sound/`: shipped assets only.
- `migrations/`: released save-state transitions.
- `scripts/`: local build, packaging, validation, and release helpers.

Do not add cross-cutting runtime systems until the first feature proves they are needed.

## Runtime State

Preferred V1 state:

- Per-player GUI state: selected recipe, ingredient quality, and count.
- Optional per-player craft queue only if real crafting time is implemented.

Avoid persistent state for equipment effects; compute equipped quality-module chance from the current armor equipment grid when needed.

If a custom crafting queue is implemented, store:

- Player index.
- Recipe name.
- Ingredient quality name.
- Count remaining.
- Progress ticks.
- Precomputed output plan only if needed for save/load stability.

Do not store Lua objects in persistent state.

## Event Model

Likely events:

- `on_gui_click`, `on_gui_selection_state_changed`, and related GUI events for the quality crafting UI.
- `on_lua_shortcut` or a custom input for opening the UI.
- `on_player_armor_inventory_changed`, `on_equipment_inserted`, and `on_equipment_removed` only if cached equipment state is needed.
- `on_tick` only if a custom timed crafting queue is implemented.
- `on_player_crafted_item` only if a later iteration modifies vanilla hand-crafting output.

Avoid frequent inventory scans. Scan equipment on demand or in response to equipment/armor events.

## Prototype Model

Expected custom prototypes:

- `player-quality-quality-module-equipment`
- `player-quality-quality-module-2-equipment`
- `player-quality-quality-module-3-equipment`
- Matching item prototypes.
- Matching recipes.
- Optional shortcut/custom input for opening the UI.

Expected dependency on vanilla prototypes:

- Vanilla quality modules supply source icon/effect semantics.
- Vanilla armor equipment category should be used if possible so existing modular armor grids accept the equipment.

Avoid modifying vanilla quality modules or armor grids unless testing proves it is required.

## Compatibility Practices

- Prefer narrowly scoped behavior over broad global patches.
- Prefix all custom names, settings, commands, remote interfaces, and prototypes with the mod namespace.
- Avoid changing base prototypes unless the feature requires it and the compatibility risk is documented.
- Keep migrations explicit once released saves can contain mod-owned state.
- Treat multiplayer and headless behavior as first-class requirements when the feature touches runtime logic.
- Prefer custom UI and custom equipment over patching native player crafting behavior globally.
