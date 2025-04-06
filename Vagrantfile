Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"
  config.vm.provider "qemu" do |qemu|
    qemu.qemu_dir = `dirname $(which qemu-system-x86_64)`.chomp
    qemu.arch = "x86_64"
    qemu.machine = "q35"  # emulate a modern intel-based chipset with PCIe support
    qemu.memory = 4096
    qemu.cpu = "max"  # use full feature set and max performance of the host CPU
    qemu.net_device = "virtio-net-pci"
    #qemu.ssh_port = 5555 # use different port for the QEMU instance
    qemu.disk_size = 64_000
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".vagrant/"
  config.vm.boot_timeout = 400
  #config.vm.network "forwarded_port", guest: 22, host: 5555

  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive

    apt update && apt upgrade -y

    apt-get install -y wget gnupg2 curl lsb-release

    echo "deb http://download.proxmox.com/debian/pve jessie pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
    curl -fsSL https://enterprise.proxmox.com/debian/proxmox-ve-release-6.x.gpg | tee /etc/apt/trusted.gpg.d/proxmox.asc

    apt-get update -y

    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
    echo "postfix postfix/mailname string 'proxmoxer.local'" | debconf-set-selection

    apt-get install -y proxmox-ve postfix open-iscsi

    systemctl enable pvedaemon
    systemctl start pvedaemon
    systemctl enable pve-cluster
    systemctl start pve-cluster

    reboot
  SHELL
end
