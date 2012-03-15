###################################
#Fichier deploye par puppet
#Ne pas faire de modification locale
######################################

#!/bin/bash
#soon puppet runs will be managed by mcollective puppetcommander
#this script use for debian squeeze restart puppet randomly
 
sleepytime=$(( RANDOM % 3600 ))
 
sleep $sleepytime
/etc/init.d/puppet restart  2>&1 > /dev/null
 
exit 0

