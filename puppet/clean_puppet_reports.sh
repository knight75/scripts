#! /bin/sh
# puppet-reports-clean
# vagn scott, 21-jul-2011
###########################################
#Fichier de ploye par puppet
#Ne pas faire de modification locale
##########################################


days="+7"       # more than 7 days old

for d in `find /var/lib/reports -mindepth 1 -maxdepth 1 -type d`
do
	       find $d -type f -name \*.yaml -mtime $days |
	              sort -r |
		             tail -n +2 |
			            xargs -n50 /bin/rm -f
			    done

			    exit 0
