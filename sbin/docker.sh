#!/bin/bash

DOCKER_PID=""

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
    if [ "$(ps -p "$DOCKER_PID" >/dev/null 2>&1)" ]; then
      # terminate docker service
      kill $DOCKER_PID
    fi
  fi

  echo "Done!"
}

function start_docker() {

  echo "Starting docker daemon..."

  sudo nohup dockerd >/tmp/dockerd.log 2>&1 &
  DOCKER_PID=$(echo $! | awk '{$1=$1};1')

  echo "Done!"
}
