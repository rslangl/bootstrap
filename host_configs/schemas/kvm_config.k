# schemas/kvm_config.k

import schemas.common

schema LiveSystemConfig:
  network_device: str
  ip: str

schema KVMConfig(common.CommonConfig):
  live_system: LiveSystemConfig
