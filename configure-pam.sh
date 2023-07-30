#!/bin/bash

apt install libpam-pwquality
# change password lenght required
sed -i 's/^#minlen = 8/minlen = 14/' /etc/security/pwquality.conf
# change complexity required
sed -i 's/^#minclass = 0/minclass = 4/' /etc/security/pwquality.conf
echo "account   required    pam_faillock.so" >> /etc/pam.d/common-account
sudo sed -i '/pam_unix.so obscure use_authtok try_first_pass yescrypt/ s/$/ remember=5/' /etc/pam.d/common-password

# ensure all current passwords use configured encryption algorithm
{
   UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
   awk -F: -v UID_MIN="${UID_MIN}" '( $3 >= UID_MIN && $1 != "nfsnobody" ) { print $1 }' /etc/passwd | xargs -n 1 chage -d 0
}
