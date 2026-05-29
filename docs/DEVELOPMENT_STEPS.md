# Development Checklist

Status: V0.1.5 personal assembler pivot implemented on 2026-05-29.

## Research

- [x] Confirm the mod goal and first player-facing feature.
- [x] Confirm target Factorio version.
- [x] Confirm whether Space Age is required, optional, or unsupported.
- [x] Check official Factorio API/prototype docs for the target version.
- [ ] Find one or two current reference mods if the feature touches a known pattern.
- [x] Record implementation constraints in `docs/TECHNICAL_DIRECTION.md`.
- [x] Require `space-age` for the current Space Age-targeted playtest path.
- [x] Verify a relative GUI can be anchored to the character inventory for a vanilla-adjacent panel.

## Local Prerequisites

- [x] Locate the local Factorio install or confirm the intended test machine.
- [x] Confirm how to launch Factorio with this mod enabled.
- [x] Confirm where local mods are installed.
- [x] Decide whether a package script should copy or symlink the mod into the local mods directory.
- [x] If needed, install Factorio on the VPS through Steam CLI under `/mnt`.

## Scaffold

- [x] Add `info.json`.
- [x] Add `data.lua` with personal assembler armor equipment and linked hidden assembler prototypes.
- [x] Add `control.lua` with linked assembler lifecycle, panel, inventory transfer, and energy gating.
- [x] Add `locale/` entries for player-facing strings.
- [x] Add a shortcut or custom input for opening the quality crafting UI.
- [x] Add runtime-global personal assembler energy multiplier setting.
- [x] Add package/check scripts for the first local test zip.
- [x] Add local install helper for the default Linux Factorio mods folder.

## First Playable Test

- [x] Load Factorio with the mod enabled.
- [x] Start a new save.
- [ ] Add or craft personal assembler armor equipment.
- [ ] Insert the equipment into modular armor.
- [ ] Open the bottom-right `Personal assemblers` panel in a real client.
- [ ] Open the linked vanilla assembler GUI.
- [ ] Craft one recipe using normal ingredients.
- [ ] Craft one recipe using non-normal ingredients.
- [x] Save and reload if runtime state exists.
- [x] Check headless load output for errors or warnings.
- [x] Record the result in this checklist.

Headless result: Factorio 2.0.76 created and benchmark-loaded a new save with `quality`, `space-age`, and `player_quality` enabled. This validated prototype loading, `control.lua` compilation, and save reload, but did not exercise the real linked assembler GUI.

V0.1.1 smoke result: a temporary local helper mod called the corrected Factorio API methods for recipe category checks, quality unlock checks, and module effect lookup during `on_init`; Factorio 2.0.76 completed map creation without errors.

## Compatibility And Safety

- [ ] Review whether the feature affects existing saves.
- [ ] Add migration notes before releasing any persistent-state change.
- [ ] Test with Space Age if support is claimed.
- [ ] Test multiplayer or headless server behavior if support is claimed.
- [ ] Document known incompatibilities.

## Packaging And Release

- [x] Decide versioning rules.
- [x] Add package script if needed.
- [x] Validate the zip layout before release.
- [x] Write release notes.
- [x] Add GitHub release helper.
- [x] Add Factorio Mod Portal publish helper.
- [x] Decide whether to publish to GitHub only or also the Factorio mod portal.

Release channel decision: publish to the Factorio Mod Portal so in-game install/update can be used for faster iteration.

Portal result: V0.1.1 is published at `https://mods.factorio.com/mod/player_quality`.

V0.1.2 adds `/player-quality-test-setup` so test saves can be prepared without a long `/c` command.

V0.1.3 adds the character-inventory quality crafting panel, keeps `/player-quality` as a debug GUI, requires module energy, and enforces researched quality caps.

V0.1.4 fixes reported recipe/quality gate test issues, adds explicit debug research buttons, adds a status-button fallback crafting window, increases module footprint/cost, and adds a runtime-global chance multiplier setting.

V0.1.5 replaces the custom hand-crafting path with personal assembler equipment, linked hidden assemblers, vanilla assembler quality controls, inventory transfer, and armor-grid energy gating.

## Debugging Workflow

- [x] Record useful log paths.
- [x] Record launch commands.
- [x] Record commands or remote interfaces added by the mod.
- [ ] Keep reproducible bug notes tied to exact Factorio version and mod version.
