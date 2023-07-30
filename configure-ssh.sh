#!/usr/bin/env bash

chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config
{
   l_skgn="ssh_keys" # Group designated to own openSSH keys
   l_skgid="$(awk -F: '($1 == "'"$l_skgn"'"){print $3}' /etc/group)"
   awk '{print}' <<< "$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -L -c "%n %#a %U %G %g" {} +)" | (while read -r  l_file l_mode l_owner l_group l_gid; do
      [ -n "$l_skgid" ] && l_cga="$l_skgn" || l_cga="root"
      [ "$l_gid" = "$l_skgid" ] && l_pmask="0137" || l_pmask="0177"
      l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"
      if [ $(( $l_mode & $l_pmask )) -gt 0 ]; then
         echo -e " - File: \"$l_file\" is mode \"$l_mode\" changing to mode: \"$l_maxperm\""
         if [ -n "$l_skgid" ]; then
            chmod u-x,g-wx,o-rwx "$l_file"
         else
            chmod u-x,go-rwx "$l_file"
         fi
      fi
      if [ "$l_owner" != "root" ]; then
         echo -e " - File: \"$l_file\" is owned by: \"$l_owner\" changing owner to \"root\""
         chown root "$l_file"
      fi
      if [ "$l_group" != "root" ] && [ "$l_gid" != "$l_skgid" ]; then
         echo -e " - File: \"$l_file\" is owned by group \"$l_group\" should belong to group \"$l_cga\""
         chgrp "$l_cga" "$l_file"
      fi
   done
   )
}
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod u-x,go-wx {} \;
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;
# allow only ict user to ssh to server
touch /etc/ssh/sshd_config.d/allowlist.conf
echo "AllowUsers ict" >> /etc/ssh/sshd_config.d/allowlist.conf
#set log-level to info
sed -i 's/^#LogLevel INFO/LogLevel INFO/' /etc/ssh/sshd_config
#set rootlogin to false
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
#disable host-base auth
echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
# disable empty password
echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
# disable user environment
echo "PermitUserEnvironment no" >> /etc/ssh/sshd_config
# ignore rhosts
echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
# disable X11 forwarding
sed -i 's/^X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
# disbale tcp forwarding
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
# set max authentication retries
sed -i 's/^#MaxAuthTries 6/MaxAuthTries 4/' /etc/ssh/sshd_config
# set max startups
sed -i 's/^#MaxStartups 10:30:100/MaxStartups 10:30:60/' /etc/ssh/sshd_config
# set max sessions
sed -i 's/^#MaxSessions 10/MaxSessions 10/' /etc/ssh/sshd_config
# set login grace time
sed -i 's/^#LoginGraceTime 2m/LoginGraceTime 60/' /etc/ssh/sshd_config
# set client alive max and interval
sed -i 's/^#ClientAliveCountMax 3/ClientAliveCountMax 3\nClientAliveInterval 15/' /etc/ssh/sshd_config

systemctl restart sshd

