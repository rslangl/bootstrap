#!/bin/sh

# Install base tools
apt install -y \
	make \
	autoconf \
	python3-pip \
	libssl-dev

# Install CMake
mkdir /home/user/src/cmake
curl -sSL https://github.com/Kitware/CMake/releases/download/v3.28.1/cmake-3.28.1.tar.gz | tar -xz --strip-components=1 -C /home/user/src/cmake && cd /home/user/src/cmake
./bootstrap && make && make install
