# Ansible Collection - bootstrap

## Pre-provisioning

Some tasks are not easily automated for a so-called "black start". These are outlined with a short description below.

### Router (OPNsense)

* Device assignments is not exposed through the existing API. Set `igc0` to WAN and `igc1` to LAN.
* Once LAN and WAN are configured, setup DHCP client on the WAN, and static IPv4 on LAN.

### Application server (Proxmox)

* Temporary root access for user `ansible`. Then, copy the public SSH key to `/home/ansible/.ssh/authorized_keys`:

```shell
# Manually in PVE
useradd -m -s /bin/bash ansible
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible-temp
chmod 440 /etc/sudoers.d/ansible-temp
```

## Collection description

* `roles/`: Generic tasks with support for the various OS'es in use.
* `playbooks/`: Roles composition based on host roles.

## References

* [oxlorg.opnsense on Ansible Galaxy](https://galaxy.ansible.com/ui/repo/published/oxlorg/opnsense/docs)
