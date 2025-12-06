terraform {
  required_version = ">= 1.12.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
  backend "local" {
    path = "../.cache/tfdata/sandbox/terraform.tfstate"
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "sandbox_pool" {
  name = "sandbox_pool"
  type = "dir"
  target {
    path = "${var.cache_dir}/libvirt/pool/sandbox"
  }
}

# -------------------------------
#   Virtual networks
# -------------------------------

# LAN network, used by all devices, where routed mode is needed to
# enable VM-VM, VM-internet, host-VM communication
resource "libvirt_network" "sandbox_network_lan" {
  name      = "sandbox_LAN"
  bridge    = "virbr10"
  mode      = "nat"
  domain    = "sandbox.local"
  addresses = ["192.168.50.0/24"]
  dns {
    enabled = true
    # Enables forwarding unanswered DNS queries to upstream
    local_only = false
  }
  autostart = true
}

# WAN network, only used by OPNsense
resource "libvirt_network" "sandbox_network_wan" {
  name      = "sandbox_WAN"
  bridge    = "virbr20"
  mode      = "route"
  addresses = ["10.10.10.0/24"]
  autostart = true
}

# -------------------------------
#   LiveOS
# -------------------------------

resource "libvirt_volume" "sandbox_liveos_disk" {
  name   = "liveos_disk"
  source = "${var.cache_dir}/vm_disks/liveos.qcow2"
  pool   = libvirt_pool.sandbox_pool.name
  format = "qcow2"
}

resource "libvirt_domain" "sandbox_liveos_domain" {
  name   = "liveos"
  memory = 2048
  vcpu   = 1
  disk {
    volume_id = libvirt_volume.sandbox_liveos_disk.id
  }
  # The bootstrap system will get the third address in the local range,
  # namely 192.168.50.12
  network_interface {
    network_id = libvirt_network.sandbox_network_lan.id
    hostname   = "bootstrap"
    addresses  = ["192.168.50.12"]
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
  autostart = true
}

# -------------------------------
#   PiKVM (AP greenzone)
# -------------------------------

# TODO:

# -------------------------------
#   PiKVM
# -------------------------------

resource "libvirt_volume" "sandbox_pikvm_disk" {
  name   = "pikvm_disk"
  # source = "${var.cache_dir}/vm_disks/pikvm.qcow2"
  source = "${var.cache_dir}/vm_disks/debian_cloud.qcow2"
  pool   = libvirt_pool.sandbox_pool.name
  format = "qcow2"
}

# NOTE: the fields `machine`, `firmware`, and `nvram` were required to run UEFI images
resource "libvirt_domain" "sandbox_pikvm_domain" {
  name   = "pikvm"
  memory = 2048
  vcpu   = 1
  # machine = "q35"
  # firmware = "/nix/store/z30h26qgxw1bd2vmb1vxyp8xvapj74m4-OVMF-202508-fd/FV/OVMF_CODE.fd"
  # nvram {
  #   file = "${var.cache_dir}/tmp/pikvm_VARS.fd"
  # }
  # cloudinit = libvirt_cloudinit_disk.sandbox_pikvm_cloudinit.id
  disk {
    volume_id = libvirt_volume.sandbox_pikvm_disk.id
  }
  # The router gets the first IP in range, while the provisioner gets the next,
  # namely 192.168.50.11
  network_interface {
    network_id = libvirt_network.sandbox_network_lan.id
    hostname   = "pikvm"
    addresses  = ["192.168.50.11"]
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
  # NOTE: used to be ["hd", "cdrom"] due to the cloudinit image
  boot_device {
    dev = ["hd"]
  }
  # depends_on = [libvirt_cloudinit_disk.sandbox_pikvm_cloudinit]
  autostart  = true
}

# -------------------------------
#   OPNsense
# -------------------------------

resource "libvirt_volume" "sandbox_opnsense_disk" {
  name   = "opnsense_disk"
  source = "${var.cache_dir}/vm_disks/opnsense.qcow2"
  pool   = libvirt_pool.sandbox_pool.name
  format = "qcow2"
}

resource "libvirt_domain" "sandbox_opnsense" {
  name   = "opnsense"
  memory = 2048
  vcpu   = 2
  disk {
    volume_id = libvirt_volume.sandbox_opnsense_disk.id
    scsi      = false
  }
  # OPNsense acts as the router for the entire network
  network_interface {
    network_id     = libvirt_network.sandbox_network_lan.id
    hostname       = "opnsense"
    addresses      = ["192.168.50.10"]
    wait_for_lease = false
  }
  # OPNsense acts as a client towards `ap_greenzone` which serves IPs
  # over the 10.10.10.0/24 subnet, thus getting the next address 10.10.10.11
  network_interface {
    network_id     = libvirt_network.sandbox_network_wan.id
    hostname       = "opnsense"
    addresses      = ["10.10.10.11"]
    wait_for_lease = false
  }
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
  console {
    type        = "pty"
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
