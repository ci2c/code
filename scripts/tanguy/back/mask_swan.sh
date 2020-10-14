#! /bin/bash

if [ $# -lt 4 ]
then
		echo ""
		echo "Usage: mask_swan.sh -sd <Subject dir> -i <image> "
		echo ""
		echo "-sd				: SUBJECT DIR : dir to find images"
		echo ""
		echo "-i                                : image"
		echo ""
		echo "-seq                              : sequence name"
		echo ""
		echo "-rep				: repere de travail : mni ou patient"
		echo "Usage: mask_swan.sh -sd <Subject dir> -i <image>"
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
		echo "Usage: mask_swan.sh -sd <Subject dir> -i <image> "
		echo ""
		echo "-sd				: SUBJECT DIR : dir to find images"
		echo ""
		echo "-i                                : image"
		echo ""
		echo "-seq                              : sequence name"
		echo ""
		echo "-rep				: repere de travail : mni ou patient"
		echo "Usage: mask_swan.sh -sd <Subject dir> -i <image>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
		;;
	-sd)
		
		DIR=`expr $index + 1`
		eval DIR=\${$DIR}
		echo "DIR : $DIR"
		;;
	-i)
		
		im=`expr $index + 1`
		eval im=\${$im}
		echo "image : $im"
		;;

	-seq)
		
		SEQ=`expr $index + 1`
		eval SEQ=\${$SEQ}
		echo "sequence : $SEQ"
		;;

	-rep)
		
		ESPACE=`expr $index + 1`
		eval ESPACE=\${$ESPACE}
		echo "repere : $ESPACE"
		;;	
	
	esac
	index=$[$index+1]
done

####
# Définition de l'espace de travail 


if  [ "$ESPACE" = 'mni' ]
then


###################################
#  Travail dans l'espace du MNI   #
###################################

echo "travail dans l'espace du MNI"

# variables
mask_dir="/home/tanguy/NAS/tanguy/SWAN/ROI"
model="/home/global/freesurfer/mni/bin/../share/mni_autoreg/average_305.mnc"


#calcul de variables
nameseq=${im%.*}
nametxt=$DIR/results/${SEQ}_MNI_mean
transfo="${nameseq}.xfm"


#création du fichier .txt
touch $nametxt.txt
t="moyenne  écart-type"
echo $t>>$nametxt.txt

mkdir $DIR/ROI_espace_MNI/$SEQ

for ROI in `ls $mask_dir`
do
	echo $ROI	
	nameROI=${ROI%.*}
	


	#variables ROI

	in="${mask_dir}/${ROI}"
	mask="${DIR}/ROI_espace_MNI/$SEQ/mask_${nameROI}.nii"
	
	#on applique le masque du cerveau 
	fslmaths $in -mas ${DIR}/brain_mask_mni/mask_${SEQ}.nii $mask
	gunzip $mask.gz
	

	echo $nameROI>>$nametxt.txt
	echo `3dmaskave -mask ${mask} -sigma -quiet ${nameseq}_recal.mnc`>>$nametxt.txt



done

else

###################################
# Travail dans l'espace du sujet  #
###################################

echo "travail dans l'espace du sujet"

# variables
mask_dir="/home/tanguy/NAS/tanguy/SWAN/ROI"
model="/home/global/freesurfer/mni/bin/../share/mni_autoreg/average_305.mnc"


#calcul de variables
nameseq=${im%.*}
nametxt=$DIR/results/${SEQ}_sujet_mean
transfo="${nameseq}.xfm"


#création du fichier .txt
touch $nametxt.txt
t="moyenne  écart-type"
echo $t>>$nametxt.txt

mkdir $DIR/ROI_espace_sujet/$SEQ

for ROI in `ls $mask_dir`
do
	echo $ROI	
	nameROI=${ROI%.*}
	


	#variables ROI

	in="${mask_dir}/${ROI}"
	out="${DIR}/ROI_espace_sujet/$SEQ/${nameROI}.mnc"
	outrecal="${DIR}/ROI_espace_sujet/$SEQ/${nameROI}_recal.mnc"
	outnii="${DIR}/ROI_espace_sujet/$SEQ/${nameROI}_recal.nii"
	mask_temp="${DIR}/ROI_espace_sujet/$SEQ/mask_temp_${nameROI}.nii"
	mask="${DIR}/ROI_espace_sujet/$SEQ/mask_${nameROI}.nii"
	
	#création du masque de la ROI dans le repère de la séquence
	mri_convert $in $out -odt short
	mincresample -like ${im} -invert_transformation -transformation ${transfo} $out $outrecal -short -clobber
	mri_convert $outrecal $outnii -odt short
	mri_binarize --i $outnii --min 10 --binval 1 --o $mask_temp


	#on applique le masque du cerveau 
	echo "	fslmaths $mask_temp -mas ${DIR}/brain_mask_patient/mask_${SEQ}.nii $mask"
	fslmaths $mask_temp -mas ${DIR}/brain_mask_patient/mask_${SEQ}.nii $mask
	gunzip $mask.gz
	

	echo $nameROI>>$nametxt.txt
	echo `3dmaskave -mask ${mask} -sigma -quiet ${nameseq}.nii`>>$nametxt.txt

	rm -f $out $outrecal $outnii $mask_temp

done

fi



