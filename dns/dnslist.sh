########################
#File manage by puppet
#Do not make any local modification
#######################

#!/bin/bash

zonesdir=$puppetdir/$modulesdir/$dnsmodule/files/zones
cd $zonesdir

#List all dns aliases in zones

dnslist=/opt/scripts/dns/list.sh

  while getopts h:l option;
  do
	case "$option" in

		"h")  $dnslist | grep $OPTARG 
				       	;;
                "l")  $dnslist
				       	;;

		      *)
			   echo -e "unknown argument try -l or -h"
				       	;;
		      esac
     done

