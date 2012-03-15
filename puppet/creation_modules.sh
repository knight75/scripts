#!/bin/sh
cd /etc/puppet/modules

echo "saisissez le nom du module: "
read module
echo "creation des dossiers"
mkdir -p $module/manifests
mkdir -p $module/files
mkdir -p $module/templates
mkdir -p $module/lib
mkdir -p $module/definitions
touch $module/params.pp
echo "dossier $module cree avec les sous-dossiers!"
