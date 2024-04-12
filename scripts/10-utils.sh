#!/bin/sh

# Add repo for glow (markdown renderer)
curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list >/dev/null
apt update
#
# Install packages avaialable through apt
apt install -y \
	btop \
	glow
