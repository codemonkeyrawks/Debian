#!/bin/bash
## Install: Kernel (Free) ##

if grep -q '^backport*' /etc/apt/sources.list; then
echo ""
echo "Debian Backports Are Already Enabled"
echo ""
else
echo -e "
# stretch-backports
deb http://ftp.us.debian.org/debian/ stretch-backports main contrib non-free 
deb-src http://ftp.us.debian.org/debian/ stretch-backports main contrib non-free
" | sudo tee -a /etc/apt/sources.list > /dev/null
fi

sudo apt-get update

# A: Install: Linux Kernel #
sudo apt-get -t stretch-backports install linux-image-amd64

# B: Remove: Old Linux Kernel #
sudo apt-get autoremove
