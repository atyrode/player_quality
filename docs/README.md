# Documentation Index

These documents are adapted from the reusable planning structure in `/home/alex/sts2_character/hologirl`, not copied as project content. Hologirl is a Slay the Spire 2 mod, so game-specific mechanics, release notes, card formats, and asset pipelines should not be imported directly.

## Hologirl Documentation Review

Reusable as templates:

| Hologirl source | Reuse decision | Player Quality target |
| --- | --- | --- |
| `README.md` | Reuse the entry-point shape: current state, development commands, document map. | `README.md` |
| `docs/PROJECT_SPEC.md` | Reuse the milestone/spec shape: goal, assumptions, source preferences, first target, next target. | `docs/PROJECT_SPEC.md`, `docs/PROJECT_BRIEF.md` |
| `docs/ARCHITECTURE.md` | Reuse the research snapshot, repository-shape, local environment, build/release, and compatibility sections. | `docs/ARCHITECTURE.md`, `docs/TECHNICAL_DIRECTION.md` |
| `docs/DESIGN.md` | Reuse the design overview shape: fantasy, core mechanic, terminology, compatibility, open questions. | `docs/DESIGN.md` |
| `docs/DEVELOPMENT_STEPS.md` | Reuse the checklist shape: research, prerequisites, scaffold, first playable test, roadmap, risks, debugging. | `docs/DEVELOPMENT_STEPS.md` |
| `docs/design/COMPATIBILITY.md` | Reuse the practice of documenting mod compatibility before implementing shared or global behavior. | `docs/DESIGN.md`, `docs/ARCHITECTURE.md` |
| `docs/design/TERMINOLOGY.md` | Reuse the idea of a term dictionary once the mod has player-facing terms. | `docs/DESIGN.md` |
| `docs/design/ASSET_PIPELINE.md` | Reuse later only if this mod needs custom graphics or generated art. | Deferred |

Not reused now:

- `docs/releases/`: historical release notes for Hologirl.
- `docs/CARD_FORMAT.md`: STS2/BaseLib-specific card implementation notes.
- `docs/modding/LIBRARY_REFERENCE.md`: useful as a pattern, but the actual references must be Factorio API, mod portal, and working Factorio mod sources.
- `docs/design/forms/`, `docs/design/effects/`, `docs/design/relics/`, and menu-specific notes: Hologirl-specific gameplay design.
- Godot, Spine, PCK, C#, and Slay the Spire 2 toolchain notes: not applicable unless a future external asset tool needs similar documentation.

## Fill Order

1. Fill [PROJECT_BRIEF.md](PROJECT_BRIEF.md) with the mod's purpose, target player, scope, and non-goals.
2. Fill [REQUIREMENTS.md](REQUIREMENTS.md) with user-visible behavior and compatibility expectations.
3. Fill [TECHNICAL_DIRECTION.md](TECHNICAL_DIRECTION.md) with target Factorio version, dependency policy, validation path, and packaging approach.
4. Fill [PROJECT_SPEC.md](PROJECT_SPEC.md) with the first concrete implementation milestone.
5. Fill [DESIGN.md](DESIGN.md) with gameplay, UX, balance, terminology, and settings decisions.
6. Update [ARCHITECTURE.md](ARCHITECTURE.md) once the runtime file layout is chosen.
7. Track implementation in [DEVELOPMENT_STEPS.md](DEVELOPMENT_STEPS.md).
8. Use [PLAYTEST.md](PLAYTEST.md) for release download, install, new-save setup, and report-back steps.
