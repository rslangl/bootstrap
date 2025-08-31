variable cache_dir {
  type = string
  default = ""
}

variable "scripts_dir" {
  type = string
  default = ""
  #default = "/home/user/dev/sw/bootstrap/sbin"
}

variable "iso_url" {
  type    = string
  default = "https://download.freebsd.org/releases/ISO-IMAGES/14.2/FreeBSD-14.2-RELEASE-amd64-disc1.iso"
}

variable "iso_checksum" {
  type    = string
  default = "3caa1fcbd9a9f825f394d5296e80e25a72022381154290ef508aa33f3e325ee4"
}

variable "iso_path" {
  type    = string
  #default = "../../../.cache/images/bsd.iso"
  default = "/home/user/dev/sw/bootstrap/.cache/images/bsd.iso"
}
