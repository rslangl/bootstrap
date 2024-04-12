#!/bin/sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
. "$SCRIPT_DIR/../configs/pkg_versions.sh"

# Install C++ tools
apt install -y \
	gcc \
	g++ \
	valgrind \
	gdb \
	clangd \
	libtool \
	gettext

# Install vpckg
mkdir /opt/vcpkg
git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg
chown -R user:user /opt/vcpkg
cd /opt/vcpkg && ./bootstrap-vcpkg.sh -disableMetrics
ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg

# Install Rust
curl --proto '=https' --tlsv1.2 -sSF https://sh.rustup.rs | sh

# Install Go
curl https://go.dev/dl/go${GO_VERSION}.darwin-amd64.tar.gz | tar -xzf go${GO_VERSION}.darwin-amd64.tar.gz -C /usr/local

# Install VirtualBox
curl -sSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor -o /etc/apt/keyrings/virtualbox.gpg && apt-key add /etc/apt/keyrings/virtualbox.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian bookworm contrib" | tee /etc/apt/sources.list.d/virtualbox.list >/dev/null
apt update
apt install -y virtualbox-${VIRTUALBOX_VERSION}

# Install Docker
aot install ca-certificates
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
apt update
apt install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

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
git clone https://github.com/neovim/neovim /home/user/src/neovim && cd /home/user/src/neovim
make CMAKE_BUILD_TYPE=Release && make install

# Install LazyVim
git clone https://github.com/LazyVim/starter /home/user/.config/nvim
rm -rf /home/user/.config/nvim/.git
cd /home/user/.dotfiles && ./install
