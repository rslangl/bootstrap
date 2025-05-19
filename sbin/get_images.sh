#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/images"

PVE_SRC="https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso|d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"
UBUNTU_SRC="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|1ecb0f1fbb7d722987e498cc5cdb8a3221c09c9501d02cdbba31fb8097e5349b"
OPNSENSE_SRC="https://opnsense-mirror.hiho.ch/releases/mirror/OPNsense-25.1-dvd-amd64.iso.bz2|68efe0e5c20bd5fbe42918f000685ec10a1756126e37ca28f187b2ad7e5889ca"

declare -A IMAGES

IMAGES=(
  [pve]="$PVE_SRC"
  #[ubuntu]="$UBUNTU_URL"
)

for image in "${!IMAGES[@]}"; do
  IFS="|" read -r url checksum <<<"${IMAGES[$image]}"
  dest_file="${DOWNLOAD_DIR}/${image}.iso"

  echo "Downloading from $url..."
  curl -s -o "$dest_file" "$url"

  if [[ $? -eq 0 ]]; then
    echo "Saved image as $dest_file"

    echo "Verifying checksum..."
    actual_checksum=$(sha256sum "$dest_file" | awk '{print $1}')

    if [[ $actual_checksum == $checksum ]]; then
      echo "Checksum verified"
      # echo "Converting to img..."
      # qemu-img convert -f raw -O raw "$dest_file" "${DOWNLOAD_DIR}/${image}.img"
      # echo "Done!"
    else
      echo "WARNING: Checksum failed! Expected $checksum but got $actual_checksum"
    fi
  else
    echo "Failed to download from $url"
  fi
done
