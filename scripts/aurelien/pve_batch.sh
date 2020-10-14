#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
	echo "Usage: pve_batch.sh path_to_data"
	echo "le dossier data doit contenir les images r_volume_GMROI.img et r_asl001.img"
	echo
	exit 1
fi

datadir=$1

cp /home/aurelien/PVELAB/pve_ASL_256_PUTHOST/ONE_ROI.dat /home/aurelien/PVELAB/pve_ASL_256_PUTHOST/config_pvec $datadir

pve -w -s -cs 84 $datadir/r_volume_GMROI.img $datadir/r_asl001.img $datadir/config_pvec


