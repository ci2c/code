#!/bin/bash

IP=$1

echo "auto eth0" >> /etc/network/interfaces
echo "allow-hotplug eth0" >> /etc/network/interfaces
echo "iface eth0 inet static" >> /etc/network/interfaces
echo "address $IP" >> /etc/network/interfaces
echo "broadcast 10.11.204.255" >> /etc/network/interfaces
echo "gateway 10.11.204.1" >> /etc/network/interfaces
echo "netmask 255.255.255.0" >> /etc/network/interfaces
echo "network 10.11.204.0" >> /etc/network/interfaces
echo "dns-nameserver 10.11.204.190" >> /etc/network/interfaces
echo "dns-search irm3t" >> /etc/network/interfaces

echo "search irm3t" > /etc/resolv.conf
echo "nameserver 10.11.204.243" >> /etc/resolv.conf

echo "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games\"" > /etc/environment
echo "http_proxy=\"http://10.50.2.2:3128/\"" >> /etc/environment
echo "http_proxy=\"http://10.50.2.2:3128/\"" >> /etc/environment
echo "http_proxy=\"http://10.50.2.2:3128/\"" >> /etc/environment

scp irm3t@10.11.204.190:/etc/nsswitch.conf /etc/nsswitch.conf

echo "Acquire::http::proxy \"http://10.50.2.2:3128/\";" > /etc/apt/apt.conf
echo "Acquire::ftp::proxy \"http://10.50.2.2:3128/\";" >> /etc/apt/apt.conf
echo "Acquire::https::proxy \"https://10.50.2.2:3128/\";" >> /etc/apt/apt.conf
sudo /etc/init.d/networking restart
sudo apt-get update
sudo apt-get upgrade
echo "10.11.204.243:/home /home nfs rw,auto,sync" >> /etc/fstab
echo "10.11.204.174:/data /home/fatmike nfs rw,auto,sync" >> /etc/fstab



