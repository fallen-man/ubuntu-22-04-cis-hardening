#!/usr/bin/env bash

{
   l_mnames=("squashfs" "cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "udf" "fat") # set module names
   for l_mname in "${l_mnames[@]}"; do
      if ! modprobe -n -v "$l_mname" | grep -P -- '^\h*install \/bin\/(true|false)'; then
         echo -e " - setting module: \"$l_mname\" to be not loadable"
         echo -e "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mname".conf
      fi
      if lsmod | grep "$l_mname" > /dev/null 2>&1; then
         echo -e " - unloading module \"$l_mname\""
         modprobe -r "$l_mname"
      fi
      if ! grep -Pq -- "^\h*blacklist\h+$l_mname\b" /etc/modprobe.d/*; then
         echo -e " - deny listing \"$l_mname\""
         echo -e "blacklist $l_mname" >> /etc/modprobe.d/"$l_mname".conf
      fi
   done
}
