# player_quality

Factorio mod project workspace.

The target mod lets players install personal assemblers in modular armor. Each personal assembler opens a linked vanilla assembler GUI, so recipe selection, ingredient quality, and module slots use Factorio's native quality-aware assembler behavior.

## Current Shape

- Persistent agent/contributor workflow rules: [AGENTS.md](AGENTS.md).
- Planning and tracking documents: [docs/](docs/).
- Factorio mod scaffold: `info.json`, `data.lua`, `control.lua`, and `locale/`.
- Factorio changelog: `changelog.txt`.
- Current prototype: personal assembler armor equipment with linked hidden assembling machines.
- A bottom-right `Personal assemblers` panel appears only while personal assembler equipment is worn.
- Opening a personal assembler uses the vanilla assembler UI for recipe quality, ingredient quality, and module slots.
- Personal assemblers pull matching ingredients from the player's inventory, return completed outputs, and drain armor-grid energy while enabled.
- A runtime-global mod setting scales personal assembler energy draw from `0.1` to `10.0`; default `1.0` uses the listed draw.
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

5. Use the bottom-right `Personal assemblers` panel to open the linked assembler.
6. In the vanilla assembler UI, choose a recipe, choose recipe/ingredient quality, and place quality modules in module slots.
7. Use `/player-quality` only for debug controls such as infinite energy, give buttons, and individual research buttons.
8. Confirm exact-quality ingredients are pulled from inventory, outputs return to inventory, and quality options obey research gates.

V0.1.5 has been smoke-tested with Factorio 2.0.76 headless by creating and benchmarking a save with `quality`, `space-age`, and `player_quality` enabled. The actual linked assembler GUI still needs a real client playtest.

## Prototype Limits

- Personal assemblers are hidden linked assembling machines on a private surface.
- The mod feeds item ingredients from the player inventory opportunistically; fluid recipes are not supported by the inventory-feeding layer yet.
- The assembler's own vanilla GUI is responsible for recipe quality, ingredient quality, modules, and crafting behavior.
- The current armor equipment is implemented as 4x4 battery equipment so it can live in a standard armor grid, cost meaningful space, and consume charge while crafting.

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
