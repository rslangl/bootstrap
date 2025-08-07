terraform {
  required_version = ">= 1.12.0"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
  backend "local" {
    path = "../.cache/tfstate/sandbox/terraform.tfstate"
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "sandbox_pool" {
  name = "sandbox"
  type = "dir"
  target {
    path = "../.cache/libvirt/pool/sandbox"
  }
}

# -------------------------------
#   ISO paths
# -------------------------------

variable "opnsense_iso_path" {
  type = string
}

# -------------------------------
#   Virtual networks
# -------------------------------

# LAN network, used by all devices
resource "libvirt_network" "sandbox_lan" {
  name = "sandbox LAN"
  bridge = "virbr10"
  # Need routed mode to enable VM-VM, VM-internet, host-VM communication
  mode = "route"
  domain = "sandbox.local"
  addresses = ["192.168.50.0/24"]
  dns {
    enabled = true
    # Enables forwarding unanswered DNS queries to upstream
    local_only = false
  }
  autostart = true
}

# WAN network, only used by OPNsense
resource "libvirt_network" "sandbox_wan" {
  name = "sandbox WAN"
  bridge = "virbr20"
  mode = "route"
  addresses = ["10.10.10.0/24"]
  autostart = true
}

# -------------------------------
#   PiKVM
# -------------------------------

resource "libvirt_domain" "sandbox_pikvm" {
  name   = "pikvm"
  memory = 2048
  vcpu   = 1
  disk {
    volume_id = libvirt_volume.sandbox_pikvm_disk.id
  }
  disk {
    volume_id = libvirt_volume.sandbox_bootstrap_usb.id
  }
  network_interface {
    network_id = libvirt_network.sandbox_lan.id
    mac        = "52:54:00:00:00:01"
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
  autostart = true
}

# PiKVM OS image
resource "libvirt_volume" "sandbox_pikvm_disk" {
  name = "pikvm.qcow2"
  pool = libvirt_pool.sandbox_pool.name
  format = "qcow2"
}

# Bootstrap image (mountable)
resource "libvirt_volume" "sandbox_bootstrap_usb" {
  name   = "bootstrap.qcow2"
  pool = libvirt_pool.sandbox_pool.name
  format = "qcow2"
}

# -------------------------------
#   OPNsense
# -------------------------------

resource "libvirt_volume" "sandbox_opnsense_disk" {
  name   = "opnsense.qcow2"
  format = "qcow2"
  pool = libvirt_pool.sandbox_pool.name
  size   = 21474836480
}

resource "libvirt_domain" "sandbox_opnsense" {
  name   = "opnsense"
  memory = 2048
  vcpu   = 2
  disk {
    file = var.opnsense_iso_path
  }
  disk {
    volume_id = libvirt_volume.sandbox_opnsense_disk.id
    scsi = false
  }
  network_interface {
    network_id = libvirt_network.sandbox_lan.id
    mac = "52:54:00:ea:a5:05"
    hostname = "opnsense"
    wait_for_lease = false
  }
  network_interface {
    network_id = libvirt_network.sandbox_wan.id
    mac = "52:54:00:00:00:aa"
    wait_for_lease = false
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

# -------------------------------
#   PVE
# ------------------------------- 

# TODO: 
