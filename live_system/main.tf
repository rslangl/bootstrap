terraform {
  required_version = ">= 1.12.0"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.9.2"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.94.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.6.2"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
  backend "local" {
    path = "../.cache/tfdata/modules/liveos/terraform.tfstate"
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
  cache_dir = var.cache_dir
}

module "bsd" {
  source = "./modules/bsd"
  cache_dir = var.cache_dir
  scripts_dir = var.scripts_dir
}

module "registry" {
  source = "./modules/registry"
  cache_dir = var.cache_dir
}

module "liveos" {
  source = "./modules/liveos"
  cache_dir = var.cache_dir
}
