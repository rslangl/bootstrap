#!/bin/bash

set -ex

PVE_URL="https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso"

declare -A IMAGES

IMAGES=(
  [pve]="$PVE_URL"
)

for image in "${!IMAGES[@]}"; do
  url="${IMAGES[$image]}"
  echo "Downloading from $url..."
  curl -s -o "$image.iso" "$url"

  if [[ $? -eq 0 ]]; then
    echo "Saved image as $image.iso"
    echo "Converting to img..."
    qemu-img convert -f raw -O raw "$image.iso" "$image.img"
    echo "Done!"
  else
    echo "Failed to download from $url"
  fi
done
