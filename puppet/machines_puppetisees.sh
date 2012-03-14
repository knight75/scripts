#!/bin/sh
puppetca --list --all > /opt/resultats/machines_puppetisees.txt
sed -i "s/+/ /g" /opt/resultats/machines_puppetisees.txt
sed -i "s/(.*)//g" /opt/resultats/machines_puppetisees.txt
echo "$(grep -c "." /opt/resultats/machines_puppetisees.txt) machines ont bascule du cote obscur de la Force"
