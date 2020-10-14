#!/bin/bash

dir=$1

if [ $# -lt 1 ]
then
	echo ""
	echo "Usage: extract_label.sh path_to_freesurfer_data"
	echo "les donnees seront enregistrées dans path_to_freesurfer_data/outdir"
	echo
	exit 1
fi

if [ ! -d ${dir}/outdir ]
then
	mkdir ${dir}/outdir
fi

if [ ! -d ${dir}/jobs ]
then
	mkdir ${dir}/jobs
else
	rm -fr ${dir}/jobs/*
fi

echo "Voulez-vous voir la liste des labels freesurfer ? (y/n). Si y, taper sur q pour sortir de la liste."
read rep
case "$rep" in
	y)
	less ~/SVN/scripts/aurelien/FreeSurferColorLUT.txt
	echo
	echo "Entrer le numéro du label: "
	read label
;;
	n)
	echo "Entrer le numéro du label: "
	read label
;;
	*)
	echo "Usage : réponse attendue : y ou n"
	exit 1
esac

label_name=`cat ~/SVN/scripts/aurelien/FreeSurferColorLUT.txt |sed -n /^${label}\ /p |awk '{print $2}'`
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Extraction du ${label_name} de tous les sujets du dossier $dir"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
for i in `ls -1 $dir --hide=fsaverage --hide=lh.EC_average --hide=rh.EC_average`
do
qbatch -N extract_label -q short.q mri_extract_label ${dir}/${i}/mri/aparc.a2009s+aseg.mgz ${label} ${dir}/outdir/${i}_${label_name}.nii
sleep 0.2
done

