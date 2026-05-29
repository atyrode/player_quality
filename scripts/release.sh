#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python_bin="${PYTHON:-python3}"
version="$("$python_bin" -c 'import json; print(json.load(open("info.json"))["version"])')"
tag="v${version}"
package_path="$(scripts/package.sh | tail -n 1)"
notes_path="dist/release-notes-${version}.md"

cat > "$notes_path" <<NOTES
First playable Player Quality prototype.

- Adds personal quality module equipment for modular armor.
- Adds a Player Quality crafting GUI opened with Ctrl + Shift + Q, the shortcut button, or /player-quality.
- Supports exact ingredient quality selection for simple unlocked item recipes.
- Rolls output quality using equipped quality module chance and the vanilla quality chain.
- Includes local packaging and install scripts.

Validation:
- Packaged zip layout checked.
- Factorio 2.0.76 headless created and reloaded a save with quality, space-age, and player_quality enabled.
- Real client GUI playtest is still required.

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
