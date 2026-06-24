#!/bin/bash
#V1.20260624.0
#do_overlayfs <0/1>
#  1  = disable overlayfs
#  0  = enable overlayfs
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
else
  clear
  timestamp=$(cat lastupdate.txt)
  echo "last update: $timestamp"
  read -p '[u]pdate or [p]rotect system? ' mode
  read -p '[Vaccum] journal logs? (enter "skip" to skip) ' clean
fi
  
#vacuum journals
if [ -z "$clean" ]; then
  echo  "vacuuming journactl ..."
  journalctl --flush --rotate --vacuum-time=1s
  journalctl --user --flush --rotate --vacuum-time=1s
  echo ""
else
  echo "skipped vacuuiming journalctl ..."
fi

if [ -z "$mode" ]; then
  echo "Error: invalid selection what to to. Your entered: $mode"
  exit 1
fi

if [ "$mode" == "u" ]; then
  #check if overlayfs is enabled (!=0)
  tmpfs=$(cat /boot/firmware/cmdline.txt | grep overlayroot)
    if [ -z "$tmpfs" ]; then
      echo "overlayfs is disabled, starting update in 2s"
      sleep 2
      #make boot partition writeable for kernel and firmware updates
      sudo mount -o remount,rw /boot/firmware 
      apt update
      apt upgrade -y
      echo "updates completed, start tidying up in 5s"
      sleep 5
      apt autoremove -y
      apt autoclean
      echo $(date) > lastupdate.txt
      echo "enabling read-only filesystem again in 2s"
      sleep 2
      raspi-config nonint do_overlayfs 0
      echo "all done, rebooting in 5s"
      sleep 5
      reboot
    else
      read -p "disable read-only filesystem? [ENTER] " confirm
        if [ -z "$confirm" ]; then
          echo "disabling read-only filesystem in 2s"
          sleep 2
          raspi-config nonint do_overlayfs 1
          echo "overlayfs disabled, please runt his script again after reboot. rebooting in 2s"
          sleep 2
          reboot
        else
          echo "OK, we'll do nothing..."
          exit
        fi
    fi
fi

if [ "$mode" == "p" ]; then
  #check if overlayfs is enabled (!=0)
  tmpfs=$(cat /boot/firmware/cmdline.txt | grep overlayroot)
    if [ -z "$tmpfs" ]; then
          echo "enabling read-only filesystem in 2s"
          sleep 2
          raspi-config nonint do_overlayfs 0
          echo "overlayfs enabled, rebooting in 2s"
          reboot
    else
          echo "filesystem allready protected, nothing to do"
          exit
    fi
fi

          
