#!/bin/bash -
#title          :hardening.sh
#description    :Set of functinos to harden an ubuntu server
#               :http://blog.codybunch.com/2015/05/12/Update-Userdata-Hardening-Script/
#author         :Cody Bunch
#date           :20170228
#version        :000
#usage          :. /path_to_file/hardening.sh
#notes          :
#============================================================================

if [ "$DBG" = "true" ]; then {
    log "debugging enabled" -c "red" -b -u
    log "hardening.sh imported" -c "red" -b -u
} fi

# Other things worth verifying / changing:
[[ "$(which iptables 2>/dev/null)" ]] && IPTABLES=$(which iptables)
[[ "$(which ip6tables 2>/dev/null)" ]] && IP6TABLES=$(which ip6tables)
[[ "$(which modprobe 2>/dev/null)" ]] && MODPROBE=$(which modprobe)

INT_INTF=eth1
EXT_INTF=eth0
INT_NET=$(ifconfig $INT_INTF | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
EXT_NET=$(ifconfig $EXT_INTF | awk '/inet addr/ {split ($2,A,":"); print A[2]}')


# Harden sysctl
configure_sysctl() {
    log "Configuring sysctl" -c "blue"

    # Sysctl
    echo "
    # IP Spoofing protection
    net.ipv4.conf.all.rp_filter = 1
    net.ipv4.conf.default.rp_filter = 1

    # Ignore ICMP broadcast requests
    net.ipv4.icmp_echo_ignore_broadcasts = 1

    # Disable source packet routing
    net.ipv4.conf.all.accept_source_route = 0
    net.ipv6.conf.all.accept_source_route = 0
    net.ipv4.conf.default.accept_source_route = 0
    net.ipv6.conf.default.accept_source_route = 0

    # Ignore send redirects
    net.ipv4.conf.all.send_redirects = 0
    net.ipv4.conf.default.send_redirects = 0

    # Block SYN attacks
    net.ipv4.tcp_syncookies = 1
    net.ipv4.tcp_max_syn_backlog = 2048
    net.ipv4.tcp_synack_retries = 2
    net.ipv4.tcp_syn_retries = 5

    # Log Martians
    net.ipv4.conf.all.log_martians = 1
    net.ipv4.icmp_ignore_bogus_error_responses = 1

    # Ignore ICMP redirects
    net.ipv4.conf.all.accept_redirects = 0
    net.ipv6.conf.all.accept_redirects = 0
    net.ipv4.conf.default.accept_redirects = 0
    net.ipv6.conf.default.accept_redirects = 0

    # Ignore Directed pings
    net.ipv4.icmp_echo_ignore_all = 1
    " | sudo tee -a /etc/sysctl.conf

    sudo sysctl -p
}


# Configure iptables
configure_iptables(){
    log "Configuring IPTABLES" -c "blue"
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
}


# Extra rules
ufw_rules() {
    if [ ! "${RULES[@]}" -eq 0 ]; then {
        log "Extra UFW rules found, configuring" -c "blue"
        for rule in ${RULES[0]}; do {
            sudo ufw allow "$rule"
        } done
    } fi
}


# Install and configure fail2ban, aide, and psad IDS's
install_ids() {
    log "[+] Installing IDS" -c "blue"
    sudo apt-get install -y fail2ban psad aide
    sudo aideinit
    sudo aide -c /etc/aide/aide.conf --update
}


# Install and configure logwatch to report
log_reporting(){
    log "Configuring logwatch" -c "blue"
    hostname=$(hostname -f)

    sudo debconf-set-selections <<< "postfix postfix/mailname string $hostname"
    sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
    sudo apt-get install -yf postfix logwatch

    echo "/usr/sbin/logwatch --output mail --mailto $EMAIL --detail high" \
        sudo tee -a /etc/cron.daily/00logwatch
}


# A proposed ordering for hardening the server
hardening(){
    log "Starting Hardening" - "blue"
    configure_sysctl
    configure_iptables
    log_reporting
    install_ids
}