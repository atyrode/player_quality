# Requirements

Status: V0.1.5 requirements snapshot on 2026-05-29.

## Functional Requirements

- The mod adds personal assembler armor equipment items.
- Personal assembler equipment can be inserted into modular armor grids.
- When a player has personal assembler equipment installed, the mod exposes a small panel for opening linked assemblers.
- Linked assemblers use Factorio's vanilla assembler GUI for recipe selection, recipe quality, ingredient quality, and modules.
- Ingredient quality choices and output quality behavior are governed by the vanilla assembler UI and force research gates.
- Personal assemblers pull item ingredients from the player's inventory when the assembler input accepts them.
- Personal assemblers return completed item outputs to the player's inventory or spill overflow at the player.
- Fluid recipes are out of V1 for automatic inventory feeding.
- Personal assembler equipment must have stored energy to run unless debug infinite energy is enabled.
- Personal assembler recipes must unlock with the matching vanilla quality module technologies, including when added to an existing save.
- Personal assembler energy draw must be configurable from 0.1x to 10.0x, defaulting to 1.0x.
- Personal assembler equipment should be a meaningful armor-grid commitment; current target is 4x4.
- Multiplayer should work out of the box by keeping all state in deterministic runtime script state.

## User Experience Requirements

- Player-facing text must be clear in Factorio's UI and localization format.
- New controls, shortcuts, alerts, or GUI surfaces must be predictable and not compete with base-game workflows.
- Settings should exist only when they change meaningful behavior.
- The preferred UX is to reuse the vanilla assembler controls instead of reimplementing quality selection.
- V1 uses a small bottom-right panel only when personal assembler equipment is worn. Free-floating GUI controls are debug-only.

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

- Store per-player linked assembler slots and debug toggles.
- Keep persistent state minimal and rebuild hidden assembler entities from currently equipped armor when possible.
- Avoid storing complex derived crafting state; the assembler entity owns recipe, quality, modules, and crafting progress.
- Add migrations before release if persistent queue data or settings schema change after a public build.

## Validation Requirements

Before release, define the smallest meaningful checks for:

- Loading the mod in Factorio.
- Starting or loading a save.
- Exercising the primary feature.
- Multiplayer or headless server behavior, if required.
- Migration behavior, if persistent state exists.
- Equipping and removing personal assembler equipment.
- Opening linked assemblers and selecting recipes/qualities through the vanilla GUI.
- Pulling normal and non-normal item ingredients from inventory.
- Returning outputs and recovering assembler contents when equipment is removed.

## Release Requirements

- GitHub releases first for fast iteration.
- Factorio mod portal is the end goal so friends can install and update easily.
- Package zip layout must match Factorio mod portal expectations.
- Versioning should start at `0.1.0` for the first playable local build.
