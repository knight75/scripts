#!/bin/sh

set -e
                                                                                                                                                                                                               
confdir=/opt/chroot/bind9/etc/bind/

cd $confdir

echo "check named.conf" 
        /usr/sbin/named-checkconf named.conf
echo "check named.conf.options"
       /usr/sbin/named-checkconf named.conf.options
echo "les fichiers de conf sont valides reload de bind"
       /etc/init.d/bind9 reload
