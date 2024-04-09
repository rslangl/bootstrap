#!/bin/sh

# Create directory where sources will be stored to
mkdir /home/user/src
chown -R user:user /home/user/src

# Install base tools
apt install -y \
	make \
	autoconf \
	python3-pip

# Install CMake
mkdir /home/user/src/cmake
curl -sSL https://github.com/Kitware/CMake/releases/download/v3.28.1/cmake-3.28.1.tar.gz | tar -xz --strip-components=1 -C /home/user/src/cmake && cd /home/user/src/cmake
./bootstrap && make && make install
