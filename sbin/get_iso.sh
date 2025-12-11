#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/.cache/tmp"
CACHE_DIR="${ROOT_DIR}/.cache/images"

FREEBSD_CLOUDINIT_VERSION="15.0"
DEBIAN_CLOUDINIT_VERSION="13"

FREEBSD_CLOUDINIT_SRC="https://download.freebsd.org/releases/VM-IMAGES/${FREEBSD_CLOUDINIT_VERSION}-RELEASE/amd64/Latest/FreeBSD-${FREEBSD_CLOUDINIT_VERSION}-RELEASE-amd64-BASIC-CLOUDINIT-zfs.qcow2.xz|bsd-cloud|qcow2"
DEBIAN_CLOUDINIT_SRC="https://cloud.debian.org/images/cloud/trixie/latest/debian-${DEBIAN_CLOUDINIT_VERSION}-generic-amd64.qcow2|debian-cloud|qcow2"

declare -A IMAGES

IMAGES=(
  [freebsd]="${FREEBSD_CLOUDINIT_SRC}"
  [debian]="${DEBIAN_CLOUDINIT_SRC}"
)

get_checksum() {  # TODO: check for type of checksum
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

mkdir -p "${CACHE_DIR}"

for image in "${!IMAGES[@]}"; do
  IFS="|" read -r url file_name file_format <<<"${IMAGES[$image]}"
  clean_url="${url%%\?*}"
  filename="${clean_url##*/}"
  target_file="${DOWNLOAD_DIR}/${filename}"
  image_file="${CACHE_DIR}/${file_name}.${file_format}"
 
  # echo "clean_url: $clean_url"
  # echo "filename: $filename"
  # echo "target_file: $target_file"
  # echo "image_file: $image_file"

  rm -f "$target_file"

  curl --fail --location --show-error --output "$target_file" "$url"

  [ -s "$target_file" ] || { echo "ERROR: Download empty"; exit 1; }

  rm -f "$image_file"
  tmp="${image_file}.tmp"

  case "$target_file" in
    *.bz2)
      bunzip2 --stdout "$target_file" > "$tmp"
      ;;
    *.xz)
      xz --decompress --stdout "$target_file" > "$tmp"
      ;;
    *)
      cp "$target_file" "$tmp"
      ;;
  esac

  [ -s "$tmp" ] || { echo "ERROR: Decompress empty"; exit 1; }
  mv "$tmp" "$image_file"

  qemu-img info --force-share -f qcow2 "$image_file" >/dev/null
  qemu-img check -f qcow2 "$image_file"

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

