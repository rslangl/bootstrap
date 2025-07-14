#!/bin/bash
set -euo pipefail

mkdir -p packages
touch all-deps.txt

echo "Resolving dependencies..."

apt-get update -qq

while read -r pkg; do
    echo ">> Resolving: $pkg"
    apt-rdepends --follow=Depends --print-state --state-follow=Installed "$pkg" 2>/dev/null \
        | grep -v '^ ' >> all-deps.txt
done < packages.txt

sort -u all-deps.txt > deduped.txt

echo "Downloading .deb files..."
cd packages

xargs -a ../deduped.txt apt-get download

echo "Done. .deb files are in $(pwd)"

