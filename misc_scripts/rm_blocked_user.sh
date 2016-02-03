#!/bin/bash



if [ "$#" -lt 1 ]; then
    echo "Illegal number of parameters"
    echo "Usage $0 address1 address2 address3....."
    exit
fi

#if [[ $1 == *['!'@#\$%^\&*()_+]* ]]
#then
#  echo "It contains one of those"
#fi

#Ask are you sure
echo "Are you sure you want to remove:"
for rm_address in "$@"
do 
    echo "${rm_address}"
done

echo "
from:
/etc/hosts.deny
/var/lib/denyhosts/hosts
/var/lib/denyhosts/hosts-restricted
/var/lib/denyhosts/hosts-root 
/var/lib/denyhosts/hosts-vaild
/var/lib/denyhosts/user-hosts"
read -p "[y/N]? " -n 1 -r
#echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    #Stop DenyHosts
    /etc/init.d/denyhosts stop
	
    #Delete Stuff
    for rm_address in "$@"
        do

    	    sed -i "/${rm_address}/d" /etc/hosts.deny
            sed -i "/${rm_address}/d" /var/lib/denyhosts/hosts
            sed -i "/${rm_address}/d" /var/lib/denyhosts/hosts-restricted
            sed -i "/${rm_address}/d" /var/lib/denyhosts/hosts-root
            sed -i "/${rm_address}/d" /var/lib/denyhosts/hosts-vaild
            sed -i "/${rm_address}/d" /var/lib/denyhosts/user-hosts
            echo "${rm_address} removed"
	done
    #Start DenyHosts
    /etc/init.d/denyhosts start
else 
    echo "exited...."
fi


