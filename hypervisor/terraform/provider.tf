provider "proxmox" {
  endpoint = var.pve_endpoint
  username = var.pve_username
  password = var.pve_password

  insecure = true

  ssh {
    agent = true
  }
}

