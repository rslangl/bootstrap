terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.88.0"
    }
  }
}

# module "talos" {
#   source = "./modules/baseline"
# }
