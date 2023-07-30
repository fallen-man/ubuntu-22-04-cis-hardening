#!/bin/bash

# Check if the autofs.service is enabled.
if systemctl is-enabled autofs --quiet; then
    sudo systemctl stop autofs
    sudo systemctl mask autofs
    echo "autofs.service stopped and masked"
else
    echo "autofs.service was stopped"
fi
