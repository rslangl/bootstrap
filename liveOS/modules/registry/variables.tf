variable "cache_dir" {
  type = string
  default = ""
}

variable "registry_containers" {
  type = list(string)
  default = ["alpine"]
}
