#!/bin/sh

spinner() {
	local pid=$1
	local delay=0.1
	local spinstr='|/-\'

	while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
		local temp=${spinstr#?}
		printf " [%c] " "$spinstr"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\r"
	done
	printf "\t\r"
}
