terraform {
  required_version = ">= 1.12.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
  backend "local" {
    path = "../.cache/tfdata/sandbox/terraform.tfstate"
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "sandbox_pool" {
  name = "sandbox_pool"
  type = "dir"
  target = {
    path = "${var.cache_dir}/libvirt/pool/sandbox"
  }
}

# -------------------------------
#   Virtual networks
# -------------------------------

# LAN network, used by all devices, where routed mode is needed to
# enable VM-VM, VM-internet, host-VM communication
resource "libvirt_network" "sandbox_network_lan" {
  name      = "sandbox_LAN"
  bridge    = {
    name = "virbr10"
  }
  forward      = {
    mode = "nat"
  }
  domain    = {
    name = "sandbox.local"
  }
  ips = [
    {
      address = "14.88.0.0/24"
    }
  ]
  dns = {
    enabled = true
    # Enables forwarding unanswered DNS queries to upstream
    local_only = false
  }
  autostart = true
}

# WAN network, only used by OPNsense
resource "libvirt_network" "sandbox_network_wan" {
  name      = "sandbox_WAN"
  bridge    = {
    name = "virbr20"
  }
  forward      = {
    mode = "route"
  }
  ips = [
    {
      address = "192.168.88.0/24"
    }
  ]
  autostart = true
}

# -------------------------------
#   LiveOS
# -------------------------------

resource "libvirt_volume" "sandbox_liveos_disk" {
  name   = "liveos_disk"
  backing_store = {
    path = "${var.cache_dir}/libvirt/vm_disks/liveos.qcow2"
    #format = "qcow2"
  }
  pool   = libvirt_pool.sandbox_pool.name
}

resource "libvirt_domain" "sandbox_liveos_domain" {
  name   = "liveos"
  memory = 2048
  vcpu   = 1
  type = "kvm"

  devices = {
    disks = [
      {
        source = {
          file = {
            #pool = libvirt_pool.sandbox_pool.name
            volume = libvirt_volume.sandbox_liveos_disk.name
          }
        }
      }
    ]
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        # The bootstrap system will get the third address in the local range,
        # namely 192.168.50.12
        source = {
          network = {
            network = libvirt_network.sandbox_network_lan.name
            ip = "192.168.50.12"
          }
        }
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
    graphics = [
      {
        vnc = {
          auto_port = true
          listen = "address"  # invalid?
        }
      }
    ]
  }
  autostart = true
}

# -------------------------------
#   PiKVM (AP greenzone)
# -------------------------------

# TODO:

# -------------------------------
#   PiKVM
# -------------------------------

resource "libvirt_volume" "sandbox_pikvm_disk" {
  name   = "pikvm_disk"
  backing_store = {
    path = "${var.cache_dir}/libvirt/vm_disks/debian_cloud.qcow2"
    #format = "qcow2"
  }
  pool   = libvirt_pool.sandbox_pool.name
}

resource "libvirt_domain" "sandbox_pikvm_domain" {
  name   = "pikvm"
  memory = 2048
  vcpu   = 1
  type = "kvm"

  devices = {
    disks = [
      {
        source = {
          #pool = libvirt_pool.sandbox_pool.name
          volume = libvirt_volume.sandbox_pikvm_disk.name
        }
      }
    ]
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            # The router gets the first IP in range, while the provisioner (the PiKVM) gets the next,
            # namely 14.88.0.11
            network = libvirt_network.sandbox_network_lan.name
            ip = "14.88.0.11"
          }
        }
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
    graphics = [
      {
        vnc = {
          auto_port = true
          listen = "address"  # invalid?
        }
      }
    ]
  }
  # # cloudinit = libvirt_cloudinit_disk.sandbox_pikvm_cloudinit.id
  autostart  = true
}

# -------------------------------
#   OPNsense
# -------------------------------

resource "libvirt_volume" "sandbox_opnsense_disk" {
  name   = "opnsense_disk"
  backing_store = {
    path = "${var.cache_dir}/vm_disks/opnsense.qcow2"
    #format = "qcow2"
  }
  pool   = libvirt_pool.sandbox_pool.name
}

resource "libvirt_domain" "sandbox_opnsense" {
  name   = "opnsense"
  memory = 2048
  vcpu   = 2
  type = "kvm"

  # os = {
  #   type         = "hvm"
  #   type_arch    = "x86_64"
  #   type_machine = "q35"
  #   boot_devices = ["cdrom", "hd"]
  # }

  devices = {
    consoles = [
      {
        target = {
          port = "0"
          type = "serial" # or "pty""?
        }
      }
    ]
    graphics = [
      {
        vnc = {
          auto_port = true
          listen = "address"  # invalid?
        }
      }
    ]
    disks = [
      {
        source = {
          #pool = libvirt_pool.sandbox_pool.name
          volume = libvirt_volume.sandbox_opnsense_disk.name
        }
      }
    ]
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            # OPNsense acts as a client towards `ap_greenzone` which serves IPs
            # over the 192.168.88.0/24 subnet, thus getting the next address 192.168.88.11
            network = libvirt_network.sandbox_network_wan.name
            ip = "192.168.88.11"
          }
        }
      },
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            # OPNsense acts as the router for the entire network
            network = libvirt_network.sandbox_network_lan.name
            ip = "14.88.0.10"
          }
        }
      }
    ]
  }
}

# -------------------------------
#   PVE
# ------------------------------- 

# TODO: 
