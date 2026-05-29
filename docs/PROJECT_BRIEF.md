# Project Brief

Status: initial direction recorded from operator answers on 2026-05-29.

## Goal

Create a Factorio Space Age quality mod named `player_quality`.

Players can insert quality-module-style equipment into modular armor. When crafting by hand, the player can choose ingredient quality and receive quality-upgrade chances using the same quality-roll model as assembling machines with quality modules.

## Player Problem

Quality is a major Space Age system, but hand crafting does not naturally behave like an assembler with quality modules. Players carrying high-quality ingredients and wearing modular armor should be able to make intentional quality crafts without placing a machine for every small job.

## Target Audience

- Space Age players who use quality and modular armor.
- Solo players and multiplayer groups.
- Players who want extra gameplay around personal equipment, not a full overhaul.

## V1 Scope

V1 proves the core loop:

- Add quality-module armor equipment.
- Let players place that equipment in modular armor.
- Provide a small player-facing quality crafting interface.
- Let players select ingredient quality for eligible hand-craftable recipes.
- Consume exact-quality ingredients from the player inventory.
- Roll output quality from equipped quality modules using Factorio's quality formula.
- Insert the crafted output into the player inventory.

## Non-Goals

- No overhaul-level balance changes.
- No new production chain beyond quality-module armor equipment.
- No intended support matrix for other mods in V1, though the implementation should avoid collisions.
- No custom graphics unless vanilla quality module icons cannot be reused cleanly.
- No guaranteed native-player-crafting-menu integration until the Factorio GUI API path is proven.
- No persistent crafting queue complexity until the basic quality crafting path works.

## Assumptions

- The target Factorio version is Factorio 2.0+ with quality enabled; exact local version still needs to be confirmed.
- The user owns or targets Space Age, but the implementation should depend only on the `quality` mod if that is sufficient.
- Implementation should prefer Factorio's documented Lua API and conventional mod structure.
- Compatibility and save safety matter more than clever hooks.
- Adding the mod to an existing save should be safe.
- Removing the mod should not corrupt a save; mod-owned items/state may disappear as normal when disabling a mod.

## Open Decisions

- Whether `info.json` should require `quality` only or full `space-age`.
- Whether V1 uses a mod-owned crafting UI only, or also attempts to augment the vanilla player crafting GUI.
- Whether quality crafting should use real crafting time immediately or be instant for the first proof of concept.
- Which vanilla technology should unlock the armor equipment.
