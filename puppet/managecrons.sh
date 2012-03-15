#!/bin/bash
# -*- coding: UTF8 -*-


crondir=/etc/puppet/files/crons
listhostpuppetises=/opt/scripts/puppet/machines_puppetisees.sh 
resultfile=/opt/resultats/machines_puppetisees.txt

#we make the puppet nodes resultfile
$listhostpuppetises 2>&1 > /dev/null

#no org, .net, etc... except for nodes .example
cat $resultfile | grep -vF ".example"|  cut -d "." -f1 | sed "s/ //g" > /opt/resultats/hosts_puppetisesnodomainnames.txt
#add .example to list
cat $resultfile | grep -F ".example" | sed "s/.example.org//g" | sed "s/ //g" >> /opt/resultats/hosts_puppetisesnodomainnames.txt

#comparison hostlist to directories in crondir
#if directory does not exist we create it

cd $crondir  
for i in $(cat /opt/resultats/hosts_puppetisesnodomainnames.txt) 
do
	if ! ls -d $i 2>&1 > /dev/null
	then
		mkdir $i 
	fi 
done

listcrondir=$(ls -d * | egrep -v '(ALL|default)' > /opt/resultats/listrep.txt)

for i in $(cat /opt/resultats/listrep.txt)
do
	if ! grep -F $i /opt/resultats/hosts_puppetisesnodomainnames.txt 2>&1 > /dev/null
		then 
			rm -rf  $i
		fi	
done



