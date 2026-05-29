# Architecture Notes

Status: draft template, awaiting mod concept decisions.

## Current Repository Shape

- `AGENTS.md`: persistent workflow rules for future agents and contributors.
- `README.md`: repository entry point and documentation map.
- `docs/`: planning, design, architecture, and checklist documents.

Runtime mod files are not scaffolded yet.

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

TBD.

Before adding persistent state, define:

- What data is stored.
- Whether it is global, force-level, surface-level, entity-level, or per-player.
- How it is initialized for new saves.
- How it is migrated for existing saves.
- How it is cleaned up when entities, players, forces, or surfaces are removed.

## Event Model

TBD.

For each runtime event handler, record:

- Event name.
- Why the event is needed.
- Expected frequency.
- Guard conditions.
- Performance risk.
- Multiplayer considerations.

## Prototype Model

TBD.

For each prototype change, record:

- Target prototype type and name.
- Whether the mod creates, modifies, or removes data.
- Compatibility risk with base game and other mods.
- Whether the change is gated by a startup setting.

## Compatibility Practices

- Prefer narrowly scoped behavior over broad global patches.
- Prefix all custom names, settings, commands, remote interfaces, and prototypes with the mod namespace.
- Avoid changing base prototypes unless the feature requires it and the compatibility risk is documented.
- Keep migrations explicit once released saves can contain mod-owned state.
- Treat multiplayer and headless behavior as first-class requirements when the feature touches runtime logic.
