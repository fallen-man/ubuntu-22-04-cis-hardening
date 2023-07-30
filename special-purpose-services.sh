#!/bin/bash

# Set the package names
PACKAGES=("xserver-xorg" "avahi-daemon" "cups" "isc-dhcp-server" "slapd" "nfs-kernel-server" "bind9" "vsftpd" "apache2" "dovecot-imapd" "dovecot-pop3d" "samba" "squid" "snmp" "nis" "rsync")

# Loop over the packages
for PACKAGE in "${PACKAGES[@]}"; do
    # Check if the package is installed
    if dpkg-query -W -f='${Status}' "$PACKAGE" 2>/dev/null | grep -q "ok installed"; then
        # If the package is installed, take action based on the package name
        case "$PACKAGE" in
            "avahi-daemon")
                # Stop the avahi-daemon.service and avahi-daemon.socket
                systemctl stop avahi-daemon.service
                systemctl stop avahi-daemon.socket
                ;;
        esac

        # Purge the package using apt
        apt purge -y "$PACKAGE"
    fi
done
