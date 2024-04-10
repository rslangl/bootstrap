#!/bin/sh

# Install C++ tools
apt install -y \
	gcc \
	g++ \
	valgrind \
	gdb \
	clangd \
	libtool

# Install vpckg
mkdir /opt/vcpkg
git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg
chown -R user:user /opt/vcpkg
cd /opt/vcpkg && ./bootstrap-vcpkg.sh -disableMetrics
ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg

# TODO: Install virtualization tools
# VirtualBox
# Dokcer

# Install IaC tools
apt install -y \
	ansible \
	vagrant

# Install packages required for neovim
apt install -y \
	luajit \
	ripgrep \
	unzip

# Install neovim from source
git clone https://github.com/neovim/neovim /home/user/src && cd /home/user/src/neovim
make CMAKE_BUILD_TYPE=Release && make install
