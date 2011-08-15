#!/bin/sh

zonesdir=/opt/chroot/bind9/etc/bind/zones/

cd $zonesdir

                echo "Verification des zones avant le reload"   
                if ! /usr/sbin/named-checkconf -z  | /bin/grep "not loaded due to errors"
                then echo "reload bind"
                        /etc/init.d/bind9 reload
                else  echo "probleme detecte dans un fichier de zone. bind ne sera pas reloade"
                        exit
                fi

