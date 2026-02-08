resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"
  url          = ""
  file_name    = "talos.iso"
}

resource "proxmox_virtual_environment_vm" "k8s_controller" {
  for_each = var.k8s_controller_node

  name        = each.value.name
  description = "K8s controller node"
  tags        = ["terraform", "k8s", "control-plane"]

  node_name = each.value.node
  vm_id     = each.value.vmid

  agent {
    enabled = true
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  bios = ovmf

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
    # Disables ballooning
    floating = 0
  }

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.talos_image
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "q35"
  }

  tpm_state {
    version = "v2.0"
  }

  serial_device {}

  virtiofs {

  }
}

resource "proxmox_virtual_environment_vm" "k8s_worker" {
  for_each = var.k8s_worker_node

  name        = each.value.name
  description = "K8s worker node"
  tags        = ["terraform", "k8s", "data-plane"]

  node_name = each.value.node
  vm_id     = each.value.vmid

  agent {
    enabled = true
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  bios = ovmf

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
    # Disables ballooning
    floating = 0
  }

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.talos_image
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "q35"
  }

  tpm_state {
    version = "v2.0"
  }

  serial_device {}

  virtiofs {

  }
}
