# schemas/router_config.k

import schemas.common

schema RouterConfig(common.CommonConfig):
  config_file: str
  # TODO: more configs specific for router as needed
