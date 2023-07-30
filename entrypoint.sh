#!/bin/bash

# this script will run all the hardenings in a row

bash ./cis-fs-check.sh
bash ./cis-fs-disable.sh
bash ./fstab-options.sh
bash ./configure-apport.sh
bash ./set-sticky-bit.sh
bash ./ASLR-check-and-set.sh
bash ./autofs-check-mask.sh
bash ./check-core-dump.sh
bash ./prelink-check.sh
bash ./grub-permissions.sh
bash ./config-system-file-permissions.sh
bash ./config-local-user-gp-setting.sh
bash ./configure-network-parameters.sh
bash ./special-purpose-services.sh
bash ./configure-cron.sh
bash ./configure-chrony.sh
bash ./configure-pam.sh
bash ./configure-ufw.sh
bash ./configure-pam.sh
bash ./configure-rsyslog.sh
bash ./configure-auditd.sh
bash ./check-reboot.required.sh