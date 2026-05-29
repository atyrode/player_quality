# Playtest Guide

Status: V0.1.4 real-client playtest path.

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

Direct V0.1.4 GitHub zip:

```text
https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.4.zip
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
curl -L -o ~/.factorio/mods/player_quality_0.1.4.zip https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.4.zip
```

Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\Factorio\mods"
Invoke-WebRequest -Uri "https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.4.zip" -OutFile "$env:APPDATA\Factorio\mods\player_quality_0.1.4.zip"
```

macOS:

```sh
mkdir -p "$HOME/Library/Application Support/factorio/mods"
curl -L -o "$HOME/Library/Application Support/factorio/mods/player_quality_0.1.4.zip" https://github.com/atyrode/player_quality/releases/latest/download/player_quality_0.1.4.zip
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

1. Open the character inventory.
2. Confirm the attached `Quality crafting` panel appears. If not, click the top `Quality` status button to open the fallback crafting window.
3. Confirm the top `Quality` status button shows next-quality chance and powered module count.
4. Open `/player-quality`.
5. Click `Research module techs` if you want the personal quality module recipes unlocked for the current test.
6. Click `Research quality techs` only when you want to test non-normal ingredient selection and upgrades.
7. Select an unlocked recipe and unlocked ingredient quality, set a count, and click `Craft`.
8. Confirm exact-quality ingredients are consumed and outputs do not exceed the qualities currently unlocked.

The debug GUI is still available with `Ctrl + Shift + Q`, the shortcut button, or `/player-quality`. Use it to toggle infinite module energy, give yourself personal quality modules at the selected quality, and manually research/lock test gates.

Energy test:

1. In the debug GUI, turn off `Debug: infinite module energy`.
2. Remove or discharge the personal quality modules.
3. Open the character inventory and confirm the next quality chance drops to `0.00%`.
4. Attempt a quality craft and confirm the mod reports that personal quality modules need energy.

Research gate test:

1. Start a clean save or use `Lock qualities` in the debug GUI.
2. Confirm only researched qualities appear in the ingredient-quality selector.
3. Confirm personal quality module recipes are not listed before module tech research.
4. Click `Research module techs`.
5. Confirm the matching personal quality module recipes unlock.
6. Click `Research quality techs`.
7. Confirm new qualities appear and output upgrades stop at the highest researched quality.

Balance setting test:

1. Open Factorio's mod settings.
2. Change `Personal quality chance multiplier`.
3. Confirm `0.01` is divided by 100, `0.1` is divided by 10, and `1.0` is vanilla module chance.

Also test the normal-quality path by selecting `normal` ingredient quality and crafting another batch.

## Report Back

Send:

- Factorio version.
- Whether the mod appeared in the Mods menu.
- Whether the `Quality crafting` panel appeared when opening inventory.
- Whether the debug GUI opened with `/player-quality`.
- Whether `iron stick` appeared in the recipe selector.
- Whether rare input crafting consumed the correct items.
- What output qualities you received.
- Whether unpowered modules blocked crafting.
- Whether locked qualities stayed unavailable.
- Any error text from the game.
- The relevant part of `factorio-current.log` if Factorio reports a mod error.
