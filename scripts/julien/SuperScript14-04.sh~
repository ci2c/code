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
echo "10.11.204.212:/home/ /home/ nfs rw,sync,hard,intr 0 0" >> /etc/fstab
#echo "10.11.204.212:/home /home nfs rw,auto,sync" >> /etc/fstab
echo "10.11.204.174:/data /home/fatmike nfs rw,auto,sync" >> /etc/fstab
echo "10.11.204.85:/irm3t /home/notorious nfs rw,auto,sync" >> /etc/fstab
sudo mkdir -p /NAS/dumbo
sudo echo "10.11.204.237:/volume1/data /NAS/dumbo nfs rw,auto,sync" >> /etc/fstab
# defaults,user,auto,exec,noatime
#users,atime,auto,rw,dev,exec,suid 0 0
sudo mount -a


echo '
*******************************************************************************
* 8 - Conf. LDAP   			                                      *
******************************************************************************* 
- install LDAP Client ...
'
apt-get install libpam-ldap libnss-ldap nss-updatedb nscd
sudo sed -i -e "s/compat/files ldap/g" /etc/nsswitch.conf

echo'
Configure Users -> ou=people,dc=imv3t,dc=lan'
sudo sed -i -e "s/#nss_base_passwd/nss_base_passwd/g" /etc/ldap.conf
sudo sed -i -e "s/ou=People,dc=padl,dc=com/ou=people,dc=imv3t,dc=lan/g" /etc/ldap.conf
sudo sed -i -e "s/#nss_base_shadow/nss_base_shadow/g" /etc/ldap.conf
sudo sed -i -e "s/#nss_base_group/nss_base_group/g" /etc/ldap.conf
sudo sed -i -e "s/ou=Group,dc=padl,dc=com/ou=groups,dc=imv3t,dc=lan/g" /etc/ldap.conf
echo 'Configure Groups -> ou=groups,dc=imv3t,dc=lan
Done
'

echo '
Allow create user home folder at first loggin
'
sudo sed -i "30i\session   required      pam_mkhomedir.so skel=/etc/skel\n"  /etc/pam.d/common-session 

echo '
- update lightdm ldap compatibility ...
'
echo "greeter-show-manual-login=true" >>  /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "greeter-hide-users=true" >>  /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
echo "allow-guest=false" >>  /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf

echo '
*******************************************************************************
* 9 - Minc Tool & DICOM TOOL			                              *
******************************************************************************* 
'
 sudo apt-get install cmtk dcmtk tk paraview libc6 libstdc++6 imagemagick perl freeglut3 libgl1-mesa-glx libxcb1 libxdmcp6 libx11-6 libxext6 libxau6 libuuid1 libjpeg62 libexpat1 libtiff4-dev 
sudo dpkg -i /home/global/minc_tool_kit/minc-toolkit-1.0.01-20131211-Ubuntu_12.04-x86_64.deb /home/global/minc_tool_kit/minc-toolkit-testsuite-0.1.3-20131212.deb /home/global/minc_tool_kit/bic-mni-models-0.1.1-20120421.deb /home/global/minc_tool_kit/beast-library-1.1.0-20121212.deb 


echo '
*******************************************************************************
* 10 - Install Matlab 2014a in /usr/local/matlab    	                      *
******************************************************************************* 
Use 12345-67890-12345-67890'

bash /home/global/matlab2014a/install
cp /home/global/matlab2014a/Crack/Linux/libmwservices.so /usr/local/matlab/bin/glnxa64/
sudo ln -s /lib/x86_64-linux-gnu/libc-2.19.so /lib64/libc.so.6

echo '
*******************************************************************************
* 10 - Install Matlab 2011 in /usr/local/matlab11    	                      *
******************************************************************************* 
Use 59327-00840-06743-08309-05690
'
mkdir -p /media/cd
mount -o loop /home/global/matlab11/matl11bu.iso /media/cd/
bash /media/cd/install



echo '
*******************************************************************************
* 11 - Patching tool                                                          *
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
sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5.2.0 /usr/lib/libtiff.so.3
sudo ln -s /usr/local/matlab/bin/glnxa64/libexpat.so.1.5.0 /usr/lib/libexpat.so.0
sudo apt-get install libmng-dev
sudo ln -s /usr/lib/x86_64-linux-gnu/libmng.so.2.0.2 /usr/lib/libmng.so.1


echo '
*******************************************************************************
* 12 - More tools         	                                              *
******************************************************************************* 
'
sudo apt-get install rapidsvn pbzip2 i7z icedtea-7-plugin openjdk-7-jre 

echo '
*******************************************************************************
* 13 - Conf of Sun GridEngine Client  (SGE)                                   *
*******************************************************************************
- Installing Client ... '

apt-get install gridengine-client gridengine-exec


echo'
- Patching Qmon adobe font error ...
'

#apt-get install xfs
#service xfs start
apt-get install xfonts-75dpi
xset +fp /usr/share/fonts/X11/75dpi
xset fp rehash


echo '
*******************************************************************************
* 14 - Change UMASK in /etc/lognin.defs ...				      *
*******************************************************************************
'

sudo sed -i -e 's/UMASK\t\t022/UMASK\t\t002/g' /etc/login.defs




echo '
Ajouter manuellement le nouveau poste dans le SGE
Modifier visudo
'
