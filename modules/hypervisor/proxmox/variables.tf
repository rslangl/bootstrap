variable "app_servers" {
  description = "Application servers"
  type = map(object({
    ipv4     = string
    pve_node = string
    ssh_user = string
    ssh_key  = string
  }))
}

variable "k8s_controller_node" {
  description = "K8s control node VMs"
  type = map(object({
    node   = string
    vmid   = number
    name   = string
    ipv4   = string
    cpu    = number
    memory = number
    disk   = number
    vlan   = number
  }))
}
