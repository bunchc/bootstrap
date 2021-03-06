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

declare functions="${*:-$run_dir/lib/**}"
for file in $functions; do {
    # shellcheck source=/dev/null
    . $file
} done

# shellcheck source=/dev/null
. "$run_dir/conf"

main () {
    export prompt_delay=15
    do_stuff "init"
    [[ "$HARDENING" = "true" ]] && do_stuff "hardening"
}

case "$DBG" in
    debug )
        log "Debugging enabled. Logging to $LOGFILE" -c "red" -b -u
        log "Starting bootstrap" -c "blue"
        set -e -u -x
        time { main "$@"; } 2>&1 | tee -a "$LOGFILE"
        ;;
    log )
        log "Logging output to $LOGFILE" -c "yellow" -u
        log "Starting bootstrap" -c "blue"
        time { main "$@"; } 2>&1 | tee -a "$LOGFILE"
        ;;
    * )
        log "Starting bootstrap" -c "blue"
        main "$@"
        ;;
esac