#!/bin/bash

set -e

rm -rf chroot binary cache

# Configure live-build
lb config \
  --config /workdir/config \
  --architectures amd64 \
  --distribution bookworm \
  --debian-installer live \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components" \
  --mirror-bootstrap http://deb.debian.org/debian/ \
  --mirror-binary http://deb.debian.org/debian/ \
  --image-name bootstrap

# Build image
lb build

mv bootstrap-amd64.hybrid.iso /workdir/output/liveUSB.iso
