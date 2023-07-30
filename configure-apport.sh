#!/bin/bash

# Check if apport is enabled and active
if dpkg-query -s apport > /dev/null 2>&1 && grep -q 'enabled=1' /etc/default/apport && systemctl is-active apport.service | grep '^active'; then
    # Stop and disable the apport service
    systemctl stop apport.service
    systemctl --now disable apport.service
fi
# Disable apport by replacing enabled=1 with enabled=0 in /etc/default/apport
    sed -i 's/enabled=1/enabled=0/' /etc/default/apport
