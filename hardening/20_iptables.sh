#!/bin/bash -
#title          :20_iptables.sh
#description    :Starts IPTables and provides a basic ruleset
#author         :Cody Bunch
#date           :2017-03-01
#version        :
#usage          :. /Users/bunchc/Dropbox/Work/projects/bootstarp/hardening/20_iptables.sh
#notes          :http://www.cipherdyne.org/LinuxFirewalls/ch01/
#               :Installs IPTABLES if not found. Flushes the rules, and then
#               :blocks all traffic except for SSH and other ports
#               :defined in the $RULES environment var or conf
#============================================================================

declare -a iptables_pkg
INT_INTF=eth1
EXT_INTF=eth0
INT_NET=$(ifconfig $INT_INTF | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
EXT_NET=$(ifconfig $EXT_INTF | awk '/inet addr/ {split ($2,A,":"); print A[2]}')

# IPTABLES for the bulk of our rules
log "Checking if IPTABLES is installed" -c "blue"
if [ "$(which iptables 2>/dev/null)" ]; then {
    IPTABLES=$(which iptables)
    log "IPTABLES found at $IPTABLES" -c "green"
} else {
    log "IPTABLES not installed" -c "red"
    iptables_pkg+=("iptables")
} fi

# IP6TABLES for ipv6 support
log "Checking if IP6TABLES is installed" -c "blue"
if [ "$(which ip6tables 2>/dev/null)" ]; then {
    IP6TABLES=$(which ip6tables)
    log "IP6TABLES found at $IP6TABLES" -c "green"
} else {
    log "IP6TABLES not installed" -c "red"
    iptables_pkg+=("ip6tables")
} fi

# UFW for ease of use
log "Checking for ufw"
if [ "$(which ufw 2>/dev/null)" ]; then {
    UFW=$(which ufw)
    log "ufw found at $UFW" -c "green"
} else {
    log "ufw not installed" -c "red"
    iptables_pkg+=("ufw")
} fi

if [ ! "${iptables_pkg[@]}" -eq 0 ]; then {
    log "Installing fw management packages" -c "blue"
    sudo apt-get install -qqy "${iptables_pkg[@]}"
} fi


log "Configuring IPTABLES" -c "blue"
{
    # Firewall
    # Modified from http://www.cipherdyne.org/LinuxFirewalls/ch01/
    ### flush existing rules and set chain policy setting to DROP
    $IPTABLES -F
    $IPTABLES -F -t nat
    $IPTABLES -X
    $IPTABLES -P INPUT DROP
    $IPTABLES -P FORWARD DROP

    ### this policy does not handle IPv6 traffic except to drop it.
    #
    $IP6TABLES -P INPUT DROP
    $IP6TABLES -P OUTPUT DROP
    $IP6TABLES -P FORWARD DROP

    ### load connection-tracking modules
    #
    $MODPROBE ip_conntrack
    $MODPROBE iptable_nat
    $MODPROBE ip_conntrack_ftp
    $MODPROBE ip_nat_ftp

    ###### INPUT chain ######
    ### state tracking rules
    $IPTABLES -A INPUT -m conntrack --ctstate INVALID -j LOG --log-prefix "DROP INVALID " --log-ip-options --log-tcp-options
    $IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
    $IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    ### anti-spoofing rules
    $IPTABLES -A INPUT -i $INT_INTF ! -s "$INT_NET" -j LOG --log-prefix "SPOOFED PKT "
    $IPTABLES -A INPUT -i $INT_INTF ! -s "$INT_NET" -j DROP

    ### ACCEPT rules
    $IPTABLES -A INPUT -i $INT_INTF -p tcp -s "$INT_NET" --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    $IPTABLES -A INPUT -i $EXT_INTF -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    $IPTABLES -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

    ### default INPUT LOG rule
    $IPTABLES -A INPUT ! -i lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options

    ### make sure that loopback traffic is accepted
    $IPTABLES -A INPUT -i lo -j ACCEPT

    ###### OUTPUT chain ######
    ### state tracking rules
    $IPTABLES -A OUTPUT -m conntrack --ctstate INVALID -j LOG --log-prefix "DROP INVALID " --log-ip-options --log-tcp-options
    $IPTABLES -A OUTPUT -m conntrack --ctstate INVALID -j DROP
    $IPTABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    ### default OUTPUT LOG rule
    $IPTABLES -A OUTPUT ! -o lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options

    ### make sure that loopback traffic is accepted
    $IPTABLES -A OUTPUT -o lo -j ACCEPT

    ###### FORWARD chain ######
    ### state tracking rules
    $IPTABLES -A FORWARD -m conntrack --ctstate INVALID -j LOG --log-prefix "DROP INVALID " --log-ip-options --log-tcp-options
    $IPTABLES -A FORWARD -m conntrack --ctstate INVALID -j DROP
    $IPTABLES -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    ### anti-spoofing rules
    $IPTABLES -A FORWARD -i $INT_INTF ! -s "$INT_NET" -j LOG --log-prefix "SPOOFED PKT "
    $IPTABLES -A FORWARD -i $INT_INTF ! -s "$INT_NET" -j DROP
} || log "Failed to configure IPTABLES" -c "red"


# Additional rules
if [ ! "${RULES[@]}" -eq 0 ]; then {
    log "Extra UFW rules found, configuring" -c "blue"
    for rule in ${RULES[0]}; do {
        sudo ufw allow "$rule"
    } done
} fi
