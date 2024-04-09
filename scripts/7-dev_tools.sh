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

# Install IaC tools
apt install -y \
	ansible \
	vagrant

# TODO: Install neovim
