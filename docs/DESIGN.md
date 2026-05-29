# Design Direction

Status: draft template, awaiting mod concept decisions.

## Player Experience

TBD.

Describe what a player should notice, do, or feel while using the mod.

## Core Feature Idea

TBD.

Record the smallest useful mechanic or quality-of-life behavior first. Avoid stacking multiple systems into V1 unless they are inseparable.

## Balance Direction

TBD.

Record whether the mod should be:

- Pure quality-of-life.
- Convenience with no production advantage.
- Balance-changing but vanilla-feeling.
- Cheat/debug/admin-oriented.
- Overhaul-compatible helper behavior.

## Settings Direction

TBD.

Settings should be added only for meaningful choices. Record:

- Setting name.
- Scope: startup, map, or per-player.
- Default value.
- Why the default is safe.
- Whether changing it affects existing saves.

## UI And Controls

TBD.

Record any GUI, shortcut, command, hotkey, alert, or tooltip behavior.

## Terminology

TBD.

Use this section for player-facing terms, setting names, commands, and localization decisions.

## Art And Sound

TBD.

Keep this empty unless the mod needs custom assets. If assets are needed, document source, license, dimensions, naming, and packaging path before adding them.

## Mod Compatibility Policy

- Prefer local, opt-in behavior.
- Avoid broad prototype edits when a runtime or setting-gated approach is safer.
- Avoid hidden player advantages unless the mod is intentionally cheat/debug/admin-oriented.
- Document interactions with Space Age and common overhaul mods before claiming compatibility.

## Open Questions

- What exact player problem should `player_quality` solve?
- Is the mod meant to be quality-of-life, gameplay balance, admin/debug tooling, or something else?
- Should V1 work in vanilla Factorio only, Space Age only, or both?
- Should multiplayer and dedicated servers be supported from the first version?
- Should the mod be safe for existing saves from V1?
