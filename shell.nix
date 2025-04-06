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
      DOCKER_PID=""

      declare -A hosts

      function shutdown_docker() {
        echo "Shutting down containers..."

        if [ "$(docker ps -a -q | wc -l)" -gt 0 ]; then
          # stops all containers 
          docker stop $(docker ps -a -q)

          # force remove all containers and associated volumes
          docker container rm -vf $(docker ps -a -q)

          # force remove all images
          docker rmi -f $(docker images -aq)
        fi

        if [ ! -z "$DOCKER_PID" ]; then
          if [ "$(ps -p "$DOCKER_PID" > /dev/null 2>&1)" ]; then
            # terminate docker service
            kill $DOCKER_PID
          fi
        fi

        echo "Done!"
      }

      function start_docker() {

        echo "Starting docker daemon..."

        sudo nohup dockerd > /tmp/dockerd.log 2>&1 &
        DOCKER_PID=$(echo $! | awk '{$1=$1};1')

        echo "Done!"
      }

      function add_host() {
        read -p "Hostname: " hostname
        read -p "IPv4: " ip
        hosts["$hostname"]="$ip"
      }

      function generate_ssh_key() {
        echo "Generating SSH key..."

        mkdir ssh
        ssh-keygen -t rsa -b 4096 -f ssh/id_rsa -N "" -q

        echo "Done!"
      }

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
