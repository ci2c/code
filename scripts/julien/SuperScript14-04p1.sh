#!/bin/bash

echo '
 

*******************************************************************************
*******************************************************************************
****************************** SuperScript ************************************
*******************************************************************************
***************** Configuration automatique sous Ubuntu 14.04 *****************
*******************************************************************************

Exécuter le script en mode console (sans aucun mode graphique)
Exécuter le en vous positionnent autre part que dans le home qui va être monté

'


echo '
***************************  Entrer IP ***************************************
'
read IP
echo '
************************ Entrer hostname *************************************
'
read host_name


echo '
*******************************************************************************
* 1 - Moving local user & Change number-date format (auto fr on ubuntu 14)    *
******************************************************************************* 
'
mkdir -p /local
cp -R /home/irm3t /local
chgrp -R irm3t /local/irm3t/
chown -R irm3t /local/irm3t/

sed -i -e "s/home\/irm3t/local\/irm3t/g" /etc/passwd

sed -i -e "s/fr_FR.UTF-8/en_US.UTF-8/g" /etc/default/locale



echo '
*******************************************************************************
* 2 - Configuration /etc/network/interfaces                                   *
******************************************************************************* 
'
echo "auto eth0" >> /etc/network/interfaces
echo "allow-hotplug eth0" >> /etc/network/interfaces
echo "iface eth0 inet static" >> /etc/network/interfaces
echo "address $IP" >> /etc/network/interfaces
echo "netmask 255.255.255.0" >> /etc/network/interfaces
echo "network 10.11.204.0" >> /etc/network/interfaces
echo "broadcast 10.11.204.255" >> /etc/network/interfaces
echo "gateway 10.11.204.1" >> /etc/network/interfaces
echo "dns-nameservers 10.11.204.212 10.49.11.1" >> /etc/network/interfaces
echo "dns-search imv3t.lan" >> /etc/network/interfaces
echo "dns-domain imv3t.lan" >> /etc/network/interfaces


echo '
*******************************************************************************
* 3 - Configuration /etc/hosts                                                *
******************************************************************************* 
'
mv /etc/hosts /etc/hosts_back
touch /etc/hosts

echo "127.0.0.1       $host_name localhost.localdomain      localhost" >> /etc/hosts
echo "$IP    $host_name.imv3t.lan $host_name" >> /etc/hosts
echo "
10.11.204.212   gaia" >> /etc/hosts
echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
echo "::1     ip6-localhost ip6-loopback" >> /etc/hosts
echo "fe00::0 ip6-localnet" >> /etc/hosts
echo "ff00::0 ip6-mcastprefix" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts


echo '
*******************************************************************************
* 4 - Configuration du proxy 	                                              *
******************************************************************************* 
- configure system proxy ...
'
echo "http_proxy=\"http://10.50.2.2:3128/\"" >> /etc/environment
echo "https_proxy=\"https://10.50.2.2:3128/\"" >> /etc/environment
echo "ftp_proxy=\"ftp://10.50.2.2:3128/\"" >> /etc/environment
echo "socks_proxy=\"socks://10.50.2.2:3128/\"" >> /etc/environment

echo '
-configure apt proxy ...
'
touch /etc/apt/apt.conf.d/95proxies
echo "Acquire::http::proxy \"http://10.50.2.2:3128/\";" >> /etc/apt/apt.conf.d/95proxies
echo "Acquire::ftp::proxy \"ftp://10.50.2.2:3128/\";" >> /etc/apt/apt.conf.d/95proxies
echo "Acquire::https::proxy \"https://10.50.2.2:3128/\";" >> /etc/apt/apt.conf.d/95proxies

service networking restart


