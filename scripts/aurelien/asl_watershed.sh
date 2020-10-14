#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
		echo "Usage: process_asl.sh  -dir DICOM_FILES"
		echo ""
		echo "  -dir DICOM_FILES                   : Path to DICOMS dir"
		echo ""
		echo "Usage: scripttoto.sh  -dir DICOM_FILES"
		echo ""
		exit 1
fi


index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: scripttoto.sh  -dir DICOM_FILES"
		echo ""
		echo "  -dir DICOM_FILES                   : Path to DICOMS dir"
		echo ""
		echo "Usage: scripttoto.sh  -dir DICOM_FILES"
		echo ""
		exit 1
		;;
	-dir)
		Dicom=`expr $index + 1`
		eval Dicom=\${$Dicom}
		echo "DICOM_DIR : ${Dicom}"
		;;
	esac
	index=$[$index+1]
done

dcm2nii -g n -o ${Dicom} ${Dicom}
rm -fr ${Dicom}/co*3dt1*.nii
rm -fr ${Dicom}/o*3dt1*.nii
rm -fr ${Dicom}/o*t13d*.nii
rm -fr ${Dicom}/co*t13d*.nii
echo
echo
for i in `ls ${Dicom}/*star*.nii`
do
echo
echo "========================="
echo "correction du volume $i"
echo "========================="
echo
index=`echo $i |sed -n "/star/s/.*\([0-9]\)\.nii.*/\1/p"`
eddy_correct $i ${Dicom}/raw_ASL_recal_${index}.nii 0
fslmaths ${Dicom}/raw_ASL_recal_${index}.nii -Tmean ${Dicom}/Vol_${index}_mean.nii -odt double
done

fslmaths ${Dicom}/Vol_2_mean.nii -sub ${Dicom}/Vol_1_mean.nii.gz ${Dicom}/diff_map.nii
gunzip ${Dicom}/diff_map.nii.gz

echo
echo "========================="
echo "conversion des fichiers"
echo "========================="
echo

for d in `ls ${Dicom}/*3dt1*.nii`
doi
mri_convert ${d} ${Dicom}/3dt1.mnc
done

for f in `ls ${Dicom}/*t13d*.nii`
do
mri_convert ${f} ${Dicom}/3dt1.mnc
done

mri_convert ${Dicom}/diff_map.nii ${Dicom}/diff_map.mnc
echo "================="
echo "On fait des trucs"
echo "================="
mri_convert ${Dicom}/3dt1.mnc ${Dicom}/wst1.mgz
mri_watershed -h 25 ${Dicom}/wst1.mgz ${Dicom}/wst1_brain.mgz
echo
echo "================="
echo "On fait des trucs"
echo "================="
mri_convert ${Dicom}/wst1_brain.mgz ${Dicom}/wst1_brain.mnc --out_orientation RAS
echo "========================"
echo "On fait encore des trucs"
echo "========================"
mritotal -modeldir /home/aurelien/ASL/Etude_TI/atlas/template -model template ${Dicom}/wst1_brain.mnc ${Dicom}/wst1_brain.xfm
echo "======================"
echo "On fait d'autres trucs"
echo "======================"
mincresample -like /home/aurelien/ASL/Etude_TI/atlas/mni_icbm152_t1_tal_nlin_sym_09a.mnc -transformation ${Dicom}/wst1_brain.xfm ${Dicom}/wst1_brain.mnc ${Dicom}/wst1_brain_tal.mnc

mincresample -like /home/aurelien/ASL/Etude_TI/aal.mnc -transformation ${Dicom}/wst1_brain.xfm ${Dicom}/diff_map.mnc ${Dicom}/asl_to_t1.mnc -clobber

echo
echo "==================================="
echo "on va extraire des ROIs au pif"
echo "==================================="
indice=1

echo "resultats de l'analyse pour ${Dicom}"> ${Dicom}/results.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
while [ ${indice} -le 116 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask /home/aurelien/ASL/Etude_TI/aal.mnc /home/aurelien/ASL/Etude_TI/aal.mnc -sample ${Dicom}/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/aal.txt |sed -n ''${indice}p'' >> ${Dicom}/results.txt

mincstats -mean -stddev ${Dicom}/asl_to_t1.mnc -mask ${Dicom}/mask.mnc -mask_binvalue 1 >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
indice=$[$indice+1]
done
nline=`cat /tmp/stderr |wc -l`
if [ $nline -gt 3 ]
then
echo |cat /home/aurelien/SVN/scripts/aurelien/rage_guy
echo "Fuck No !!! Y'a une erreur, Va vite voir ce qui s'est passé dans /tmp/stderr"
else
echo |cat /home/aurelien/SVN/scripts/aurelien/fyeah
echo "Fuck yeah, c'est termine !!! Allez champion, va vite voir les resultats dans ${Dicom}"
fi
echo
echo "taper entrée pour quitter"
read q
