Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian12"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    if ENV['BOOTSTRAP_ENABLE_GUI'] == 'true'
      vb.gui = true
      # config.vm.network "forwarded_port", guest: 3389, host: 3389
    else
      config.vm.network "private_network". type: "dhcp"
    end
  end

  config.vm.synced_folder Dir.pwd, "/upload"

  config.vm.provision "shell", inline: <<-SHELL
    useradd -m -s /bin/sh user
    echo "user:user" | chpasswd
    usermod -aG sudo user

    # Ensure user can run sudo without prompt
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

    mkdir -p /home/user/Downloads

    cp -r /upload/* /home/user/Downloads
    chown -R user:user /home/user/Downloads

    sudo -i /home/user/Downloads/bootstrap.sh
  SHELL
end
