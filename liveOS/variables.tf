variable "build_apt" {
  description = "Build APT-related resources"
  type        = bool
  default     = true
}

variable "build_bsd" {
  description = "Build BSD-related resources"
  type        = bool
  default     = true
}

variable "build_registry" {
  description = "Build registry-related resources"
  type        = bool
  default     = true
}

