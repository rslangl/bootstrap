# liveOS

Builds a bootable custom image with resources needed to serve as an airgapped resource
provider for a centralized provisioner component, i.e. PiKVM.

## Overview

This directory is structured into Terraform modules in which each module builds a particular resource provider.

### apt

Uses a Debian Docker image to fetch desired apt packages, which will be served under the `/apt` endpoint.

### bsd

Uses a FreeBSD VM image with cloud-init to fetch desired bsd packages, which will be served under the `/bsd` endpoint.

### registry

Uses the standard Docker registry image to build a tarball containing desired container images,
which will be server under the `/registry` endpoint.

### liveos

Builds the actual live system through Docker. Once built, it can be tested directly using QEMU:

```shell
qemu-system-x86_64 \
  -m 2048 \
  -cdrom ../.cache/output/liveUSB.iso \
  -boot d \
  -enable-kvm \
  -nic user,hostfwd=tcp::8080-:80,hostfwd=tcp::5000-:5000
```
