#!/bin/bash
chown root:root /etc/passwd
chmod u-x,go-wx /etc/passwd
chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-
chown root:root /etc/group
chmod u-x,go-wx /etc/group
chown root:root /etc/group-
chmod u-x,go-wx /etc/group-
chown root:root /etc/shadow
chmod u-x,g-wx,o-rwx /etc/shadow
chown root:root /etc/shadow-
chmod u-x,g-wx,o-rwx /etc/shadow-
chown root:root /etc/gshadow
chmod u-x,g-wx,o-rwx /etc/gshadow
chown root:root /etc/gshadow-
chmod u-x,g-wx,o-rwx /etc/gshadow-
