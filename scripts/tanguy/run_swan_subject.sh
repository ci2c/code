#! /bin/bash

if [ $# -lt 6 ]
then
		echo ""
		echo "Usage: run_swan_subject.sh -sd <SUBJECT_DIR> -subj <SUBJECT> -mask_dir <MASK_DIR> "
		echo ""
		echo " -sd				: Subject directory"
		echo ""
		echo " -subj				: Subject"
		echo ""
		echo " -mask_dir			: Mask directory : path to find ROI files"
		echo ""
		echo "Usage: run_swan_subject.sh -sd <SUBJECT_DIR> -subj <SUBJECT> -mask_dir <MASK_DIR> "
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
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
		echo "Usage: run_swan_subject.sh -sd <SUBJECT_DIR> -subj <SUBJECT> -mask_dir <MASK_DIR> "
		echo ""
		echo " -sd				: Subject directory"
		echo ""
		echo " -subj				: Subject"
		echo ""
		echo " -mask_dir			: Mask directory : path to find ROI files"
		echo ""
		echo "Usage: run_swan_subject.sh -sd <SUBJECT_DIR> -subj <SUBJECT> -mask_dir <MASK_DIR> "
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
		;;
	-sd)
		
		SD=`expr $index + 1`
		eval SD=\${$SD}
		echo "Subject Dir : $SD"
		;;

	-subj)
		
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "Subject : $SUBJ"
		;;


	-mask_dir)
		
		mask_dir=`expr $index + 1`
		eval mask_dir=\${$mask_dir}
		echo "Path to find ROI files : $mask_dir"
		;;
	
	esac
	index=$[$index+1]
done



slice=5



# initialisation des variables

sourcenii="$SD/$SUBJ/mr/images/swan.nii"
sourcemnc="$SD/$SUBJ/mr/images/swan.mnc"
recalmnc="$SD/$SUBJ/mr/images/swan_recal.mnc"
transfo="$SD/$SUBJ/mr/images/swan.xfm"

model="/home/global/freesurfer/mni/bin/../share/mni_autoreg/average_305.mnc"


#on regarde si la conversion a déjà été faite
#en testant la présence du fichier swan.nii dans $SD/$SUBJ/mr/images

