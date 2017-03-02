#!/bin/bash -
#title          :12_docker.sh
#description    :Install Docker
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/init/12_docker.sh
#notes          :
#============================================================================

log "Installing docker" -c "blue"
curl -sL https://get.docker.com/ | sudo bash
sudo usermod -oG docker $USER
