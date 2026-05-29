#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python_bin="${PYTHON:-/home/alex/.nix-profile/bin/python3}"

scripts/check.sh
"$python_bin" scripts/package.py
