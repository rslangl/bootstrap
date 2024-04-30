#!/bin/sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
. "$SCRIPT_DIR/../configs/pkg_versions.sh"

mkdir /home/user/src
SRC_ROOT=/home/user/src

git clone git://git.suckless.org/scroll /home/user/src/scroll && cd /home/user/src/scroll
cp "$SCRIPT_DIR/../src/scroll/config.h" .
make clean install
mv /usr/local/bin/scroll /usr/bin/scroll

cd $SRC_ROOT

curl -OL https://dl.suckless.org/st/st-${ST_VERSION}.tar.gz | tar -xzf st-${ST_VERSION}.tar.gz -C /home/user/src/st --strip-components=1 && cd /home/user/src/st
cp "$SCRIPT_DIR/../src/st/config.h" .
make clean install
mv /usr/local/bin/st /usr/bin/st

# Change terminal
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/st 10
update-alternatives --set x-terminal-emulator /usr/bin/st
