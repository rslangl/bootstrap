# schemas/common.k

type NetworkInterfaceRole = "WLAN" | "LAN"

schema StaticIPConfig:
  ip: str
  netmask: str = "255.255.255.0"

schema NetworkInterface:
  iface_name: str
  role: NetworkInterfaceRole
  use_dhcp: bool
  static_ip?: StaticIPConfig = None

schema CommonConfig:
  hostname: str
  ip: str
  ssh_port: int
  localdomain: str
  interfaces: [NetworkInterface]
