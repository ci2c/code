#!/bin/bash

echo '
 

*******************************************************************************
*******************************************************************************
****************************** SuperScript ************************************
*******************************************************************************
***************** Configuration automatique sous Ubuntu 12.10 *****************
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
* 1 - Moving local user 		                                      *
******************************************************************************* 
'
mkdir -p /local
cp -R /home/irm3t /local
chgrp -R irm3t /local/irm3t/
chown -R irm3t /local/irm3t/

sed -i -e "s/home\/irm3t/local\/irm3t/g" /etc/passwd


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

echo '
*******************************************************************************
* 5 - Update system                                                           *
******************************************************************************* 
'
sudo apt-get update
sudo apt-get upgrade

echo '
*******************************************************************************
* 6 - Install Network Service                                                 *
******************************************************************************* 
'
apt-get install ssh tcsh smb4k nfs-common 

echo '
*******************************************************************************
* 7 - Conf mount points       /etc/fstab                                      *
******************************************************************************* 
'

echo "10.11.204.212:/home /home nfs rw,auto,sync" >> /etc/fstab
echo "10.11.204.174:/data /home/fatmike nfs rw,auto,sync" >> /etc/fstab
echo "10.11.204.85:/irm3t /home/notorious nfs rw,auto,sync" >> /etc/fstab
sudo mkdir -p /NAS/dumbo
sudo echo "10.11.204.237:/volume1/data /NAS/dumbo nfs defaults,exec,_netdev,auto,noatime,intr      0       0" >> /etc/fstab

sudo mount -a


echo '
*******************************************************************************
* 8 - Conf. LDAP   			                                      *
******************************************************************************* 
- install LDAP Client ...
'
apt-get install libpam-ldap libnss-ldap nss-updatedb nscd
sudo sed -i -e "s/compat/files ldap/g" /etc/nsswitch.conf

echo '
- update lightdm ldap compatibility ...
'
echo "greeter-show-manual-login=true" >>  /etc/lightdm/lightdm.conf
echo "greeter-hide-users=true" >>  /etc/lightdm/lightdm.conf
echo "allow-guest=false" >>  /etc/lightdm/lightdm.conf

echo '
*******************************************************************************
* 8 - Installing NeuroDebian & MNI Tools                                      *
******************************************************************************* 
'

wget -O- http://neuro.debian.net/lists/quantal.de-m.libre | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver pgp.mit.edu 2649A5A9

echo "deb http://packages.bic.mni.mcgill.ca/ubuntu-precise ./" >> /etc/apt/sources.list

sudo apt-get update

sudo apt-get install cmtk dcmtk tk paraview bicpl classify conglomerate display ebtks glim-image inormalize libmni-perllib-perl minc mincblob mincbundle mincdti mincfft mincmorph mincregress mincsample mni-autoreg mni-models-average305-lin mni-models-colin27-lin mni-models-icbm152-lin mni-models-icbm152-nl-2009 mrisim n3 postf ray-trace register volperf volregrid



echo '
*******************************************************************************
* 9 - Install Matlab      	                                              *
******************************************************************************* 
'

mkdir -p /media/cd
mount -o loop /home/julien/Desktop/matl11bu.iso /media/cd/
bash /media/cd/install

sudo ln -s /lib/x86_64-linux-gnu/libc-2.15.so /lib64/libc.so.6




echo '
*******************************************************************************
* 10 - Patching tool                                                          *
******************************************************************************* 
- KWMeshVisu ...
'
sudo apt-get install tcl8.4-dev tk8.4-dev

echo '
mrview ...
'
sudo apt-get install libgtkmm-2.4-1c2a libgtkglext1 libgsl0-dev

echo '
Freeview ...
'
sudo apt-get install libjpeg62

echo '
mcverter ...
'
sudo apt-get install libwxgtk2.8-dev

echo '
FSL ...
' 
sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5.1.0 /usr/lib/libtiff.so.3
sudo ln -s /lib/x86_64-linux-gnu/libexpat.so.1.6.0 /usr/lib/libexpat.so.0


echo '
inormalize ...
'
sudo cp /home/notorious/NAS/julien/lib/libnetcdf.so.6 /usr/lib/
sudo cp /home/notorious/NAS/julien/lib/libhdf5.so.6.0.3 /usr/lib/
sudo ln -s /usr/lib/libnetcdf.so.6 /usr/lib/libnetcdf.so.4
sudo ln -s /usr/lib/libhdf5.so.6.0.3 /usr/lib/libhdf5.so.6
sudo ln -s /usr/local/matlab11/bin/glnxa64/libhdf5_hl.so.6.0.5 /usr/lib/libhdf5_hl.so.6


echo '
*******************************************************************************
* 11 - Nvidia drivers   	                                              *
******************************************************************************* 
'
sudo apt-get install build-essential linux-source
sudo apt-get install linux-headers-`uname -r`
sudo apt-get install nvidia-current


echo '
*******************************************************************************
* 12 - rapidSVN          	                                              *
******************************************************************************* 
'
sudo apt-get install rapidsvn

echo '
*******************************************************************************
* 13 - Conf of Sun GridEngine Client  (SGE)                                   *
*******************************************************************************
- Installing Client ... '

apt-get install gridengine-client gridengine-exec


echo'
- Patching Qmon adobe font error ...
'

apt-get install xfs
service xfs start
apt-get install xfonts-75dpi
xset +fp /usr/share/fonts/X11/75dpi
xset fp rehash


echo '
Ajouter manuellement le nouveau poste dans le SGE
Modifier visudo
'
