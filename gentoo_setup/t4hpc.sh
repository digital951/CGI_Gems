#!/bin/bash

#Setup Tubes
#Partition Disks
#Make filesystems
#Mount Disks 



swapon /dev/sda2
echo 'nameserver 128.206.6.244' >> /etc/resolv.conf
ntpdate time.missouri.edu
cd /mnt/gentoo
wget http://lug.mtu.edu/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20151112.tar.bz2
tar xvjpf stage3-*.tar.bz2 --xattrs
echo MAKEOPTS="-j33" >> /mnt/gentoo/etc/portage/make.conf
sed -i 's/^USE.*/USE="-X apache2 bindist crypt cxx fastcgi git -gnome gnutls -gtk -kde ldap mmx php postgres -qt4 -qt5 unicode sasl sse sse2"/' /mnt/gentoo/etc/portage/make.conf
sed -i 's/^CFLAGS.*/CFLAGS="-march=native -O2 -pipe"/' /mnt/gentoo/etc/portage/make.conf
echo 'GENTOO_MIRRORS="http://lug.mtu.edu/gentoo/"' >> /mnt/gentoo/etc/portage/make.conf
mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
echo 'nameserver 128.206.6.244
nameserver 128.206.130.244' >> /mnt/gentoo/etc/resolv.conf

vi /mnt/gentoo/etc/fstab

#add wget for second script here

chroot /mnt/gentoo /bin/bash 
source /etc/profile 
export PS1="(chroot) $PS1"

#TODO
#edit network & hostname
#sim link eth(s)
#edit fstab

emerge-webrsync
echo "America/Chicago" > /etc/timezone
emerge --config sys-libs/timezone-data
eselect profile set 1
echo 'en_US ISO-8859-1
en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
eselect locale set 4
env-update && source /etc/profile
export PS1="(chroot) $PS1"
emerge sys-kernel/gentoo-sources
emerge genkernel 
#edit fstab



genkernel --menuconfig all


touch /etc/portage/package.use/postgresql
echo 'dev-db/postgresql -ldap' >> /etc/portage/package.use/postgresql

emerge sys-kernel/linux-firmware
emerge eix genlop gentoolkit ccache logrotate app-misc/screen denyhosts ntp emacs vim syslog-ng vixie-cron htop atop mlocate xfsprogs dev-db/postgresql nfs-utils nss-pam-ldapd
updatedb


#NETWORK CONFIGURATION

echo 'alias bond0 bonding
options bond0 mode=802.3ad miimon=100' > /etc/modules.d/bond.conf

echo 'hostname="t4ds-comp-p01"' > /etc/conf.d/hostname
touch /etc/conf.d/net
echo 'config_eno1="null"
config_eno3="null"

slaves_bond0="eno1 eno3"

mode_bond0="802.3ad"
miimon_bond0="100"
lacp_rate_bond0="1"

config_bond0="172.16.0.151/24"
routes_bond0="default via 172.16.0.254"

dns_domain="t4ds.lan.net"
dns_servers="128.206.6.244 128.206.130.244"
dns_search="t4ds.lan.net"' > /etc/conf.d/net


ln -s /etc/init.d/net.lo /etc/init.d/net.bond0

#Setup LDAP

##MAKE KEY FOR JANUS

scp root@aqua.cgi.missouri.edu:/etc/ssl/ldap.crt.pem /etc/ssl/ldap.crt.pem
scp root@aqua.cgi.missouri.edu:/etc/openldap/ldap.key.pem /etc/openldap/ldap.key.pem

touch /etc/openldap/ldap.conf
echo '
BASE    dc=t4ds,dc=net
URI     ldap://alpha.lan.t4ds.net

TLS_CERT     /etc/ssl/ldap.pem
TLS_KEY      /etc/openldap/ldap-key.pem
TLS_CACERT   /etc/ssl/ldap.pem
TLS_REQCERT     demand' > /etc/openldap/ldap.conf

