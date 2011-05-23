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
TEMPLATEFILE=/opt/scripts/templates/dhcpd.template
TEMPLATEDIR=/opt/scripts/templates
DHCPFILE=/etc/dhcp3/dhcpd.conf

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
    # DhcpAddHost - Ajout d'un host
    #------------------------------------------------
    DhcpAddHost()
    {
                 cd $TEMPLATEDIR
                 echo "Veuillez saisir le hostname sans point ni nom de domaine : "
                 read hostname
#on verifie que le host est bien enregistre au DNS

#                      if ! host $hostname >/dev/null 2>&1 ; then
#                            echo "le host doit etre enregistrer au  DNS pour pouvoir etre cree";
#                          exit 1
#                      fi
#on supprime les . dans le hostname

                         hostname2=$(echo $hostname | tr -d '.')   

                         if grep -Fi $hostname2 $DHCPFILE >/dev/null 2>&1; then
	                       echo "le host existe deja";
	                       exit 1
                         fi

                 echo "Veuillez saisir l'ip :"
                 read ip
                         subnet=$(echo $ip | cut -d "." -f3)

                 echo "Veuillez saisir la macaddress:"
                 read macaddress

                 if expr length $macaddress \< 17 >/dev/null; then
                   echo "une adresse MAC doit etre au format xx:xx:xx:xx:xx:xx "
                 exit 1
                 fi


                 echo " veuillez verifier les informations ci-dessous :"

                      echo "hostname: $hostname"
                      echo "adresse ip: $ip"
                      echo "adresse MAC :  $macaddress"

                 echo "ces parametres sont-ils valides ? [y/n]"
                 read confirm

                 if [ "$confirm" != "y" ]; then
                     echo "desole faut recommencer depuis le debut ;-)"
                     exit 1
                 fi
              
              #sauvegarde du fichier /etc/dhcp/hdcpd.conf

              cp $DHCPFILE /opt/scripts/pxe/backup/

             #creation du fichier final
             echo "Ajout de l'hote au dhcp"

             cp $TEMPLATEFILE /opt/scripts/pxe/hostfiles/dhcpd.conf.$hostname2
             finaldhcpfile=/opt/scripts/pxe/hostfiles/dhcpd.conf.$hostname2 
              sed -i "s/<hostname>/$hostname2/g" $finaldhcpfile
              sed -i "s/<subnet>/$subnet/g" $finaldhcpfile
              sed -i "s/<macaddress>/$macaddress/g" $finaldhcpfile
              exit 1
    }
    #------------------------------------------------
    # DhcpAddHosts - Ajout de plusieurs hosts
    #------------------------------------------------
    DhcpAddHosts()
    {
       echo -e "\n***\n*** AddHosts\n***\n"
    }
    
    
    #------------------------------------------------
    # CreePxeFile - Creation du fichier PXE
    #------------------------------------------------
    CreePxeFile()
    {
       echo -e "\n***\n*** CreePxeFile\n***\n"
    }
    
    #================================================
   # M A I N . . .
    #================================================
    Menu \
      "############################### Menu PXE #################################################" \
       DhcpAddHost "Ajouter d'un host au DHCP" \
       DhcpAddHosts "Ajouter plusieurs hosts au DHCP" \
       CreePxeFile "Creation du fichier d'install PXE pour un host" \
