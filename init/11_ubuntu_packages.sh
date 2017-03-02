#!/bin/bash -
#title          :10_packages.sh
#description    :Install some system packages
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/init/10_packages.sh
#notes          :Installs packages from the PACKAGES env variable.
#============================================================================

log "Installing additional packages" -c "blue"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq

sudo DEBIAN_FRONTEND=noninteractive apt-get -y \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    install "${PACKAGES[@]}"