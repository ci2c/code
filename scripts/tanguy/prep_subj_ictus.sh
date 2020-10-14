#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:  prep_subj_ictus.sh  -subj <subj name> -n <group number> -dd <DICOM dir> -pd <PA dir> -sd <ST dir>"
	echo ""
	echo "  -subj				: subj name "
	echo ""
	echo "	-n 				: group number"
	echo ""
	echo "	-dd				: DICOM dir"
	echo ""
	echo "	-pd				: PA dir"
	echo ""
	echo "	-sd				: ST dir"
	echo ""
	echo "Usage:  prep_subj_ictus.sh  -subj <subj name> -dd <DICOM dir> -pd <PA dir> -sd <ST dir>"
	echo ""
	echo "Author: Tanguy Hamel - CHRU Lille - 2014"
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
		echo ""
		echo "Usage:  prep_subj_ictus.sh  -subj <subj name> -n <group number> -dd <DICOM dir> -pd <PA dir> -sd <ST dir>"
		echo ""
		echo "  -subj				: subj name "
		echo ""
		echo "	-n 				: group number"
		echo ""
		echo "	-dd				: DICOM dir"
		echo ""
		echo "	-pd				: PA dir"
		echo ""
		echo "	-sd				: ST dir"
		echo ""
		echo "Usage:  prep_subj_ictus.sh  -subj <subj name> -dd <DICOM dir> -pd <PA dir> -sd <ST dir>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		echo ""
		exit 1
		;;
	-subj)
		index=$[$index+1]
		eval name=\${$index}
		echo "Subj name : ${name}"
		;;

	-n)
		index=$[$index+1]
		eval group=\${$index}
		echo "group number : ${group}"
		;;

	-dd)
		index=$[$index+1]
		eval DD=\${$index}
		echo "DICOM dir : ${DD}"
		;;
	-pd)
		index=$[$index+1]
		eval PD=\${$index}
		echo "PA dir : ${PD}"
		;;
	-sd)
		index=$[$index+1]
		eval SD=\${$index}
		echo "ST dir : ${SD}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  prep_subj_ictus.sh  -subj <subj name> -n <group number> -dd <DICOM dir> -pd <PA dir> -sd <ST dir>"
		echo ""
		echo "  -subj				: subj name "
		echo ""
		echo "	-n 				: group number"
		echo ""
		echo "	-dd				: DICOM dir"
		echo ""
		echo "	-pd				: PA dir"
		echo ""
		echo "	-sd				: ST dir"
		echo ""
		echo "Usage:  prep_subj_ictus.sh  -subj <subj name> -dd <DICOM dir> -pd <PA dir> -sd <ST dir>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]

done

echo ""
echo ""
echo "init"
echo ""
echo ""

echo "wd=/NAS/dumbo/protocoles/ictus/data/2014_05_19_ETUDE_ICTUS/"
wd=/NAS/dumbo/protocoles/ictus/data/2014_05_19_ETUDE_ICTUS/

echo "dicom_path=$wd/patients_ictus_${group}/${DD}/${PD}/${SD}"
dicom_path=$wd/patients_ictus_${group}/${DD}/${PD}/${SD}

echo "subj_dir=$wd/patients_ictus_${group}/sujets/${name}"
subj_dir=$wd/patients_ictus_${group}/sujets/${name}


if [ ! -d $subj_dir ]
then
	echo "mkdir $subj_dir -p"
	mkdir $subj_dir -p
fi

if [ ! -d $subj_dir/mcverter ]
then
	echo "mkdir $subj_dir/verter"
	mkdir $subj_dir/verter
fi

if [ ! -d $subj_dir/dcmnii ]
then
	echo "mkdir $subj_dir/dcmnii"
	mkdir $subj_dir/dcmnii
fi

echo ""
echo ""
echo "mcverter"
echo ""
echo ""

echo "mcverter -o $subj_dir/verter -f fsl $dicom_path/*/*"
mcverter -o $subj_dir/verter -f fsl $dicom_path/*/*




echo ""
echo ""
echo "dcm2nii"
echo ""
echo ""

echo "ndcmnii=`ls $dicom_path/*nii.gz | wc -l`"
ndcmnii=`ls $dicom_path/*nii.gz | wc -l`

if [ $ndcmnii -gt 1 ]
then
	echo "cp -f $dicom_path/* $subj_dir/dcmnii"
	cp -f $dicom_path/* $subj_dir/dcmnii
else
	echo "dcm2nii -o $subj_dir/dcmnii -f fsl $dicom_path/*"
	dcm2nii -o $subj_dir/dcmnii -f fsl $dicom_path/*
fi



racine=`ls ${subj_dir}/verter/*img | head -1`
racine=`basename $racine`
racine=${racine%%_*}

racine_name=${name%%_*}

if [ $racine != $racine_name ]
then
	echo ""
	echo ""
	echo "Possible conflit de nom"
	echo ""
	echo ""
	echo "racine mcverter : $racine "
	echo "racine dossier : $racine_name "
	echo "s'agit il du même patient? [o/N]"
	read rsp
	if [ $rsp != o ]
	then
		echo "problème de récupération de fichiers DICOM"
		rm -Rf $subj_dir/*
		exit
	fi
else
	echo "racine verter : $racine"
	echo "racine name : $racine_name"
fi
	

DTI_base=`ls $subj_dir/dcmnii/*bval`
DTI_base=`basename $DTI_base`
DTI_base=${DTI_base%%.bval}

gunzip $subj_dir/dcmnii/${DTI_base}.nii.gz
cp -f $subj_dir/dcmnii/${DTI_base}.nii $subj_dir/${name}_DTI_${DTI_base}.nii
cp -f $subj_dir/dcmnii/${DTI_base}.bval $subj_dir/${name}_DTI_${DTI_base}.bval
cp -f $subj_dir/dcmnii/${DTI_base}.bvec $subj_dir/${name}_DTI_${DTI_base}.bvec

mkdir $subj_dir/verter/DTI
mv $subj_dir/verter/*TENSOR* $subj_dir/verter/DTI

mkdir $subj_dir/verter/RS
mv $subj_dir/verter/*RESTING* $subj_dir/verter/RS

nbravo=`ls $subj_dir/verter/*3D*BRAVO*.img | wc -l`
if [ $nbravo -gt 1 ]
then
	for BRAVO in `ls $subj_dir/verter/*3D*BRAVO*.img`
	do
		BRAVO=`basename $BRAVO`
		BRAVO=${BRAVO%%.img}
		mri_convert $subj_dir/verter/${BRAVO}.img $subj_dir/${BRAVO}.nii
	done
else
	echo "T1 ou FLAIR à chercher manuellement"
fi
	



