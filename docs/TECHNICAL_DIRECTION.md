# Technical Direction

Status: draft template, awaiting mod concept decisions and current Factorio version check.

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

Confirm exact API names, lifecycle events, prototype formats, dependency syntax, and packaging rules against the target Factorio version before implementation.

## Target Game Version

TBD.

Record:

- Factorio version.
- Whether Space Age is required.
- Whether the mod must work without expansion content.
- Local install path and launch method, if useful.

## Dependency Policy

TBD.

Prefer no dependencies for a small quality-of-life mod unless an existing library clearly reduces risk.

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

## Build And Package Direction

TBD.

Likely eventual helpers:

- `scripts/package.sh`: create a mod zip with the correct top-level folder name.
- `scripts/check.sh`: run syntax checks and lightweight packaging validation.
- `scripts/release.sh`: publish a release only from clean, pushed source if release automation is needed.

## Validation Direction

TBD.

Useful checks may include:

- Lua syntax checks for changed files.
- Loading the mod in a local Factorio install.
- Starting a new save.
- Loading an existing save if persistent state or migrations exist.
- Headless server test for multiplayer-sensitive behavior.

## Technical Risks

- Runtime event handlers can affect performance if they run too often or scan too broadly.
- Prototype changes can break compatibility with other mods if they assume base-game values.
- Persistent state requires migration discipline after release.
- GUI changes can conflict with player expectations or other mods if not scoped carefully.
- Multiplayer behavior must be deterministic and avoid per-client-only assumptions.
