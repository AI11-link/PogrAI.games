#!/usr/bin/env bash
set -euo pipefail

# Config
CFG="${PWD}/.runconfig.json"
[[ -f "$CFG" ]] || { echo "Not found $CFG" >&2; exit 1; }

# First arg — path to main.dart
FILE_PATH="$1"
if [[ -z "$FILE_PATH" ]]; then
  echo "Usage: $0 <path-to-file>" >&2
  exit 1
fi

# Get workspace root and UUID
WS_ROOT="$PWD"
REL_PATH="${FILE_PATH#$WS_ROOT/}"
UUID="${REL_PATH%%/*}"

# Read destination and appPath
DEST_BASE=$(jq -r '.destination' "$CFG")
APP=$(jq -r '.appPath' "$CFG")

DEST="$DEST_BASE/$UUID"

echo "→ Delete old folder: $DEST"
rm -rf "$DEST"

echo "→ Copy from $WS_ROOT/$UUID → $DEST"
mkdir -p "$DEST"
cp -R "$WS_ROOT/$UUID/." "$DEST/"

echo "→ Launch app: $APP -uuid $UUID"
exec "$APP" -uuid "$UUID"