terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "isolated_lan" {
  name = "isolated-lan"
  bridge = "virbr10"
  #forward_mode = "none"
  addresses = ["192.168.50.1/24"]
}

resource "libvirt_domain" "opnsense" {
  name   = "opnsense"
  memory = 2048
  vcpu   = 2
  disk {
    volume_id = libvirt_volume.opnsense_disk.id
  }
  disk {
    volume_id = libvirt_volume.opnsense_iso.id
  }
  network_interface {
    network_id = libvirt_network.isolated_lan.id
  }
  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = true
  }
  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }
  boot_device {
    dev = ["cdrom", "hd"]
  }
}

resource "libvirt_pool" "sandbox" {
  name = "sandbox"
  type = "dir"
  target {
    path = "../libvirt/pool"
  }
}

resource "libvirt_volume" "opnsense_disk" {
  name   = "opnsense.qcow2"
  format = "qcow2"
  pool = libvirt_pool.sandbox.name
  size   = 21474836480
}

resource "libvirt_volume" "opnsense_iso" {
  name = "opnsense.iso"
  format = "raw"
  pool = libvirt_pool.sandbox.name
  source = "../iso/opnsense.iso"
}

