#!/bin/bash

set -ex

VM_LIST=$(virsh --connect qemu:///session list --all --name | grep -v '^$')

for vm in $VM_LIST; do
  echo "Stopping and removing VM: $vm"

  if virsh --connect qemu:///session domstate "$vm" | grep -q running; then
    virsh --connect qemu:///session destroy "$vm"
  fi

  virsh --connect qemu:///session undefine "$vm" --remove-all-storage
done
