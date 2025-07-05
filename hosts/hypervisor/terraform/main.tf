terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}

module "talos" {
  source = "./modules/baseline"
}
