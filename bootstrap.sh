#!/bin/bash -
set -eux
#title          :bootstrap.sh
#description    :Pulls in dotfiles, sets up iptables, and installs other \
#               :packages as needed
#author         :Cody Bunch
#date           :20170209
#version        :000
#usage          :./start.sh
#notes          :
#bash_version   :3.2.57(1)-release
#============================================================================

directory=$(pwd)

# load options
source "$directory/bootstrap/options.rc"

# load functions
source "$directory/bootstrap/functions.rc"

main () {
    dotfiles
    stty sane
    install_packages
    [[ "$ENABLE_ARM" ]] && enable_arm
    hardening
}

main "$@"