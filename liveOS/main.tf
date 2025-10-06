terraform {
  required_version = ">= 1.13.0"
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
      version = "0.84.1"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.3"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
  backend "local" {
    path = "../.cache/tfdata/liveos/terraform.tfstate"
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
