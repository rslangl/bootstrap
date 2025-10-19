# hosts/kvm.k 

import common
import schemas.kvm_config

kvm: kvm_config.KVMConfig {
  hostname: "kvm",
  ip: "14.88.0.2",
  ssh_port: common.common_config.ssh_port,
  localdomain: common.common_config.localdomain,
  interfaces: [
    {
      iface_name: "eth0"
      role: "LAN"
      use_dhcp: False
      static_ip: {
        ip: "14.88.0.2",
        netmask: "255.255.255.0"
      }
    }
  ],
  live_system: {
    network_device: "usb0"
    ip: "14.88.0.3"
  }
}
