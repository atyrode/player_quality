# Project Brief

Status: updated for V0.1.5 personal assembler pivot on 2026-05-29.

## Goal

Create a Factorio Space Age quality mod named `player_quality`.

Players can insert personal assembler equipment into modular armor. Each personal assembler opens a linked vanilla assembler GUI, so the player can use recipe quality, ingredient quality, and quality modules without placing a world assembler for every small job.

## Player Problem

Quality is a major Space Age system, but hand crafting does not naturally expose assembler-quality controls. Players carrying high-quality ingredients and wearing modular armor should be able to make intentional quality crafts without placing a permanent machine for every small job.

## Target Audience

- Space Age players who use quality and modular armor.
- Solo players and multiplayer groups.
- Players who want extra gameplay around personal equipment, not a full overhaul.

## V1 Scope

V1 proves the core loop:

- Add personal assembler armor equipment.
- Let players place that equipment in modular armor.
- Provide a small player-facing panel for opening linked assemblers.
- Reuse the vanilla assembler GUI for recipe quality, ingredient quality, and modules.
- Move accepted item ingredients from the player inventory into the linked assembler.
- Return crafted outputs to the player inventory.
- Drain armor-grid equipment energy while the linked assembler is enabled and crafting.

## Non-Goals

- No overhaul-level balance changes.
- No new production chain beyond personal assembler armor equipment.
- No intended support matrix for other mods in V1, though the implementation should avoid collisions.
- No custom graphics unless vanilla assembler/module icons cannot be reused cleanly.
- No guaranteed native-player-crafting-menu integration unless Factorio exposes the required GUI API later.
- No custom crafting queue while the linked vanilla assembler can own recipe and progress state.

## Assumptions

- The target Factorio version is Factorio 2.0+ Space Age with quality enabled.
- The implementation currently depends on `space-age` explicitly.
- Implementation should prefer Factorio's documented Lua API and conventional mod structure.
- Compatibility and save safety matter more than clever hooks.
- Adding the mod to an existing save should be safe.
- Removing the mod should not corrupt a save; mod-owned items/state may disappear as normal when disabling a mod.

## Open Decisions

- Whether fluid recipes should be unsupported, manual-only, or supported through a later fluid-transfer design.
- Whether equipment quality should affect personal assembler speed, energy buffer, or draw.
- Whether personal assembler recipes should stay tied to quality-module technologies or move to automation technologies after balance testing.
