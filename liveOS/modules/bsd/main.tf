variable "iso_path" {
  type = string
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_pool" "bsd_pool" {
  name = "bsd_resource_pool"
  type = "dir"
  target {
    path = "../.cache/libvirt/pool/bsd"
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name = "cloudinit.iso"
  pool = libvirt_pool.bsd_pool.name
  user_data = data.template_file.user_data.rendered
}


resource "libvirt_volume" "bsd_disk" {
  name = "freebsd.qcow2"
  pool = libvirt_pool.bsd_pool.name
  #format = qcow2
}

resource "libvirt_domain" "bsd" {
  name = "freebsd"
  memory = 2048
  vcpu = 2
  cloudinit = libvirt_cloudinit_disk.cloudinit.id
  disk {
    file = libvirt_volume.resourcebuilder_freebsd_disk.id
  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
  autostart = true
}

