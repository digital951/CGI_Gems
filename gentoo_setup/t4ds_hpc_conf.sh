#!/bin/bash

#HPC NODE PROVISIONING by Matthew J Blackwood

#USAGE CHECK
#if [ $# -eq 0 ]
#  then
#    echo "No arguments supplied"
#    echo "USAGE ./provision IP_ADDRESS HOSTNAME DISK"
#fi

#SETUP NETWORK
/mnt/stuff/setup_bond.sh
while ! ping -c1 172.16.0.254 &>/dev/null; do :; done


#SET VARIABLES
ip_address="172.16.0.151"
hostname="comp-p01"
disk="sda"

#SETUP SSH

mkdir -p /root/.ssh/
touch /root/.ssh/config
echo -e "HOST 172.16.0.9\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
chmod 600 /root/.ssh/config
cp /mnt/stuff/id_rsa /root/.ssh/
chmod 600 /root/.ssh/id_rsa

#SET IMAGE IP

#PARTITION DISKS
(echo o; echo n; echo p; echo 1; echo; echo +512M; echo a; echo n; echo p; echo 2; echo; echo +8GiB; echo n; echo p; echo 3; echo; echo; echo t;echo 2; echo 82; echo p; echo w;)| fdisk /dev/"${disk}"

#MAKE FILE SYSTEMS
mkfs.ext2 -F /dev/"${disk}"1
mkswap /dev/"${disk}"2
mkfs.xfs -f /dev/"${disk}"3

#MOUNT DISKS

mount /dev/"${disk}"3 /mnt/gentoo/
mkdir -p /mnt/gentoo/boot/
mkdir -p /mnt/boot/
mount /dev/"${disk}"1 /mnt/boot/

#RUN RSYNC
rsync -a root@172.16.0.9:/data/hpc_image/gentoo/* /mnt/gentoo/
rsync -a root@172.16.0.9:/data/hpc_image/boot/* /mnt/boot/

#SET HOST UNIQUE VARIABLES
sed -i "/config_bond0/ s/172.16.0.150/${ip_address}/" /mnt/gentoo/etc/conf.d/net
sed -i "/hostname/ s/t4ds-comp-image/${hostname}/" /mnt/gentoo/etc/conf.d/hostname


#REGEN HOST SSH KEYS
#/usr/bin/ssh-keygen -t rsa1 -b 2048 -f /mnt/getnoo/etc/ssh/ssh_host_key -N
#/usr/bin/ssh-keygen -d -f /mnt/gentoo/etc/ssh/ssh_host_dsa_key -N
echo -e 'y' | /usr/bin/ssh-keygen -t rsa -f /mnt/gentoo/etc/ssh/ssh_host_rsa_key -N "" 

#REMOUNT DISKS FOR CHROOT
sync
umount /mnt/boot
mount /dev/${disk}1 /mnt/gentoo/boot/

###MOUNT VOLUMES FOR CHROOT
mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

#INSTALL GRUB
chroot /mnt/gentoo/ /grub_inst.sh ${disk} 

#UNMOUNT VOLUMES
cd 

umount -l /mnt/gentoo/dev{/shm,/pts,} 
umount -l /mnt/gentoo/sys/
umount /mnt/gentoo{/boot,/proc,} 
sync

#REBOOT
reboot

#PROFIT
