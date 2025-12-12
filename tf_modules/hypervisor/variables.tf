variable "pve_endpoint" {
  type = string
  default = "https://192.168.88.2:8006/"
}

variable "pve_username" {
  type = string
  default = "root@pam"
}

variable "pve_password" {
  type = string
  sensitive = true
}
