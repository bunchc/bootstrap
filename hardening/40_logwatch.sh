#!/bin/bash -
#title          :40_logwatch.sh
#description    :Install and configure logwatch
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/hardening/40_logwatch.sh
#notes          :
#============================================================================


hostname=$(hostname -f)


# Check for postfix
if [ ! "$(which postfix 2>/dev/null)" ]; then {
    log "Could not find postfix, installing" -c "red"
    sudo debconf-set-selections <<< "postfix postfix/mailname string $hostname"
    sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
    logwatch_pkg+=("postfix")
} fi

# Check for logwatch
if [ ! "$(which logwatch 2>/dev/null)" ]; then {
    log "Could not find logwatch, installing" -c "red"
    logwatch_pkg+=("logwatch")
} fi

# Install what's missing
if [ ! "${logwatch_pkg[@]}" -eq 0 ]; then {
    log "Installing logwatch packages" -c "blue"
    sudo apt-get install -qqy "${logwatch_pkg[@]}"
} fi

if [ "$(which logwatch 2>/dev/null)" ] && [ "$(which postfix 2>/dev/null)" ]; then {
    log "Adding logwatch to cron" -c "blue"
    echo "/usr/sbin/logwatch --output mail --mailto $EMAIL --detail high" \
        sudo tee -a /etc/cron.daily/00logwatch
} fi
