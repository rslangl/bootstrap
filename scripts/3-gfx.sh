#!/bin/sh

install_nvidia() {
	apt install -y linux-headers-amd64
	sed -i '/^deb http:\/\/deb.debian.org\/debian\/ bookworm main non-free-firmware contrib/ s/$/ non-free-firmware/' /etc/apt/sources.list
	apt update && apt install -y nvidia-driver firmware-misc-nonfree nvidia-xconfig
	echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINX nvidia-drm.modeset=1"' >/etc/default/grub.d/nvidia-modeset.cfg && update-grub
}

install_amd() {
	# https://wiki.debian.org/AtiHowTo
	echo "Not yet implemented"
}

if lspci | grep -E "VGA|3D" | grep -qi "nvidia"; then
	install_nvidia
elif lspci | grep -E "VGA|3D" | grep -qi "amd"; then #"amd\|ati"
	install_amd
else
	echo "No AMD or Nvidia GPU detected"
fi
