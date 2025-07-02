# hosts/router.k

import common
import schemas.router_config

router: router_config.RouterConfig = {
  hostname: "ruuuuuuuter",
  ip: "14.88.0.1"
  ssh_port: common.common_config.ssh_port,
  localdomain: common.common_config.localdomain,
  config_file: "/conf/config.xml",
}
