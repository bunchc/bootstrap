#!/bin/bash -
#title          :30_IDS.sh
#description    :Installs and configures some IDS software
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/hardening/30_IDS.sh
#notes          :Installs fal2ban, aide, and psad. Configures aide
#============================================================================

log "[+] Installing IDS" -c "blue"
sudo apt-get install -y fail2ban psad aide
sudo aideinit
sudo aide -c /etc/aide/aide.conf --update