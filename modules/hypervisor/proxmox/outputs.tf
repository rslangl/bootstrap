output "k8s_control_node" {
  value = {
    for k, v in proxmox_virtual_environment_vm.vm :
    k => {
      name = v.name
      id   = v.vmid
      node = v.target_node
    }
  }
}
