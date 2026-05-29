# Design Direction

Status: V0.1.5 personal assembler direction on 2026-05-29.

## Player Experience

A player wearing modular armor can install personal assemblers as equipment. With that equipment installed, the player opens a linked vanilla assembler GUI, chooses recipe quality and ingredient quality there, inserts normal quality modules, and crafts from inventory-backed inputs.

## Core Feature Idea

Core loop:

- Craft or obtain personal assembler armor equipment.
- Insert it into modular armor.
- Use the bottom-right `Personal assemblers` panel to open a linked assembler.
- Pick recipe, quality, and modules in the vanilla assembler GUI.
- The mod moves accepted item ingredients from inventory into the assembler and returns outputs.

The goal is to feel like a portable assembler, not a separate cheat crafting menu.

## Balance Direction

This is balance-changing additional gameplay, not pure quality-of-life.

Balance intent:

- The player gets portable quality crafting utility, but only by spending armor grid space.
- Personal assembler tier should matter through speed, module slots, and energy draw.
- Quality behavior should come from vanilla assembler/module rules instead of custom output rolling.
- V1 should avoid convenience features that bypass ingredient quality requirements.
- Crafting with personal assemblers should require armor-grid energy unless debug infinite energy is explicitly enabled.
- Personal assembler energy draw has a runtime-global multiplier for balancing.
- Personal assemblers occupy a 4x4 armor grid footprint.

## Settings Direction

Current setting:

- Personal assembler energy multiplier, default `1.0`, range `0.1` to `10.0`.

Possible later settings:

- Scale equipment size or energy draw if balance testing shows the defaults are too strong.
- Restrict quality crafting to unlocked recipe categories.

## UI And Controls

V1 uses a compact bottom-right `Personal assemblers` panel while personal assembler equipment is worn. The free-floating debug window remains debug-only.

Expected controls:

- One row per equipped personal assembler.
- Open button for the linked vanilla assembler.
- Enable checkbox for energy/crafting control.
- Quality chance, energy percentage, and ready/no-energy status.

Debug controls:

- `Ctrl + Shift + Q`, the shortcut button, and `/player-quality` open the debug GUI.
- The debug GUI can enable infinite personal assembler energy, give personal assemblers, and give vanilla quality modules for testing.
- The debug GUI has individual research buttons so recipe and quality gates can be tested before and after.

Current prototype behavior:

- Crafting timing, recipe selection, quality selection, and module effects are owned by the linked vanilla assembler.
- The inventory-feeding layer only moves item ingredients that the assembler input inventory accepts.
- Fluid ingredients are not automatically fed in V1.

## Terminology

- Player Quality: mod display name.
- Personal assembler: armor-grid equipment that owns one linked hidden assembler.
- Ingredient quality: the exact quality required for item ingredients.
- Output quality: the quality of the crafted result as produced by the vanilla assembler.
- Linked assembler: hidden assembling-machine entity opened through the personal assembler panel.

## Art And Sound

Prefer reusing vanilla assembler and quality module icons through prototype references.

If the game requires custom icons for armor equipment variants, create simple derived icons and document source paths and license expectations before publishing.

## Mod Compatibility Policy

- Prefer local, opt-in behavior.
- Avoid broad prototype edits when a runtime or setting-gated approach is safer.
- Avoid hidden player advantages unless the mod is intentionally cheat/debug/admin-oriented.
- Document interactions with Space Age and common overhaul mods before claiming compatibility.
- Be agnostic toward other mods by default; do not claim support until tested.
- Avoid patching other mods' recipes except through generic recipe eligibility checks.

## Open Questions

- Should fluid recipes be unsupported, manual-only, or handled through a portable fluid-container pattern?
- Should equipment quality affect assembler speed, energy buffer, or energy draw?
- Should multiple personal assemblers have a higher cost or footprint curve after real playtesting?
