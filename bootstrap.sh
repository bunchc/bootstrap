#!/bin/bash -
#title          :bootstrap.sh
#description    :Pulls in dotfiles, sets up iptables, and installs other \
#               :packages as needed
#author         :Cody Bunch
#date           :20170209
#version        :000
#usage          :/vagrant/start.sh
#notes          :
#============================================================================
# Pull in some helpers
run_dir=$(dirname "$0")
# shellcheck source=/dev/null
. "$run_dir/conf"

declare functions="${*:-$run_dir/lib/**}"
for file in $functions; do {
    # shellcheck source=/dev/null
    . $file
} done

main () {
    [[ "$DOTFILES" = "true" ]] && dotfiles
    [[ "$INSTALL_PACKAGES" = "true" ]] && install_packages
    [[ "$ENABLE_ARM" = "true" ]] && enable_arm
    [[ "$HARDENING" = "true" ]] && hardening
}

if [ "$DBG" = "true" ]; then {
    main "$@"
} else {
    log "Debugging enabled" -c "red" -b -u
    set -e -u -x
    time { main "$@"; } 2>&1 | tee -a /tmp/bootstrap.log
} fi