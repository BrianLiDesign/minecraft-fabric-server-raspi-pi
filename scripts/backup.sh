#!/bin/bash
set -euo pipefail

SERVER_DIR="${SERVER_DIR:-$HOME/mc-fabric}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/mc-backups}"

mkdir -p "$BACKUP_DIR"

PROPS_FILE="$SERVER_DIR/server.properties"
LEVEL_NAME="world"

if [[ -f "$PROPS_FILE" ]]; then
  LEVEL_NAME="$(grep -E '^level-name=' "$PROPS_FILE" | cut -d= -f2- || true)"
  [[ -z "$LEVEL_NAME" ]] && LEVEL_NAME="world"
fi

WORLD_PATH="$SERVER_DIR/$LEVEL_NAME"
DATAPACKS_PATH="$WORLD_PATH/datapacks"
MODS_PATH="$SERVER_DIR/mods"

if [[ ! -d "$WORLD_PATH" ]]; then
  echo "ERROR: World folder not found at: $WORLD_PATH"
  echo "Check level-name in $PROPS_FILE"
  exit 1
fi

STAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
OUT="$BACKUP_DIR/${LEVEL_NAME}_backup_${STAMP}.tar.gz"

echo "Backing up:"
echo "  Server dir:  $SERVER_DIR"
echo "  World:       $WORLD_PATH"
echo "  Mods:        $MODS_PATH"
echo "  Datapacks:   $DATAPACKS_PATH"
echo "  Output:      $OUT"
echo

# Build list of paths to include (relative to SERVER_DIR)
INCLUDE_PATHS=("$LEVEL_NAME")

# Include mods folder if it exists
if [[ -d "$MODS_PATH" ]]; then
  INCLUDE_PATHS+=("mods")
fi

# Include server configs if present
for f in server.properties eula.txt whitelist.json ops.json banned-players.json banned-ips.json usercache.json; do
  [[ -f "$SERVER_DIR/$f" ]] && INCLUDE_PATHS+=("$f")
done

# Include Fabric/mod config folder if present
[[ -d "$SERVER_DIR/config" ]] && INCLUDE_PATHS+=("config")

# Make the tarball; exclude noisy runtime folders inside the world
tar -czf "$OUT" \
  -C "$SERVER_DIR" \
  --exclude="$LEVEL_NAME/session.lock" \
  --exclude="$LEVEL_NAME/logs" \
  --exclude="$LEVEL_NAME/crash-reports" \
  "${INCLUDE_PATHS[@]}"

echo "Done."
ls -lh "$OUT"
