#!/bin/bash

for u in `hostname`
do
if [ $u != morrison ]
then
echo "Il faut etre logguer sur morrison pour pouvoir lancer ce script"
fi
done
for i in `id -u`
do
if [ $i -eq 0 ]
then
echo "**** Bienvenu, nous allons créer un nouveau compte utilisateur ****"
echo
echo "** entrer un nouvel utilisateur **"
read user
echo 
sleep 1
echo "configuration du compte"
sleep 1
echo
adduser --gid 1001 --home /home/$user $user
sleep 1
cd /var/yp && make
cd /home/$user
mkdir public_html
mkdir SVN
mkdir NAS
cp /home/pierre/SVN/bash_profile /home/$user/SVN
cd /home
chown -R $user $user
chgrp -R irm3t $user
echo "le nouveau compte est créé. Si des problèmes persiste, ecrire un mail aux admins aurelsan@gmail.com ou besson.pierre@gmail.com"
echo
echo "#############################################################"
echo "!!!!! N'oubliez pas de créer un compte $user sur le NAS !!!!!"
echo "#############################################################"
else
echo "!!!!!! Petit canaillou, il faut etre root pour pouvoir lancer ce script !!!!!!"
fi
done
