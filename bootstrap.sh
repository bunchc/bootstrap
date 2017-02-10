#!/bin/bash -
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

if [ $# -eq 0 ]; then {
    directory=$(pwd)
} else {
    directory=$1
} fi

# load options
source "$directory/options.rc"

# load functions
source "$directory/functions.rc"

main () {
    dotfiles
    install_packages
    [[ "$ENABLE_ARM" ]] && enable_arm
    hardening
}

main "$@"