module "hv01" {
  source = "../../modules/hypervisor/proxmox"
  hosts  = var.hosts
}
