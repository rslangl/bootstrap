#!/bin/sh

# Install zsh
apt install -y zsh fzf

# Setup global zshenv settings
cat <<EOF >/etc/zsh/zshenv
if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
then
  export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
fi

# XDG paths
export XDG_DATA_HOME=${XDG_DATA_HOME:="$HOME/.local/share"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="$HOME/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="$HOME/.config"}
export XDG_STATE_HOME=${XDG_STATE_HOME:="$HOME/.local/state"}

# XDG system directories
export XDG_DATA_DIRS=${XDG_DATA_DIRS:="/usr/local/share:/usr/share"}
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:="/etc/xdg"}

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME"/zsh
export HISTFILE="$XDG_STATE_HOME"/zsh/history
EOF

# Ensure X starts properly from global zprofile using the picom X compositor (used for st)
cat <<EOF >/etc/zsh/zprofile
if [[ -z "$DISPLAY" ]] && [[ &(tty) = /dev/tty1 ]]; then
  picom -b &
  startx
fi
EOF

# Install fonts
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inconsolata.tar.xz | tar -xf Inconsolata.tar.xz -C /home/user/.local/share/fonts

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

# Install zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
