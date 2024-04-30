#!/bin/sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
. "$SCRIPT_DIR/../configs/fonts.sh"

# Install zsh
apt install -y zsh fzf

# Setup global zshenv settings
cat <<EOF >/etc/zsh/zshenv
if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
then
  export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games
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

# Xorg-auth
#export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority

# Xorg
#export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
#export XSERVERRC="$XDG_CONFIG_HOME"/X11/xserverrc
#export XAUTHORITY="$XDG_RUNTIME_DIR"/X11/xauthority
EOF

# Ensure X starts properly from global zprofile using the picom X compositor (used for st)
#cat <<EOF >/etc/zsh/zprofile
# if [[ -z "$DISPLAY" ]] && [[ &(tty) = /dev/tty1 ]]; then
#   picom -b &
#   startx
# fi
# EOF

# Install fonts
oldIFS="$IFS"
IFS=":"
for font in $fonts; do
	case "$font" in
	*tar.xz)
		curl -OL https://github.com/ryanoasis/nerd-fonts/releases/download/$font | tar -xf $font -C /home/user/.local/share/fonts
		;;
	*zip)
		curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font -o /home/user/Downloads/$font
		unzip /home/user/Downloads/$font -d /home/user/.local/share/fonts
		rm /home/user/Downloads/$font
		;;
	esac
done
#curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inconsolata.tar.xz | tar -xf Inconsolata.tar.xz -C /home/user/.local/share/fonts
IFS="$oldIFS"

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

# Install tmux
apt install -y tmux
git clone https://github.com/tmux-plugins/tpm /home/user/.config/tmux/plugins/tpm
