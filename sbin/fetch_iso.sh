#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/.cache/tmp"
CACHE_DIR="${ROOT_DIR}/.cache/images"

# Structure: image URL, checksum
PVE_SRC="https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso|d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"
OPNSENSE_SRC="https://opnsense-mirror.hiho.ch/releases/mirror/OPNsense-25.1-dvd-amd64.iso.bz2|e4c178840ab1017bf80097424da76d896ef4183fe10696e92f288d0641475871"
DEBIAN_CLOUD_SRC="https://cloud.debian.org/images/cloud/bookworm/20250530-2128/debian-12-generic-amd64-20250530-2128.qcow2|c8a11fa4bf0aafb2ec69fdf2348fc2c43aebfbf81791fe784d975e1b01cdc66e88b1046fda0649ac7771bec2f4e729100789bc11e8b3767637ad371306fa4333" # TODO: sha512sum, need a third field for algorithm used

declare -A IMAGES

IMAGES=(
  [pve]="$PVE_SRC"
  [opnsense]="$OPNSENSE_SRC"
  [debian]="$DEBIAN_CLOUD_SRC"
)

get_checksum() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "ERROR: No file provided"
    exit 1
  fi
  sha256sum "$file" | awk '{print $1}'
}

is_compressed() {
  local file="$1"

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
  local compressed="$1"
  local dest="$2"

  case "$compressed" in
  *.bz2)
    bunzip2 -c "$compressed" >"$dest"
    ;;
  *)
    echo "ERROR: Unsupported compression type"
    exit 1
    ;;
  esac
}

for image in "${!IMAGES[@]}"; do
  IFS="|" read -r url checksum <<<"${IMAGES[$image]}"
  clean_url="${url%%\?*}"
  filename="${clean_url##*/}"
  target_file="${DOWNLOAD_DIR}/${filename}"
  image_file="${CACHE_DIR}/${image}.iso"

  # Skip download if image or archive is already present
  if [[ -e "$image_file" ]]; then
    image_checksum=$(get_checksum "$image_file")

    if [[ "$image_checksum" == "$checksum" ]]; then
      echo "$image_file already present, skipping"
      continue
    fi
  elif [[ -e "$target_file" ]]; then
    echo "$target_file already present, skipping..."
    continue
  fi

  echo "Downloading from $url..."

  # Save uncompressed images directly, otherwise do proper decompression
  if [[ "$filename" =~ \.iso$ ]]; then
    curl -s -o "$image_file" "$url"
    echo "Saved ISO file as $image_file"
  elif [[ "$filename" =~ \.qcow2$ ]]; then
    curl -s -o "$image_file" "$url"
    echo "Saved QCOW2 file as $image_file"
  else
    curl -s -o "$target_file" "$url"
    if is_compressed "$target_file"; then

      case "$target_file" in
      *.bz2)
        bunzip2 -c "$target_file" >"$image_file"
        ;;
      *)
        echo "ERROR: Unsupported compression type"
        exit 1
        ;;
      esac

      echo "Saved decompressed $target_file to $image_file"
    fi
  fi

  # Extra security check by comparing actual and expected checksums
  if [[ -f "$image_file" ]]; then
    echo "Verifying checksum..."
    actual_checksum=$(get_checksum "$image_file")

    if [[ "$actual_checksum" == "$checksum" ]]; then
      echo "Checksum verified"
    else
      echo "WARNING: Checksum failed! Expected $checksum but got $actual_checksum"
    fi
  else
    echo "ERROR: Failed to download from $url"
  fi
done
