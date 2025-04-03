{ pkgs ? import ./nixpkgs.nix }:

  let tools = with pkgs; [
    docker
    ansible
    python3
  ];

  in pkgs.mkShell {
    packages = tools;
    inputsFrom = with pkgs; tools;

    shellHook = ''
      DOCKER_PID=""
      TARGET_IP=""

      function shutdown_docker() {
        # stops all containers 
        docker stop $(docker ps -a -q)

        # force remove all containers and associated volumes
        docker container rm -vf $(docker ps -a -q)

        # force remove all images
        docker rmi -f $(docker images -aq)

        # terminate docker service
        kill $DOCKER_PID
      }

      function start_docker() {
        nohup dockerd > /tmp/dockerd.log 2>&1 &
        DOCKER_PID=$!
      }
  
      trap 'ssh-keygen -R $CONTAINER_IP; "HOME"/.ssh/ sed -i '2s/.*/CONTAINER/' inventory;' EXIT SIGTERM SIGINT

      ssh-keygen -t rsa -b 4096 -f ssh/ssh -N "" -q
      '';
  }
