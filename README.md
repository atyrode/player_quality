# player_quality

Factorio mod project workspace.

The target mod lets players put quality-module-style equipment into modular armor. When equipped, the player can hand-craft with quality ingredients and receive quality-upgrade rolls like an assembling machine with quality modules.

## Current Shape

- Persistent agent/contributor workflow rules: [AGENTS.md](AGENTS.md).
- Planning and tracking documents: [docs/](docs/).
- Factorio mod scaffold: `info.json`, `data.lua`, `control.lua`, and `locale/`.
- Factorio changelog: `changelog.txt`.
- Current prototype: personal quality-module armor equipment plus an instant `Quality crafting` panel attached to the character inventory GUI for simple hand-craftable item recipes.
- A top status button shows current next-quality chance and opens a player-facing fallback crafting window if the inventory-attached panel is not visible.
- A runtime-global mod setting scales personal quality chance from `0.01` to `1.0`; default `0.1` means divided by 10.
- Debug tools remain available through `Ctrl + Shift + Q`, the shortcut button, or `/player-quality`.

## Development

Before committing, branching, merging, or pushing, fetch the remote branch state and check whether the local branch is ahead, behind, or diverged:

```sh
git fetch
git status --short --branch
```

When project tooling is added, document the setup, run commands, generated outputs, and validation steps here.

Run lightweight repository checks:

```sh
scripts/check.sh
```

Build a local Factorio mod zip:

```sh
scripts/package.sh
```

The package is written to `dist/player_quality_<version>.zip`.

Install the packaged zip into the default Linux Factorio mods folder:

```sh
scripts/install-local.sh
```

Override the target folder when needed:

```sh
FACTORIO_MODS_DIR=/path/to/factorio/mods scripts/install-local.sh
```

Publish or update the GitHub release for the current `info.json` version:

```sh
scripts/release.sh
```

Publish or update the Factorio Mod Portal release:

```sh
FACTORIO_MOD_PORTAL_API_KEY=<your-api-key> scripts/publish-portal.sh
```

The script also loads an ignored `.env` file and accepts `FACTORIO_API_KEY=<your-api-key>`. The API key must be created on `https://factorio.com/profile` with `ModPortal: Publish Mods`, `ModPortal: Upload Mods`, and `ModPortal: Edit Mods` usages. Do not commit the key or paste it into chat.

## Download And Playtest

Preferred once published: install `Player Quality` from Factorio's in-game Mods interface.

Fallback manual download: use the latest GitHub release:

```text
https://github.com/atyrode/player_quality/releases/latest
```

The full install and instant new-save setup path is in [docs/PLAYTEST.md](docs/PLAYTEST.md).

## Fast Manual Test

1. Run `scripts/install-local.sh`.
2. Start Factorio 2.0 Space Age with `player_quality` enabled.
3. Start or load a save.
4. Use this console command for a quick prototype test.

```lua
/player-quality-test-setup
```

5. Open the character inventory to use the `Quality crafting` panel. If it does not appear, click the top `Quality` status button to open the player-facing fallback window.
6. Use `/player-quality` only for debug controls such as infinite energy and manual research buttons.
7. Select an unlocked simple recipe such as iron stick, choose an unlocked ingredient quality, set a count, and craft.
8. Confirm exact-quality ingredients are consumed and the output does not exceed researched quality.

V0.1.4 has been smoke-tested with Factorio 2.0.76 headless by creating and reloading a save with `quality`, `space-age`, and `player_quality` enabled. The actual GUI still needs a real client playtest.

## Prototype Limits

- The quality crafting panel is attached to the character inventory GUI, but it still uses mod-owned instant crafting rather than Factorio's native crafting queue.
- Crafting is instant for the first proof of concept.
- Only unlocked, simple item recipes in the `crafting` category are listed.
- Recipes with fluids, multiple products, probabilistic products, or non-item ingredients are skipped.
- The current armor equipment is implemented as 4x4 battery equipment so it can live in a standard armor grid, cost meaningful space, and consume charge per quality craft.

## Documents

- [docs/README.md](docs/README.md): documentation index and Hologirl template source review.
- [docs/PROJECT_BRIEF.md](docs/PROJECT_BRIEF.md): high-level mod intent, scope, assumptions, and open decisions.
- [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md): user-visible behavior and release requirements.
- [docs/PROJECT_SPEC.md](docs/PROJECT_SPEC.md): concrete first milestone and implementation target.
- [docs/TECHNICAL_DIRECTION.md](docs/TECHNICAL_DIRECTION.md): Factorio modding stack, validation path, and technical risks.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): repository structure, runtime responsibilities, and ownership boundaries.
- [docs/DESIGN.md](docs/DESIGN.md): gameplay, balance, UX, terminology, art, and compatibility direction.
- [docs/DEVELOPMENT_STEPS.md](docs/DEVELOPMENT_STEPS.md): working checklist.
- [docs/PLAYTEST.md](docs/PLAYTEST.md): release download, install, instant setup, and report-back checklist.
