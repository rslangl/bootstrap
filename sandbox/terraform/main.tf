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

resource "libvirt_network" "sandbox_net" {
  name = "sandbox"
  bridge = "virbr10"
  mode = "route"
  domain = "sandbox.local"
  addresses = ["192.168.50.1/24"]
}

resource "libvirt_domain" "opnsense" {
  name   = "opnsense"
  memory = 2048
  vcpu   = 2
  disk {
    file = "opnsense.iso"
  }
  disk {
    volume_id = libvirt_volume.opnsense_disk.id
    scsi = false
  }
  network_interface {
    network_id = libvirt_network.sandbox_net.id
    hostname = "opnsense"
    addresses = ["192.168.50.80"]
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

resource "libvirt_pool" "sandbox_pool" {
  name = "sandbox"
  type = "dir"
  target {
    path = "./libvirt/pool"
  }
}

resource "libvirt_volume" "opnsense_disk" {
  name   = "opnsense.qcow2"
  format = "qcow2"
  pool = libvirt_pool.sandbox_pool.name
  size   = 21474836480
}


