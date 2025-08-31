# variable "build_apt" {
#   description = "Build APT-related resources"
#   type        = bool
#   default     = true
# }
#
# variable "build_bsd" {
#   description = "Build BSD-related resources"
#   type        = bool
#   default     = true
# }
#
# variable "build_registry" {
#   description = "Build registry-related resources"
#   type        = bool
#   default     = true
# }
#
variable "cache_dir" {
  description = "Local project path to cache directory"
  type = string
  default = ""
}

variable "scripts_dir" {
  description = "Local project path to scripts directory"
  type = string
  default = ""
}
