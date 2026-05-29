# player_quality

Factorio mod project workspace.

The target mod lets players put quality-module-style equipment into modular armor. When equipped, the player can hand-craft with quality ingredients and receive quality-upgrade rolls like an assembling machine with quality modules.

## Current Shape

- Persistent agent/contributor workflow rules: [AGENTS.md](AGENTS.md).
- Planning and tracking documents: [docs/](docs/).
- Runtime mod files are not scaffolded yet. Add them after the quality crafting proof-of-concept path is validated against a local Factorio install.

## Development

Before committing, branching, merging, or pushing, fetch the remote branch state and check whether the local branch is ahead, behind, or diverged:

```sh
git fetch
git status --short --branch
```

When project tooling is added, document the setup, run commands, generated outputs, and validation steps here.

## Documents

- [docs/README.md](docs/README.md): documentation index and Hologirl template source review.
- [docs/PROJECT_BRIEF.md](docs/PROJECT_BRIEF.md): high-level mod intent, scope, assumptions, and open decisions.
- [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md): user-visible behavior and release requirements.
- [docs/PROJECT_SPEC.md](docs/PROJECT_SPEC.md): concrete first milestone and implementation target.
- [docs/TECHNICAL_DIRECTION.md](docs/TECHNICAL_DIRECTION.md): Factorio modding stack, validation path, and technical risks.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): repository structure, runtime responsibilities, and ownership boundaries.
- [docs/DESIGN.md](docs/DESIGN.md): gameplay, balance, UX, terminology, art, and compatibility direction.
- [docs/DEVELOPMENT_STEPS.md](docs/DEVELOPMENT_STEPS.md): working checklist.
