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
  [opnsense]="$OPNSENSE_SRC"
)

get_checksum() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: no file provided"
    exit 1
  fi
  sha256sum "$file" | awk '{print $1}'
}

is_compressed() {
  local file="$1"
  [[ -f "$file" ]] || return 1

  file_type=$(file -b --mime-type "$file")

  case "$file_type" in
  application/x-gzip | application/gzip | application/x-bzip2 | application/zip)
    return 0 # it's compressed
    ;;
  *)
    return 1 # not compressed
    ;;
  esac
}

decompress_image() {
  local img="$1"
  [[ -f "$img" ]] || return 1

  echo "Decompressing $1..."

  case "$img" in
  *.bz2)
    bzip2 -dk "$img"
    ;;
  *)
    echo "Error: unsupported compression type"
    exit 1
    ;;
  esac
}

for image in "${!IMAGES[@]}"; do
  IFS="|" read -r url checksum <<<"${IMAGES[$image]}"
  dest_file="${DOWNLOAD_DIR}/${image}.iso"

  if [[ -e "$dest_file" ]]; then
    dest_file_checksum=$(get_checksum "$dest_file")

    if [[ "$dest_file_checksum" == "$checksum" ]]; then
      echo "$dest_file already present, skipping"
      continue
    fi
  fi

  echo "Downloading from $url..."
  curl -s -o "$dest_file" "$url" # TODO: error: unsupported compression type since file is stored as `opnsense.iso` and not *.bz2

  if [[ $? -eq 0 ]]; then
    echo "Saved image as $dest_file"

    if is_compressed "$dest_file"; then
      decompress_image "$dest_file"
    fi

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
