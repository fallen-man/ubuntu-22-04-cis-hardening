#!/bin/bash

# Check if a reboot is required to load audit rules
if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then
    # If a reboot is required, notify the user
    echo "Reboot required to load rules"
    
    # Reboot the system
    systemctl isolate reboot.target
fi