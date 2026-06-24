#!/bin/bash
#>fetch-update-script.sh< is placed in home dir as >update-pi.sh< on clients
clear
echo "fetching most recent version of update-script from github..."
mkdir -p scripts
rm -rf scripts/raspi-overlayfs-updates
git clone https://github.com/uk3k/raspi-overlayfs-updates.git scripts/raspi-overlayfs-updates
cd scripts/raspi-overlayfs-updates
chmod +x update-pi.sh
echo "executing actual update-script now!"
sudo -u root sh update-pi.sh
