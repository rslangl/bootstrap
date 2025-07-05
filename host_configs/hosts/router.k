# hosts/router.k

import common
import schemas.router_config

router: router_config.RouterConfig = {
  hostname: "router",
  ip: "14.88.0.1"
  ssh_port: common.common_config.ssh_port,
  localdomain: common.common_config.localdomain,
  config_file: "/conf/config.xml",
  templates_dir: {
    "default" = "/usr/local/opnsense/service/templates/OPNsense-custom/"
    "custom" = "/usr/local/opnsense/service/templates/OPNsense"
  }
  interfaces: [
    {
      iface_name: "igc0"
      role: "WLAN"
      use_dhcp: True
      static_ip: None
    }
  ]
}
