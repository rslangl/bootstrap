#!/bin/bash

set -ex

# TODO: declare list of images to be built, based on environment (e.g. --sandbox builds image versions for local development)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${ROOT_DIR}/images"
SOURCES_DIR="${ROOT_DIR}/sandbox"

if docker image inspect proxmox-iso-builder >/dev/null 2>&1; then
  echo "Image already present"
else
  echo "Image not present, building..."
  docker build -t proxmox-iso-builder -f Dockerfile.pve-autoinstaller-builder .
fi

# TODO: add --on-first-boot /build/first_boot.sh
docker run --rm \
  -v "${IMAGES_DIR}/pve.iso:/build/pve.iso:ro" \
  -v "${SOURCES_DIR}/answer.toml:/build/answer.toml:ro" \
  -v "${SOURCES_DIR}/output:/build/output" \
  -v "${SOURCES_DIR}/first_boot.sh:/build/first_boot.sh" \
  proxmox-iso-builder /build/pve.iso \
  --fetch-from iso \
  --answer-file /build/answer.toml \
  --output /build/output/pve-auto.iso
