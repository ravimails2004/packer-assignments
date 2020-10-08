#!/bin/sh
set -x #trace on
set -e #break on error

# Update APT packages, upgrade existing then delete cache
apt update
apt upgrade -y
rm -rf /var/cache/apt/*

# Add user to run container: appuser
useradd -d /app -s /sbin/nologo -u 1000 appuser
sed -i -r 's/^appuser:!:/appuser:x:/' /etc/shadow

# Remove unnecessary user accounts.
sed -i -r '/^(appuser|root)/!d' /etc/group
sed -i -r '/^(appuser|root)/!d' /etc/passwd
sed -i -r '/^(appuser|root)/!d' /etc/shadow

# Remove interactive login shell for everybody but appuser.
sed -i -r '/^appuser:/! s#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd

# Removing files generated by sed commands above (group-, passwd- and shadow-)
find $sysdirs -xdev -type f -regex '.*-$' -exec rm -f {} +

sysdirs="
  /bin
  /etc
  /lib
  /sbin
  /usr
"

# Ensure system dirs are owned by root and not writable by anybody else.
find $sysdirs -xdev -type d \
  -exec chown root:root {} \; \
  -exec chmod 0755 {} \;

# Remove existing crontabs, if any.
rm -fr /var/spool/cron
rm -fr /etc/crontabs
rm -fr /etc/periodic
  
# Remove init scripts since we do not use them.
rm -fr /etc/init.d
rm -fr /lib/rc
rm -fr /etc/conf.d
rm -fr /etc/inittab
rm -fr /etc/runlevels
rm -fr /etc/rc.conf

# Remove kernel tunables since we do not need them.
rm -fr /etc/sysctl*
rm -fr /etc/modprobe.d
rm -fr /etc/modules

# Remove fstab since we do not need them.
rm -f /etc/fstab

# Remove all but a handful of admin commands.
find /sbin /usr/sbin ! -type d \
  -a ! -name nologin \
  -a ! -name go \
  -a ! -name sh \
  -delete

# Remove all but a handful of executable commands.
find /bin /usr/bin ! -type d \
  -a ! -name cd \
  -a ! -name ls \
  -a ! -name sh \
  -a ! -name bash \
  -a ! -name dir \
  -a ! -name rm \
  -a ! -name go \
  -a ! -name find \
  -a ! -name test \
  -a ! -name dash \
  -a ! -name chown \
  -a ! -name chmod \
  -a ! -name rm \
  -delete

# Remove broken symlinks (because we removed the targets above).
find $sysdirs -xdev -type l -exec test ! -e {} \; -delete
