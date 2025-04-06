#!/bin/bash

declare -A hosts

function add_host() {
  read -p "Hostname: " hostname
  read -p "IPv4: " ip
  hosts["$hostname"]="$ip"
}
