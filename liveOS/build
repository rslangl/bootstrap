#!/bin/bash

set -e

WORKDIR=/tmp/live-build
mkdir -p "$WORKDIR"
cp -r /config/* "$WORKDIR/"
cd "$WORKDIR"

rm -rf chroot binary cache

# Configure live-build
lb config \
  --architectures amd64 \
  --distribution bookworm \
  --debian-installer live \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components" \
  --mirror-bootstrap http://deb.debian.org/debian/ \
  --mirror-binary http://deb.debian.org/debian/

# Build image
lb build

mv live-image-amd64.hybrid.iso /output/liveUSB.iso
