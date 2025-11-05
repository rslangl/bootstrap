terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.86.0"
    }
  }
}

# module "talos" {
#   source = "./modules/baseline"
# }
