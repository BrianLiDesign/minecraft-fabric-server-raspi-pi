#!/bin/bash
set -euo pipefail

SERVER_DIR="${SERVER_DIR:-$HOME/mc-fabric}"
MC_VERSION="${1:-}"

cd "$SERVER_DIR"

# Try to detect MC version if not provided
if [[ -z "$MC_VERSION" ]]; then
  # Fabric installer creates fabric-server-launcher.properties sometimes; this is a best-effort guess
  if [[ -f "fabric-server-launcher.properties" ]]; then
    # Not always present; MC version may not be stored here
    MC_VERSION=""
  fi
fi

if [[ -z "$MC_VERSION" ]]; then
  echo "Usage: $0 <minecraft_version>"
  echo "Example: $0 1.21.1"
  exit 1
fi

echo "Updating Fabric server in: $SERVER_DIR"
echo "Target Minecraft version:  $MC_VERSION"
echo

# Requirements
command -v java >/dev/null || { echo "ERROR: Java not found"; exit 1; }
command -v curl >/dev/null || { echo "ERROR: curl not found"; exit 1; }

# Get latest Fabric installer version from Fabric meta
echo "Fetching latest Fabric installer version..."
INSTALLER_VERSION="$(curl -fsSL https://meta.fabricmc.net/v2/versions/installer | python3 -c 'import sys,json; print(json.load(sys.stdin)[0]["version"])')"
INSTALLER_JAR="fabric-installer-${INSTALLER_VERSION}.jar"

echo "Installer version: $INSTALLER_VERSION"
echo "Downloading installer jar..."
curl -fL -o "$INSTALLER_JAR" "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${INSTALLER_VERSION}/${INSTALLER_JAR}"

echo
echo "Running Fabric installer (server mode) and downloading vanilla server jar..."
java -jar "$INSTALLER_JAR" server -dir . -mcversion "$MC_VERSION" -downloadMinecraft

echo
echo "Resulting jars:"
ls -lh *.jar | sed 's/^/  /'

echo
echo "Done. Start with:"
echo "  cd \"$SERVER_DIR\""
echo "  java -Xms512M -Xmx2500M -jar fabric-server-launch.jar nogui"
