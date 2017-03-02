#!/bin/bash -
#title          :20_OSA.sh
#description    :Installs OSA using the rbac_prep scripts
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/init/20_OSA.sh
#notes          :Defaults to the most recent stable branch unless overridden
#============================================================================

log "Checking for conflicts" -c "blue"
if [ "$DOTFILES" = "true" ] \
    || [ "$ENABLE_ARM" = "true" ] \
    || [ "$INSTALL_DOCKER" = "true" ] \
    || [ "$HARDENING" = "true" ] \
    || [ "$INSTALL_OPENSHIFT" = "true" ]; then {
        log "Unable to install OSA: Conflicting packages" -c "red" -b
        exit
} else {
    log "Installing OSA" -c "blue"
    git clone "https://github.com/bunchc/rbac_prep" "$HOME/rbac_prep"
    bash -c "cd $HOME/rbac_prep; ./rbac_prep.sh"
} fi
