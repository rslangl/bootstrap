# test

Spins up a local sandbox for testing the IaC contained in the parent directory.

Build image:
```shell
docker build -t proxmox-iso-builder -f Dockerfile.pve-autoinstaller-builder .
```

Run image:
```shell
docker run --rm \
  -v "$(pwd)/../images/pve.iso:/build/pve.iso:ro" \
  -v "$(pwd)/answer.toml:/build/answer.toml:ro" \
  -v "$(pwd)/output:/build/output" \
  proxmox-iso-builder /build/pve.iso --fetch-from iso --answer-file /build/answer.toml \
  --output /build/output/pve-auto.iso
```

Or, just use the convenience scripts...
