let
  pkgs = import (builtins.fetchTarball {
    # renovate: datasource=github-tags depName=NixOS/nixpgs
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz";
  }) {
    config.allowUnfree = true;
  };
in pkgs
