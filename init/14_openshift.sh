#!/bin/bash -
#title          :14_openshift.sh
#description    :Install the openshift CLI
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/init/14_openshift.sh
#notes          :
#============================================================================

if [ ! "$(which docker)" ]; then {
    log "FAIL: Requirement not met: Docker" -c "red" -b
} else {
    log "Installing OpenShift" -c "blue"
    wget https://github.com/openshift/origin/releases/download/v1.4.1/openshift-origin-client-tools-v1.4.1-3f9807a-linux-64bit.tar.gz \
        -O /tmp/openshift.tar.gz
    mkdir -p "$HOME"/openshift/
    tar -zxf /tmp/openshift.tar.gz -C "$HOME"/openshift/
    mv "$HOME"/openshift/**/oc /usr/sbin/oc
    rm -rf /tmp/openshift* "$HOME"/openshift*
} fi