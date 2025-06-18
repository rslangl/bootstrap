# Router

Provisioning of an OPNSense router, additionally used as the authoritative DNS for the internal network which is setup as a split-horizon DNS configuration.

## TODO

* Setup interfaces, each with their own IP subnets
  * `igc0`: Internet facing
  * `igc1`: Internal facing
  * `igc2`: DMZ
* Setup authoritative DNS with Unbound
  * Use DNSSEC and IPSec
* Configure firewall
  * SSH and web-GUI only available via `igc1`
