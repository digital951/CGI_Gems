#!/bin/bash

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

time genkernel all

emerge sys-kernel/linux-firmware
emerge eix genlop gentoolkit ccache logrotate app-misc/screen denyhosts ntp emacs vim syslog-ng vixie-cron htop atop mlocate xfsprogs
updatedb


touch /etc/portage/package.use/postgres
echo 'dev-db/postgresql -ldap' >> /etc/portage/package.use/postgres


echo 'hostname="canyon"' > /etc/conf.d/hostname
touch /etc/conf.d/net
echo 'config_enp3s0="128.206.116.232 netmask 255.255.255.192 brd 128.206.116.255"
routes_enp3s0="default via 128.206.116.254"

config_enp2s0="172.16.200.232 netmask 255.255.255.0 brd 172.16.200.255"

dns_domain="cgi.missouri.edu"
dns_servers="128.206.116.40 128.206.116.41 128.206.130.244 128.206.6.244"
dns_search="cgi.missouri.edu"' > /etc/conf.d/net


ln -s /etc/init.d/net.lo /etc/init.d/net.enp3s0
ln -s /etc/init.d/net.lo /etc/init.d/net.enp2s0

#edit network & hostname
#sim link eth(s)

rc-update add net.enp3s0 default
rc-update add net.enp2s0 default
rc-update add syslog-ng default
rc-update add vixie-cron default
rc-update add sshd default
rc-update add denyhosts default
rc-update add ntp-client default
rc-update add ntpd default

emerge sys-boot/grub
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg

echo 'FEATURES="ccache"' >> /etc/portage/make.conf

#SET PASSWORD

exit 


cd 

umount -l /mnt/gentoo/dev{/shm,/pts,} 
umount -l /mnt/gentoo/sys/
umount /mnt/gentoo{/boot,/proc,} 
sync

reboot




#Canyon fstab
# /etc/fstab: static file system information.
#
# noatime turns off atimes for increased performance (atimes normally aren't
# needed); notail increases performance of ReiserFS (at the expense of storage
# efficiency).  It's safe to drop the noatime options if you want and to
# switch between notail / tail freely.
#
# The root filesystem should have a pass number of either 0 or 1.
# All other filesystems should have a pass number of 0 or greater than 1.
#
# See the manpage fstab(5) for more information.
#

# <fs>			<mountpoint>	<type>		<opts>		<dump/pass>

# NOTE: If your BOOT partition is ReiserFS, add the notail option to opts.
/dev/sda2		/boot		ext3		noauto,noatime	1 2
/dev/sdb2		/		xfs		noatime		0 1
/dev/sdb1		none		swap		sw		0 0
/dev/cdrom		/mnt/cdrom	auto		noauto,ro	0 0
/dev/fd0		/mnt/floppy	auto		noauto		0 0



