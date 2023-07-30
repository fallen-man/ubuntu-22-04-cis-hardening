#!/bin/bash

# Define variables
FSTAB_FILE="/etc/fstab"
MOUNT_POINTS=("/tmp" "/var/tmp")
OPTIONS="nosuid,nodev,noexec"

# Backup the original fstab file
cp $FSTAB_FILE "${FSTAB_FILE}.bak"

# Add the options to the mount points
for MOUNT_POINT in "${MOUNT_POINTS[@]}"; do
    if ! grep -q "$MOUNT_POINT.*$OPTIONS" $FSTAB_FILE; then
        sed -i "s|\($MOUNT_POINT.*\)\(defaults\)\(.*\)|\1\2,$OPTIONS\3|" $FSTAB_FILE
    fi
done

# Add the nodev option to the /home mount point
if ! grep -q "/home.*nodev" $FSTAB_FILE; then
    sed -i "s|\(/home.*\)\(defaults\)\(.*\)|\1\2,nodev\3|" $FSTAB_FILE
fi

echo "The options have been added to the fstab file."

MOUNT_POINTS=("/tmp" "/var/tmp" "/home")

for MOUNT_POINT in "${MOUNT_POINTS[@]}"; do
    mount -o remount $MOUNT_POINT
    echo "$MOUNT_POINT remounted."
done
