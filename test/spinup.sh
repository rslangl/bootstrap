#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${ROOT_DIR}/images"

declare -A HOSTS

HOSTS=(
  [pve]="2048|2|192.168.100.10|52:54:00:aa:bb:01|${IMAGES_DIR}/pve-auto.iso"
)

# launch the network to be used by the VMs
virsh net-define test/testnet.xml
virsh net-autostart testnet
virsh net-start testnet

# launch VMs
for host in "${!HOSTS[@]}"; do
  IFS="|" read -r ram vcpu ip mac iso <<<"${IMAGES[$host]}"

  virt-install \
    --name "${host}-local" \
    --ram $ram \
    --vcpus $vcpu \
    --disk path="$iso",format=raw \
    --graphics none \
    --network network=testnet,mac=$mac \
    --console pty,target_type=serial \
    --extra-args 'console=ttyS0,115200n8 serial'

done
