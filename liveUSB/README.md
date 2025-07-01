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

Run the container and build:
```shell
$ docker build -t liveos-builder .
$ docker run --rm -it \
  -v "$(pwd)/config":/home/builder/config \
  -v "$(pwd)/output":/home/builder/output \
  -v "$(pwd)/build.sh":/home/builder/build.sh \
  liveos-builder ./build.sh
```

The image will be written to `output/liveUSB.iso`
