#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
	echo "Usage:  imvdb_compressor.sh  -d <date1,date2@dateX,dateX2>"
	echo "!! Attention necessite d'etre execute en sudo user sur GAIA !! "
	echo "  -d      : date"
	echo "            peut etre une liste de dates separees par une virgule"
	echo "            peut être un interval de dates separes par un @"
	echo "            peut être un mix des deux"
	echo ""
	echo "Author: Julien DUMONT - CHRU Lille - Jul 30, 2014"
	echo ""
fi


while getopts hd: option
do
   case ${option}
     in
	d) mydate=$OPTARG
	   /usr/bin/php -f /var/www/imvdb/archive_a_day.php $mydate	   
	;;
	h) echo ""
	echo "Usage:  imvdb_compressor.sh  -d <date1,date2@dateX,dateX2>"
	echo "!! Attention necessite d'etre execute en sudo user sur GAIA !! "
	echo "  -d      : date"
	echo "            peut etre une liste de dates separees par une virgule"
	echo "            peut être un interval de dates separes par un @"
	echo "            peut être un mix des deux"
	echo ""
	echo "Author: Julien DUMONT - CHRU Lille - Jul 30, 2014"
	echo ""
	exit 1
	;;
   esac
done


