#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/.cache/tmp"
CACHE_DIR="${ROOT_DIR}/.cache/images"

FREEBSD_CLOUDINIT_VERSION="15.0"
DEBIAN_CLOUDINIT_VERSION="13"

FREEBSD_CLOUDINIT_SRC="https://download.freebsd.org/releases/VM-IMAGES/${FREEBSD_CLOUDINIT_VERSION}-RELEASE/amd64/Latest/FreeBSD-${FREEBSD_CLOUDINIT_VERSION}-RELEASE-amd64-BASIC-CLOUDINIT-zfs.qcow2.xz"
DEBIAN_CLOUDINIT_SRC="https://cloud.debian.org/images/cloud/trixie/latest/debian-${DEBIAN_CLOUDINIT_VERSION}-generic-amd64.qcow2"

declare -A IMAGES

IMAGES=(
  [freebsd]="${FREEBSD_CLOUDINIT_SRC}"
  [debian]="${DEBIAN_CLOUDINIT_SRC}"
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

mkdir -p "${CACHE_DIR}"

for image in "${!IMAGES[@]}"; do
  IFS="|" read -r url <<<"${IMAGES[$image]}"
  clean_url="${url%%\?*}"
  filename="${clean_url##*/}"
  target_file="${DOWNLOAD_DIR}/${filename}"
  image_file="${CACHE_DIR}/${file}"
 
  if [ -f "$image_file" ]; then
    echo "ISO already exists at $image_file"
  else
    echo "Downloading ISO from $url..."
    curl -s -o "$target_file" "$url"
  fi

  if is_compressed "$target_file"; then
    case "$target_file" in
      *.bz2)
        bunzip2 -c "$target_file" >"$image_file"
        ;;
      *.xz)
        # TODO: decompress xz
        ;;
      *)
        echo "ERROR: Unsupported compression type"
        exit 1
        ;;
    esac
  fi

  # echo "Verifying checksum..."
  # ACTUAL_CHECKSUM=$(sha256sum "$ISO_PATH" | awk '{print $1}')
  # #ACTUAL_CHECKSUM=$(get_checksum "$ISO_PATH")
  #
  # if [ "$ACTUAL_CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
  #   echo "Checksum mismatch!"
  #   echo "Expected: $EXPECTED_CHECKSUM"
  #   echo "Actual:   $ACTUAL_CHECKSUM"
  #   #exit 1
  # fi
  #
  # echo "Checksum verified"

done

