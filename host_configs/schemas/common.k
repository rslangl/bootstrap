# schemas/common.k

schema NetworkInterface:
  iface_name: str

schema CommonConfig:
  hostname: str
  ip: str
  ssh_port: int
  localdomain: str
  interfaces: [NetworkInterface]
