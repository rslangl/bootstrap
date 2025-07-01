# liveUSB

Builds a bootable custom image with contents needed to serve as an airgapped resource provider for a centralized provisioner component, i.e. PiKVM. 

## Overview

* `Dockerfile`: Builds the actual image
* `build.sh`: Runs the build process
* `package-lists/custom.list.chroot`: Packages to be installed to the live system
* `includes.chroot`: Everything in here gets copied to the live system, for example:
  * `includes.chroot/srv/registry`: Container images
  * `includes.chroot/srv/aptrepo`: Deb files
  * `includes.chroot/usr/local/bin/startup.sh`: Custom startup script
* `hooks/live.chroot`: Configures services or startup scripts, e.g. docker, nginx

## Build

During build, the `live-build` will try to mount `/proc` and `/dev/pts` inside the chroot, but Docker containers do not allow nested mounts by default. Thus, the container must be ran with elevated privileges.

Run the container and build:
```shell
$ docker build -t liveos-builder .
$ docker run --rm -it \
  --privileged \
  --cap-add=SYS_ADMIN \
  --security-opt seccomp=unconfined \
  -v "$(pwd)/config":/home/builder/config \
  -v "$(pwd)/output":/home/builder/output \
  -v "$(pwd)/build.sh":/home/builder/build.sh \
  liveos-builder ./build.sh
```

The image will be written to `output/liveUSB.iso`

## Test image

Run with QEMU:
```shell
$ qemu-system-x86_64 \
  -m 2048 \
  -cdrom output/liveUSB.iso \
  -boot d \
  -enable-kvm \
  -nic user,hostfwd=tcp::8080-:80,hostfwd=tcp::5000-:5000
```
