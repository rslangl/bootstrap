#!/bin/bash

function generate_ssh_key() {
  echo "Generating SSH key..."

  mkdir ssh
  ssh-keygen -t rsa -b 4096 -f ssh/id_rsa -N "" -q

  echo "Done!"
}
