#!/bin/sh

set -e

# Change the mirror when needed, eg:
# sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/nz.archive.ubuntu.com\/ubuntu\//' /etc/apt/sources.list

# Update apt cache
apt update --fix-missing

# Install gosu for switching from root to regular user in entrypoint.sh
apt install -y openssh-server gosu
mkdir /var/run/sshd

# Change the dummy username in entrypoint.sh
sed -i "s/DUMMY_USERNAME/${USERNAME}/g" /entrypoint.sh

# Clean up
apt clean && rm -rf /var/lib/apt/lists/*
