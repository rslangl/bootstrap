#!/bin/sh

start_spinner() {
  spinner='/|\\-/|\\-'
  while :; do
    for i in $(seq 0 7); do
      printf "\r${spinner:$i:1}"
      sleep 0.1
    done
  done
}

stop_spinner() {
  kill "$1" > /dev/null 2>&1
  wait "$1" 2>/dev/null
  printf "\r%s" " "
}
