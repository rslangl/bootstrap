terraform {
  required_version = ">= 1.12.0"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = ">=0.79.0"
    }
    local = {
      source = "hashicorp/local"
      version = ">=2.5.3"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
  backend "local" {
    path = "../.cache/tfstate/sandbox/terraform.tfstate"
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

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
