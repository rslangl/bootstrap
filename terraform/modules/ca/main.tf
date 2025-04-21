resource "proxmox_virtual_environment_vm" "vm" {
  name = "ca"
  node_name = "wintermute"
  tags = ["terraform", "ca"]
  
  agent {
    enabled = true
  }

  bios = "ovmf"

  cpu {
    cores = var.vm_cores
    type = "x86-64-v2-AES"
    #flags = ["-cpu kvm64","+cx16","+lahf_lm","+popcnt","+sse3","+ssse3","+sse4.1","+sse4.2"]
  }

  memory {
    dedicated = var.vm_memory
  }

  disk {
    datastore_id = "local-zfs"
    file_id = "local:iso/alpine.img"
    interface = "virtio0"
    size = var.vm_disk
  }

  initialization {
    datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    #user_account {
    #  keys = [trimspace(tls_private_key.vm_key.public_key_openssh)]
    #  password = random_password.vm_password.result
    #  username = "herder"
    #}

  }

  #startup {
  #  order = "3"
  #  up_delay = "60"
  #  down_delay = "60"
  #}

  network_device {
    bridge = "vmbr0"
  }
}
