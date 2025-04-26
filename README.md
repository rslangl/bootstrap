# bootstrap

Bootable environment to bootstrap my infrastructure.

## Usage

Local development:
```shell
# Launch nix shell
nix-shell

# Starts Docker service
start_docker

# Generate SSH key
generate_ssh_key

# Add host to environment
add_host
$ Hostname: appsrv
$ IPv4: 10.0.0.2
```
For local, virtualized testing:
```shell
# launch Vagrant:
vagrant up --provider=qemu

# use dev workspace
terraform workspace select dev
terraform apply -var-file=dev.tfvars
```

## TODO

### Disks on appsrv

* 2 disks, ext4, RAID1, for OS
* RAIDZ2 on remaining disks for workloads

### SDN

* VXLAN `vnet-k8s-workers` for k8s worker nodes
* VXLAN `vnet-k8s-control` for k8s control plane nodes
* Bridge or NAT `vnet-ingress` for exposing the k8s cluster
* VXLAN `vnet-admin` for jump hosts/monitoring
