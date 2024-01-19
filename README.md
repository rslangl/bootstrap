# dotfiles

## Fresh install on barebones Debian 12

Install sudo and add myself
```shell
su 
apt install sudo usermod
/usr/sbin/usermod -a -G sudo rune
su rune
```

Run playbook
```shell
./tools/ansible-playbook playbook.yaml -i inventory.ini -K
```

Reboot and do something that is actually productive

## References

* [XDG base directory](https://wiki.archlinux.org/title/XDG_Base_Directory)
* [Zsh](https://wiki.debian.org/Zsh)
* [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
* [NvidiaGraphicsDriver](https://wiki.debian.org/NvidiaGraphicsDrivers)
* [NvidiaGraphicsDriver: Configuration](https://wiki.debian.org/NvidiaGraphicsDrivers/Configuration)
