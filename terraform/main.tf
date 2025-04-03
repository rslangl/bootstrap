terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

module "talos" {
  source = "./modules/baseline"
}
