#!/bin/bash -
#title          :10_dotfiles.sh
#description    :Installs dotfiles
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/init/10_dotfiles.sh
#notes          :https://github.com/bunchc/dotfiles
#============================================================================

log "Installing dotfiles" -c "blue"
chattr +i "$HOME/.ssh/"
curl -fsSL "https://raw.github.com/$GITHUB_USER/dotfiles/master/bin/dotfiles" \
    | sudo bash
chattr +i "$HOME"/.ssh/