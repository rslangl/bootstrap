# Ansible Collection - bootstrap

## Router

Using OPNsense, the device assignments is not exposed through the existing API. Thus, to assign LAN to `igc1`
and WAN to `igc0`, manual interaction is required. These will also need manual handling for setting DHCP
client on the WAN, and static IPv4 on LAN.

## References

* [oxlorg.opnsense on Ansible Galaxy](https://galaxy.ansible.com/ui/repo/published/oxlorg/opnsense/docs)
