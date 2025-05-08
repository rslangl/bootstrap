# test

Spins up a local sandbox for testing the IaC contained in the parent directory using libvirt.

## Requirements
* `libvirt`
* `libvirt-daemon`
* `libvirt-daemon-qemu`

## Usage 

### Build PVE

Build PVE autoinstaller image with Docker:
```shell
docker build -t proxmox-iso-builder -f Dockerfile.pve-autoinstaller-builder .
```

Run image to build image:
```shell
docker run --rm \
  -v "$(pwd)/../images/pve.iso:/build/pve.iso:ro" \
  -v "$(pwd)/answer.toml:/build/answer.toml:ro" \
  -v "$(pwd)/output:/build/output" \
  proxmox-iso-builder /build/pve.iso --fetch-from iso --answer-file /build/answer.toml \
  --output /build/output/pve-auto.iso
```

Where:
* `pve.iso` is the ISO fetched from Proxmox
* `answer.toml` is the configuration file seeded to the PVE autoinstaller
* `output/` is the path to which the autoinstaller image will be placed

### Run VMs

Run:
```shell
./spinup.sh
```

Once running, get the VNC display number, and connect:
```shell
# lists running VMs
$ virsh --connect qemu:///session list
 Id   Name         State
--------------------------------
 1    pve-local    running

# get the VNC display number
$ virsh --connect qemu:///session vncdisplay pve-local 
127.0.0.1:0

# connect
$ vncviewer :0
```


## Troubleshooting

### Docker

I couldn't be bothered to do permission checks on users, so just give yourself privileges to run Docker as a regular user:
```shell
sudo usermod -aG docker $USER
```

### libvirt

Libvirt runs in two modes; namely system session and user session, of which we use the latter to avoid needing to run scripts as sudo.

First, the test network we use is to provide a supported mode for user session mode, namely user-mode networking (slirp) or macvtap, which does not support `bridge` or `nat` with `virbr0`. Thus, this is solved as easily as to simply not define one, but pass the parameter `--network user` to `virt-install`, as shown below.

The per-user session socket can be started by executing the following:
```shell
virsh --connect qemu:///session list
```

Then, you may perform a dry-run to check whether the session mode is working:
```shell
virt-install --connect qemu:///session \
  --name testvm \
  --memory 512 \
  --vcpus 1 \
  --disk size=5 \
  --cdrom ../images/pve.iso \
  --network user \
  --dry-run
```
