#!/bin/bash
check_time () {
   output="" l_tsd="" l_sdtd="" chrony="" l_ntp=""
   dpkg-query -W chrony > /dev/null 2>&1 && l_chrony="y"
   dpkg-query -W ntp > /dev/null 2>&1 && l_ntp="y" || l_ntp=""
   systemctl list-units --all --type=service | grep -q 'systemd-timesyncd.service' && systemctl is-enabled systemd-timesyncd.service | grep -q 'enabled' && l_sdtd="y"
#   ! systemctl is-enabled systemd-timesyncd.service | grep -q 'enabled' && l_nsdtd="y" || l_nsdtd=""
   if [[ "$l_chrony" = "y" && "$l_ntp" != "y" && "$l_sdtd" != "y" ]]; then
      l_tsd="chrony"
      output="$output\n- chrony is in use on the system"
   elif [[ "$l_chrony" != "y" && "$l_ntp" = "y" && "$l_sdtd" != "y" ]]; then
      l_tsd="ntp"
      output="$output\n- ntp is in use on the system"
   elif [[ "$l_chrony" != "y" && "$l_ntp" != "y" ]]; then
      if systemctl list-units --all --type=service | grep -q 'systemd-timesyncd.service' && systemctl is-enabled systemd-timesyncd.service | grep -Eq '(enabled|disabled|masked)'; then
         l_tsd="sdtd"
         output="$output\n- systemd-timesyncd is in use on the system"
      fi
   else
      [[ "$l_chrony" = "y" && "$l_ntp" = "y" ]] && output="$output\n- both chrony and ntp are in use on the system"
      [[ "$l_chrony" = "y" && "$l_sdtd" = "y" ]] && output="$output\n- both chrony and systemd-timesyncd are in use on the system"
      [[ "$l_ntp" = "y" && "$l_sdtd" = "y" ]] && output="$output\n- both ntp and systemd-timesyncd are in use on the system"
   fi
   if [ -n "$l_tsd" ]; then
      echo -e "\n- PASS:\n$output\n"
   else
      echo -e "\n- FAIL:\n$output\n"
   fi
}
# check the time daemon already in use
check_time
# install chrony time daemon and remove the others
apt install chrony
systemctl stop systemd-timesyncd.service
systemctl --now mask systemd-timesyncd.service
systemctl --now enable chrony.service
apt purge ntp

# Set the file path
FILE="/etc/chrony/chrony.conf"

# Find the line number of the first pool directive
LINE_NUM=$(grep -n '^pool ' "$FILE" | head -n 1 | cut -d: -f1)

if [ -n "$LINE_NUM" ]; then
    # If a pool directive was found, remove all pool directives
    sed -i '/^pool /d' "$FILE"

    # Add the specified pool directive at the line number of the first pool directive
    sed -i "${LINE_NUM}i pool ntp.gig.holdings iburst maxsources 2" "$FILE"
else
    # If no pool directive was found, add the specified pool directive at the end of the file
    echo "pool ntp.gig.holdings iburst maxsources 2" >> "$FILE"
fi
# Add the user _chrony at the end of the file
echo "user _chrony" >> "$FILE"

timedatectl set-timezone Asia/Tehran

systemctl restart chrony
#verify that time daemon in changed to ntp
time_check