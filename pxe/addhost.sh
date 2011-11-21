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
                      #on supprime les . dans le hostname

                         hostname2=$(echo $hostname | tr -d '.'| tr '[:upper:]' '[:lower:]')   

                         if grep -Fi $hostname2 $DHCPFILE >/dev/null 2>&1; then
	                       echo "le host existe deja";
	                       exit 1
                         fi

                     #on verifie que le host est bien enregistre au DNS

                      if ! host $hostname2 >/dev/null 2>&1 ; then
			    echo "$hostname2 n'est pas une entree valide du dns"
			    echo "Pour memoire, le nom ne doit pas contenir de point ni de majuscule ou de nom de domaine"
                            echo "le host doit etre enregistre au  DNS pour pouvoir etre cree"
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

       pxemacaddress=01-$(cat $DHCPFILE | grep -1 $hostname2 | grep hardware | awk '{print $3}' | cut -d ";" -f1 | sed "s/:/-/g")
             echo "desirez vous creer le fichier pxelinux.cfg/$pxemacaddress ? [y/n]"
             read createpxefile

             if [ "$createpxefile" = "y" ]; then
                     CreePxeFileCommun
                     exit 1
                 fi
  
              exit 1
    }
    #------------------------------------------------
    # DhcpAddHosts - Ajout de plusieurs hosts
    #------------------------------------------------
    DhcpAddHosts()
    {
           #Jusqu'a ce que la reponse soit composée par un nombre, j'attends la saisie
           until [[ ${nombre} =~ ^[0-9]+$ ]]; do
            echo "Combien de hosts allez-vous ajouter ?"
           read nombre
           done
 
           #On execute $nombre de fois le script de creationn des hosts
                 for (( i=${nombre}; i>=1; i-- ))
                 do
                     DhcpAddHost
                 done

    }
    
    #------------------------------------------------
    # CreePxeFile - Creation du fichier PXE
    #------------------------------------------------
    CreePxeFile()
    {
       echo "veuillez saisir le nom de la machine sans point ni nom de domaine"
       read hostname2
       pxemacaddress=01-$(cat $DHCPFILE | grep -1 $hostname2 | grep hardware | awk '{print $3}' | cut -d ";" -f1 | sed "s/:/-/g")
       CreePxeFileCommun
    }
    
    #------------------------------------------------
    # CreePxeFileCommun - Creation du fichier PXE
    #------------------------------------------------
    CreePxeFileCommun()
    {
       echo "Veuillez selectionner le systeme: lenny ou squeeze rhel4 ou rhel5"
       read system
       case $system in
       lenny|squeeze)
       distrib="debian"
       echo "le system choisit est $distrib $system"

        cp $PXEDEBIANTEMPLATE /opt/scripts/pxe/hostfiles/pxedebianfile.$hostname2
        finalpxefile=/opt/scripts/pxe/hostfiles/pxedebianfile.$hostname2 
        sed -i "s/<hostname>/$hostname2/g" $finalpxefile
        sed -i "s/<system>/$system/g" $finalpxefile
    ;;

       rhel4|rhel5)
       distrib="redhat"
       echo "le system choisit est $distrib $system"
        cp $PXEREDHATTEMPLATE /opt/scripts/pxe/hostfiles/pxeredhatfile.$hostname2
        finalpxefile=/opt/scripts/pxe/hostfiles/pxeredhatfile.$hostname2
        sed -i "s/<hostname>/$hostname2/g" $finalpxefile
        sed -i "s/<system>/$system/g" $finalpxefile

    ;;
       * ) echo "La reponse doit etre lenny squeeze rhel4 ou rhel5" ;;
       esac

       echo "Veuillez selectionner l'architecture [32 ou 64 ]"
       read arch
       case $arch in
       32) echo "l'architecture choisie est $arch bits"
           truearch="i386"
        sed -i "s/<arch>/$arch/g" $finalpxefile
        sed -i "s/<truearch>/$truearch/g" $finalpxefile
    ;;
       64) echo "l'architecture choisie est $arch bits" 
           truearch="x86_64"
        sed -i "s/<arch>/$arch/g" $finalpxefile
        sed -i "s/<truearch>/$truearch/g" $finalpxefile
    ;;
       *)  echo "vous devez saisir 32 ou 64";;
       esac
       
     cp $finalpxefile /srv/tftp/pxelinux.cfg/$pxemacaddress
     ln -s /srv/tftp/pxelinux.cfg/$pxemacaddress $PXEREALNAMEDIR/$hostname2
     pxerealnamefile=$PXEREALNAMEDIR/$hostname2
     echo "le fichier $pxerealnamefile est cree"
     cp /opt/scripts/templates/pxe/templatepreseed$system /var/www/pxe/$distrib/$system/$hostname2.cfg 
     echo "le fichier /var/www/pxe/$system/$hostname2.cfg est cree"
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
