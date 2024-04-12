#!/bin/sh

# Install i3
apt install -y i3

# Install rofi packages
apt install -y \
	rofi \
	ddgr \
	libjson-glib-dev \
	libcairo2-dev \
	rofi-dev

# Create rofi-search-box wrapper script
echo "#!/bin/sh \
  export DDG_ARGS='["-n", 5]' \
  export ROFI_SEARCH='ddgr' \
  rofi -modi blocks -blocks-wrap $HOME/.local/bin/rofi-search -show blocks -lines 4 -eh 4 -kb-custom-1 'Control+y'" | tee /home/user/.local/bin/rofi-search-box >/dev/null && chmod +x /home/user/.local/bin/rofi-search-box

# Install rofi-blocks
git clone https://github.com/OmarCastro/rofi-blocks /home/user/src/rofi-blocks && cd /home/user/src/rofi-blocks
autoreconf -i && mkdir build && cd build/ && ../configure && make && make install && libtool

# Install i3lock-color dependencies
apt install -y \
	autoconf \
	gcc \
	make \
	pkg-config \
	libpam0g-dev \
	libcairo2-dev \
	libfontconfig1-dev \
	libxcb-composite0-dev \
	libev-dev \
	libx11-xcb-dev \
	libxcb-xkb-dev \
	libxcb-xinerama0-dev \
	libxcb-randr0-dev \
	libxcb-image0-dev \
	libxcb-util0-dev \
	libxcb-xrm-dev \
	libxkbcommon-dev \
	libxkbcommon-x11-dev \
	libjpeg-dev

# Install custom i3 lockscreen
apt purge i3lock
git clone https://github.com/Raymo111/i3lock-color /home/user/src/i3lock-color && cd /home/user/src/i3lock-color
./install-i3lock-color.sh

# Install polybar
curl -sSL https://github.com/polybar/polybar/releases/download/3.7.1/polybar-3.7.1.tar.gz | tar -xz --strip-components=1 -C /home/user/src/polybar && cd /home/user/src/polybar
./build.sh
