# Hypervisor

Provisioning of a Proxmox VE instance.

## TODO

* Setup 2 OS disk with ext4 in RAID1
* Setup data disks in RAIDZ-2
* Setup SDNs:
  * VXLAN `vnet-k8s-workers` for k8s worker nodes
  * VXLAN `vnet-k8s-control` for k8s control plane nodes
  * Bridge or NAT `vnet-ingress` for exposing the k8s cluster (take into account the reverse proxy)
  * VXLAN `vnet-admin` for jump hosts/monitoring
