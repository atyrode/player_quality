# Design Direction

Status: initial direction recorded from operator answers on 2026-05-29.

## Player Experience

A player wearing modular armor can install quality modules as personal equipment. With that equipment installed, hand crafting gains a quality-aware path: choose the ingredient quality, craft from matching ingredients, and get the same chance-based quality upgrades that a machine would get from quality modules.

## Core Feature Idea

Core loop:

- Craft or obtain quality-module armor equipment.
- Insert it into modular armor.
- Open the character inventory and use the attached `Quality crafting` panel.
- Pick recipe, ingredient quality, and count.
- Craft using exact-quality ingredients.
- Output quality is selected ingredient quality or better, based on equipped module chance.

The long-term ideal is for this to feel like assembler ingredient-quality selection, but attached to the player's crafting workflow.

## Balance Direction

This is balance-changing additional gameplay, not pure quality-of-life.

Balance intent:

- The player gets new personal quality crafting utility, but only by spending armor grid space.
- Equipped module tier and equipment item quality should matter.
- The output formula should follow vanilla quality rules instead of inventing a stronger shortcut.
- V1 should avoid convenience features that bypass ingredient quality requirements.
- Crafting with personal quality modules should require module energy unless debug infinite energy is explicitly enabled.
- Personal module chance defaults to one tenth of vanilla module chance, with a runtime-global setting from one hundredth to vanilla chance for balancing.
- Personal quality modules occupy a 4x4 armor grid footprint.

## Settings Direction

No settings are required yet.

Possible later settings:

- Enable or disable native hand-crafting output upgrades if implemented.
- Scale equipment size or module chance if balance testing shows the defaults are too strong.
- Restrict quality crafting to unlocked recipe categories.

## UI And Controls

V1 uses a mod-owned `Quality crafting` panel anchored to the character inventory GUI. The older free-floating window remains as a debug GUI only.

Expected controls:

- Recipe selector.
- Ingredient quality selector.
- Count selector.
- Craft button.
- Active next-quality chance and powered-module count.
- Top status button showing current next-quality chance and opening a fallback crafting window.
- Clear feedback for missing exact-quality ingredients.
- Clear feedback when no quality-module equipment is installed.
- Clear feedback when installed modules are unpowered.

Preferred later UX:

- Show ingredient quality controls near the native player crafting menu if Factorio supports it cleanly.

Debug controls:

- `Ctrl + Shift + Q`, the shortcut button, and `/player-quality` open the debug GUI.
- The debug GUI can enable infinite module energy and give personal quality modules for testing.
- The debug GUI has explicit research/lock buttons so recipe and quality gates can be tested before and after.

Current prototype behavior:

- Crafting is instant.
- The GUI lists simple unlocked item recipes in the `crafting` category.
- The ingredient-quality selector lists only qualities unlocked by the player's force.
- The GUI skips recipes with fluids, non-item ingredients, multiple products, probabilistic products, or no ingredients.
- Output upgrade rolls use active equipped quality chance multiplied by each current quality tier's `next_probability`, and stop before locked qualities.

## Terminology

- Player Quality: mod display name.
- Quality module equipment: armor-grid equipment that contributes quality chance to hand crafting.
- Ingredient quality: the exact quality required for item ingredients.
- Output quality: the quality of the crafted result after quality rolls.
- Eligible recipe: a hand-craftable item recipe supported by the mod-owned crafting path.

## Art And Sound

Prefer reusing vanilla quality module icons through prototype references.

If the game requires custom icons for armor equipment variants, create simple derived icons and document source paths and license expectations before publishing.

## Mod Compatibility Policy

- Prefer local, opt-in behavior.
- Avoid broad prototype edits when a runtime or setting-gated approach is safer.
- Avoid hidden player advantages unless the mod is intentionally cheat/debug/admin-oriented.
- Document interactions with Space Age and common overhaul mods before claiming compatibility.
- Be agnostic toward other mods by default; do not claim support until tested.
- Avoid patching other mods' recipes except through generic recipe eligibility checks.

## Open Questions

- Can Factorio's native player crafting UI be augmented, or should we keep a separate GUI permanently?
- Should the first playable version craft instantly or use a timed mod-owned queue?
- Which recipes are eligible in V1: single-product item recipes only, or broader recipe support?
- Should armor equipment size match vanilla module item size conceptually, or be larger for balance?
