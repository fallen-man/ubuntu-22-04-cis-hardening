#!/bin/bash
sed -e 's/^\([a-zA-Z0-9_]*\):[^:]*:/\1:x:/' -i /etc/passwd


# check local user and groups

awk -F: '($2 == "" ) { print $1 " does not have a password "}' /etc/shadow
for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
  grep -q -P "^.*?:[^:]*:$i:" /etc/group
  if [ $? -ne 0 ]; then
    echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group"
  fi
done

awk -F: '($1=="shadow") {print $NF}' /etc/group
awk -F: -v GID="$(awk -F: '($1=="shadow") {print $3}' /etc/group)" '($4==GID) {print $1}' /etc/passwd
cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x ; do
  [ -z "$x" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
    echo "Duplicate UID ($2): $users"
  fi
done
cut -d: -f3 /etc/group | sort | uniq -d | while read x ; do
    echo "Duplicate GID ($x) in /etc/group"
done
cut -d: -f1 /etc/passwd | sort | uniq -d | while read -r x; do
  echo "Duplicate login name $x in /etc/passwd"
done
cut -d: -f1 /etc/group | sort | uniq -d | while read -r x; do
  echo "Duplicate group name $x in /etc/group"
done
RPCV="$(sudo -Hiu root env | grep '^PATH' | cut -d= -f2)"
echo "$RPCV" | grep -q "::" && echo "root's path contains a empty directory (::)"
echo "$RPCV" | grep -q ":$" && echo "root's path contains a trailing (:)"
for x in $(echo "$RPCV" | tr ":" " "); do
   if [ -d "$x" ]; then
      ls -ldH "$x" | awk '$9 == "." {print "PATH contains current working directory (.)"}
      $3 != "root" {print $9, "is not owned by root"}
      substr($1,6,1) != "-" {print $9, "is group writable"}
      substr($1,9,1) != "-" {print $9, "is world writable"}'
   else
      echo "$x is not a directory"
   fi
done
awk -F: '($3 == 0) { print $1 }' /etc/passwd
{
   valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"
   awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do
      if [ ! -d "$home" ]; then 
         echo -e "\n- User \"$user\" home directory \"$home\" doesn't exist\n- creating home directory \"$home\"\n"
         mkdir "$home"
         chmod g-w,o-wrx "$home"
         chown "$user" "$home"
      fi
   done
}
{
   output=""
   valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"
   awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do
      owner="$(stat -L -c "%U" "$home")"
      if [ "$owner" != "$user" ]; then
         echo -e "\n- User \"$user\" home directory \"$home\" is owned by user \"$owner\"\n  - changing ownership to \"$user\"\n"
         chown "$user" "$home"
      fi
   done
}
{
  perm_mask='0027'
   maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
   valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"
   awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | (while read -r user home; do
      mode=$( stat -L -c '%#a' "$home" )
      if [ $(( $mode & $perm_mask )) -gt 0 ]; then
         echo -e "- modifying User $user home directory: \"$home\"\n- removing excessive permissions from current mode of \"$mode\""
         chmod g-w,o-rwx "$home"
      fi
   done
    )
}
{
   perm_mask='0177'
   valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"
   awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do
      if [ -f "$home/.netrc" ]; then
         echo -e "\n- User \"$user\" file: \"$home/.netrc\" exists\n - removing file: \"$home/.netrc\"\n"
         rm -f "$home/.netrc"
      fi
   done
}
{
   output=""
   fname=".forward"
   valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"
   awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | (while read -r user home; do
      if [ -f "$home/$fname" ]; then
         echo -e "$output\n- User \"$user\" file: \"$home/$fname\" exists\n  - removing file: \"$home/$fname\"\n"
         rm -r "$home/$fname"
      fi
   done
   )
}
{
   perm_mask='0177'
   valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"
   awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do
      if [ -f "$home/.rhosts" ]; then
         echo -e "\n- User \"$user\" file: \"$home/.rhosts\" exists\n - removing file: \"$home/.rhosts\"\n"
         rm -f "$home/.rhosts"
      fi
   done
}
{
   perm_mask='0022'
   valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"
   awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do
      find "$home" -type f -name '.*' | while read -r dfile; do
         mode=$( stat -L -c '%#a' "$dfile" )
         if [ $(( $mode & $perm_mask )) -gt 0 ]; then
            echo -e "\n- Modifying User \"$user\" file: \"$dfile\"\n- removing group and other write permissions"
            chmod go-w "$dfile"
         fi
      done
   done
}