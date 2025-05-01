#!/bin/bash

set -ex

PVE_URL="https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso"

declare -A IMAGES

IMAGES=(
  [pve]="$PVE_URL"
)

for image in "${IMAGES[@]}"; do
  url="${IMAGES[$image]}"
  echo "Downloading from $url..."
  curl -s -o "$image.iso" "$url"
  qemu-img convert -f raw -O raw "$image.iso" "$image.img"
done
