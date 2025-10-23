terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.85.1"
    }
  }
}

# module "talos" {
#   source = "./modules/baseline"
# }
