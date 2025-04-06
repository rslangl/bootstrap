{ pkgs ? import ./nixpkgs.nix }:

  let tools = with pkgs; [
    docker
    ansible
    vagrant
    terraform
    python3
  ];

  in pkgs.mkShell {
    packages = tools;
    inputsFrom = with pkgs; tools;

    shellHook = ''

      source ./sbin/* > /dev/null 2>&1

      function terminate() {
        if [ "$(id -u)" -ne 0 ]; then
          echo "Superuser privileges required"
          read -p "Press enter to run as sudo, or Ctrl+C to cancel"
          sudo bash -c "$(declare -f shutdown_docker); shutdown_docker"
        else
          eval "$1"
        fi
      }

      trap 'terminate;' SIGTERM SIGINT EXIT

      echo ""
      echo "Working in nix-shell environment, usage:"
      echo -e "  start_docker:\t\tStarts the docker daemon"
      echo -e "  generate_ssh_key:\tGenerates an SSH key to ./ssh"
      # TODO: aliases for running lengthy ansible and terraform commands, with instructions printed here
      '';
  }
