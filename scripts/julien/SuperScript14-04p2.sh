#!/bin/bash



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
apt-get -y install ssh tcsh smb4k nfs-common

echo '
*******************************************************************************
* 7 - Conf mount points       /etc/fstab                                      *
******************************************************************************* 
'
echo "10.11.204.212:/home/ /home/ nfs rw,sync,hard,intr 0 0" >> /etc/fstab
echo "10.11.204.174:/data /home/fatmike nfs rw,auto,sync" >> /etc/fstab
echo "10.11.204.85:/irm3t /home/notorious nfs rw,auto,sync" >> /etc/fstab
sudo mkdir -p /NAS/dumbo
sudo echo "10.11.204.237:/volume1/data /NAS/dumbo nfs rw,auto,sync" >> /etc/fstab
sudo mkdir -p /NAS/tupac
sudo echo "10.11.204.243:/data /NAS/tupac nfs rw,auto,sync" >> /etc/fstab
# defaults,user,auto,exec,noatime
#users,atime,auto,rw,dev,exec,suid 0 0
sudo mount -a


echo '
****** Vérifier les montages NFS avant de poursuivre  *************************
'
read verif



echo '
*******************************************************************************
* 8 - Conf. LDAP   			                                      *
******************************************************************************* 
- install LDAP Client ...
'
apt-get -y install libpam-ldap libnss-ldap nss-updatedb nscd
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
sudo apt-get -y install cmtk dcmtk tk paraview libc6 libstdc++6 imagemagick perl freeglut3 libgl1-mesa-glx libxcb1 libxdmcp6 libx11-6 libxext6 libxau6 libuuid1 libjpeg62 libexpat1 libtiff4-dev 
sudo dpkg -i /home/global/minc_tool_kit/minc-toolkit-1.0.01-20131211-Ubuntu_12.04-x86_64.deb /home/global/minc_tool_kit/minc-toolkit-testsuite-0.1.3-20131212.deb /home/global/minc_tool_kit/bic-mni-models-0.1.1-20120421.deb /home/global/minc_tool_kit/beast-library-1.1.0-20121212.deb 

## minc stuff
sudo python /home/global/minc_tool_kit/setuptools-23.0.0/setup.py  install
sudo apt-get -y install libvtk5-dev python-vtk cython
sudo python /home/global/minc_tool_kit/minc-stuffs/setup.py  install

echo '
*******************************************************************************
* 9b - MAGeTbrain  - required Minc Tool	      	                              *
******************************************************************************* 
'
sudo apt-get -y install python-numpy python-scipy
sudo python /home/global/minc_tool_kit/pyminc/setup.py install

echo '
*******************************************************************************
* 10 - Install Matlab 2014a in /usr/local/matlab    	                      *
******************************************************************************* 
Use 12345-67890-12345-67890'

bash /home/global/matlab2014a/install
cp /home/global/matlab2014a/Crack/Linux/libmwservices.so /usr/local/matlab/bin/glnxa64/
sudo ln -s /lib/x86_64-linux-gnu/libc-2.19.so /lib64/libc.so.6

echo '
Fixing BLAS loading error: dlopen: cannot load any more object with static TLS 
'
sudo mv /usr/local/matlab/sys/os/glnxa64/libiomp5.so /usr/local/matlab/sys/os/glnxa64/libiomp5.so.back
sudo apt-get -y install libiomp5
sudo ln -s /usr/lib/libiomp5.so.5 /usr/local/matlab/sys/os/glnxa64/libiomp5.so

echo '
*******************************************************************************
* 10 - Install Matlab 2011 in /usr/local/matlab11    	                      *
******************************************************************************* 
Use 59327-00840-06743-08309-05690
'
mkdir -p /media/cd
mount -o loop /home/global/matlab11/matl11bu.iso /media/cd/
bash /media/cd/install

echo 'Patching LibGl error with Ubuntu 14.04
'
sudo mv /usr/local/matlab11/sys/os/glnxa64/libstdc++.so.6 /usr/local/matlab11/sys/os/glnxa64/libstdc++.so.6.back
sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.19 /usr/local/matlab11/sys/os/glnxa64/libstdc++.so.6

echo '
*******************************************************************************
* 11 - Patching tool                                                          *
******************************************************************************* 
- KWMeshVisu ...
'
sudo apt-get -y install tcl8.4-dev tk8.4-dev

echo '
mrview ...
'
sudo apt-get -y install libgtkmm-2.4-1c2a libgtkglext1 libgsl0-dev

echo '
Freeview ...
'
sudo apt-get -y install libjpeg62

# Quand Talairach Transform failed freesurfer utilise MINC mritotal pour faire le Talairach align.Besoin du paquet suivant sur ubuntu 14.04 and FS5.3, sinon mritotal se plante
echo '
Freesurfer
'
sudo apt-get -y install libperl4-corelibs-perl

echo '
mcverter ...
'
sudo apt-get -y install libwxgtk2.8-dev

echo '
FSL ...
' 
sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5.2.0 /usr/lib/libtiff.so.3
sudo ln -s /usr/local/matlab/bin/glnxa64/libexpat.so.1.5.0 /usr/lib/libexpat.so.0
sudo apt-get -y install libmng-dev
sudo ln -s /usr/lib/x86_64-linux-gnu/libmng.so.2.0.2 /usr/lib/libmng.so.1

echo '
FSL atlasquery...
' 
sudo dpkg -i /home/global/lib/libmng1_1.0.10-3_amd64.deb /home/global/lib/libqt3-mt_3.3.8-b-8ubuntu3_amd64.deb
sudo apt-get install -f -y


echo '
Module Python
'
sudo apt-get -y install python-numpy python-scipy python-matplotlib

echo '
Fixing shape analysis ...
'
sudo ln -s /usr/lib/x86_64-linux-gnu/libgfortran.so.3.0.0 /usr/lib/libgfortran.so.1
sudo apt-get -y install libblas3
cp /home/global/lib/liblapack.so.3 /usr/lib/


echo '
*******************************************************************************
* 12 - More tools         	                                              *
******************************************************************************* 
'
sudo apt-get -y install rapidsvn pbzip2 lbzip2 pxz i7z icedtea-7-plugin openjdk-7-jre 

echo '
*******************************************************************************
* 13 - Conf of Sun GridEngine Client  (SGE)                                   *
*******************************************************************************
- Installing Client ... '

apt-get -y install gridengine-client gridengine-exec


echo '
- Patching Qmon adobe font error ...
'

#apt-get install xfs
#service xfs start
apt-get -y install xfonts-75dpi
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