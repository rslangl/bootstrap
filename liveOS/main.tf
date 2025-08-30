terraform {
  required_version = ">= 1.12.0"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = ">=0.79.0"
    }
    local = {
      source = "hashicorp/local"
      version = ">=2.5.3"
    }

    backend "local" {
      path = "../.cache/tfstate/sandbox/terraform.tfstate"
    }
  }
}

# -------------------------------
#   Providers
# -------------------------------

provider "libvirt" {
  uri = "qemu:///system"
}

provider "docker" {
  host = "unix://var/run/docker.sock"
}

resource "libvirt_pool" "resourcebuilder_pool" {
  name = "resourcesbuilder"
  type = "dir"
  target {
    path = "../.cache/libvirt/pool"
  }
}

# -------------------------------
#   Variables
# -------------------------------

variable "build_apt" {
  type = bool
  default = true
}

variable "build_bsd" {
  type = bool
  default = true
}

variable "build_registry" {
  type = bool
  default = true
}

# -------------------------------
#   Modules
# -------------------------------

module "apt" {
  source = "./modules/apt"
  count = var.build_apt ? 1 : 0
}

module "bsd" {
  source = "./modules/bsd"
  count = var.build_bsd ? 1 : 0
}

module "registry" {
  source = "./modules/registry"
  count = var.build_registry ? 1 : 0
}
