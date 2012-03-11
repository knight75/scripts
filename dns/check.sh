#########################################
#File managed by puppet
#Do not mak ant local modifications
#########################################
#!/bin/sh


zonesdir=Addyourzonedirhere
serial=$(grep -Rh serial $zonesdir | cut -d ";" -f1 | sed 's/ //g' | awk -F : 'BEGIN{OFS="\t"} {$1=$1; print $0}')

#our dns zone serial may not have more han 10 numbers
#For all serial in zonesdir we check that none is more than 10 numbers long

for i in $serial; do
	if expr length $i \> 10 >/dev/null ; then
                   echo "this zone's serial is corrupted!! "
		   grep -R $i $zonesdir
		   echo "$i is not a valid serial"
                exit 1
                 fi
	 done
