# Architecture Notes

Status: V0.1.5 personal assembler architecture on 2026-05-29.

## Current Repository Shape

- `AGENTS.md`: persistent workflow rules for future agents and contributors.
- `README.md`: repository entry point and documentation map.
- `docs/`: planning, design, architecture, and checklist documents.
- `info.json`: mod metadata and dependencies.
- `data.lua`: personal assembler equipment, hidden linked assembler entities, items, recipes, shortcut, and keybind prototypes.
- `control.lua`: bottom-right assembler panel, debug GUI, equipment scan, hidden assembler lifecycle, inventory transfer, energy consumption, and output insertion.
- `locale/en/player-quality.cfg`: English names, descriptions, GUI text, and command help.
- `changelog.txt`: Factorio-facing release notes.
- `scripts/`: lightweight check and package helpers.

Expected first runtime shape:

- `data.lua`: declare personal assembler armor equipment, linked assembler entities, items, recipes, shortcut/custom input if needed.
- `control.lua`: GUI lifecycle, hidden assembler management, inventory transfer, energy gating, and save/load hooks.
- `settings.lua`: runtime-global personal assembler energy multiplier.
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

- Per-player linked assembler slots and debug infinite-energy toggle.
- Runtime-global setting state: personal assembler energy multiplier, default `1.0`, clamped between `0.1` and `10.0`.

The linked assembler entity owns recipe, quality selection, module inventory, and crafting progress. The mod rebuilds or destroys slots based on the current armor equipment grid.

The current prototype stores LuaEntity references for linked hidden assemblers. If save/load testing shows invalid references or migration friction, replace this with stable entity lookup through registration.

## Event Model

Likely events:

- `on_gui_click`, `on_gui_checked_state_changed`, and related GUI events for the personal assembler/debug UI.
- `on_gui_opened` to refresh the bottom-right panel when the player opens normal game GUIs.
- `on_lua_shortcut` or a custom input for opening the debug GUI.
- `on_research_finished` and configuration sync for retroactive personal assembler recipe unlocks.
- `on_player_armor_inventory_changed`, `on_player_placed_equipment`, and `on_player_removed_equipment` for refreshing linked assembler slots.
- `on_runtime_mod_setting_changed` for refreshing energy setting displays.
- `on_nth_tick` for energy draw, ingredient feeding, output return, and panel status refresh.

Keep scans coarse. The current prototype scans equipped assemblers and active assembler inventories every 30 ticks for connected players.

## Prototype Model

Expected custom prototypes:

- `player-quality-personal-assembler-equipment`
- `player-quality-personal-assembler-2-equipment`
- `player-quality-personal-assembler-3-equipment`
- `player-quality-personal-assembler-entity`
- `player-quality-personal-assembler-2-entity`
- `player-quality-personal-assembler-3-entity`
- Matching item prototypes.
- Matching recipes.
- Optional shortcut/custom input for opening the debug UI.

Expected dependency on vanilla prototypes:

- Vanilla assemblers supply source icon/entity semantics.
- Vanilla quality modules are inserted into linked assemblers directly by the player.
- Vanilla armor equipment category should be used if possible so existing modular armor grids accept the equipment.

Avoid modifying vanilla quality modules or armor grids unless testing proves it is required.

Current implementation details:

- The equipment prototypes are 4x4 `battery-equipment` with tiered buffers/input flow so they can be inserted into standard armor grids and spend charge while crafting.
- Recipes consume assemblers, matching vanilla quality modules, batteries, and tier-appropriate circuit/structural ingredients.
- Recipes are unlocked from the matching vanilla quality module technologies when those technologies exist; runtime sync explicitly disables them again if an old save had them enabled before research.
- Hidden assembler entities use copied vanilla assembling-machine prototypes with void energy, no collision mask, no mining, and script-controlled `active` state.
- Runtime energy gating drains the matching equipment while the linked assembler has a recipe and is enabled.
- Runtime inventory transfer inserts only item ingredients accepted by the assembler input inventory, preserving vanilla quality filters.
- Vanilla assembler behavior handles quality selection, module effects, and output quality gates.

## Compatibility Practices

- Prefer narrowly scoped behavior over broad global patches.
- Prefix all custom names, settings, commands, remote interfaces, and prototypes with the mod namespace.
- Avoid changing base prototypes unless the feature requires it and the compatibility risk is documented.
- Keep migrations explicit once released saves can contain mod-owned state.
- Treat multiplayer and headless behavior as first-class requirements when the feature touches runtime logic.
- Prefer custom UI and custom equipment over patching native player crafting behavior globally.
