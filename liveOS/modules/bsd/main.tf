terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

resource "libvirt_pool" "builder_bsd_pool" {
  name = "builder-bsd-pool"
  type = "dir"
  target = {
    path = "${var.cache_dir}/libvirt/pool/builder_bsd"
  }
}

# Base FreeBSD cloud image
resource "libvirt_volume" "builder_bsd_base" {
  name = "builder-base"
  pool = libvirt_pool.builder_bsd_pool.name
  target = {
    format = {
      type = "qcow2"
    }
  }
  create = {
    content = {
      url = "${var.image_url}"
    }
  }
}

data "template_file" "builder_bsd_user_data" {
  template = file("${path.module}/cloudinit/user-data")
}

data "template_file" "builder_bsd_meta_data" {
  template = file("${path.module}/cloudinit/meta-data")
}

resource "libvirt_cloudinit_disk" "builder_bsd_cloudinit_disk" {
  name = "builder-bsd-cloudinit-disk"
  # pool = libvirt_pool.liveos_bsd_pool.name
  user_data = data.template_file.builder_bsd_user_data.rendered
  meta_data = data.template_file.builder_bsd_meta_data.rendered
}

# Upload cloud-init ISO to pool
resource "libvirt_volume" "builder_bsd_seed_disk" {
  name = "builder-bsd-seed"
  pool = libvirt_pool.builder_bsd_pool.name
  # target = {
  #   format = {
  #     type = "qcow2"
  #   }
  # }
  create = {
    content = {
      url = libvirt_cloudinit_disk.builder_bsd_cloudinit_disk.path
    }
  }
  #backing_store = {
  #   #path = "${var.cache_dir}/libvirt/vm_disks/liveos_builder_bsd_seed.qcow2"
  #   path = libvirt_volume.bsd_base.path
  #   format = {
  #     type = "qcow2"
  #   }
  # }
  capacity = 2147483648
}

# Writable copy-on-write layer for the FreeBSD VM
resource "libvirt_volume" "builder_bsd_disk" {
  name = "builder-bsd-disk"
  pool   = libvirt_pool.builder_bsd_pool.name
  target = {
    format = {
      type = "qcow2"
    }
  }
  backing_store = {
    #path = "${var.cache_dir}/libvirt/vm_disks/builder_bsd.qcow2"
    path = libvirt_volume.builder_bsd_base.path
    format = {
      type = "qcow2"
    }
  }
  capacity = 2147483648
}

resource "libvirt_domain" "builder_bsd" {
  name = "builder-bsd"
  memory = 2048
  memory_unit = "MiB"
  vcpu = 2
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    #boot_devices = ["hd"]
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
             pool = libvirt_volume.builder_bsd_disk.pool
             volume = libvirt_volume.builder_bsd_disk.name
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        driver = {
          type = "qcow2"
        }
      }
    ]
    filesystems = [
      {
        source = {
          mount = {
            dir = "${var.cache_dir}/build_artifacts/bsdrepo"
          }
        }
        target = {
          dir = "shared"
        }
        access_mode = "mapped"
        #read_only = true
      }
    ]
    consoles = [
      {
        target = {
          port = "0"
          type = "serial" # or "pty""?
        }
      }
    ]
  }
  #cloudinit = libvirt_cloudinit_disk.liveos_bsd_cloudinit_disk.id
}

