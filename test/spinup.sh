#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${ROOT_DIR}/images"
DISKS_DIR="${ROOT_DIR}/test/vm_disks"

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
  IFS="|" read -r osinfo ram vcpu disk ip mac iso <<<"${HOSTS[$host]}"

  echo "Spinning up $host..."

  virt-install \
    --connect qemu:///session \
    --osinfo "$osinfo" \
    --name "${host}-local" \
    --ram "$ram" \
    --vcpus "$vcpu" \
    --cdrom "$iso" \
    --disk path="${DISKS_DIR}/$host".qcow2,format=qcow2,size="$disk" \
    --graphics vnc \
    --network user,model=virtio \
    --wait 0 \
    --noautoconsole
  #--console pty,target_type=serial

done
