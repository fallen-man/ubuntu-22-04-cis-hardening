#!/bin/bash

# Check if the prelink package is installed
if dpkg-query -W -f='${Status}\n' prelink 2>/dev/null | grep -q "ok installed"; then
    # If prelink is installed, remove it
    prelink -ua #restore binaries to normal
    apt purge prelink
    echo "The prelink package has been removed."
else
    echo "The prelink package is not installed."
fi
