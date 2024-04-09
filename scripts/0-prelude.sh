#!/bin/sh

# Install required tools
apt install -y \
	git \
	python3

# Clone and setup dotfiles
git clone https://github.com/rslangl/dotfiles /home/user/.dotfiles && cd /home/user/.dotfiles
./install.sh
