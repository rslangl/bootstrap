terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  #   null = {
  #     source = "hashicorp/null"
  #   }
  }
}

# resource "null_resource" "download_iso" {
#   provisioner "local-exec" {
#     command = <<EOT
#       bash ${var.scripts_dir}/fetch_iso.sh \
#         "${var.iso_url}" \
#         "${var.iso_path}" \
#         "${var.iso_checksum}"
#     EOT
#   }
#   triggers = {
#     iso_url = var.iso_url
#     iso_checksum = var.iso_checksum
#   }
# }
#

resource "libvirt_pool" "bsd_pool" {
  name = "bsd_pool"
  type = "dir"
  target {
    path = "${var.cache_dir}/libvirt/pool/bsd"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloudinit/user-data")
}

data "template_file" "meta_data" {
  template = file("${path.module}/cloudinit/meta-data")
}

resource "libvirt_cloudinit_disk" "bsd_cloudinit" {
  name = "bsd_cloudinit.iso"
  pool = libvirt_pool.bsd_pool.name
  user_data = data.template_file.user_data.rendered
  meta_data = data.template_file.meta_data.rendered
}

resource "libvirt_volume" "bsd_disk" {
  name = "freebsd.qcow2"
  pool = libvirt_pool.bsd_pool.name
  source = "${var.cache_dir}/images/freebsd_cloudinit.qcow2"
  format = "qcow2"
  #depends_on = [null_resource.download_iso]
}

resource "libvirt_domain" "bsd" {
  name = "freebsd"
  memory = 2048
  vcpu = 2
  disk {
    volume_id = libvirt_volume.bsd_disk.id
  }
  cloudinit = libvirt_cloudinit_disk.bsd_cloudinit.id
  network_interface {
    network_name = "default"
    wait_for_lease = true
  }
  filesystem {
    source = "${var.cache_dir}/build_artifacts/bsdrepo"
    target = "shared"
    accessmode = "passthrough"
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
  boot_device {
    dev = ["hd"]
  }
}

