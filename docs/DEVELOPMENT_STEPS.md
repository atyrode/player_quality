# Development Checklist

Status: draft template, awaiting mod concept decisions.

## Research

- [ ] Confirm the mod goal and first player-facing feature.
- [ ] Confirm target Factorio version.
- [ ] Confirm whether Space Age is required, optional, or unsupported.
- [ ] Check official Factorio API/prototype docs for the target version.
- [ ] Find one or two current reference mods if the feature touches a known pattern.
- [ ] Record implementation constraints in `docs/TECHNICAL_DIRECTION.md`.

## Local Prerequisites

- [ ] Locate the local Factorio install or confirm the intended test machine.
- [ ] Confirm how to launch Factorio with this mod enabled.
- [ ] Confirm where local mods are installed.
- [ ] Decide whether a package script should copy or symlink the mod into the local mods directory.

## Scaffold

- [ ] Add `info.json`.
- [ ] Add only the required lifecycle files for the first milestone.
- [ ] Add `locale/` entries for player-facing strings.
- [ ] Add settings only if V1 behavior needs configuration.
- [ ] Add scripts only after repeated manual commands are known.

## First Playable Test

- [ ] Load Factorio with the mod enabled.
- [ ] Start a new save.
- [ ] Exercise the first feature.
- [ ] Save and reload if runtime state exists.
- [ ] Check `factorio-current.log` for errors or warnings.
- [ ] Record the result in this checklist.

## Compatibility And Safety

- [ ] Review whether the feature affects existing saves.
- [ ] Add migration notes before releasing any persistent-state change.
- [ ] Test with Space Age if support is claimed.
- [ ] Test multiplayer or headless server behavior if support is claimed.
- [ ] Document known incompatibilities.

## Packaging And Release

- [ ] Decide versioning rules.
- [ ] Add package script if needed.
- [ ] Validate the zip layout before release.
- [ ] Write release notes.
- [ ] Decide whether to publish to GitHub only or also the Factorio mod portal.

## Debugging Workflow

- [ ] Record useful log paths.
- [ ] Record launch commands.
- [ ] Record commands or remote interfaces added by the mod.
- [ ] Keep reproducible bug notes tied to exact Factorio version and mod version.
