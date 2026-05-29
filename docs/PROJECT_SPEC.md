# Project Spec

Status: V0.1.5 personal assembler pivot implemented on 2026-05-29.

## Goal

Create a Factorio Space Age quality mod named `player_quality`.

The mod lets modular armor host personal assemblers that reuse Factorio's vanilla assembler GUI for recipe quality, ingredient quality, and module slots.

## Working Assumption

The target behavior probably needs both data-stage prototypes and runtime scripting:

- Data stage for armor equipment items, linked hidden assembling-machine prototypes, recipes, shortcuts, and settings.
- Runtime control for equipment scanning, hidden assembler lifecycle, inventory transfer, armor-grid energy gating, and debug tooling.

The native player crafting menu is not directly extensible enough for vanilla-quality crafting controls. The current workaround is to provide armor-grid personal assemblers and let the base assembler UI handle quality behavior.

## Research Sources To Prefer

- Official Factorio Lua API documentation for the target game version.
- Official Factorio modding tutorials and prototype documentation.
- Source code of current, maintained Factorio mods that solve similar problems.
- Local game logs and in-game behavior from the user's installed Factorio version.
- Factorio wiki quality page for player-facing formula references, then verify implementation details against the Lua API and in-game behavior.

## First Milestone

Milestone 1: linked personal assembler proof of concept.

Player-visible flow:

- Player equips at least one personal assembler armor equipment item.
- A bottom-right `Personal assemblers` panel appears.
- Player opens the linked vanilla assembler GUI.
- Player selects recipe quality, ingredient quality, and modules through vanilla controls.
- The mod pulls matching item ingredients from player inventory and returns outputs to the player.
- The assembler drains armor-grid equipment energy while enabled and crafting.

Implementation files likely needed:

- `info.json`
- `data.lua`
- `control.lua`
- `locale/en/player-quality.cfg`
- `scripts/package.sh` once local testing is ready

Status: implemented locally as a packageable personal assembler prototype. Factorio 2.0.76 headless can load the mod, create a new save, and run a 120-tick benchmark. V0.1.5 removes the custom hand-crafting panel and replaces it with linked hidden assemblers opened from armor equipment.

Validation:

- Load a clean Space Age save.
- Insert personal assembler equipment into modular armor.
- Open the linked assembler through the bottom-right panel.
- Select recipe/quality and install quality modules in the vanilla GUI.
- Confirm item ingredients move from player inventory to assembler input.
- Confirm outputs return to player inventory.
- Confirm removing the equipment removes the panel and destroys the linked assembler after returning contents.

## Next Target

After the proof of concept:

- Real-client playtest the linked assembler GUI and inventory-transfer behavior.
- Decide whether fluid recipes should be explicitly hidden, supported by a fluid container pattern, or left to manual insertion only.
- Improve panel placement and status display if the real client layout needs it.
- Validate add/remove-save behavior with a real save containing equipment and crafted outputs.
- Add release automation after the first manual playtest passes.

## Success Criteria

- The mod loads without errors.
- Personal assembler equipment can be crafted and inserted into modular armor.
- A player can open a linked vanilla assembler from equipped armor.
- The vanilla assembler GUI handles recipe quality, ingredient quality, and module chance.
- The mod transfers item ingredients and outputs between player inventory and the linked assembler.
- Personal assembler recipes unlock with the matching vanilla quality module technologies, including existing saves.
- The behavior works after save/load.
- Removing the mod does not corrupt the save.
- Logs are clean enough to debug real issues.
- The implementation has a clear path to GitHub release packaging and later mod portal publishing.
