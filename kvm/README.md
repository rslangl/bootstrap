# kvm

Provisioning of a PiKVM 4 Plus.

## TODO

* Setup user account
  * Change password `kvmd-htpasspwd set admin`
  * Get USB configuration (OTG) with `kvmd-otgconf` and register what device to use, e.g.:
  ```shell
  + hid.usb0  # Keyboard
  + hid.usb1  # Absolute mouse
  + hid.usb2  # Relative mouse
  ```
* Enable toggling between local and remote with:
```shell
# kvmd-otgconf --enable-function hid.usb0 --enable-function hid.usb1
# kvmd-otgconf --disable-function hid.usb0 --disable-function hid.usb1
```

