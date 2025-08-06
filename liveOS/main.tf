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
    path = "./libvirt/pool"
  }
}

variable "iso_url" {
  default = "https://download.freebsd.org/releases/ISO-IMAGES/14.1/FreeBSD-14.1-RELEASE-amd64-disc1.iso"
}

variable "freebsd_iso_path" {
  type = string
}

# Download FreeBSD ISO
resource "libvirt_volume" "resourcebuilder_freebsd_iso" {
  name = "freebsd.iso"
  pool = libvirt_pool.resourcesbuilder_pool.name
  source = var.iso_url
  format = "raw"
}

# Disk volume for VM
resource "libvirt_volume" "resourcebuilder_freebsd_disk" {
  name = "freebsd.qcow2"
  pool = libvirt_pool.resourcesbuilder_pool.name
  format = qcow2
}

resource "libvirt_domain" "resourcebuilder_freebsd" {
  name = "freebsd"
  memory = 2048
  vcpu = 2
  disk {
    file = var.freebsd_iso_path
  }
}
