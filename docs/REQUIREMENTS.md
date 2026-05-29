# Requirements

Status: V0.1.4 requirements snapshot on 2026-05-29.

## Functional Requirements

- The mod adds armor equipment items that represent quality modules.
- Quality-module equipment can be inserted into modular armor grids.
- When a player has quality-module equipment installed, the mod exposes a quality hand-crafting interface.
- The interface lets the player choose an eligible recipe, ingredient quality, and craft count.
- The player-facing quality crafting interface should be attached to the character inventory/crafting workflow when possible.
- Ingredient quality is exact, matching vanilla quality-machine behavior: all item ingredients must be available at the selected quality.
- Ingredient quality choices must be limited to qualities unlocked by the player's force.
- Fluid-only recipes and recipes with fluid ingredients are out of V1 unless a direct player-crafting path is proven.
- The output base quality is the selected ingredient quality.
- Equipped quality-module equipment contributes quality chance according to the corresponding vanilla quality module and the equipment item's own quality.
- The output quality roll should match Factorio quality behavior: roll once using total quality chance; if upgraded, repeat further upgrades with the game's 10% follow-up chance until the roll fails or the maximum unlocked quality is reached.
- Equipped personal quality modules must have stored energy to contribute to quality crafting.
- Personal quality module recipes must unlock with the matching vanilla quality module technologies, including when added to an existing save.
- Personal quality module chance must be configurable from 0.01x to 1.0x, defaulting to 0.1x.
- Personal quality module equipment should be a meaningful armor-grid commitment; current target is 4x4.
- Multiplayer should work out of the box by keeping all state in deterministic runtime script state.

## User Experience Requirements

- Player-facing text must be clear in Factorio's UI and localization format.
- New controls, shortcuts, alerts, or GUI surfaces must be predictable and not compete with base-game workflows.
- Settings should exist only when they change meaningful behavior.
- The long-term preferred UX is for ingredient quality controls to feel close to assembler recipe quality controls.
- V1 uses a mod-owned relative GUI next to the character inventory. Free-floating GUI controls are debug-only.

## Compatibility Requirements

- Target Factorio 2.0+ Space Age with the quality feature enabled.
- Depend on `space-age` explicitly while the mod is designed and tested against Space Age quality progression.
- Avoid direct edits to vanilla recipes where possible.
- Avoid changing existing armor grid definitions unless required to let the new equipment fit.
- Use a `player-quality` namespace for custom prototypes, settings, GUI element names, shortcuts, custom inputs, and runtime state.
- Multiplayer and dedicated-server compatibility are V1 requirements.
- Adding to an existing save is a V1 requirement.
- Removing from a save should be safe in the Factorio sense: the game should load without the mod, and mod-owned items/state may be removed.

## Data And Persistence Requirements

- Prefer no persistent state until the quality crafting proof of concept works.
- If a custom crafting queue is needed, store only per-player queue entries with recipe, selected ingredient quality, count, progress, and pending output.
- Do not store Lua objects in persistent state; store stable names, quality names, player indices, and numeric progress.
- Add migrations before release if persistent queue data or settings schema change after a public build.

## Validation Requirements

Before release, define the smallest meaningful checks for:

- Loading the mod in Factorio.
- Starting or loading a save.
- Exercising the primary feature.
- Multiplayer or headless server behavior, if required.
- Migration behavior, if persistent state exists.
- Equipping and removing quality-module equipment.
- Crafting from normal and non-normal ingredients.
- Verifying quality output distribution enough to catch obvious formula errors.

## Release Requirements

- GitHub releases first for fast iteration.
- Factorio mod portal is the end goal so friends can install and update easily.
- Package zip layout must match Factorio mod portal expectations.
- Versioning should start at `0.1.0` for the first playable local build.
