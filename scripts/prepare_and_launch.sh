#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WS_ROOT="$(dirname "$SCRIPT_DIR")"

# Config
CFG="$WS_ROOT/.runconfig.json"
if [[ ! -f "$CFG" ]]; then
  echo "Not found $CFG" >&2
  exit 1
fi

# First arg — path to main.dart
FILE_PATH="$1"
if [[ -z "$FILE_PATH" ]]; then
  echo "Usage: $0 <path-to-file>" >&2
  exit 1
fi

FILE="$(realpath "$FILE_PATH")"
REL_PATH="${FILE#$WS_ROOT/}"
UUID="${REL_PATH%%/*}"
DEST_BASE=$(jq -r '.destination' "$CFG")
APP=$(jq -r '.appPath' "$CFG")

DEST="$DEST_BASE/$UUID"
APP_FOLDER="$(dirname "$APP")"
APP_FILE="$(basename "$APP")"

echo "→ Clean: $DEST"
rm -rf "$DEST"

echo "→ Copy: $WS_ROOT/$UUID → $DEST"
mkdir -p "$DEST"
cp -R "$WS_ROOT/$UUID/." "$DEST/"

echo "→ Launch: cmd-like behavior in Bash"
printf "\033]0;PogrAI output\007"
cd "$APP_FOLDER"
./"$APP_FILE" -uuid "$UUID" | more
exit 0