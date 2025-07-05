# schemas/router_config.k

import schemas.common

schema RouterConfig(common.CommonConfig):
  config_file: str
  templates_dir: {str:str}
