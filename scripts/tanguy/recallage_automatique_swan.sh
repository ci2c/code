#! /bin/bash

if [ $# -lt 3 ]
then
		echo ""
		echo "Usage: recallage_automatique_Swan.sh -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "  -sd                             : Subjects Dir : directory containing the patient records to control"
		echo ""
		echo "	-subj				: Subj ID"
		echo ""
		echo "Usage: recallage_automatique_Swan.sh -sd <SUBJECTS_DIR> -subj <SUBJ> "
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
		echo ""
		echo "Usage: recallage_automatique_Swan.sh -sd <SUBJECTS_DIR> -subj <SUBJ> "
		echo ""
		echo "  -sd                             : Subjects Dir : directory containing the patient records to control"
		echo ""
		echo "	-subj				: Subj ID"
		echo ""
		echo "Usage: recallage_automatique_Swan.sh -sd <SUBJECTS_DIR> -subj <SUBJ> "
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
		;;
	-sd)
		
		SD=`expr $index + 1`
		eval SD=\${$SD}
		echo "SUBJ_DIR : $SD"
		;;

	-subj)
		
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "SUBJ : $SUBJ"
		;;


	
	esac
	index=$[$index+1]
done

model="/home/global/freesurfer/mni/bin/../share/mni_autoreg/average_305.mnc"

DIR="${SD}/${SUBJ}/mr"

mkdir $DIR/ROI_espace_sujet
mkdir $DIR/ROI_espace_MNI
mkdir $DIR/brain_mask_patient
mkdir $DIR/brain_mask_mni
mkdir $DIR/images
mkdir $DIR/results

#################
# Etude du SWAN #
#################

n=$(ls $DIR/data | grep -i swan | grep -i -v swan_min_ip | grep -i .img | grep -v Cor | grep -v Sag | wc -l)


