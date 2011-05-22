#!/bin/bash
Menu()
{
 local -a menu fonc
 local titre nbchoix
 DHCPFILE=/opt/scripts/pxe/dhcp/dhcpd.conf
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
    # AddHost - Ajout d'un host
    #------------------------------------------------
    AddHost()
    {
                 cd /opt/scripts/pxe/dhcp
                 echo "quel est le hostname?"
                 read hostname

                 echo "saisissez la macadress?"
                 read macaddress

                 echo "quel est l'adresse IP?"
                 read IP

                 sed "s/<hostname>/$hostname/g" | sed "s/<macaddress>/$macaddress/g" $DHCPFILE
                 exit
    }
    #------------------------------------------------
    # AddHosts - Ajout de plusieurs hosts
    #------------------------------------------------
    AddHosts()
    {
       echo -e "\n***\n*** AddHosts\n***\n"
    }
    
    #================================================
   # M A I N . . .
    #================================================
    Menu \
      "+++ Menu PXE +++"                           \
       AddHost   "Ajouter un host"          \
       AddHosts  "Ajouter plusieurs hosts" \


