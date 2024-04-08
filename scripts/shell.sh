#!/bin/sh

# Install zsh
apt install -y zsh

# Change login shell
chsh -s /usr/bin/zsh user

# Set ZDOTDIR globally
ZDOTDIR_LINE="export $ZDOTDIR=/home/user/.config/zsh"
if [ ! grep -qF "$ZDOTDIR_LINE" /etc/zsh/zshenv ]; then
	echo "$ZDOTDIR_LINE" >>/etc/zsh/zshenv
fi

# Install oh-my-zsh
mkdir /home/user/src/oh-my-zsh && cd /home/user/src/oh-my-zsh
curl -sSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod +x install.sh
ZSH=/home/user/.config/zsh/ohmyzsh sh install.sh

# Get zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH/custom/plugins
