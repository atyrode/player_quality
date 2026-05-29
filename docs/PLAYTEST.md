# Playtest Guide

Status: V0.1.2 real-client playtest path.

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

Direct V0.1.2 GitHub zip:

```text
https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.2.zip
```

## Install

Preferred path:

1. Start Factorio.
2. Open `Mods`.
3. Open `Install`.
4. Search for `Player Quality`.
5. Install or update it.
6. Enable `Quality` and `Player Quality`.
7. Restart Factorio when prompted.

Manual fallback:

The repository is public, so these commands do not require GitHub CLI or authentication.

Linux:

```sh
mkdir -p ~/.factorio/mods
curl -L -o ~/.factorio/mods/player_quality_0.1.2.zip https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.2.zip
```

Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\Factorio\mods"
Invoke-WebRequest -Uri "https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.2.zip" -OutFile "$env:APPDATA\Factorio\mods\player_quality_0.1.2.zip"
```

macOS:

```sh
mkdir -p "$HOME/Library/Application Support/factorio/mods"
curl -L -o "$HOME/Library/Application Support/factorio/mods/player_quality_0.1.2.zip" https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.2.zip
```

You can also download the zip from the release page in a browser, then place it in the same mods folder.

If you already installed an older Player Quality zip, remove the old `player_quality_*.zip` from the same mods folder first so Factorio cannot pick the wrong version.

## Enable

1. Start Factorio 2.0 or Space Age.
2. Open `Mods`.
3. Enable `Quality`.
4. Enable `Player Quality`.
5. Restart Factorio when prompted.
6. Start a new freeplay save for testing.

## Instant Test Setup

Paste this into the in-game console in the new test save:

```lua
/player-quality-test-setup
```

If Factorio says this command is unknown, `Player Quality` is not enabled in the current mod set or Factorio has not restarted after enabling it.

Then:

1. Open the Player Quality GUI with `Ctrl + Shift + Q`, the shortcut button, or `/player-quality`.
2. Confirm the equipped quality chance reads about `100.00%`.
3. Select `iron stick`.
4. Select `rare` ingredient quality.
5. Set count to `100`.
6. Click `Craft`.
7. Confirm rare iron plates are consumed and rare or better iron sticks are produced.

Also test the normal-quality path by selecting `normal` ingredient quality and crafting another batch.

## Report Back

Send:

- Factorio version.
- Whether the mod appeared in the Mods menu.
- Whether the Player Quality GUI opened.
- Whether `iron stick` appeared in the recipe selector.
- Whether rare input crafting consumed the correct items.
- What output qualities you received.
- Any error text from the game.
- The relevant part of `factorio-current.log` if Factorio reports a mod error.