if [ ! -f $sourcenii ]
then

	# swan.nii n'existe pas : on convertit les fichiers DICOM afin d'obtenir le fichier.

	cd $SD/$SUBJ/mr
	mkdir $SD/$SUBJ/mr/data
	echo "conversion des données dicoms"
	mcverter -o $SD/$SUBJ/mr/data -f fsl -n */*
	echo "conversion achevée"

	# on récupère l'image swan dans le dossier data

	n=$(ls $SD/$SUBJ/mr/data | grep -i swan | grep -i -v swan_min_ip  | grep -v Cor | grep -v Sag | wc -l)

	if [ $n -eq 1 ]
	then
		mkdir $SD/$SUBJ/mr/images

		echo "fil=$(ls $SD/$SUBJ/mr/data | grep -i swan | grep -i -v swan_min_ip  | grep -v Cor | grep -v Sag)"
		fil=$(ls $SD/$SUBJ/mr/data | grep -i swan | grep -i -v swan_min_ip  | grep -v Cor | grep -v Sag)

		echo "cp -f $SD/$SUBJ/mr/data/$fil $sourcenii"
		cp -f $SD/$SUBJ/mr/data/$fil $sourcenii

	else	
		echo ""
		echo ""
		echo "WARNING : impossible to find one swan file"
		echo ""
		echo ""
		exit
		
	
	fi

else
	echo ""
	echo "the file swan.nii exists"
fi


# création de la matrice de recallage -> espace mni
# qui servira à passer les ROI dans l'espace patient



#création masque cerveau espace patient
echo "création brain mask espace patient"

mkdir $SD/$SUBJ/mr/temp	
mkdir $SD/$SUBJ/mr/brain_mask_patient

echo "bet $sourcenii $SD/$SUBJ/mr/temp/temp.nii -m"
bet $sourcenii $SD/$SUBJ/mr/temp/temp.nii -m

rm -f $SD/$SUBJ/mr/temp/temp.nii.gz
gunzip $SD/$SUBJ/mr/temp/*.gz
mv $SD/$SUBJ/mr/temp/*.nii $SD/$SUBJ/mr/brain_mask_patient/mask_swan.nii
rm -Rf $SD/$SUBJ/mr/temp


#conversion

echo "mri_convert $sourcenii $sourcemnc"
mri_convert $sourcenii $sourcemnc



#matrice de transformation
echo "calcul de la matrice de transformation"
echo "sourcemnc : $sourcemnc"
echo "transfo : $transfo"


echo "mritotal $sourcemnc $transfo"
mritotal $sourcemnc $transfo

echo "mincresample -like $model -transformation $transfo $sourcemnc $recalmnc -clobber"
mincresample -like $model -transformation $transfo $sourcemnc $recalmnc -clobber


# attention : il est important de vérifier le recallage 

freeview $model $recalmnc &

echo "vérifier recallage sur freeview"




#création masque cerveau espace MNI
echo "création brain mask espace MNI"

mkdir $SD/$SUBJ/mr/temp		
mkdir $SD/$SUBJ/mr/brain_mask_mni

echi "mri_convert $recalmnc $SD/$SUBJ/mr/temp/swan.nii"
mri_convert $recalmnc $SD/$SUBJ/mr/temp/swan.nii

echo "bet $SD/$SUBJ/mr/temp/swan.nii $SD/$SUBJ/mr/temp/temp.nii -m"
bet $SD/$SUBJ/mr/temp/swan.nii $SD/$SUBJ/mr/temp/temp.nii -m

rm -f $SD/$SUBJ/mr/temp/temp.nii.gz
gunzip $SD/$SUBJ/mr/temp/*.gz
mv $SD/$SUBJ/mr/temp/temp_mask.nii $SD/$SUBJ/mr/brain_mask_mni/mask_swan.nii
rm -Rf $SD/$SUBJ/mr/temp

echo "mri_convert $SD/$SUBJ/mr/brain_mask_mni/mask_swan.nii $SD/$SUBJ/mr/brain_mask_mni/mask_swan.nii --out_orientation LAS"
mri_convert $SD/$SUBJ/mr/brain_mask_mni/mask_swan.nii $SD/$SUBJ/mr/brain_mask_mni/mask_swan.nii --out_orientation LAS




# Compute min ip

echo "création du fichier swan_min_ip.nii"


echo "im2minip.sh -im $SD/$SUBJ/mr/images/swan.nii"
im2minip.sh -im $SD/$SUBJ/mr/images/swan.nii -slice $slice -dir axial



# Passer ROI dans l'espace du sujet
mkdir $SD/$SUBJ/mr/ROI_espace_sujet

echo "passage des ROI dans l espace sujet"

echo "mkdir $SD/$SUBJ/mr/ROI_espace_sujet/swan"
mkdir $SD/$SUBJ/mr/ROI_espace_sujet/swan

for ROI in `ls $mask_dir`
do
	
	echo $ROI
	nameROI=${ROI%.*}


	#variables ROI
	in="${mask_dir}/${ROI}"
	out="$SD/$SUBJ/mr/ROI_espace_sujet/swan/${nameROI}.mnc"
	outrecal="$SD/$SUBJ/mr/ROI_espace_sujet/swan/${nameROI}_recal.mnc"
	outnii="$SD/$SUBJ/mr/ROI_espace_sujet/swan/${nameROI}_recal.nii"
	mask_temp="$SD/$SUBJ/mr/ROI_espace_sujet/swan/mask_temp_${nameROI}.nii"
	mask="$SD/$SUBJ/mr/ROI_espace_sujet/swan/mask_${nameROI}.nii"
	

	#création du masque de la ROI dans le repère de la séquence
	echo "mri_convert $in $out -odt short"
	mri_convert $in $out -odt short
	echo "mincresample -like $sourcemnc -invert_transformation -transformation ${transfo} $out $outrecal -short -clobber"
	mincresample -like $sourcemnc -invert_transformation -transformation ${transfo} $out $outrecal -short -clobber
	echo "mri_convert $outrecal $outnii -odt short"
	mri_convert $outrecal $outnii -odt short
	echo "mri_binarize --i $outnii --min 10 --binval 1 --o $mask_temp"
	mri_binarize --i $outnii --min 10 --binval 1 --o $mask_temp

	#on applique le masque du cerveau 
	echo "	fslmaths $mask_temp -mas $SD/$SUBJ/mr/brain_mask_patient/mask_${SEQ}.nii $mask"
	fslmaths $mask_temp -mas $SD/$SUBJ/mr/brain_mask_patient/mask_swan.nii $mask
	gunzip ${mask}.gz

	rm -f $out $outrecal $outnii $mask_temp

done





# Calcul des moyennes et écarts type de signal

mkdir $SD/$SUBJ/mr/results
nametxt=$SD/$SUBJ/mr/results/result_swan_min_ip
path_min_ip_dim=$SD/$SUBJ/mr/images/swan_Ax_min_ip_dim_${slice}.nii

#création du fichier .txt
echo "création du fichier texte"
touch $nametxt.txt
t="moyenne  écart-type"
echo $t>>$nametxt.txt


# calcul des données pour chaque ROI

echo "calcul des données pour chaque ROI"

for mask_roi in `ls $SD/$SUBJ/mr/ROI_espace_sujet/swan`
do
	echo "calcul pour $mask_roi"
	nameROI=${mask_roi%.*}
	ROI=$SD/$SUBJ/mr/ROI_espace_sujet/swan/$mask_roi
	echo $nameROI>>$nametxt.txt
	echo "echo `3dmaskave -mask ${ROI} -sigma -quiet ${path_min_ip_dim}`>>$nametxt.txt"
	echo `3dmaskave -mask ${ROI} -sigma -quiet ${path_min_ip_dim}`>>$nametxt.txt

done



