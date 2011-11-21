#!/bin/bash
# -*- coding: UTF8 -*-

#recuperation du hostname sans le nom de domaine
hostnamenodomain=$(echo $(hostname -s))
#recuperation du hostname jusqu'au 3eme element
ferme=$(echo "$hostnamenodomain" | cut -d "-" -f-3)
ferme2=$(echo "$hostnamenodomain" | cut -d "-" -f-2)
#fichier dans lequel seront stockes les noms des hosts de la ferme a mettre a jour
listerps=/opt/scripts/apache/listerp/listerptoupdate.txt
#au debut de chaque mise a jour on supprime l'ancien fichier
rm -f $listerps

# on  determine tous les hosts enregistres au dns avec la mem base de nom de machine
# maximum 9 rp peuvent etre trouves (10 - le rp sur lequel on se trouve)
i=1
limit=10

echo -e "\tDecouverte des hosts composant la ferme"

if [ "$ferme" != "specialferme" ]; then
echo -e "\tnous sommes sur la ferme $ferme2"
while (($i < $limit)); do
	fermehostname=$(echo "$ferme" | sed 's/.\{1\}$//')
	host $ferme2-0$i | grep -v "not found" | grep -v $ferme |cut -d " " -f1 | cut -d "." -f1 >> $listerps
	i=$((i + 1));
done

else
echo -e "\tnous sommes sur la ferme $ferme"
while (($i < $limit)); do
	fermehostname=$(echo "$ferme" | sed 's/.\{1\}$//')
	host $ferme2-0$i | grep -v "not found" | grep -v $ferme |cut -d " " -f1 | cut -d "." -f1 >> $listerps
	i=$((i + 1));
done
fi
	echo -e "\thosts qui seront mis a jour:"
        cat $listerps
