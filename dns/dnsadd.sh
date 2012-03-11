###############################
#File manage by puppet
#Do not apply local modifications
##############################
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
zonesdir=Addyourzonesdirhere
daydate=$(date --rfc-3339=date | tr -d '-')
resetcnt="01"
serialupdated=$(echo $daydate$resetcnt)
      # menu constitution
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
      # Prompt menu
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
    # AddDnsEntry - Add a DNS entry
    #------------------------------------------------
    AddDnsEntry()
    {
	    shopt -s extglob

                 cd $zonesdir
		       echo "please tell us what is your zone (ex: toto.example.com or toto.test.example.net) : "
		       read aname
		       echo "Please enter ip address"
		       read ip

		       #no underscore in dns names

                       if  echo $aname | grep "_" ; then 
			       echo "un nom dns ne peut contenir d'underscore";
		       exit 1
			fi

			#we catch the zone
			hostavantzone=$(echo $aname | cut -d "." -f1)
			zone=$(echo $aname | sed -e "s/$hostavantzone./ /g")

			#findzone function

                        FindZone

                       if grep -RFiw $aname $zonesdir$zone.direct; then 
			       echo "host already exist";
			       exit 1
			fi

                       if grep -RFiw $ip $zonesdir$zone.direct; then 
			       echo "ip already taken";
			       exit 1
			fi

                      echo -e " Please confirm these informations are good :"
                      echo -e "\tZone: $zone"
                      echo -e "\tHostname: $aname"
                      echo -e "\tAdresse IP : $ip  "
                      echo -e "\vces parametres sont-ils valides ? [y/n]"
                      read confirm

                 if [ "$confirm" != "y" ]; then
                     echo "desole faut recommencer depuis le debut ;-)"
                     exit 1
	     else
		     echo "Modifications to make:"
		     echo -e "In file $zonesdir$zone.direct"
		     echo -e "Actual serial of  zone $zone.direct"
		     directserial=$(grep serial $zonedir$zone.direct | cut -d ";" -f1 | sed 's/ //g')
		     echo $directserial
		     directserialdate=$(grep serial $zonedir$zone.direct | cut -d ";" -f1 | sed 's/ //g' | cut -c 1-8)
		     echo -e "\t$directserial"
		     directserialversionincremente=`expr $directserial + 1` 
		     echo -e "Entree DNS"
		     echo -e "\t$aname. IN A $ip"

                     #since how many time the zone hasen't been updated

		     daydateratio=`expr $daydate - $directserialdate` 2>&1 > /dev/null

		     # if zone has been updated more than one day ago we increment all serial number
		     #else we just increment last number

                     if [ "$daydateratio" -ge 1 ]; then
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

		     daydateratio=`expr $daydate - $inverseserialdate` 2>&1 > /dev/null
		     # Si la zone a ete mise a jour a une date differente de aujourd'hui, on n'incremente pas le dernier chiffre
		     #sinon on incremente

                     if [ "$daydateratio" -ge 1 ]; then
		             echo -e "Numero de serie de la zone $zone.inverse a saisir"
		             echo -e "\t$serialupdated"
		     else
		             echo -e "Numero de serie de la zone $zone.inverse a saisir"
		             echo -e "\t$inverseserialversionincremente"
    		     fi
    		     fi

		     #call of function CGU
		     CGU

	     exit 0
    }
    #------------------------------------------------
    # DnsAddCname - Add CNAME to dns
    #------------------------------------------------
    DnsAddCname()
    {
                 cd $zonesdir
		 echo "Please enter cname (ex: toto.example.com) : "
		      read cname
		      echo "wich host does the CNAME refers to ? (no dot nor domainname)"
		      read hostcnamepointer

		       #no undercor in dns entries
                       if  echo $cname | grep "_" ; then 
			       echo "un nom dns ne peut contenir d'underscore";
		       exit 1
			fi

			#we get the zone
			hostavantzone=$(echo $cname | cut -d "." -f1)
			zone=$(echo $cname | sed -e "s/$hostavantzone./ /g")

			#findzone function

                        FindZone

                      if grep -RFi $cname $zonesdir$zone.direct; then 
			       echo "le host existe deja";
			       exit 1
		fi

                 echo -e "\t\nplease confirm these informations :"
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

		     daydateratio=`expr $daydate - $directserialdate` 2>&1 > /dev/null

		     # Si la zone a ete mise a jour a une date differente de aujourd'hui, on n'incremente pas le dernier chiffre
		     #sinon on incremente

                     if [ "$daydateratio" -ge 1 ]; then
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$serialupdated"
		     else
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$directserialversionincremente"
    		     fi

                 fi
		 #call of function CGU
		     CGU
exit 0
    }
    
    #------------------------------------------------
    # ModifHost - Modify or delete an entry
    #------------------------------------------------
    ModifHost()
    {
	    echo -e "\vwhich entry do you wish to modify ? (ex: toto.example.net)"
		 read entree

		#on recuperer la zone
		 hostavantzone=$(echo $entree | cut -d "." -f1)
		 zone=$(echo $entree | sed -e "s/$hostavantzone./ /g")

		#Findzone function

                 FindZone

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

		     daydateratio=`expr $daydate - $directserialdate` 2>&1 > /dev/null

		     # Si la zone a ete mise a jour a une date differente de aujourd'hui, on n'incremente pas le dernier chiffre
		     #sinon on incremente

                     if [ "$daydateratio" -ge 1 ]; then
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$serialupdated"
		     else
		             echo -e "Numero de serie de la zone $zone.direct a saisir"
		             echo -e "\t$directserialversionincremente"
    		     fi

                 fi
		 exit
    }

    
    #------------------------------------------------
    # fonctions- Starting this point are functions called in this script
    #------------------------------------------------
    #Automatically find zones 
    FindZone()
    {

			if  $(ls "$zonesdir/$zone.direct" > /dev/null 2>&1)  ;then
				echo -e "\t\nla zone choisie est : $zone"	
			elif echo "$zone" | grep "exceptzone1" > /dev/null 2>&1 ; then
			       zone="exceptzone1.example.net."	
				echo -e "\t\nla zone choisie est : $zone"	
			elif echo "$zone" | grep "exceptzone2" > /dev/null 2>&1; then
			       zone="exceptzone2.example.fr"	
				echo -e "\t\nla zone choisie est : $zone"	
			else   
				echo -e "\t\nit appears that we do not manage this zone"
			exit	
			fi
    }

    #DNS is manage by puppet
    #so you can wait around 30 minutes to get them synchronized or sync them with a puppet run

    CGU()
    {
	    echo -e "#########################################################################################"
	    echo -e "\nUne fois les Fichiers ci-dessus modifies, las alias peuvent-etre propages de 2 manieres: "
	    echo -e "         "
	    echo -e "\t-Normale: Dans les 30 minutes qui suivent les modifications"
	    echo -e "         "
	    echo -e "\t-Acceleree: se connecter a $dnshost\tTaper sudo puppetd --test"
	    echo -e "#########################################################################################"
    }

    #================================================
   # M A I N . . .
    #================================================
    Menu \
      "############################### Ajout Entrees au DNS #################################################" \
       AddDnsEntry "Ajouter une entree au DNS" \
       DnsAddCname "Ajouter un CNAME au DNS" \
       ModifHost "modifier ou supprimer une entree dns (CNAME, A)" \
