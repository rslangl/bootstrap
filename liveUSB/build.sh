#!/bin/bash

set -e

# Copy config
mkdir -p live-build
cp -r config/* live-build/

# Configure live-build
lb config \
  --architecture amd64 \
  --distribution bookworm \
  --debian-installer live \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components" \
  --mirror-bootstrap http://deb.debian.org/debian/ \
  --mirror-binary http://deb.debian.org/debian/

# Build image
lb build

mv live-image-amd64.hybrid.iso ../output/liveUSB.iso
