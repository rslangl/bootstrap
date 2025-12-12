# bootstrap

<!-- markdownlint-disable MD013 -->
![Build](https://github.com/rslangl/bootstrap/actions/workflows/lint.yml/badge.svg) ![License](https://img.shields.io/github/license/rslangl/bootstrap) ![GitHub release](https://img.shields.io/github/v/release/rslangl/bootstrap) ![Top Language](https://img.shields.io/github/languages/top/rslangl/bootstrap) ![Repo Size](https://img.shields.io/github/repo-size/rslangl/bootstrap)
<!-- markdownlint-enable MD013 -->

Bootable environment to bootstrap my infrastructure.

## Overview

TODO

## Development

Using nix, which spins up a nix-shell containing all tools required:

```shell
nix develop .#default
```

## TODO

### Router

* Setup interfaces, each with their own IP subnets
  * `igc0`: Internet facing
  * `igc1`: Internal facing
  * `igc2`: DMZ
* Setup authoritative DNS with Unbound
  * Use DNSSEC and IPSec
* Configure firewall
  * SSH and web-GUI only available via `igc1`

### Hypervisor

* Setup 2 OS disk with ext4 in RAID1
* Setup data disks in RAIDZ-2
* Setup SDNs:
  * VXLAN `vnet-k8s-workers` for k8s worker nodes
  * VXLAN `vnet-k8s-control` for k8s control plane nodes
  * Bridge or NAT `vnet-ingress` for exposing the k8s cluster (take into account the reverse proxy)
  * VXLAN `vnet-admin` for jump hosts/monitoring

### KVM

* Setup user account
  * Change password `kvmd-htpasspwd set admin`
  * Get USB configuration (OTG) with `kvmd-otgconf` and register what device to use, e.g.:

  ```shell
  + hid.usb0  # Keyboard
  + hid.usb1  # Absolute mouse
  + hid.usb2  # Relative mouse
  ```

* Enable toggling between local and remote with:

```shell
# kvmd-otgconf --enable-function hid.usb0 --enable-function hid.usb1
# kvmd-otgconf --disable-function hid.usb0 --disable-function hid.usb1
```

### AP redzone

* Setup user account
* Configure DHCP client on WLAN
* Configure DHCP server on eth
* Configure firewall
* Disable unused peripherals
  * GPIO
  * Audio
  * MIPI CSI camera port
  * MIPI DSI dispay port
  * Bluetooth
