#!/bin/bash
#V1.20260624.1
#interactive automated update script for digital signage raspberries with overlayfs enabled

#  apt config #
#  "" = wait for user input
#  "-y" = accept all changes 
  autoapt="-y"
###############

# browser cache dir #
  cachedir="../.cache/chromium/"
#####################

#   styling   #
#colors
  NOCOLOR='\033[0m'
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  GREEN='\033[0;32m'
#bold
  b=$(tput bold)
#regular
  r=$(tput sgr0)
################

# usage of do_overlayfs <0/1> #
#  1  = disable overlayfs
#  0  = enable overlayfs
###############################

if [ "$EUID" -ne 0 ]
  then echo -e "${b}${RED}Please run as root!${NOCOLOR}${r}\n"
  exit
else
  clear
  timestamp=$(cat lastupdate.txt)
  echo -e "${b}${GREEN}last update: $timestamp${NOCOLOR}${r}\n"
  echo -e "${b}[u]pdate or [p]rotect system?${r}"
  read -p 'Your choice: ' mode
  echo  ""
  echo -e "${b}[Vaccum] journal logs? (type "skip" to skip)${r}"
  read -p '[ENTER] to vacuum or skip? ' clean
  echo ""
fi

if [ -z "$mode" ]; then
  echo -e "${b}${RED}Error: invalid selection what to to. Your entered: $mode ${NOCOLOR}${r}\n"
  exit 1
fi

if [ "$mode" == "u" ]; then
  #check if overlayfs is enabled (!=0)
  tmpfs=$(cat /boot/firmware/cmdline.txt | grep overlayroot)
    if [ -z "$tmpfs" ]; then
      #vacuum journals
      if [ -z "$clean" ]; then
        echo -e "${b}${YELLOW}vacuuming journactl ...${NOCOLOR}${r}\n"
        journalctl --flush --rotate --vacuum-time=1s
        journalctl --user --flush --rotate --vacuum-time=1s
        echo ""
      else
        echo -e "${b}${RED}skipped vacuuiming journalctl ...${NOCOLOR}${r}\n"
      fi
      echo -e "${b}${GREEN}Overlayfs is disabled, starting update in 2s${NOCOLOR}${r}\n"
      sleep 2
      #make boot partition writeable for kernel and firmware updates
      mount -o remount,rw /boot/firmware
      #stop chromium
      killall chromium
      apt update
      apt upgrade $autoapt
      echo -e "${b}${GREEN}Updates completed, start tidying up in 5s${NOCOLOR}${r}\n"
      sleep 5
      apt autoremove $autoapt
      apt autoclean
      echo -e "${b}${YELLOW}Clearing chromium cache${NOCOLOR}${r}\n"
      rm -rf $cachedir
      echo $(date) > ../../lastupdate.txt
      echo -e "${b}${YELLOW}Enabling read-only filesystem again in 2s${NOCOLOR}${r}\n"
      sleep 2
      raspi-config nonint do_overlayfs 0
      echo -e "${b}${GREEN}All done, reboot required!${NOCOLOR}${r}\n"
      read -p 'Press [ENTER] to reboot ' confirm
      reboot
    else
      echo -e "${b}disable read-only filesystem?${r}"
      read -p "Press [ENTER] to confirm " confirm
      echo ""
        if [ -z "$confirm" ]; then
          echo -e "${b}${YELLOW}disabling read-only filesystem in 2s${NOCOLOR}${r}\n"
          sleep 2
          raspi-config nonint do_overlayfs 1
          echo -e "${b}${GREEN}Overlayfs disabled, please run this script again after reboot${NOCOLOR}${r}"
          read -p 'Press [ENTER] to reboot ' confirm
          reboot
        else
          echo -e "${b}${RED}OK, we'll do nothing...${NOCOLOR}${r}\n"
          exit
        fi
    fi
fi

if [ "$mode" == "p" ]; then
  #check if overlayfs is enabled (!=0)
  tmpfs=$(cat /boot/firmware/cmdline.txt | grep overlayroot)
    if [ -z "$tmpfs" ]; then
          #vacuum journals
          if [ -z "$clean" ]; then
            echo -e "${b}${YELLOW}vacuuming journactl ...${NOCOLOR}${r}\n"
            journalctl --flush --rotate --vacuum-time=1s
            journalctl --user --flush --rotate --vacuum-time=1s
            echo ""
          else
            echo -e "${b}${RED}skipped vacuuiming journalctl ...${NOCOLOR}${r}\n"
          fi
          echo -e "${b}${YELLOW}Enabling read-only filesystem in 2s${NOCOLOR}${r}\n"
          sleep 2
          raspi-config nonint do_overlayfs 0
          echo -e "${b}${GREEN}Overlayfs enabled, reboot reboot required!${NOCOLOR}${r}\n"
          read -p 'Press [ENTER] to reboot ' confirm
          reboot
    else
          echo -e "${b}${YELLOW}filesystem allready protected, nothing to do${NOCOLOR}${r}\n"
          exit
    fi
fi
