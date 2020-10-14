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
echo "conversion des nii en mnc"
echo "========================="
echo

for d in `ls ${Dicom}/*3dt1*.nii`
do
nii2mnc ${d} ${Dicom}/3dt1.mnc
done

for d in `ls ${Dicom}/*t13d*.nii`
do
nii2mnc ${d} ${Dicom}/3dt1.mnc
done

nii2mnc ${Dicom}/diff_map.nii

echo
echo
echo "(>'-')>[recalage du 3DT1 dans l'espace de Talairach et re-echantillonnage : hell yeah]<('-'<)"
echo
echo "mritotal ${Dicom}/3dt1.mnc ${Dicom}/trans "
mritotal ${Dicom}/3dt1.mnc ${Dicom}/trans
#mincresample -like /home/aurelien/ASL/Etude_TI/aal.mnc -transformation ${Dicom}/trans.xfm ${Dicom}/diff_map.mnc ${Dicom}/diff_to_tal.mnc
echo
weight=1
stiffness=1
similarity=0.3
echo "on va blurrer!!!"
echo
mincblur -fwhm 8 ${Dicom}/3dt1.mnc ${Dicom}/3dt1_8
mincblur -fwhm 8 /home/aurelien/ASL/Etude_TI/atlas/mni_icbm152_t1_tal_nlin_sym_09a.mnc ${Dicom}/mni_icbm152_t1_tal_nlin_sym_09a.mnc_8
mincblur -fwhm 4 ${Dicom}/3dt1.mnc ${Dicom}/3dt1_4
mincblur -fwhm 4 /home/aurelien/ASL/Etude_TI/atlas/mni_icbm152_t1_tal_nlin_sym_09a.mnc ${Dicom}/mni_icbm152_t1_tal_nlin_sym_09a.mnc_4
mincblur -fwhm 2 ${Dicom}/3dt1.mnc ${Dicom}/3dt1_2
mincblur -fwhm 2 /home/aurelien/ASL/Etude_TI/atlas/mni_icbm152_t1_tal_nlin_sym_09a.mnc ${Dicom}/mni_icbm152_t1_tal_nlin_sym_09a.mnc_2
echo
echo "recalage non rigide !!!"
echo
# Linear registration
#mritoself ${Dicom}/mni_icbm152_t1_tal_nlin_sym_09a.mnc.mnc ${Dicom}/3dt1.mnc ${Dicom}/source_to_target_lin.xfm -clobber

# Nonlinear registration
minctracc -iterations 30 -step 8 8 8 -sub_lattice 6 -lattice_diam 24 24 24 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${Dicom}/trans.xfm ${Dicom}/mni_icbm152_t1_tal_nlin_sym_09a.mnc_8_blur.mnc ${Dicom}/3dt1_8_blur.mnc ${Dicom}/source_to_target_8_blur_nlin.xfm -clobber

minctracc -iterations 30 -step 4 4 4 -sub_lattice 6 -lattice_diam 12 12 12 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${Dicom}/source_to_target_8_blur_nlin.xfm ${Dicom}/mni_icbm152_t1_tal_nlin_sym_09a.mnc_4_blur.mnc ${Dicom}/3dt1_4_blur.mnc ${Dicom}/source_to_target_4_blur_nlin.xfm -clobber

minctracc -iterations 10 -step 2 2 2 -sub_lattice 6 -lattice_diam 6 6 6 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${Dicom}/source_to_target_4_blur_nlin.xfm ${Dicom}/mni_icbm152_t1_tal_nlin_sym_09a.mnc_2_blur.mnc ${Dicom}/3dt1_2_blur.mnc ${Dicom}/source_to_target_nlin.xfm -clobber
 
# Apply nl transform
mincresample -like /home/aurelien/ASL/Etude_TI/aal.mnc -transformation ${Dicom}/source_to_target_nlin.xfm ${Dicom}/diff_map.mnc ${Dicom}/asl_to_t1.mnc -clobber

echo
echo "==================================="
echo "on va extraire les ROIs du template"
echo "==================================="
indice=1
#mnc2nii -nii ${Dicom}/asl_to_t1.mnc ${Dicom}/asl.nii
echo "resultats de l'analyse pour ${Dicom}"> ${Dicom}/results.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
while [ ${indice} -le 116 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask /home/aurelien/ASL/Etude_TI/aal.mnc /home/aurelien/ASL/Etude_TI/aal.mnc -sample ${Dicom}/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/aal.txt |sed -n ''${indice}p'' >> ${Dicom}/results.txt
#echo "resultat de la roi ${indice}" >> ${Dicom}/results.txt
mincstats -mean -stddev ${Dicom}/asl_to_t1.mnc -mask ${Dicom}/mask.mnc -mask_binvalue 1 >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
indice=$[$indice+1]
done

