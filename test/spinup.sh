#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${ROOT_DIR}/images"

NETWORK_NAME="testnet"

declare -A HOSTS

HOSTS=(
  [pve]="2048|2|192.168.100.10|52:54:00:aa:bb:01|${IMAGES_DIR}/pve-auto.iso"
)

# checks whether the test network is running
if virsh net-info "$NETWORK_NAME" &> /dev/null; then
  echo "Test network $NETWORK_NAME exists"
  if virsh net-info "$NETWORK_NAME" | grep -q '^Active:\s*yes'; then
    echo "Test network $NETWORK_NAME is running"
  else
    echo "Test network $NETWORK_NAME not running, starting..."
    virsh net-start "$NETWORK_NAME"
  end
else
  virsh net-define "${SCRIPT_DIR}/testnet.xml"
  virsh net-autostart testnet
  virsh net-start testnet
end

# iterates list of VMs and ensures they are in a started state
for host in "${!HOSTS[@]}"; do
  IFS="|" read -r ram vcpu ip mac iso <<<"${HOSTS[$host]}"

  #qemu-img create -f qcow2 $host.qcow2 10G

  virt-install \
    --osinfo debian12 \
    --name "${host}-local" \
    --ram "$ram" \
    --vcpus "$vcpu" \
    --disk path="$host".qcow2 \
    --cdrom "$iso" \
    --graphics none \
    --network network=testnet,mac=$mac \
    --console pty,target_type=serial
  #--extra-args 'console=ttyS0,115200n8 serial'

done
