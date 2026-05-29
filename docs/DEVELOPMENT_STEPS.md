# Development Checklist

Status: first packageable prototype implemented and headless load-tested on 2026-05-29.

## Research

- [x] Confirm the mod goal and first player-facing feature.
- [x] Confirm target Factorio version.
- [x] Confirm whether Space Age is required, optional, or unsupported.
- [x] Check official Factorio API/prototype docs for the target version.
- [ ] Find one or two current reference mods if the feature touches a known pattern.
- [x] Record implementation constraints in `docs/TECHNICAL_DIRECTION.md`.
- [ ] Verify whether `quality` dependency alone is sufficient or whether `space-age` must be required.
- [ ] Verify if the native player crafting GUI can be augmented.

## Local Prerequisites

- [x] Locate the local Factorio install or confirm the intended test machine.
- [x] Confirm how to launch Factorio with this mod enabled.
- [x] Confirm where local mods are installed.
- [x] Decide whether a package script should copy or symlink the mod into the local mods directory.
- [x] If needed, install Factorio on the VPS through Steam CLI under `/mnt`.

## Scaffold

- [x] Add `info.json`.
- [x] Add `data.lua` with one prototype spike for quality-module armor equipment.
- [x] Add `control.lua` with one backend quality crafting spike.
- [x] Add `locale/` entries for player-facing strings.
- [x] Add a shortcut or custom input for opening the quality crafting UI.
- [ ] Add settings only if V1 behavior needs configuration.
- [x] Add package/check scripts for the first local test zip.
- [x] Add local install helper for the default Linux Factorio mods folder.

## First Playable Test

- [x] Load Factorio with the mod enabled.
- [x] Start a new save.
- [ ] Add or craft quality-module armor equipment.
- [ ] Insert the equipment into modular armor.
- [ ] Open the Player Quality crafting UI.
- [ ] Craft one eligible recipe using normal ingredients.
- [ ] Craft one eligible recipe using non-normal ingredients.
- [x] Save and reload if runtime state exists.
- [x] Check headless load output for errors or warnings.
- [x] Record the result in this checklist.

Headless result: Factorio 2.0.76 created and benchmark-loaded a new save with `quality`, `space-age`, and `player_quality` enabled. This validated prototype loading, `control.lua` compilation, and save reload, but did not exercise the GUI.

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
- [x] Decide whether to publish to GitHub only or also the Factorio mod portal.

Release channel decision: use GitHub Releases for V0.1.0 real-client testing. Publish to the Factorio Mod Portal after a real client confirms the GUI opens, crafts, and reloads cleanly.

## Debugging Workflow

- [x] Record useful log paths.
- [x] Record launch commands.
- [x] Record commands or remote interfaces added by the mod.
- [ ] Keep reproducible bug notes tied to exact Factorio version and mod version.
