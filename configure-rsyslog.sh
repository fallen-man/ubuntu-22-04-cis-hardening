#!/bin/bash

# Set the package name
PACKAGE="rsyslog"

# Check if the package is installed
if ! dpkg-query -W -f='${Status}' "$PACKAGE" 2>/dev/null | grep -q "ok installed"; then
    # If the package is not installed, install it using apt
    apt update
    apt install -y "$PACKAGE"
fi

# Enable the rsyslog service
systemctl --now enable rsyslog

# Uncomment ForwardToSyslog=yes in /etc/systemd/journald.conf
sed -i 's/^#ForwardToSyslog=yes/ForwardToSyslog=yes/' /etc/systemd/journald.conf

# Check /etc/rsyslog.conf for $FileCreateMode 0640
if ! grep -q '$FileCreateMode 0640' /etc/rsyslog.conf; then
    # If $FileCreateMode 0640 is not found, change it
    sed -i 's/^\$FileCreateMode .*/$FileCreateMode 0640/' /etc/rsyslog.conf
fi

# Restart the rsyslog service
systemctl restart rsyslog
