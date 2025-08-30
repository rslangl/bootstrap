#!/bin/bash

set -e

#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#ROOT_DIR="$(dirname "$SCRIPT_DIR")"
#DOWNLOAD_DIR="${ROOT_DIR}/.cache/tmp"
#CACHE_DIR="${ROOT_DIR}/.cache/images"

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

ISO_URL="$1"
ISO_PATH="$2"
EXPECTED_CHECKSUM="$3"

if [ -f "$ISO_PATH" ]; then
    echo "ISO already exists at $ISO_PATH"
else
    echo "Downloading ISO from $ISO_URL..."
    curl -L -o "$ISO_PATH" "$ISO_URL"
fi

if is_compressed "$ISO_PATH"; then
  case "$ISO_PATH" in
    *.bz2)
      bunzip2 -c "$ISO_PATH" >"$ISO_PATH"
      ;;
    *)
      echo "ERROR: Unsupported compression type"
      exit 1
      ;;
  esac
fi

echo "Verifying checksum..."
#ACTUAL_CHECKSUM=$(sha256sum "$ISO_PATH" | awk '{print $1}')
ACTUAL_CHECKSUM=$(get_checksum "$ISO_PATH")

if [ "$ACTUAL_CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
    echo "Checksum mismatch!"
    echo "Expected: $EXPECTED_CHECKSUM"
    echo "Actual:   $ACTUAL_CHECKSUM"
    exit 1
fi

echo "Checksum verified"