if [ $n -eq 1 ]
then
	


	#un fichier trouvé : conversion - recallage - masques - calculs
	echo "$SUBJ : one swan file found"
	fil=$(ls $DIR/data | grep -i swan | grep -i -v swan_min_ip | grep -i .img | grep -v Cor | grep -v Sag )
	echo $fil

	#variables
	source="$DIR/data/$fil"
	sourcemnc="$DIR/images/swan.mnc"
	sourcenii="$DIR/images/swan.nii"
	recalmnc="$DIR/images/swan_recal.mnc"
	transfo="$DIR/images/swan.xfm"


	#conversion
	mri_convert $source $sourcenii

	#création masque cerveau espace patient
	mkdir $DIR/temp	
	bet $sourcenii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/*.nii $DIR/brain_mask_patient/mask_swan.nii
	rm -Rf $DIR/temp
	
	#conversion
	mri_convert $source $sourcemnc

	#matrice de transformation
	echo "calcul de la matrice de transformation"
	echo "sourcemnc : $sourcemnc"
	echo "transfo : $transfo"


	mritotal ${sourcemnc} ${transfo} 
	mincresample -like ${model} -transformation ${transfo} ${sourcemnc} ${recalmnc} -clobber


	#création masque cerveau espace MNI
	mkdir $DIR/temp		
	mri_convert $recalmnc $DIR/temp/swan.nii
	bet $DIR/temp/swan.nii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/temp_mask.nii $DIR/brain_mask_mni/mask_swan.nii
	rm -Rf $DIR/temp
	mri_convert $DIR/brain_mask_mni/mask_swan.nii $DIR/brain_mask_mni/mask_swan.nii --out_orientation LAS



	# masques & calculs

	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq swan -rep patient"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq swan -rep patient
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq swan -rep mni"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq swan -rep mni

else
	echo ""
	echo "WARNING"
	echo ""
	echo ""
	echo "$SUBJ : $n file found"
	echo "need exactly one"
	echo ""
	echo "change conditions of detection"
fi



########################
# Etude du SWAN MIN_IP #
########################

n=$(ls $DIR/data | grep -i min_ip | grep -i .img | grep -v Cor | grep -v Sag | wc -l)


if [ $n -eq 1 ]
then
	

	#un fichier trouvé : conversion - recallage - masques - calculs
	echo "$SUBJ : one swan_min_ip file found"
	fil=$(ls $DIR/data | grep -i min_ip | grep -i .img | grep -v Cor | grep -v Sag)
	echo $fil

	#variables
	source="$DIR/data/$fil"
	sourcemnc="$DIR/images/swan_min_ip.mnc"
	sourcenii="$DIR/images/swan_min_ip.nii"
	recalmnc="$DIR/images/swan_min_ip_recal.mnc"
	transfo="$DIR/images/swan_min_ip.xfm"
	
	cp -f $DIR/images/swan.xfm $transfo

	#conversion
	mri_convert $source $sourcenii


	#création masque cerveau
	mkdir $DIR/temp	
	bet $sourcenii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/*.nii $DIR/brain_mask_patient/mask_swan_min_ip.nii
	rm -Rf $DIR/temp
	

	#conversion
	mri_convert $source $sourcemnc

	mincresample -like ${model} -transformation ${transfo} ${sourcemnc} ${recalmnc} -clobber

	#création masque cerveau espace MNI
	mkdir $DIR/temp		
	mri_convert $recalmnc $DIR/temp/swan_min_ip.nii
	bet $DIR/temp/swan_min_ip.nii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/temp_mask.nii $DIR/brain_mask_mni/mask_swan_min_ip.nii
	rm -Rf $DIR/temp
	mri_convert $DIR/brain_mask_mni/mask_swan_min_ip.nii $DIR/brain_mask_mni/mask_swan_min_ip.nii --out_orientation LAS



	# masques & calculs
	
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq swan_min_ip -rep patient"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq swan_min_ip -rep patient
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq swan_min_ip -rep mni"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq swan_min_ip -rep mni

else
	echo ""
	echo "WARNING"
	echo ""
	echo ""
	echo "$SUBJ : $n file found"
	echo "need exactly one"
	echo ""
	echo "change conditions of detection"
fi








###################
# Etude du T2_GRE #
###################

n=$(ls $DIR/data | grep -i t2 | grep -i .img | grep -v Cor | grep -v -i flair | grep -v Sag | wc -l)


if [ $n -eq 1 ]
then
	
	#un fichier trouvé : conversion - recallage - masques - calculs
	echo "$SUBJ : one T2_GRE file found"
	fil=$(ls $DIR/data | grep -i t2 | grep -i .img | grep -v Cor | grep -v -i flair | grep -v Sag )
	echo $fil

	#variables
	source="$DIR/data/$fil"
	sourcemnc="$DIR/images/T2_GRE.mnc"
	sourcenii="$DIR/images/T2_GRE.nii"
	recalmnc="$DIR/images/T2_GRE_recal.mnc"
	transfo="$DIR/images/T2_GRE.xfm"

	#conversion
	mri_convert $source $sourcenii

	#création masque cerveau
	mkdir $DIR/temp	
	bet $sourcenii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/*.nii $DIR/brain_mask_patient/mask_T2_GRE.nii
	rm -Rf $DIR/temp

	#conversion
	mri_convert $source $sourcemnc

	#matrice de transformation
	echo "calcul de la matrice de transformation"
	echo "sourcemnc : $sourcemnc"
	echo "transfo : $transfo"


	mritotal ${sourcemnc} ${transfo} 
	mincresample -like ${model} -transformation ${transfo} ${sourcemnc} ${recalmnc} -clobber

	#création masque cerveau espace MNI
	mkdir $DIR/temp		
	mri_convert $recalmnc $DIR/temp/T2_GRE.nii
	bet $DIR/temp/T2_GRE.nii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/temp_mask.nii $DIR/brain_mask_mni/mask_T2_GRE.nii
	rm -Rf $DIR/temp
	mri_convert $DIR/brain_mask_mni/mask_T2_GRE.nii $DIR/brain_mask_mni/mask_T2_GRE.nii --out_orientation LAS



	# masques & calculs
	
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq T2_GRE -rep patient"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq T2_GRE -rep patient
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq T2_GRE -rep mni"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq T2_GRE -rep mni

else
	echo ""
	echo "WARNING"
	echo ""
	echo ""
	echo "$SUBJ : $n file found"
	echo "need exactly one"
	echo ""
	echo "change conditions of detection"
fi





##################
# Etude du FLAIR #
##################

n=$(ls $DIR/data | grep -i FLAIR | grep -i .img | grep -v Cor | grep -v Sag | wc -l)


if [ $n -eq 1 ]
then
	
	#un fichier trouvé : conversion - recallage - masques - calculs
	echo "$SUBJ : one FLAIR file found"
	fil=$(ls $DIR/data | grep -i FLAIR | grep -i .img | grep -v Cor | grep -v Sag )
	echo $fil

	#variables
	source="$DIR/data/$fil"
	sourcemnc="$DIR/images/FLAIR.mnc"
	sourcenii="$DIR/images/FLAIR.nii"
	recalmnc="$DIR/images/FLAIR_recal.mnc"
	transfo="$DIR/images/FLAIR.xfm"


	#conversion
	mri_convert $source $sourcenii

	#création masque cerveau
	mkdir $DIR/temp	
	bet $sourcenii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/*.nii $DIR/brain_mask_patient/mask_FLAIR.nii
	rm -Rf $DIR/temp
	

	#conversion
	mri_convert $source $sourcemnc

	#matrice de transformation
	echo "calcul de la matrice de transformation"
	echo "sourcemnc : $sourcemnc"
	echo "transfo : $transfo"


	mritotal ${sourcemnc} ${transfo} 
	mincresample -like ${model} -transformation ${transfo} ${sourcemnc} ${recalmnc} -clobber


	#création masque cerveau espace MNI
	mkdir $DIR/temp		
	mri_convert $recalmnc $DIR/temp/FLAIR.nii
	bet $DIR/temp/FLAIR.nii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/temp_mask.nii $DIR/brain_mask_mni/mask_FLAIR.nii
	rm -Rf $DIR/temp
	mri_convert $DIR/brain_mask_mni/mask_FLAIR.nii $DIR/brain_mask_mni/mask_FLAIR.nii --out_orientation LAS

	# masques & calculs
	
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq FLAIR -rep patient"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq FLAIR -rep patient
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq FLAIR -rep mni"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq FLAIR -rep mni


else
	echo ""
	echo "WARNING"
	echo ""
	echo ""
	echo "$SUBJ : $n file found"
	echo "need exactly one"
	echo ""
	echo "change conditions of detection"
fi







####################
# Etude de la diff #
####################


n=$(ls $DIR/data | grep -i '\(dwi\|diffusion\)' | grep -i .img | grep -v Cor | grep -i 001 | grep -v Sag | wc -l)


if [ $n -eq 1 ]
then
	
	#un fichier trouvé : conversion - recallage - masques - calculs
	echo "$SUBJ : one diff file found"
	fil=$(ls $DIR/data | grep -i '\(dwi\|diffusion\)' | grep -i .img | grep -v Cor | grep -i 001 | grep -v Sag)
	echo $fil

	#variables
	source="$DIR/data/$fil"
	sourcemnc="$DIR/images/diff.mnc"
	sourcenii="$DIR/images/diff.nii"
	recalmnc="$DIR/images/diff_recal.mnc"
	transfo="$DIR/images/diff.xfm"
	

	#conversion
	mri_convert $source $sourcenii

	#création masque cerveau
	mkdir $DIR/temp	
	bet $sourcenii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/*.nii $DIR/brain_mask_patient/mask_diff.nii
	rm -Rf $DIR/temp
	

	#conversion
	mri_convert $source $sourcemnc

	#matrice de transformation
	echo "calcul de la matrice de transformation"
	echo "sourcemnc : $sourcemnc"
	echo "transfo : $transfo"


	mritotal ${sourcemnc} ${transfo} 
	mincresample -like ${model} -transformation ${transfo} ${sourcemnc} ${recalmnc} -clobber

	#création masque cerveau espace MNI
	mkdir $DIR/temp		
	mri_convert $recalmnc $DIR/temp/diff.nii
	bet $DIR/temp/diff.nii $DIR/temp/temp.nii -m
	rm -f $DIR/temp/temp.nii.gz
	gunzip $DIR/temp/*.gz
	mv $DIR/temp/temp_mask.nii $DIR/brain_mask_mni/mask_diff.nii
	rm -Rf $DIR/temp
	mri_convert $DIR/brain_mask_mni/mask_diff.nii $DIR/brain_mask_mni/mask_diff.nii --out_orientation LAS

	# masques & calculs
	
	nameseq="diff"
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq $nameseq -rep patient"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq $nameseq -rep patient
	echo "mask_swan.sh -sd $DIR -i $sourcemnc -seq $nameseq -rep mni"
	mask_swan.sh -sd $DIR -i $sourcemnc -seq $nameseq -rep mni



else
	echo ""
	echo "WARNING"
	echo ""
	echo ""
	echo "$SUBJ : $n file found"
	echo "need only one"
	echo ""
	echo "change conditions of detection"
fi



