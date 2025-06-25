#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/images"

PVE_SRC="https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso|d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"
OPNSENSE_SRC="https://opnsense-mirror.hiho.ch/releases/mirror/OPNsense-25.1-dvd-amd64.iso.bz2|e4c178840ab1017bf80097424da76d896ef4183fe10696e92f288d0641475871"
# NOTE: checksum for tarball: 68efe0e5c20bd5fbe42918f000685ec10a1756126e37ca28f187b2ad7e5889ca"

declare -A IMAGES

IMAGES=(
  [pve]="$PVE_SRC"
  [opnsense]="$OPNSENSE_SRC"
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
  image_file="${DOWNLOAD_DIR}/${image}.iso"

  echo "clean_url: $clean_url"
  echo "filename: $filename"
  echo "target_file: $target_file"
  echo "image_file: $image_file"

  if [[ -e "$image_file" ]]; then
    image_checksum=$(get_checksum "$image_file")

    if [[ "$image_checksum" == "$checksum" ]]; then
      echo "$image_file already present, skipping"
      continue
    fi
  fi

  echo "Downloading from $url..."

  if [[ "$filename" =~ \.iso$ ]]; then
    curl -s -o "$image_file" "$url"
    echo "Saved file as $image_file"
  else
    curl -s -o "$target_file" "$url"
    if is_compressed "$target_file"; then
      "$target_file is compressed, decompressing..."

      case "$target_file" in
      *.bz2)
        bunzip2 -c "$target_file" >"$image_file"
        ;;
      *)
        echo "ERROR: Unsupported compression type"
        exit 1
        ;;
      esac

      "Decompressed $target_file to $image_file"
    fi
  fi

  if [[ -f "$image_file" ]]; then
    echo "Verifying checksum..."
    actual_checksum=$(get_checksum "$image_file")

    if [[ $actual_checksum == $checksum ]]; then
      echo "Checksum verified"
    else
      echo "WARNING: Checksum failed! Expected $checksum but got $actual_checksum"
    fi
  else
    echo "ERROR: Failed to download from $url"
  fi
done
