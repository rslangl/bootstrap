#!/bin/bash

set -euo pipefail

REPO_DIR="/repo"
CONF_FILE="$REPO_DIR/conf/distributions"
DEB_DIR="$REPO_DIR/packages"
SOURCE_CONF="/workdir/config/distributions"

echo "[*] Starting APT repository preparation..."

# Ensure conf dir and distributions file exist
mkdir -p "$REPO_DIR/conf"
if [[ ! -f "$CONF_FILE" ]]; then
  if [[ -f "$SOURCE_CONF" ]]; then
    echo "[*] Copying default distributions config to $CONF_FILE"
    cp "$SOURCE_CONF" "$CONF_FILE"
  else
    echo "ERROR: No distributions file found at $SOURCE_CONF or $CONF_FILE"
    exit 1
  fi
fi

mkdir -p "$DEB_DIR"

echo "[*] Downlading packages from packages.txt..."
/workdir/download-deb-packages.sh

echo "[*] Building APT repository with reprepo..."

for deb in "$DEB_DIR"/*.deb; do
  if [[ -f "$deb" ]]; then
    echo ">> Including: $(basename "$deb")"
    reprepro -b "$REPO_DIR" includedeb bookworm "$deb"
  fi
done

echo "[✔] APT repository build complete at $REPO_DIR"

