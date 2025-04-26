resource "proxmox_virtual_environment_apt_standard_repository" "standard" {
  handle = "no-subscription"
  node   = "pve"
}
