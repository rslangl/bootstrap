#!/bin/bash

set -ex

PVE_URL="https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso|d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"

declare -A IMAGES

IMAGES=(
  [pve]="$PVE_URL"
)

for image in "${!IMAGES[@]}"; do
  IFS="|" read -r url checksum <<<"${IMAGES[$image]}"
  # url="${IMAGES[$image]}"
  echo "Downloading from $url..."
  curl -s -o "$image.iso" "$url"

  if [[ $? -eq 0 ]]; then
    echo "Saved image as $image.iso"

    echo "Verifying checksum..."z
    actual_checksum=$(sha256sum "$image.iso" | awk '{print $1}')
    if [[ $actual_checksum == $checksum ]]; then
      echo "Checksum verified"
      echo "Converting to img..."
      qemu-img convert -f raw -O raw "$image.iso" "$image.img"
      echo "Done!"
    fi
  else
    echo "Failed to download from $url"
  fi
done
