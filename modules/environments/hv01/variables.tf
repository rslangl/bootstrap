variable "proxmox_api_url" {
  type = string
}

variable "k8s_controllers" {
  type = map(any)
}

variable "k8s_workers" {
  type = map(any)
}
