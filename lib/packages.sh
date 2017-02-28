#!/bin/bash -
#title          :packages.sh
#description    :Set of functinos to preinstall packages like:
#               :openshift, cloudforms, docker, etc
#author         :Cody Bunch
#date           :20170228
#version        :000
#usage          :. /path_to_file/packages.sh
#notes          :
#============================================================================

if [ "$DBG" = "true" ]; then {
    log "debugging enabled" -c "red" -b -u
    log "packages.sh imported" -c "red" -b -u
} fi

dotfiles() {
    log "Installing dotfiles" -c "blue"
    chattr +i "$HOME/.ssh/"
    curl -fsSL "https://raw.github.com/$GITHUB_USER/dotfiles/master/bin/dotfiles" \
        | sudo bash
    chattr +i "$HOME"/.ssh/
}

install_rmate() {
    log "Installing rmate" -c "blue"
    mkdir -p "$HOME"/bin
    curl -Lo ~/bin/rmate \
        https://raw.githubusercontent.com/textmate/rmate/master/bin/rmate
    chmod a+x ~/bin/rmate
    [[ "$(ls "$HOME/.bash_profile" | wc -l 2> /dev/null)" == "1" ]] && {
        echo 'export PATH="$PATH:$HOME/bin"' >> "$HOME"/.bash_profile
    }
}

install_docker() {
    log "Installing docker" -c "blue"
    curl -sL https://get.docker.com/ | sudo bash
}

install_cloudforms() {
    log "Installing CloudForms" -c "blue"
    sudo docker pull manageiq/manageiq:euwe-1
    sudo docker run --privileged -d -p 8443:443 manageiq/manageiq:euwe-1
    if [ "$HARDENING" = "true" ]; then {
        log "Hardening enabled, adding ufw rule for cloudforms" -c "cyan"
        RULES+=('8443')
    } fi
}

install_openshift() {
    log "Installing OpenShift" -c "blue"
    wget https://github.com/openshift/origin/releases/download/v1.4.1/openshift-origin-client-tools-v1.4.1-3f9807a-linux-64bit.tar.gz \
        -O /tmp/openshift.tar.gz
    mkdir -p "$HOME"/openshift/
    tar -zxf /tmp/openshift.tar.gz -C "$HOME"/openshift/
    mv "$HOME"/openshift/**/oc /usr/sbin/oc
    rm -rf /tmp/openshift* "$HOME"/openshift*
}

install_packages() {
    log "Installing additional packages" -c "blue"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -qq

    declare packages_file="${*:-packages}"
    for packagelist in $packages_file; do
        xargs -a <(awk '/^\s*[^#]/' "$packagelist") -r -- \
            sudo DEBIAN_FRONTEND=noninteractive apt-get -y \
                -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" \
                install
    done

    install_rmate
    [[ "$INSTALL_DOCKER" ]] && install_docker
    [[ "$INSTALL_OPENSHIFT" ]] && install_openshift
}

enable_arm() {
    log "Enabling docker support for ARM" -c "cyan"
    sudo apt-get install -qqy \
        --force-yes \
        --no-install-recommends \
        qemu-user-static \
        binfmt-support

    update-binfmts --enable qemu-arm
    update-binfmts --enable qemu-aarch64
}