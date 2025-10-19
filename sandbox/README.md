# test

Spins up a local sandbox for testing the IaC contained in the parent directory using libvirt.

## Requirements

* `libvirt`
* `libvirt-daemon`
* `libvirt-daemon-qemu`
* `terraform`

The bridge created by libvirt is also required to use routed mode to enable VM-to-VM,
host-to-VM, and VM-to-internet connectivity all at once. Thus, for the host machine,
we need to configure:

* Enable IP forwarding (so traffic can route from VMs to the internet)
* Setup iptables MASQUERADE (so VM's traffic appears to come from the host)

## Preparation

Manual steps to setup the host:

```shell
# Temporarilly enable forwarding
$ sudo sysctl -w net.ipv4.ip_forward=1
# Permanently enable forwarding
$ echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-kvm.conf
$ sudo sysctl --system
# Add NAT rule via iptables (check interface)
$ sudo iptables -t nat -A POSTROUTING -s 192.168.50.0/24 -o wlan0 -j MASQUERADE
```

Automated setup using Ansible:

```shell
ansible-playbook host-setup.yaml --tags (default|setup|teardown)
```

Where:

* `default`: Does nothing, only signifies to the user that a tag is needed
* `setup`: Sets up forwarding on the host
* `teardown`: Reverses the configs from the `setup` tasks

## Usage

### Provision with Terraform

The [dmacvicar/libvirt](https://github.com/dmacvicar/terraform-provider-libvirt)
provider is used to provision a sandbox infrastructure. Simply run:

```shell
make validate
make plan
make apply
```

### Access VMs

Once running, get the VNC display number, and connect:

```shell
# Lists running VMs
$ sudo virsh list
 Id   Name         State
--------------------------------
 1    opnsense     running

# Get the VNC display number
$ sudo virsh vncdisplay --domain opnsense

# list VM info
$ sudo dominfo pve-local

# list attached disks
$ sudo domblklist pve-local
```

To connect, get the VNC display number:

```shell
# get the VNC display number
$ virsh vncdisplay pve-local 
127.0.0.1:0

# connect
$ vncviewer :0
```

Verify the VMs are assigned an IP from the virtual bridge:

```shell
# Lists all networks
$ sudo virsh net-list
Name      State    Autostart   Persistent
-------------------------------------------
default   active   yes         yes
sandbox   active   yes         yes

# Get DHCP leases
$ sudo virsh net-dhcp-leases --network sandbox
Expiry Time   MAC address   Protocol   IP address   Hostname   Client ID or DUID
-----------------------------------------------------------------------------------

```

To remove created resources:

```shell
make destroy
```
