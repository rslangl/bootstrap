#!/bin/sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
. "$SCRIPT_DIR/../configs/pkg_versions.sh"

# Install base tools
apt install -y \
	make \
	autoconf \
	python3-pip \
	libssl-dev

# Install CMake
mkdir /home/user/src/cmake
curl -sSL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz | tar -xz --strip-components=1 -C /home/user/src/cmake && cd /home/user/src/cmake
./bootstrap && make && make install
