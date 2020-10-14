#!/bin/bash

mount -a
sleep 30

datej=`date '+%Y_%m_%d'`
mydate=`date '+%Y-%m-%d'`

mkdir -p /NAS/RECPAR/$datej 
cd /NAS/RECPAR/$datej 

mv -v /mnt/export/*.SDAT /mnt/export/*.SPAR /mnt/export/*.PAR /mnt/export/*.par /mnt/export/*.nii /mnt/export/*.REC /mnt/export/*.rec /NAS/temp_recpar/*.par /NAS/temp_recpar/*.rec /NAS/RECPAR/$datej

#/mnt/export/*.CSV /mnt/export/*.csv /mnt/export/*.txt /mnt/export/*.7 /mnt/export/*.ini /mnt/export/*.XML

#/usr/bin/perl /home/global/pati_linux_42/pati_patient_liste.pl
#/usr/bin/php -f /var/www/imvdb/liste_patient_du_jour.php
#/usr/bin/perl /home/global/pati_linux_42/pati_download_patient_liste.pl
/usr/bin/php -f /var/www/imvdb/gestion3t/ajout_auto_db.php
#/usr/bin/php -f /var/www/imvdb/check_IRM_2_imvdb.php > /var/www/imvdb/pati_temp/${datej}_missing.log
#/usr/bin/php -f /var/www/imvdb/gestion3t/ajout_auto_db.php
/usr/bin/php -f /var/www/imvdb/archive_a_day.php $mydate

/home/julien/SVN/scripts/julien/star_auto_transfert.sh ${mydate} > /var/www/imvdb/pati_temp/${datej}_star_dcm.log
