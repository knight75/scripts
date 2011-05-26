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
HOSTTEMPLATEFILE=/opt/scripts/templates/pxe/dhcpd.template
TEMPLATEDIR=/opt/scripts/templates/pxe
DHCPDAEMON=/etc/init.d/isc-dhcp-server
DHCPFILE=/etc/dhcp/dhcpd.conf
SUBNETTEMPLATEFILE=/opt/scripts/templates/pxe/dhcpd.template_subnet
PXEROOTDIR=/srv/tftp/pxelinux.cfg
PXEREALNAMEDIR=/srv/tftp/pxelinux.cfg/realnames
PXEDEBIANTEMPLATE=/opt/scripts/templates/pxe/pxedebiantemplate
PXEREDHATTEMPLATE=/opt/scripts/templates/pxe/pxeredhattemplate
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

                      if ! host $hostname >/dev/null 2>&1 ; then
                            echo "le host doit etre enregistrer au  DNS pour pouvoir etre cree"
                          exit 1
                      fi
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
              #si le subnet n'est pas présent dans le dhcpd.conf on le cree

              if ! grep "subnet 10.167.$subnet.0" $DHCPFILE  >/dev/null 2>&1 ; then
                        echo "le vlan $subnet n'existe pas dans le fichier dhcpd.conf. Nous allons l'ajouter"
                        cp $SUBNETTEMPLATEFILE /opt/scripts/pxe/hostfiles/dhcpd.conf.$subnet
                        newsubnetfile=/opt/scripts/pxe/hostfiles/dhcpd.conf.$subnet
                        sed -i "s/<subnet>/$subnet/g" $newsubnetfile
                        cat $newsubnetfile >> $DHCPFILE
              fi

             #creation du fichier final
             echo "Ajout de l'hote au dhcp"

             cp $HOSTTEMPLATEFILE /opt/scripts/pxe/hostfiles/dhcpd.conf.$hostname2
             finaldhcpfile=/opt/scripts/pxe/hostfiles/dhcpd.conf.$hostname2 
              sed -i "s/<hostname>/$hostname2/g" $finaldhcpfile
              sed -i "s/<faddress>/$hostname/g" $finaldhcpfile
              sed -i "s/<macaddress>/$macaddress/g" $finaldhcpfile

              while read line
             do 
             sed -i "/vlan$subnet/ a \ $line" $DHCPFILE ;
             done < $finaldhcpfile

             echo "host ajoute"

             echo "redemarrage du serveur dhcp"
             $DHCPDAEMON restart

             echo "desirez vous creer le fichier pxelinux.cfg/01-macaddress?"
             read createpxefile

             if [ "$createpxefile" = "y" ]; then
                     CreePxeFile
                     exit 1
                 fi
  
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
       echo "veuillez saisir le nom de la machine sans point ni nom de domaine"
       read pxehostname


       echo "Veuillez selectionner le systeme: Lenny ou Squeeze RHEL4 ou RHEL5"
       read system
       pxemacaddress=01-$(cat $DHCPFILE | grep -1 $hostname | grep hardware | awk '{print $3}' | cut -d ";" -f1 | sed "s/:/-/g")
       case $system in
       Lenny) echo "le system choisit est Debian Lenny"
       sed -i "s/<hostname>/$pxehostname/g" $PXEDEBIANTEMPLATE
       sed -i "s/<system>/$system/g" $PXEDEBIANTEMPLATE
       echo "Veuillez selectionner l'architecture [32 ou 64 ]"
       read arch

       sed -i "s/<arch>//g" $PXEDEBIANTEMPLATE
       
 ;;
       R) echo Hello ;;
       * ) echo "La reponse doit etre D ou R" ;;
       esac

       echo "Veuillez selectionner l'archtitecture: 64 ou 32 bits :"
       read system
       case $system in
       64 ) echo Bonjour ;;
       32) echo Hello ;;
       * ) echo "La reponse doit etre 32 ou 64" ;;
       esac


    cp $PXEDEBIANTEMPLATE /srv/tftp/pxelinux.cfg/$pxemacaddress
    ln -s /srv/tftp/pxelinux.cfg/$pxemacaddress $PXEREALNAMEDIR/$pxehostname
    pxerealnamefile=$PXEREALNAMEDIR/$pxehostname
    echo "le fichiere est cree"

    echo "il reste eventuellement a editer le fichier $pxerealnamefile pour modifier l'url du fichier pressed ou kickstart"

              exit 1
    }
    
    #================================================
   # M A I N . . .
    #================================================
    Menu \
      "############################### Menu PXE #################################################" \
       DhcpAddHost "Ajouter d'un host au DHCP" \
       DhcpAddHosts "Ajouter plusieurs hosts au DHCP" \
       CreePxeFile "Creation du fichier d'install PXE pour un host" \
