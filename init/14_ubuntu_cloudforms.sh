#!/bin/bash -
#title          :13_cloudforms.sh
#description    :Install CloudForms
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/init/13_cloudforms.sh
#notes          :http://manageiq.org/docs/get-started/docker
#============================================================================

if [ ! "$(which docker)" ]; then {
    log "FAIL: Requirement not met: Docker" -c "red" -b
} else {
    log "Installing CloudForms" -c "blue"
    sudo docker pull manageiq/manageiq:euwe-1
    sudo docker run --privileged -d -p 8443:443 manageiq/manageiq:euwe-1
    if [ "$HARDENING" = "true" ]; then {
        log "Hardening enabled, adding ufw rule for cloudforms" -c "cyan"
        RULES+=('8443')
    } fi
} fi