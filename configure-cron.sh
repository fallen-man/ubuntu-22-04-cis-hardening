#!/bin/bash

systemctl --now enable cron
# set crontab permissions
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
# verify permissions
stat /etc/crontab

#set crontab/hourly permissions
chown root:root /etc/cron.hourly/
chmod og-rwx /etc/cron.hourly/
# verify permissions
stat /etc/cron.hourly/

#set cron.daily permissions
chown root:root /etc/cron.daily/
chmod og-rwx /etc/cron.daily/
# verify persmissions
stat /etc/cron.daily/

#set cron.weekly permissions
chown root:root /etc/cron.weekly/
chmod og-rwx /etc/cron.weekly/
# verify permissions

#set cron.monthly permissions
chown root:root /etc/cron.monthly/
chmod og-rwx /etc/cron.monthly/
# verify permissions
stat /etc/cron.monthly/

#set cron.d permissions
chown root:root /etc/cron.d/
chmod og-rwx /etc/cron.d/
# verify permissions
stat /etc/cron.d/

#5.1.8 Ensure cron is restricted to authorized users
rm /etc/cron.deny
touch /etc/cron.allow
chmod g-wx,o-rwx /etc/cron.allow
chown root:root /etc/cron.allow
# verify cron.allow permissions
stat /etc/cron.allow
# whitelisting is more secure than blacklisting, but needed to specify every user that can use cron
#add ict user
echo "ict" > /etc/cron.allow

#5.1.9 Ensure at is restricted to authorized users
rm /etc/at.deny
touch /etc/at.allow
chmod g-wx,o-rwx /etc/at.allow
chown root:root /etc/at.allow
stat /etc/at.deny
echo "ict" > /etc/at.allow






