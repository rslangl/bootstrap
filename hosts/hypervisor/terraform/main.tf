terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.84.1"
    }
  }
}

# module "talos" {
#   source = "./modules/baseline"
# }