touch /etc/openldap/ldap.conf
echo '
host  alpha.lan.t4ds.net
uri   ldap://alpha.lan.t4ds.net
base  dc=t4ds,dc=net

ldap_version 3
ssl on
ssl start_tls

tls_checkpeer no

scope sub
bind_policy soft

pam_password exop

pam_filter objectclass=posixAccount
pam_login_attribute uid
pam_member_attribute memberUid
pam_check_host_attr yes

nss_base_passwd ou=People,dc=t4ds,dc=net
nss_base_shadow ou=People,dc=t4ds,dc=net
nss_base_group  ou=groups,dc=t4ds,dc=net

nss_initgroups_ignoreusers ldap,openldap,mysql,syslog,root,postgres' > /etc/openldap/ldap.conf

touch /etc/nslcd.conf
echo 'uid nslcd
gid nslcd

uri   ldap://alpha.lan.t4ds.net

base  dc=t4ds,dc=net

scope sub

base group ou=groups,dc=t4ds,dc=net
base passwd ou=People,dc=t4ds,dc=net
base shadow ou=People,dc=t4ds,dc=net
scope group onelevel
scope hosts sub

pam_authz_search (&(objectClass=posixAccount)(uid=$username)(|(host=$hostname)(host=$fqdn)(host=\\*)))

bind_timelimit 30

timelimit 30

ssl on

ssl start_tls

tls_reqcert never' > /etc/nslcd.conf

touch /etc/pam.d/system-auth
echo '
auth            required        pam_env.so 
auth            sufficient      pam_unix.so try_first_pass likeauth
auth            sufficient      pam_ldap.so minimum_uid=1000 use_first_pass
auth            required        pam_deny.so
 
account         sufficient      pam_ldap.so minimum_uid=1000
account         required        pam_unix.so 
account         required        pam_succeed_if.so user = root
 
password        required        pam_cracklib.so difok=2 minlen=8 dcredit=2 ocredit=2 retry=3 
password        sufficient      pam_unix.so try_first_pass use_authtok nullok sha512 shadow 
password        sufficient      pam_ldap.so minimum_uid=1000 try_first_pass
password        required        pam_deny.so
 
session         required        pam_limits.so 
session         required        pam_env.so 
session         required        pam_unix.so 
session         optional        pam_ldap.so
session         optional        pam_permit.so' > /etc/pam.d/system-auth

touch /etc/nsswitch.conf
echo'
# /etc/nsswitch.conf:
# $Header: /var/cvsroot/gentoo/src/patchsets/glibc/extra/etc/nsswitch.conf,v 1.1 2006/09/29 23:52:23 vapier Exp $

passwd:      compat ldap
shadow:      compat ldap
group:       compat ldap

sudoers:     compat ldap

# passwd:    db files nis
# shadow:    db files nis
# group:     db files nis

hosts:       files dns
networks:    files dns

services:    db files
protocols:   db files
rpc:         db files
ethers:      db files
netmasks:    files
netgroup:    files
bootparams:  files

automount:   files
aliases:     files' > /etc/nsswitch.conf

touch /etc/ldap.conf.sudo
echo '
suffix dc=t4ds,dc=net
sudoers_base ou=sudoers,dc=t4ds,dc=net
host alpha.lan.t4ds.net' > /etc/ldap.conf.sudo






#edit network & hostname
#sim link eth(s)

rc-update add net.bond0 default
rc-update add syslog-ng default
rc-update add vixie-cron default
rc-update add sshd default
rc-update add denyhosts default
rc-update add ntp-client default
rc-update add ntpd default
rc-update add nslcd default
rc-update add rpc.statd default
rc-update add nfsclient default

#Create ll alias
touch /etc/profile.d/ll.sh
echo 'alias ll="ls -lah"' > /etc/profile.d/ll.sh

#GRUB ONLY
emerge sys-boot/grub
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg

echo 'FEATURES="ccache"' >> /etc/portage/make.conf

#SET PASSWORD






