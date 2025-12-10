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

resource "libvirt_pool" "liveos_bsd_pool" {
  name = "bsd_pool"
  type = "dir"
  target = {
    path = "${var.cache_dir}/libvirt/pool/bsd"
  }
}

data "template_file" "liveos_bsd_user_data" {
  template = file("${path.module}/cloudinit/user-data")
}

data "template_file" "liveos_bsd_meta_data" {
  template = file("${path.module}/cloudinit/meta-data")
}

# resource "libvirt_network" "liveos_bsd_network" {
#   name = "liveos_bsd_network"
#   addresses = ["10.17.0.0/24"]
# }

resource "libvirt_cloudinit_disk" "liveos_bsd_cloudinit_disk" {
  name = "bsd_cloudinit.iso"
  # pool = libvirt_pool.liveos_bsd_pool.name
  user_data = data.template_file.liveos_bsd_user_data.rendered
  meta_data = data.template_file.liveos_bsd_meta_data.rendered
}

resource "libvirt_volume" "liveos_bsd_disk" {
  name = "freebsd.qcow2"
  pool = libvirt_pool.liveos_bsd_pool.name
  #source = "${var.cache_dir}/images/freebsd_cloudinit.qcow2"
  #format = "qcow2"
  create = {
    content = {
      url = "${var.cache_dir}/images/freebsd_cloudinit.qcow2"
    }
  }
  #depends_on = [null_resource.download_iso]
}

resource "libvirt_domain" "liveos_bsd_domain" {
  name = "liveos_bsd_domain"
  memory = 2048
  memory_unit = "MiB"
  vcpu = 2
  type   = "kvm"

  # os = {
  #   type         = "hvm"
  #   type_arch    = "x86_64"
  #   type_machine = "q35"
  #   boot_devices = ["hd"]
  # }
  #
  devices = {
    disks = [
      {
        source = {
          volume_id = libvirt_volume.liveos_bsd_disk.id
        }
      }
    ]
    filesystem = {
      source = "${var.cache_dir}/build_artifacts/bsdrepo"
      target = "shared"
      accessmode = "passthrough"
    }
    console = {
      type        = "pty"
      target_port = "0"
      target_type = "serial"
    }
  #   graphics = {
  #     type        = "spice"
  #     listen_type = "address"
  #     autoport    = true
  #   }
  }
  #cloudinit = libvirt_cloudinit_disk.liveos_bsd_cloudinit_disk.id

  # network_interface {
  #   network_id = libvirt_network.liveos_bsd_network.id
  #   wait_for_lease = true
  # }
}

