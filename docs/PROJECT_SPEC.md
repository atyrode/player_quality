# Project Spec

Status: initial direction recorded from operator answers on 2026-05-29.

## Goal

Create a Factorio Space Age quality mod named `player_quality`.

The mod lets modular armor act as the player's quality-module carrier for hand crafting.

## Working Assumption

The target behavior probably needs both data-stage prototypes and runtime scripting:

- Data stage for armor equipment items and recipes.
- Runtime control for quality-aware hand crafting, equipment scanning, GUI, and output quality rolls.

The native player crafting menu may not be directly extensible. Prove the backend with a mod-owned GUI first, then investigate whether a vanilla-menu-adjacent integration is possible.

## Research Sources To Prefer

- Official Factorio Lua API documentation for the target game version.
- Official Factorio modding tutorials and prototype documentation.
- Source code of current, maintained Factorio mods that solve similar problems.
- Local game logs and in-game behavior from the user's installed Factorio version.
- Factorio wiki quality page for player-facing formula references, then verify implementation details against the Lua API and in-game behavior.

## First Milestone

Milestone 1: quality ingredient selection and output roll proof of concept.

Player-visible flow:

- Player equips at least one quality-module armor equipment item.
- Player opens the Player Quality crafting GUI.
- Player selects an eligible hand-craftable recipe.
- Player selects ingredient quality.
- Player crafts one item.
- The mod consumes exact-quality ingredients, rolls output quality using equipped module chance, and inserts the result into the player's inventory.

Implementation files likely needed:

- `info.json`
- `data.lua`
- `control.lua`
- `locale/en/player-quality.cfg`
- `scripts/package.sh` once local testing is ready

Validation:

- Load a clean Space Age or quality-enabled save.
- Insert equipment into modular armor.
- Craft a simple item from normal ingredients.
- Craft the same item from non-normal ingredients.
- Confirm output quality never goes below selected ingredient quality.
- Confirm removing the equipment disables or hides quality crafting.

## Next Target

After the proof of concept:

- Add all three vanilla quality-module equipment tiers.
- Gate equipment behind appropriate quality/module technologies.
- Decide whether quality crafting should share the vanilla crafting queue timing or use a mod-owned queue.
- Explore a GUI that appears near the player crafting screen or armor screen.
- Add package and release scripts.

## Success Criteria

- The mod loads without errors.
- Quality-module equipment can be crafted and inserted into modular armor.
- A player can choose ingredient quality for at least one eligible recipe through the mod UI.
- The crafted output respects selected ingredient quality and module-based upgrade chance.
- The behavior works after save/load.
- Removing the mod does not corrupt the save.
- Logs are clean enough to debug real issues.
- The implementation has a clear path to GitHub release packaging and later mod portal publishing.
