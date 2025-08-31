# liveUSB

Builds a bootable custom image with contents needed to serve as an airgapped resource
provider for a centralized provisioner component, i.e. PiKVM.

## Overview

* `Dockerfile`: Builds the actual image
* `build.sh`: Runs the build process
* `package-lists/custom.list.chroot`: Packages to be installed to the live system
* `includes.chroot`: Everything in here gets copied to the live system, for example:
  * `includes.chroot/srv/registry`: Container images
  * `includes.chroot/srv/apt`: Apt repo files
  * `includes.chroot/srv/bsd`: BSD repo files
  * `includes.chroot/usr/local/bin/startup.sh`: Custom startup script
* `hooks/live.chroot`: Configures services or startup scripts, e.g. docker, nginx

## Test image

Run with QEMU:

```shell
$ qemu-system-x86_64 \
  -m 2048 \
  -cdrom ../.cache/output/liveUSB.iso \
  -boot d \
  -enable-kvm \
  -nic user,hostfwd=tcp::8080-:80,hostfwd=tcp::5000-:5000
```
