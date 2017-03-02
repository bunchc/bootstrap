#!/bin/bash -
#title          :10_rmate.sh
#description    :Installs rmate
#author         :Cody Bunch
#date           :2017-03-01
#version        :000
#usage          :. /path_to_file/10_rmate.sh
#notes          :https://github.com/textmate/rmate
#============================================================================

log "Installing rmate" -c "blue"
mkdir -p "$HOME"/bin
curl -Lo ~/bin/rmate \
    https://raw.githubusercontent.com/textmate/rmate/master/bin/rmate
chmod a+x ~/bin/rmate
[[ "$(ls "$HOME/.bash_profile" | wc -l 2> /dev/null)" == "1" ]] && {
    echo 'export PATH="$PATH:$HOME/bin"' >> "$HOME"/.bash_profile
}