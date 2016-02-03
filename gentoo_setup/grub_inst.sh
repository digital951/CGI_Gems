#!/bin/bash
env-update
grub2-install /dev/$1
grub2-mkconfig -o /boot/grub/grub.cfg
