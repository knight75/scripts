#!/bin/bash
Menu()
{
 local -a menu fonc
 local titre nbchoix
 DHCPFILE=/opt/scripts/dhcp/dhcpd.conf
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
       echo -e "\n***\n*** AddHost\n***\n"
                 cd /opt/scripts/dhcp
                 echo "quel est le hostname?\n"
                 read hostname

          cat $DHCPFILE | awk '{print "host " $1 " {\n    hardware ethernet " $2 ";\n    fixed-address " $3 ";\n    if substring (option vendor-class-identifier, 0, 9) = \"PXEClient\" {\n      filename \"PXEFILE\";\n    } else if substring (option vendor-class-identifier, 0, 9) = \"Etherboot\" {\n      filename \"ETHERBOOTFILE\";\n      option vendor-encapsulated-options 3c:09:45:74:68:65:72:62:6f:6f:74:ff;\n    }\n}\n"}'
#sed "s/PXEFILE/$PXEFILE/" | sed "s/ETHERBOOTFILE/$ETHERBOOTFILE/"
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


