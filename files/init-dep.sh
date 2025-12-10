#!/bin/bash
set -e

# Change the mirror when needed, eg:
# sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/nz.archive.ubuntu.com\/ubuntu\//' /etc/apt/sources.list

# Update apt cache
apt update --fix-missing
apt install -y apt-utils sudo

# Configure the timezone when needed, eg:
# ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata

# Configure the locale
# https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
apt install -y locales-all locales
locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Install some basic tools
apt install -y curl vim git git-lfs

# Fix the keyrings issue of the nVidia CUDA container
curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/3bf863cc.pub | tee /etc/apt/keyrings/nvidia.pub > /dev/null
sed -i 's|^deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64 /|deb [signed-by=/etc/apt/keyrings/nvidia.pub] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64 /|g' /etc/apt/sources.list.d/cuda.list

# Clean up
apt clean && rm -rf /var/lib/apt/lists/*
