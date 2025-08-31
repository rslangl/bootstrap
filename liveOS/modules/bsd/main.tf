terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      #version = "0.8.3"
    }
    docker = {
      source  = "kreuzwerker/docker"
      #version = "3.0.2"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

resource "null_resource" "download_iso" {
  provisioner "local-exec" {
    command = <<EOT
      bash ${var.scripts_dir}/fetch_iso.sh \
        "${var.iso_url}" \
        "${var.iso_path}" \
        "${var.iso_checksum}"
    EOT
  }
  triggers = {
    iso_url = var.iso_url
    iso_checksum = var.iso_checksum
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_pool" "bsd_pool" {
  name = "bsd_resource_pool"
  type = "dir"
  target {
    #path = "../../../.cache/libvirt/pool/bsd"
    path = "${var.cache_dir}/libvirt/pool/bsd"
  }
}

# resource "libvirt_cloudinit_disk" "cloudinit" {
#   name = "cloudinit.iso"
#   pool = libvirt_pool.bsd_pool.name
#   user_data = data.template_file.user_data.rendered
# }

resource "libvirt_volume" "bsd_disk" {
  name = "freebsd.qcow2"
  pool = libvirt_pool.bsd_pool.name
  depends_on = [null_resource.download_iso]
}

resource "libvirt_domain" "bsd" {
  name = "freebsd"
  memory = 2048
  vcpu = 2
  #cloudinit = libvirt_cloudinit_disk.cloudinit.id
  disk {
    file = libvirt_volume.bsd_disk.id
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

