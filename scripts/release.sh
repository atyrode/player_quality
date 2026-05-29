#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python_bin="${PYTHON:-python3}"
version="$("$python_bin" -c 'import json; print(json.load(open("info.json"))["version"])')"
tag="v${version}"
package_path="$(scripts/package.sh | tail -n 1)"
notes_path="dist/release-notes-${version}.md"

cat > "$notes_path" <<NOTES
Player Quality ${version}.

- Adds personal assembler equipment for modular armor.
- Opens linked vanilla assembler GUIs from a bottom-right Personal assemblers panel.
- Uses vanilla assembler recipe quality, ingredient quality, and module slots.
- Pulls matching item ingredients from player inventory and returns finished outputs.
- Drains armor-grid energy while personal assemblers are enabled and crafting.
- Keeps Ctrl + Shift + Q, the shortcut button, and /player-quality for debug controls.
- Provides a runtime-global personal assembler energy multiplier setting.

Validation:
- Packaged zip layout checked.
- Factorio 2.0.76 headless created and benchmarked a save with quality, space-age, and player_quality enabled.
- Prototype loading and 120-tick runtime smoke checks passed.
- See changelog.txt for version-specific changes.

Playtest guide:
https://github.com/atyrode/player_quality/blob/main/docs/PLAYTEST.md
NOTES

if gh release view "$tag" >/dev/null 2>&1; then
  gh release upload "$tag" "$package_path" --clobber
  gh release edit "$tag" --title "Player Quality ${version}" --notes-file "$notes_path"
else
  gh release create "$tag" "$package_path" --target "$(git rev-parse HEAD)" --title "Player Quality ${version}" --notes-file "$notes_path"
fi

gh release view "$tag" --web=false
