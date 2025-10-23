terraform {
  required_version = ">= 1.12.0"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    template = {
      source = "hashicorp/template"
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
  name = "sandbox LAN"
  bridge = "virbr10"
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
resource "libvirt_network" "sandbox_network_wan" {
  name = "sandbox WAN"
  bridge = "virbr20"
  mode = "route"
  addresses = ["10.10.10.0/24"]
  autostart = true
}

# -------------------------------
#   LiveOS
# -------------------------------

resource "libvirt_volume" "sandbox_liveos_disk" {
  name   = "liveos.qcow2"
  source = "${var.cache_dir}/vm_disks/liveos.qcow2"
  pool = libvirt_pool.sandbox_pool.name
  format = "qcow2"
}

resource "libvirt_domain" "sandbox_liveos_domain" {
  name   = "pikvm"
  memory = 2048
  vcpu   = 1
  disk {
    volume_id = libvirt_volume.sandbox_liveos_disk.id
  }
  network_interface {
    network_id = libvirt_network.sandbox_network_lan.id
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

# -------------------------------
#   PiKVM
# -------------------------------

data "template_file" "sandbox_pikvm_cloudinit_userdata" {
  template = file("${path.root}/cloud-init/pikvm/user-data")
}

data "template_file" "sandbox_pikvm_cloudinit_metadata" {
  template = file("${path.root}/cloud-init/pikvm/meta-data")
}

data "template_file" "sandbox_pikvm_cloudinit_networkconfig" {
  template = file("${path.root}/cloud-init/pikvm/network-config")

}

# PiKVM is based on Arch Linux, so to make it as similar as possible
# we use an Arch Linux cloud image
resource "libvirt_cloudinit_disk" "sandbox_pikvm_cloudinit" {
  name = "pikvm-seed.iso"
  pool = libvirt_pool.sandbox_pool.name
  user_data = data.template_file.sandbox_pikvm_cloudinit_userdata.rendered
  meta_data = data.template_file.sandbox_pikvm_cloudinit_metadata.rendered
  network_config = data.template_file.sandbox_pikvm_cloudinit_networkconfig.rendered
}

resource "libvirt_volume" "sandbox_pikvm_disk" {
  name = "pikvm"
  source = "${var.cache_dir}/vm_disks/pikvm.qcow2"
  pool = libvirt_pool.sandbox_pool.name
  format = "qcow2"
}

resource "libvirt_domain" "sandbox_pikvm_domain" {
  name   = "pikvm"
  memory = 2048
  vcpu   = 1
  disk {
    volume_id = libvirt_volume.sandbox_pikvm_disk.id
  }
  cloudinit = libvirt_cloudinit_disk.sandbox_pikvm_cloudinit.id
  network_interface {
    network_id = libvirt_network.sandbox_network_lan.id
    mac        = "52:54:00:00:00:01"
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
  boot_device {
    dev = ["hd", "cdrom"]
  }
  depends_on = [libvirt_cloudinit_disk.sandbox_pikvm_cloudinit]
  autostart = true
}

# -------------------------------
#   OPNsense
# -------------------------------

resource "libvirt_volume" "sandbox_opnsense_disk" {
  name   = "opnsense"
  source = "${var.cache_dir}/vm_disks/opnsense.qcow2"
  pool = libvirt_pool.sandbox_pool.name
  format = "qcow2"
  # size   = 21474836480
}

resource "libvirt_domain" "sandbox_opnsense" {
  name   = "opnsense"
  memory = 2048
  vcpu   = 2
  disk {
    volume_id = libvirt_volume.sandbox_opnsense_disk.id
    scsi = false
  }
  network_interface {
    network_id = libvirt_network.sandbox_network_lan.id
    mac = "52:54:00:ea:a5:05"
    hostname = "opnsense"
    wait_for_lease = false
  }
  network_interface {
    network_id = libvirt_network.sandbox_network_wan.id
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
