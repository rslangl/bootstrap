#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${ROOT_DIR}/images"

docker build -t proxmox-iso-builder -f Dockerfile.pve-autoinstaller-builder .

docker run --rm \
  -v "$(pwd)/${IMAGES_DIR}/pve.iso:/build/pve.iso:ro" \
  -v "$(pwd)/answer.toml:/build/answer.toml:ro" \
  -v "$(pwd)/output:/build/output" \
  proxmox-iso-builder /build/pve.iso --fetch-from iso --answer-file /build/answer.toml \
  --output /build/output/pve-auto.iso
