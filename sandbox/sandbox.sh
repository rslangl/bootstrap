#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${ROOT_DIR}/images"
DISKS_DIR="${ROOT_DIR}/sandbox/vm_disks"

declare -A HOSTS

# structure: osinfo, RAM, CPU, disk size, static IP, MAC, ISO-file
HOSTS=(
  [pve]="debian12|2048|2|10|192.168.100.10|52:54:00:aa:bb:01|${IMAGES_DIR}/pve-auto.iso"
)

usage() {
  echo "Usage: $0 [--list-vncs | --list-vms | --terminate | --launch <vmname>]"
  exit 1
}

LIST_VNCS=0
LIST_VMS=0
TERMINATE=0
LAUNCH=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
  --list-vncs)
    LIST_VNCS=1
    ;;
  --list-vms)
    LIST_VMS=1
    ;;
  --terminate)
    TERMINATE=1
    ;;
  --launch)
    LAUNCH=1
    ;;
  -h | --help)
    usage
    ;;
  *)
    echo "Unknown option: $1"
    usage
    ;;
  esac
  shift
done

if [[ "$LIST_VNCS" -eq 1 ]]; then
  echo "🖥️  Listing VNC displays for running VMs:"
  virsh --connect qemu:///session list --name | while read vm; do
    [ -z "$vm" ] && continue
    vnc_display=$(virsh --connect qemu:///session vncdisplay "$vm" 2>/dev/null)
    if [[ $vnc_display == :* ]]; then
      port=$((5900 + ${vnc_display#:}))
      echo "  VM: $vm"
      echo "    VNC display: $vnc_display"
      echo "    VNC port:    $port"
    else
      echo "  VM: $vm (no VNC available)"
    fi
  done
fi

if [[ "$LIST_VMS" -eq 1 ]]; then
  echo "📋 Listing all defined session VMs:"
  virsh --connect qemu:///session list --all
fi

if [[ "$TERMINATE" -eq 1 ]]; then
  echo "🧹 Terminating and removing all session VMs..."
  VM_LIST=$(virsh --connect qemu:///session list --all --name | grep -v '^$')
  for vm in $VM_LIST; do
    echo "  Removing VM: $vm"
    if virsh --connect qemu:///session domstate "$vm" | grep -q running; then
      virsh --connect qemu:///session destroy "$vm"
    fi
    virsh --connect qemu:///session undefine "$vm" --remove-all-storage
  done
fi

if [[ "$LAUNCH" -eq 1 ]]; then

  for host in "${!HOSTS[@]}"; do
    IFS="|" read -r osinfo ram vcpu disk ip mac iso <<<"${HOSTS[$host]}"

    echo "🚀 Launching VM: $VMNAME"

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

  done
fi
