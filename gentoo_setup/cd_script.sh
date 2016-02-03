#!/bin/bash

#Setup Tubes
#Partition Disks
#Make filesystems
#Mount Disks 



swapon /dev/sda2
echo 'nameserver 172.16.10.1' >> /etc/resolv.conf
ntpdate 172.16.10.1
cd /mnt/gentoo

IMAGE=`curl http://lug.mtu.edu/gentoo/releases/amd64/autobuilds/current-stage3-amd64/ | grep stage3-amd64 | grep -v CONTENTS | grep -v DIGESTS | grep -v nomultilib | grep -v Index | cut -d '=' -f2 | cut -d '>' -f1 | cut -d '"' -f2`

wget http://lug.mtu.edu/gentoo/releases/amd64/autobuilds/current-stage3-amd64/${IMAGE}
#wget http://lug.mtu.edu/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20151112.tar.bz2
tar xvjpf stage3-*.tar.bz2 --xattrs
echo MAKEOPTS="-j13" >> /mnt/gentoo/etc/portage/make.conf
sed -i 's/^USE.*/USE="-X apache2 bindist crypt cxx fastcgi git -gnome gnutls -gtk -kde ldap mmx php postgres -qt4 -qt5 unicode sasl sse sse2"/' /mnt/gentoo/etc/portage/make.conf
sed -i 's/^CFLAGS.*/CFLAGS="-march=native -O2 -pipe"/' /mnt/gentoo/etc/portage/make.conf
echo 'GENTOO_MIRRORS="http://lug.mtu.edu/gentoo/"' >> /mnt/gentoo/etc/portage/make.conf
mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
echo 'nameserver 172.16.10.1
nameserver 172.16.10.2' >> /mnt/gentoo/etc/resolv.conf

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


touch /etc/portage/package.use/postgres
echo 'dev-db/postgresql -ldap -sasl' >> /etc/portage/package.use/postgres
touch /etc/portage/package.use/tty-helpers
echo 'sys-apps/util-linux tty-helpers' >> /etc/portage/package.use

emerge sys-kernel/linux-firmware
emerge eix genlop gentoolkit ccache logrotate app-misc/screen denyhosts ntp emacs vim syslog-ng vixie-cron htop atop mlocate xfsprogs net-dns/bind-tools nfs-utils sys-apps/util-linux
updatedb


#NETWORK CONFIGURATION

echo 'hostname="t4ds-comp-p01"' > /etc/conf.d/hostname
touch /etc/conf.d/net
echo 'config_enp10s0="172.16.10.10 netmask 255.255.254 brd 172.16.11.255"
routes_enp10s0="default via 172.16.10.1"

dns_domain="cgi.missouri.edu"
dns_servers="172.16.10.1 172.16.10.2"
dns_search="cgi.missouri.edu"' > /etc/conf.d/net


ln -s /etc/init.d/net.lo /etc/init.d/net.enp10s0

#edit network & hostname
#sim link eth(s)

rc-update add net.enp10s0 default
rc-update add syslog-ng default
rc-update add vixie-cron default
rc-update add sshd default
rc-update add denyhosts default
rc-update add ntp-client default
rc-update add ntpd default

#LL ALIAS
touch /etc/profile.d/ll.sh
echo alias ll='ls -lah' >> /etc/profile.d/ll.sh

#GRUB ONLY
emerge sys-boot/grub
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg

echo 'FEATURES="ccache"' >> /etc/portage/make.conf

#SET PASSWORD






