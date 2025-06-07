let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
  }) {
    config.allowUnfree = true;
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
              }).fd];
        };
      };
    };
    #virtualisation.virtualbox.host.enable = true;
    #virtualisation.virtualbox.host.enableExtensionPack = true;
  };
in pkgs
