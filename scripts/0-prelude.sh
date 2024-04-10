#!/bin/sh

# Install required tools
apt install -y \
	git \
	tar \
	python3

# Create required directories
mkdir /home/user/src
chown -R user:user /home/user/src

# Clone and setup dotfiles
#git clone https://github.com/rslangl/dotfiles /home/user/.dotfiles && cd /home/user/.dotfiles
#./install
