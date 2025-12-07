#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CACHE_DIR="${ROOT_DIR}/.cache"
DOCKER_PID=""

function shutdown_docker() {

  if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
  fi

  echo "Shutting down containers..."

  if [ "$(docker ps -a -q | wc -l)" -gt 0 ]; then
    # stops all containers
    docker stop "$(docker ps -a -q)"

    # force remove all containers and associated volumes
    docker container rm -vf "$(docker ps -a -q)"

    # force remove all images
    docker rmi -f "$(docker images -aq)"
  fi

  if [ -n "$DOCKER_PID" ]; then
    if ps -p "$DOCKER_PID" &>/dev/null; then
      # terminate docker service
      kill "$DOCKER_PID"
    fi
  fi

  echo "Done!"
}

function start_docker() {

  if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
  fi

  if ps -p "$DOCKER_PID" &>/dev/null; then
    echo "Docker already running"
  else
    echo "Starting docker daemon..."

    nohup dockerd >/tmp/dockerd.log 2>/dev/null &
    DOCKER_PID=$(echo $! | awk '{$1=$1};1')

    echo "Done!"
  fi
}

function generate_ssh_key() {
  echo "Generating SSH key..."

  mkdir -p "$CACHE_DIR}/ssh"

  ssh-keygen -t rsa -b 4096 -f "${CACHE_DIR}"/ssh/id_rsa -N "" -q

  echo "Done!"
}
