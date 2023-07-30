#!/bin/bash

# Check if systemd-coredump is installed
if ! systemctl is-enabled coredump.service; then
    # Update package lists and install systemd-coredump
    apt update
    apt install systemd-coredump
fi

# Create /etc/security/limits.d/coredump with the specified content
echo "* hard core 0" > /etc/security/limits.d/coredump

# Create /etc/sysctl.d/coredump with the specified content
echo "fs.suid_dumpable = 0" > /etc/sysctl.d/coredump

# Run the specified sysctl command
sysctl -w fs.suid_dumpable=0

# Edit /etc/systemd/coredump.conf to add or modify the specified lines
sed -i 's/^#\?\(Storage=\).*/\1none/' /etc/systemd/coredump.conf
sed -i 's/^#\?\(ProcessSizeMax=\).*/\10/' /etc/systemd/coredump.conf

# Run systemctl daemon-reload
systemctl daemon-reload
