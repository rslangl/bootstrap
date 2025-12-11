terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

resource "libvirt_pool" "builder_pool" {
  name = "builder-pool"
  type = "dir"
  target = {
    path = "${var.cache_dir}/tfdata/providers/libvirt/pool/builder"
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
  user_data = data.template_file.builder_bsd_user_data.rendered
  meta_data = data.template_file.builder_bsd_meta_data.rendered
}

resource "libvirt_volume" "builder_bsd_seed_disk" {
  name = "builder-bsd-seed-disk"
  pool = libvirt_pool.builder_pool.name
  create = {
    content = {
      url = libvirt_cloudinit_disk.builder_bsd_cloudinit_disk.path
    }
  }
}

resource "libvirt_volume" "builder_bsd_disk" {
  name = "builder-bsd-disk"
  pool   = libvirt_pool.builder_pool.name
  target = {
    format = {
      type = "qcow2"
    }
  }
  backing_store = {
     path = "${var.cache_dir}/images/bsd-cloud.qcow2"
     format = {
       type = "qcow2"
     }
   }
  capacity = 2147483648
}

resource "libvirt_domain" "builder_bsd_vm" {
  name = "builder-bsd-vm"
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
             pool = libvirt_pool.builder_pool.name
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
  }
}

