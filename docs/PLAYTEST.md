# Playtest Guide

Status: V0.1.5 real-client playtest path.

## Release Channel

Use the Factorio Mod Portal once the release is published there.

Mod Portal page:

```text
https://mods.factorio.com/mod/player_quality
```

Fallback GitHub release page:

```text
https://github.com/atyrode/player_quality/releases/latest
```

Direct V0.1.5 GitHub zip:

```text
https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.5.zip
```

## Install

Preferred path:

1. Start Factorio.
2. Open `Mods`.
3. Open `Install`.
4. Search for `Player Quality`.
5. Install or update it.
6. Enable `Quality`, `Space Age`, and `Player Quality`.
7. Restart Factorio when prompted.

Manual fallback:

The repository is public, so these commands do not require GitHub CLI or authentication.

Linux:

```sh
mkdir -p ~/.factorio/mods
curl -L -o ~/.factorio/mods/player_quality_0.1.5.zip https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.5.zip
```

Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\Factorio\mods"
Invoke-WebRequest -Uri "https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.5.zip" -OutFile "$env:APPDATA\Factorio\mods\player_quality_0.1.5.zip"
```

macOS:

```sh
mkdir -p "$HOME/Library/Application Support/factorio/mods"
curl -L -o "$HOME/Library/Application Support/factorio/mods/player_quality_0.1.5.zip" https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.5.zip
```

If you already installed an older Player Quality zip, remove the old `player_quality_*.zip` from the same mods folder first so Factorio cannot pick the wrong version.

## Instant Test Setup

Start a new freeplay save, then paste this into the in-game console:

```lua
/player-quality-test-setup
```

If Factorio says this command is unknown, `Player Quality` is not enabled in the current mod set or Factorio has not restarted after enabling it.

Then:

1. Confirm a bottom-right `Personal assemblers` panel appears.
2. Click `Open` for the personal assembler.
3. In the vanilla assembler GUI, select a simple recipe such as `iron stick` or `iron chest`.
4. Select the recipe/input quality in the vanilla quality controls.
5. Insert the provided quality modules into the assembler module slots.
6. Confirm the panel shows a non-zero quality chance once modules are installed.
7. Confirm matching ingredients are pulled from your inventory and outputs return to your inventory.
8. Use `/player-quality` for debug controls.

Debug controls:

- `Debug: infinite personal assembler energy` lets the assembler run without draining armor equipment.
- `Give A1/A2/A3` gives personal assembler equipment at the selected debug quality.
- `Give Q1/Q2/Q3` gives vanilla quality modules at the selected debug quality.
- Research buttons unlock one listed technology at a time, so before/after behavior can be tested precisely.

Energy test:

1. Open `/player-quality`.
2. Turn off `Debug: infinite personal assembler energy`.
3. Let the equipment discharge, or remove power from the armor grid.
4. Confirm the personal assembler panel reports `no energy` and the linked assembler stops.
5. Turn debug infinite energy back on and confirm crafting resumes.

Research gate test:

1. Start a clean save.
2. Confirm personal assembler recipes are not available before the matching quality module technologies.
3. Open `/player-quality`.
4. Research `quality-module`, then confirm `Personal assembler` unlocks.
5. Research `quality-module-2`, then confirm `Personal assembler 2` unlocks.
6. Research `quality-module-3`, then confirm `Personal assembler 3` unlocks.
7. Use `epic-quality` and `legendary-quality` buttons only when testing those quality tiers.
8. Confirm the vanilla assembler GUI does not allow qualities above the current research gates.

Balance setting test:

1. Open Factorio's mod settings.
2. Change `Personal assembler energy multiplier`.
3. Confirm lower values drain armor equipment more slowly and higher values drain it faster.

## Report Back

Send:

- Factorio version.
- Whether the mod appeared in the Mods menu.
- Whether the `Personal assemblers` panel appeared after `/player-quality-test-setup`.
- Whether `Open` showed the vanilla assembler GUI.
- Whether recipe and quality selection appeared in that vanilla GUI.
- Whether quality modules changed the displayed quality chance.
- Whether ingredients were pulled from inventory.
- Whether outputs returned to inventory.
- Whether unpowered equipment stopped crafting.
- Whether research gates behaved correctly.
- Any error text from the game.
- The relevant part of `factorio-current.log` if Factorio reports a mod error.
