#!/bin/bash
if [ "$(id -u)" -ne "0" ]; then
  echo "Veuillez lancer ce script en tant que root ou via la commande sudo"
  exit 2
fi

clear

Menu()
{
 local -a menu fonc
 local titre nbchoix
zonesdir=i/etc/puppet/modules/dns/files/zones/
daydate=$(date --rfc-3339=date | tr -d '-')
resetcnt="01"
serialupdated=$(echo $daydate$resetcnt)
      # Constitution du menu
      if [[ $(( $# % 1 )) -ne 0 ]] ; then
echo "$0 - Menu invalide" >&2
         return 1
      fi
titre="$1"
      shift 1
      set "$@" "return 0" "Sortie"
      while [[ $# -gt 0 ]]
      do
         (( nbchoix += 1 ))
         fonc[$nbchoix]="$1"
         menu[$nbchoix]="$2"
         shift 2
      done
      # Affichage menu
      echo -e "\t\vCe script ne modifie pas directement les fichiers de zones, vous ne risquez donc pas de casser quoique ce soit "
      PS3="Votre choix ? "
      while :
      do
echo
         [[ -n "$titre" ]] && echo -e "$titre\n"
         select choix in "${menu[@]}"
         do
if [[ -z "$choix" ]]
               then echo -e "\nChoix invalide"
               else eval ${fonc[$REPLY]}
            fi
break
done || break
done
    }
    #------------------------------------------------
    # AddDnsEntry - Ajout d'une entree host au DNS
    #------------------------------------------------
    AddDnsEntry()
    {
                 cd $zonesdir
		       echo "veuillez entrer le nom de la zone que vous desirez mettre a jour (ex: example.com)"
		       read zone
		       echo "Veuillez saisir le hostname (ex: toto.example.com) : "
		       read aname
		       echo "veuillez saisir l'adresse ip"
		       read ip

                       if grep -RFi $aname $zonesdir$zone.direct; then 
			       echo "le host existe deja";
			       exit 1
			fi

                      echo -e " veuillez verifier les informations ci-dessous :"
                      echo -e "\tZone: $zone"
                      echo -e "\tHostname: $aname"
                      echo -e "\tAdresse IP : $ip  "
                      echo -e "\vces parametres sont-ils valides ? [y/n]"
                      read confirm

                 if [ "$confirm" != "y" ]; then
                     echo "desole faut recommencer depuis le debut ;-)"
                     exit 1
	     else
		     echo "Modifications a apporter:"
		     echo -e "Dans le fichier $zonesdir$zone.direct"
		     echo -e "Numero de serie actuel de la zone $zone.direct"
		     directserial=$(grep serial $zonedir$zone.direct | cut -d ";" -f1 | sed 's/ //g')
		     directserialdate=$(grep serial $zonedir$zone.direct | cut -d ";" -f1 | sed 's/ //g' | cut -c 1-8)
		     echo -e "\t$directserial"
		     directserialversionincremente=`expr $directserial + 1` 
		     echo -e "Entree DNS"
		     echo -e "\t$aname. IN A $ip"

                     #on calcule le temps depuis lequel la zone n'a pas ete mise a jour

		     daydateratio= expr $daydate - $directserialdate 2>&1 > /dev/null

		     # Si la zone a ete mise a jour a une date differente de aujourd'hui, on n'incremente pas le dernier chiffre
		     #sinon on incremente

                     if [ "$daydateratio" != "0" ]  ; then
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$serialupdated"
		     else
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$directserialversionincremente"
    		     fi


		     echo -e "\vDans le fichier $zonesdir$zone.inverse"
		     echo -e "Numero de serie actuel de la zone $zone.inverse"
		     inverseserial=$(grep serial $zonedir$zone.inverse | cut -d ";" -f1 | sed 's/ //g')
		     inverseserialdate=$(grep serial $zonedir$zone.inverse | cut -d ";" -f1 | sed 's/ //g' | cut -c 1-8)
		     echo -e "\t$inverseserial"
		     inverseserialversionincremente=`expr $inverseserial + 1` 

		     echo -e "Entree DNS"
		     echo -e "\t$(echo "$ip" | cut -d '.' -f4).$(echo "$ip" | cut -d '.' -f3).$(echo "$ip" | cut -d '.' -f2).$(echo "$ip" | cut -d '.' -f1).in-addr.arpa. IN PTR $aname."

                     #on calcule le temps depuis lequel la zone n'a pas ete mise a jour

		     daydateratio= expr $daydate - $inverseserialdate 2>&1 > /dev/null
		     # Si la zone a ete mise a jour a une date differente de aujourd'hui, on n'incremente pas le dernier chiffre
		     #sinon on incremente

                     if [ "$daydateratio" != "0" ]  ; then
		             echo -e "Numero de serie de la zone $zone.inverse a saisir"
		             echo -e "\t$serialupdated"
		     else
		             echo -e "Numero de serie de la zone $zone.inverse a saisir"
		             echo -e "\t$inverseserialversionincremente"
    		     fi
    		     fi
	     exit 0
    }
    #------------------------------------------------
    # DnsAddCname - Ajout de CNAME au dns
    #------------------------------------------------
    DnsAddCname()
    {
                 cd $zonesdir
		      echo "veuillez entrer le nom de la zone que vous desirez mettre a jour (ex: example.com)"
		      read zone
		      echo "Veuillez saisir le cname (ex: turlutto.example.com) : "
		      read cname
		      echo "vers quel host doit pointer le CNAME ? (sans point ni nom de domaine)"
		      read hostcnamepointer
                      if grep -RFi $cname $zonesdir$zone.direct; then 
			       echo "le host existe deja";
			       exit 1
		fi

                 echo " veuillez verifier les informations ci-dessous :"
                      echo "zone: $zone"
                      echo "cname: $cname"
                      echo "machine vers laquelle pointe le CNAME : $hostcnamepointer  "

                 echo "ces parametres sont-ils valides ? [y/n]"
                 read confirm

                 if [ "$confirm" != "y" ]; then
                     echo "desole faut recommencer depuis le debut ;-)"
                     exit 1
	     else
		     echo "Modifications a apporter:"
		     echo -e "Dans le fichier $zonesdir$zone.direct"
		     echo -e "Numero de serie actuel de la zone $zone.direct"
		     directserial=$(grep serial $zonedir$zone.direct | cut -d ";" -f1 | sed 's/ //g')
		     directserialdate=$(grep serial $zonedir$zone.direct | cut -d ";" -f1 | sed 's/ //g' | cut -c 1-8)
		     echo -e "\t$directserial"
		     directserialversionincremente=`expr $directserial + 1` 
		     echo -e "Entree DNS"
		     echo -e "\t$cname. IN CNAME $hostcnamepointer"

                     #on calcule le temps depuis lequel la zone n'a pas ete mise a jour

		     daydateratio= expr $daydate - $directserialdate 2>&1 > /dev/null

		     # Si la zone a ete mise a jour a une date differente de aujourd'hui, on n'incremente pas le dernier chiffre
		     #sinon on incremente

                     if [ "$daydateratio" != "0" ]  ; then
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$serialupdated"
		     else
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$directserialversionincremente"
    		     fi

                 fi
exit 0
    }
    #------------------------------------------------
    # ModifHost - Modifier ou supprimer une entree
    #------------------------------------------------
    ModifHost()
    {
		 echo "veuillez entrer le nom de la zone que vous desirez mettre a jour (ex: example.com)"
		 read zone
		 echo -e "\vQuelle entree desirez-vous modifier?"
		 read entree

		 if grep -R $entree $zonesdir$zone.* 2>&1 > /dev/null ;
		 then
		              echo -e "Numero de serie actuel de la zone $zone.direct"
		              directserial=$(grep serial $zonesdir$zone.direct | cut -d ";" -f1 | sed 's/ //g')
		              directserialdate=$(grep serial $zonesdir$zone.direct | cut -d ";" -f1 | sed 's/ //g' | cut -c 1-8)
		              echo -e "\t$directserial"
		              directserialversionincremente=`expr $directserial + 1` 

			      echo -e "\t\vFichiers a modifier\t\t\t\t\tpartie a modifier"
			      modifs= grep -R  $entree $zonesdir$zone.* | awk -F : 'BEGIN{OFS="\t"} {$1=$1; print $0}' 
			      echo -e "\t\v$modifs"

                              #on calcule le temps depuis lequel la zone n'a pas ete mise a jour

		              daydateratio= expr $daydate - $directserialdate 2>&1 > /dev/null

		             # Si la zone a ete mise a jour a une date differente de aujourd'hui, on n'incremente pas le dernier chiffre
		             #sinon on incremente

                      if [ "$daydateratio" != "0" ]  ; then
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$serialupdated"
		     fi

	   fi
		 exit
    }

    
    #================================================
   # M A I N . . .
    #================================================
    Menu \
      "############################### Ajout Entrees au DNS #################################################" \
       AddDnsEntry "Ajouter une entree au DNS" \
       DnsAddCname "Ajouter un CNAME au DNS" \
       ModifHost "modifier ou supprimer une entree dns (CNAME, A)" \
