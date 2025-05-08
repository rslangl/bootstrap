#!/bin/bash

set -ex

apt update -y && apt install qemu-guest-agent

systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent
