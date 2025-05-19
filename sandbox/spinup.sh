#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${ROOT_DIR}/images"
DISKS_DIR="${ROOT_DIR}/sandbox/vm_disks"

NETWORK_NAME="testnet"

declare -A HOSTS

# structure: osinfo, RAM, CPU, disk size, static IP, MAC, ISO-file
HOSTS=(
  [pve]="debian12|2048|2|10|192.168.100.10|52:54:00:aa:bb:01|${IMAGES_DIR}/pve-auto.iso"
)

# start per-user session socket
virsh --connect qemu:///session list

# checks whether the test network is running
# if virsh --connect qemu:///session net-info "$NETWORK_NAME" &>/dev/null; then
#   echo "Test network $NETWORK_NAME exists"
#   if virsh --connect qemu:///session net-info "$NETWORK_NAME" | grep -q '^Active:\s*yes'; then
#     echo "Test network $NETWORK_NAME is running"
#   else
#     echo "Test network $NETWORK_NAME not running, starting..."
#     virsh --connect qemu:///session net-start "$NETWORK_NAME"
#   fi
# else
#   echo "Test network $NETWORK_NAME does not exist, creating..."
#   virsh --connect qemu:///session net-define "${ROOT_DIR}/test/testnet.xml"
#   virsh --connect qemu:///session net-autostart testnet
#   virsh --connect qemu:///session net-start testnet
# fi

# iterates list of VMs and ensures they are in a started state
for host in "${!HOSTS[@]}"; do
  IFS="|" read -r osinfo ram vcpu disk_size ip mac iso <<<"${HOSTS[$host]}"

  if [ ! -e "${DISKS_DIR}/$host".qcow2 ]; then
    echo "VM disk does not exist, creating..."
    qemu-img create -f qcow2 "${DISKS_DIR}/$host".qcow2 "${disk_size}G"
  fi

  echo "Spinning up $host..."

  # TODO: ensure nested virtualization is enabled:
  # cat /sys/module/kvm_intel/parameters/nested  # For Intel
  # cat /sys/module/kvm_amd/parameters/nested    # For AMD
  # If not enabled:
  # sudo tee /etc/modprobe.d/kvm.conf <<EOF
  # options kvm_intel nested=1
  # EOF
  # sudo modprobe -r kvm_intel && sudo modprobe kvm_intel
  virt-install \
    --connect qemu:///session \
    --osinfo "$osinfo" \
    --name "${host}-local" \
    --ram "$ram" \
    --vcpus "$vcpu" \
    --cdrom "$iso" \
    --disk path="${DISKS_DIR}/$host".qcow2,format=qcow2,size="$disk_size" \
    --boot cdrom,hd \
    --graphics vnc \
    --network user,model=virtio \
    --wait 0 \
    --noautoconsole
  #--console pty,target_type=serial

done

# TODO:
# 1. virsh managedsave-remove <vm>
# 2. virsh undefine <vm> --nvram (where nvram is used for UEFI systems)
# 3. virsh destroy <vm>
