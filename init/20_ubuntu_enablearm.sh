#!/bin/bash -
#title          :50_enablearm.sh
#description    :Enable ARM for Docker on x86
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/init/50_enablearm.sh
#notes          :http://blog.ubergarm.com/run-arm-docker-images-on-x86_64-hosts/
#============================================================================

if [ ! "$(which docker)" ]; then {
    log "FAIL: Requirement not met: Docker" -c "red" -b
} else {
    log "Enabling docker support for ARM" -c "blue"
    sudo apt-get install -qqy \
        --force-yes \
        --no-install-recommends \
        qemu-user-static \
        binfmt-support

    update-binfmts --enable qemu-arm
    update-binfmts --enable qemu-aarch64

    docker run --rm --privileged multiarch/qemu-user-static:register --reset
} fi
