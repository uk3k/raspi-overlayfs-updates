#!/bin/bash
#placed in home dir as update-pi.sh on clients
clear
echo "fetching most recent version of update-script from github..."
mkdir -p scripts
cd scripts
wget-O https://github.com/uk3k/raspi-overlayfs-updates/blob/main/update-pi.sh
chmod +x update-pi.sh
sudo -u root sh update-pi.sh
