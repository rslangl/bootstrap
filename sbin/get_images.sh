#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/images"

PVE_URL="https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso|d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"

declare -A IMAGES

IMAGES=(
  [pve]="$PVE_URL"
)

for image in "${!IMAGES[@]}"; do
  IFS="|" read -r url checksum <<<"${IMAGES[$image]}"
  dest_file="${DOWNLOAD_DIR}/${image}.iso"
  # url="${IMAGES[$image]}"
  echo "Downloading from $url..."
  curl -s -o "$dest_file" "$url"

  if [[ $? -eq 0 ]]; then
    echo "Saved image as $dest_file"

    echo "Verifying checksum..."z
    actual_checksum=$(sha256sum "$dest_file" | awk '{print $1}')

    if [[ $actual_checksum == $checksum ]]; then
      echo "Checksum verified"
      echo "Converting to img..."
      qemu-img convert -f raw -O raw "$dest_file" "${DOWNLOAD_DIR}/${image}.img"
      echo "Done!"
    fi
  else
    echo "Failed to download from $url"
  fi
done
