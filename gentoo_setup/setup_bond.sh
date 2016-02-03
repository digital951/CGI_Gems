/etc/init.d/dhcpcd stop
modprobe bonding mode=802.3ad miimon=100 lacp_rate=1
modprobe e100
cp /mnt/stuff/net /etc/conf.d/
cp /mnt/stuff/net.bond0 /etc/init.d/net.bond0
/etc/init.d/net.bond0 start
