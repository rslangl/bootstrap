#!/bin/bash
set -euo pipefail

INPUT_LIST="/workdir/packages.txt"
TEMP_DEPS="/workdir/all-deps.txt"
DEDUPED_DEPS="/workdir/deduped.txt"
OUTPUT_DIR="/repo/packages"

echo "[*] Updating APT..."
apt-get update -qq

mkdir -p "$OUTPUT_DIR" > "$TEMP_DEPS"

echo "[*] Resolving dependencies..."
while read -r pkg; do
    echo ">> Resolving: $pkg"
    apt-rdepends --follow=Depends --print-state --state-follow=Installed "$pkg" 2>/dev/null \
        | grep -v '^ ' >> "$TEMP_DEPS" 
done < "$INPUT_LIST"

sort -u "$TEMP_DEPS" > "$DEDUPED_DEPS"

echo "[*] Downloading .deb files into $OUTPUT_DIR..."
cd "$OUTPUT_DIR"

xargs -a "/$DEDUPED_DEPS" apt-get download

echo "[✔] Done. Downloaded packages stored in $OUTPUT_DIR"

