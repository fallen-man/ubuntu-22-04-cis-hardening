#!/bin/bash

# Set the package name
PACKAGE="ufw"

# Check if the package is installed
if ! dpkg-query -W -f='${Status}' "$PACKAGE" 2>/dev/null | grep -q "ok installed"; then
    # If the package is not installed, install it using apt
    apt update
    apt install -y "$PACKAGE"
fi

# Set the iptables-persistent package name
IPTABLES_PACKAGE="iptables-persistent"

# Check if the iptables-persistent package is installed
if dpkg-query -W -f='${Status}' "$IPTABLES_PACKAGE" 2>/dev/null | grep -q "ok installed"; then
    # If the iptables-persistent package is installed, purge it using apt
    apt purge -y "$IPTABLES_PACKAGE"
fi

# Check if the ufw service is enabled and active, and if ufw itself is active
if ! systemctl is-enabled ufw.service || ! systemctl is-active ufw || ! ufw status | grep -q "Status: active"; then
    # If any of the checks failed, unmask and enable the ufw service, and enable ufw itself
    systemctl unmask ufw.service
    systemctl --now enable ufw.service
    ufw enable
fi
ufw allow in on lo
ufw allow out on lo
ufw deny in from 127.0.0.0/8
ufw deny in from ::1
ufw allow out on all
ufw allow git
ufw allow in http
ufw allow out http
ufw allow in https
ufw allow out https
ufw allow out 53
ufw allow in 22
ufw allow out 22
ufw logging on
ufw default deny incoming
ufw default deny outgoing
ufw default deny routed
