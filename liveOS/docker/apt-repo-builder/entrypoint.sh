#!/bin/bash

set -euo pipefail

REPO_DIR="/repo"

if [[ ! -f "$REPO_DIR/conf/distributions" ]]; then
  echo "ERROR: Missing config/distributions file in $REPO_DIR"
  exit 1
fi

DEB_DIR="$REPO_DIR/packages"
if [[ ! -d "$DEB_DIR" ]]; then
  echo "ERROR: Directory $DEB_DIR not found"
  exit 1
fi

echo ">> Starting reprepro import..."
for deb in "$DEB_DIR"/*.deb; do
  if [[ -f "$deb" ]]; then
    echo ">> Including: $(basename "$deb")"
    reprepro -b "$REPO_DIR" includedeb bookworm "$deb"
  fi
done
