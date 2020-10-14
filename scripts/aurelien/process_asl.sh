#!/bin/bash

if [ $# -lt 1 ]
then
		echo ""
		echo "Usage: process_asl.sh  DATA_RECPAR_DIR RESULT_DIR"
		echo ""
		exit 1
fi

result_dir=$2
Dicom=$1
index=1

if [ ! -d ${result_dir} ]
then
	mkdir -p ${result_dir}
else
	rm -fr ${result_dir}/*
fi

if [ ! -d ${Dicom}/in_data_SICA ]
then
	mkdir -p ${Dicom}/in_data_SICA
else
	rm -fr ${Dicom}/in_data_SICA/*
fi

if [ ! -d ${Dicom}/process ]
then
	mkdir -p ${Dicom}/process
fi

dcm2nii -o ${Dicom} ${Dicom}/*
mv *gz ${Dicom}/process

#mkdir -p ${Dicom}/process/temp
#for afile in `ls ${Dicom}/process/*nii.gz`
#do
#index=`echo $afile |sed -n "/[sStTaArR]/s/.*\([0-9]\)\.nii.*/\1/p"`
#echo "fslsplit"
#fslsplit $afile ${Dicom}/process/temp/temp_asl -t
#counter=1
#for tempfile in `ls ${Dicom}/process/temp/*gz`
#do
#j=$(printf "%.4d" $counter)
#mri_convert ${tempfile} ${Dicom}/process/temp/asl_ras_${j}_${index}.nii --out_orientation RAS
#counter=$[$counter+1]
#done
#echo
#echo "fslmerge"
#fslmerge -t ${Dicom}/process/asl_raw_ras_${index} ${Dicom}/process/temp/asl_ras*.nii
#rm -fr ${Dicom}/process/temp/*
#done

#rm -fr ${Dicom}/process/temp

if [ ! -f ${Dicom}/process/diff_map.nii.gz ]
then
echo
for i in `ls ${Dicom}/process/*.nii.gz`
do
echo
echo "correction du volume $i"
echo
echo

index=`echo $i |sed -n "/[aAsSlL]/s/.*\([0-9]\)\.nii.*/\1/p"`
eddy_correct_sge $i ${Dicom}/process/raw_ASL_recal_${index}.nii 0
fslmaths ${Dicom}/process/raw_ASL_recal_${index}.nii.gz -Tmean ${Dicom}/process/Vol_${index}_mean.nii.gz -odt double
done

fslmaths ${Dicom}/process/Vol_2_mean.nii.gz -sub ${Dicom}/process/Vol_1_mean.nii.gz ${Dicom}/process/diff_map.nii.gz
#gunzip ${Dicom}/diff_map.nii.gz ${Dicom}/Vol_1_mean.nii.gz ${Dicom}/Vol_2_mean.nii.gz
fi

fslmerge -t ${Dicom}/process/asl_raw_all ${Dicom}/process/raw_ASL_recal_1.nii.gz ${Dicom}/process/raw_ASL_recal_2.nii.gz
bet ${Dicom}/process/asl_raw_all.nii.gz ${Dicom}/process/ASLALL_brain -f 0.5 -g 0 -n -m
fslsplit ${Dicom}/process/asl_raw_all.nii.gz ${Dicom}/in_data_SICA/raw_sica -t
gunzip ${Dicom}/in_data_SICA/*
#mri_convert ${Dicom}/process/asl_raw_all.nii.gz -ot spm ${Dicom}/in_data_SICA/raw_sica
echo
echo "performing PCA"
echo
matlab -nodisplay <<EOF >> ${result_dir}/SICA.log
% Load Matlab Path
cd /home/aurelien
p = pathdef;
addpath(p);
addpath('/home/global/matlab_toolbox/nbw_0.1')
call_ica_asl('${Dicom}/in_data_SICA/','${result_dir}');
EOF

echo "Voulez-vous continuer et supprimer des composantes ? y/n"
read rep
case "$rep" in
	y)
echo "Veuillez vérifier les composantes dans ${result_dir}/spatialComp"
echo "Puis rentrer les composantes à éliminer :"
read comp
components="[$comp]"
echo "Removing components"
echo
matlab -nodisplay <<EOF >> ${result_dir}/SICA_supp.log
cd ${HOME};
p = pathdef;
addpath(p);
addpath('/home/global/matlab_toolbox/spm8','/home/global/matlab_toolbox/nbw_0.1')
call_ica_asl_supp('${Dicom}/in_data_SICA/','${result_dir}',${components});
EOF

tail -3 ${result_dir}/SICA_supp.log
nb_file=`ls ${result_dir}/preprocess_SICA/*nii |wc -l`
let "c = $nb_file / 2"
fslmerge -t ${result_dir}/preprocess_SICA/asl_sica_cont `ls ${result_dir}/preprocess_SICA/*nii |head -$c`
fslmerge -t ${result_dir}/preprocess_SICA/asl_sica_tag `ls ${result_dir}/preprocess_SICA/*nii |tail -$c`

;;
	n)
	echo "ok,bye !"
	exit 1
;;
	*)
	echo "Pas compris : bye !"
	exit 1
esac
echo
rm -fr ~/eddy_c*
echo "Les données corrigées sont dans le dossier ${result_dir}/preprocess_SICA"
echo "c'est termine : appuyer sur une touche pour quitter"
read q
