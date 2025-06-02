# test

Spins up a local sandbox for testing the IaC contained in the parent directory using libvirt.

## Requirements
* `libvirt`
* `libvirt-daemon`
* `libvirt-daemon-qemu`

## Usage 

### Provision with Terraform

The dmacvicar/libvirt provider is used to provision a sandbox infrastructure. Simply run:
```shell
$ terraform validate
$ terraform plan -out plan
$ terraform apply plan
```


### Access VMs

Once running, get the VNC display number, and connect:
```shell
# lists running VMs
$ sudo virsh list
 Id   Name         State
--------------------------------
 1    pve          running

# get the VNC display number
$ sudo virsh vncdisplay pve-local 
127.0.0.1:0

# connect
$ vncviewer :0
```

