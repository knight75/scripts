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
zonesdir=/etc/puppet/modules/dns/files/zones/
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
		       echo "veuillez entrer le nom de la zone que vous desirez mettre a jour (ex: foo.com)"
		       read zone
		       echo "Veuillez saisir le hostname sans point ni nom de domaine (ex: toto et pas toto.foo.com) : "
		       read aname
		       echo "veuillez saisir l'adresse ip"
		       read ip

                       if grep -RFi $aname $zoneisdir$zone.direct; then 
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
		     echo -e "Numero de serie de la zone"
		     directserial= grep serial $zonesdir$zone.direct
		     echo -e "Entree DNS"
		     echo -e "\t$aname.$zone. IN A $ip"

		     echo -e "\vDans le fichier $zonesdir$zone.inverse"
		     echo -e "Numero de serie de la zone"
		     echo -e "Entree DNS"
		     inverseserial= grep serial $zonesdir$zone.inverse
		     echo -e "Entree DNS"
		     echo -e "\t$(echo "$ip" | cut -d '.' -f4).$(echo "$ip" | cut -d '.' -f3).$(echo "$ip" | cut -d '.' -f2).$(echo "$ip" | cut -d '.' -f1).in-addr.arpa. IN PTR $aname.$zone."

                 fi
exit 0
    }
    #------------------------------------------------
    # DnsAddCname - Ajout de CNAME au dns
    #------------------------------------------------
    DnsAddCname()
    {
                 cd $zonesdir
		      echo "veuillez entrer le nom de la zone que vous desirez mettre a jour (ex: foo.com)"
		      read zone
		      echo "Veuillez saisir le cname sans point ni nom de domaine (ex: toto et pas toto.foo.com) : "
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
		     echo -e "Numero de serie de la zone"
		     directserial= grep serial $zonesdir$zone.direct
		     echo -e "Entree DNS"
		     echo -e "\t$cname.$zone. IN CNAME $hostcnamepointer"

                 fi
exit 0
    }
    
    #------------------------------------------------
    # Coucou - Blagounette RFM
    #------------------------------------------------
    Coucou()
    {
       echo "Read The Fucking Menu!!!!!!!"
    }
    
    #================================================
   # M A I N . . .
    #================================================
    Menu \
      "############################### Ajout Entrees au DNS #################################################" \
       AddDnsEntry "Ajouter une entree au DNS" \
       DnsAddCname "Ajouter un CNAME au DNS" \
       Coucou "Si vous tapez 3 c'est que vous n'avez pas pris la peine de lire ce menu" \
