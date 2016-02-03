#!/bin/bash

wget -q -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | bash

yum install srvadmin-all -y
yum install OpenIPMI
/etc/init.d/ipmi start
/opt/dell/srvadmin/sbin/srvadmin-services.sh restart
#NEED IPTABLES / FIREWALLD RULE
yum install dell_ft_install
yum install $(bootstrap_firmware)
update_firmware --yes

