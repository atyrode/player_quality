#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

api_key="${FACTORIO_MOD_PORTAL_API_KEY:-${FACTORIO_API_KEY:-}}"
if [ -z "$api_key" ]; then
  cat >&2 <<'EOF'
Missing FACTORIO_MOD_PORTAL_API_KEY or FACTORIO_API_KEY.

Create an API key at https://factorio.com/profile with these usages:
- ModPortal: Publish Mods
- ModPortal: Upload Mods
- ModPortal: Edit Mods

Then run:
  FACTORIO_MOD_PORTAL_API_KEY=<your-api-key> scripts/publish-portal.sh

Or put this in an ignored .env file:
  FACTORIO_API_KEY=<your-api-key>

Do not commit the key or paste it into chat.
EOF
  exit 2
fi

python_bin="${PYTHON:-python3}"
mod_name="$("$python_bin" -c 'import json; print(json.load(open("info.json"))["name"])')"
version="$("$python_bin" -c 'import json; print(json.load(open("info.json"))["version"])')"
package_path="$(scripts/package.sh | tail -n 1)"
description_path="dist/mod-portal-description.md"

cat > "$description_path" <<DESC
# Player Quality

Player Quality lets players install personal assembler equipment into modular armor. Each equipped assembler opens a linked vanilla assembler GUI, so recipe quality, ingredient quality, and module slots work like a normal assembler while the mod moves item ingredients and outputs through the player's inventory.

Current prototype:

- Personal assembler equipment for tiers 1, 2, and 3.
- Bottom-right Personal assemblers panel appears while equipment is worn.
- Linked vanilla assembler UI handles recipe quality, ingredient quality, and quality modules.
- Item ingredients are pulled from player inventory and outputs are returned to the player.
- Armor-grid energy is drained while linked assemblers are enabled and crafting.
- Debug GUI opened with Ctrl + Shift + Q, the shortcut button, or /player-quality.

This is an early iteration. Automatic transfer currently focuses on item ingredients and item outputs; fluid recipes still need a later design.

Source:
https://github.com/atyrode/player_quality
DESC

if curl -fsS "https://mods.factorio.com/api/mods/${mod_name}" >/dev/null; then
  init_url="https://mods.factorio.com/api/v2/mods/releases/init_upload"
  mode="release"
else
  init_url="https://mods.factorio.com/api/v2/mods/init_publish"
  mode="publish"
fi

init_response="$(
  curl -fsS \
    -H "Authorization: Bearer ${api_key}" \
    -F "mod=${mod_name}" \
    "$init_url"
)"

upload_url="$(
  printf '%s' "$init_response" | "$python_bin" -c 'import json, sys; data=json.load(sys.stdin); print(data["upload_url"])'
)"

if [ "$mode" = "publish" ]; then
  upload_response="$(
    curl -fsS \
      -F "file=@${package_path}" \
      -F "description=<${description_path}" \
      -F "category=tweaks" \
      -F "source_url=https://github.com/atyrode/player_quality" \
      "$upload_url"
  )"
else
  upload_response="$(
    curl -fsS \
      -F "file=@${package_path}" \
      "$upload_url"
  )"
fi

printf '%s\n' "$upload_response" | "$python_bin" -m json.tool

if edit_response="$(
  curl -fsS \
    -H "Authorization: Bearer ${api_key}" \
    -F "mod=${mod_name}" \
    -F "title=Player Quality" \
    -F "summary=Install personal assemblers in modular armor and craft through linked vanilla quality-aware assembler GUIs." \
    -F "description=<${description_path}" \
    -F "category=tweaks" \
    -F "tags=armor" \
    -F "tags=manufacturing" \
    -F "homepage=https://github.com/atyrode/player_quality" \
    -F "source_url=https://github.com/atyrode/player_quality" \
    "https://mods.factorio.com/api/v2/mods/edit_details"
)"; then
  printf '%s\n' "$edit_response" | "$python_bin" -m json.tool
else
  echo "Uploaded ${mod_name} ${version}, but editing portal details failed. Check the API key has ModPortal: Edit Mods." >&2
fi

echo "Published ${mod_name} ${version} to the Factorio Mod Portal."
