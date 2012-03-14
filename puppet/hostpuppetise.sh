#!/bin/sh
machinespuppetisees="/opt/resultats/machines_puppetisees.txt"

while getopts :h:nl option;
do
case "$option" in
    "h") /opt/scripts/puppet/machines_puppetisees.sh 2>&1 > /dev/null
        if !(grep $OPTARG "$machinespuppetisees") ;
           then
           echo "Aucun hote puppetise ne contient $OPTARG dans son hostname" 
        fi ;;
    "n") 
    /opt/scripts/puppet/machines_puppetisees.sh ;;

    "l") 
    /opt/scripts/puppet/machines_puppetisees.sh 2>&1 > /dev/null 
    less $machinespuppetisees ;;

    *)
     echo "argument invalide essayez -l -n et -h";;
esac
done

