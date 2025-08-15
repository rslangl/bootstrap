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

resource "libvirt_pool" "resourcebuilder_pool" {
  name = "resourcesbuilder"
  type = "dir"
  target {
    path = "../.cache/libvirt/pool"
  }
}

# -------------------------------
#   ISO paths
# -------------------------------

variable "freebsd_iso_path" {
  type = string
}

variable "debian_iso_path" {
  type = string
}

# -------------------------------
#   BSD resources VM
# -------------------------------

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name = "cloudinit.iso"
  pool = libvirt_pool.resourcebuilder_pool.name
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_domain" "resourcebuilder_freebsd" {
  name = "freebsd"
  memory = 2048
  vcpu = 2
  cloudinit = libvirt_cloudinit_disk.cloudinit.id
  disk {
    file = libvirt_volume.resourcebuilder_freebsd_disk.id
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

resource "libvirt_volume" "resourcebuilder_freebsd_disk" {
  name = "freebsd.qcow2"
  pool = libvirt_pool.resourcebuilder_pool.name
  #format = qcow2
}

# -------------------------------
#   Apt resources VM
# -------------------------------

# TODO: cloud init template file

# TODO: cloud init disk

resource "libvirt_domain" "resourcebuilder_debian" {
  name = "debian"
  memory = 2048
  vcpu = 2
  disk {
    file = libvirt_volume.resourcebuilder_debian_disk.id
  }
  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
  autostart = true
}

resource "libvirt_volume" "resourcebuilder_debian_disk" {
  name = "debian.qcow2"
  pool = libvirt_pool.resourcebuilder_pool.name
}
