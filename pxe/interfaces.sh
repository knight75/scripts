#!/bin/bash

interfaces=/etc/network/interfaces
ip=`ifconfig eth0 |grep Masque|cut -d ':' -f2| cut -d ' ' -f1`
mask=`ifconfig eth0 |grep Masque|cut -d ':' -f4| cut -d ' ' -f1`
bcast=`route -n | tail -n2 |awk '{print $1}' | grep 10 | sed 's/.0$/.255/'`
gw=`route -n |tail -n1|cut -d' ' -f10`
net=`route -n | tail -n2 |awk '{print $1}' | grep 10`

sed -i 's/dhcp/static/g' $interfaces

echo "  address $ip" >> $interfaces
echo "  netmask $mask" >> $interfaces
echo "  network $net" >> $interfaces
echo "  broadcast $bcast" >> $interfaces
echo "  gateway $gw" >> $interfaces

echo "  # dns-* options are implemented by the resolvconf package, if installed" >> $interfaces                                                                                                                
echo "  dns-nameservers serveraddress serveraddress" >> $interfaces
echo "  dns-search domain" >> $interfaces
