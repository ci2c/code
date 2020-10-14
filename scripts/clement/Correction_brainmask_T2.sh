#! /bin/bash

SUBJECTS_DIR=/NAS/tupac/protocoles/Strokdem/FS5.1
SubjectDIR=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask
T2DIR=/NAS/tupac/protocoles/Strokdem/T2
FilePbT2=/home/clement/SVN/scripts/clement/Pbs_Brainmask_correction.txt
FileT2=/home/clement/SVN/scripts/clement/IRM-Restant_T2.txt # Nom des images T2 à traiter dans le dossier T2DIR


while read data
do
	f=$T2DIR/$data
	echo $f
	d=`dirname $f`
	subjid=`basename $d`
 
	if [ -e $f ] & [ -e $SUBJECTS_DIR/$subjid/mri/T1.mgz ] &  [ -e $SUBJECTS_DIR/$subjid/surf/rh.white ] # -e = exist 
	then 
		echo $subjid
		#1ere etape : Mettre T2 ref T1 en mm^3
		if [ ! -e  $T2DIR/$subjid/T2_refT1.nii.gz	]
		then
			#echo $subjid
			echo "First step: Registration"
			bbregister --s $subjid --mov $f --init-header --t2 --reg $T2DIR/$subjid/T2reg.dat --o $T2DIR/$subjid/T2_refT1.nii.gz	#--s : nom du sujet, --mov : volume à charger, --init-header : initialise la registration en fonction de la géométire du header
			# --t2 : contraste t2, --reg : output registration file --o : output
		fi
	
		#2eme etape : Extraire Cerveau de T2 recalee = enleve crane etc
		if [ ! -e $T2DIR/$subjid/T2_refT1_brain.nii.gz ]
		then
			echo "Second step: T2 Extraction"
			bet $T2DIR/$subjid/T2_refT1.nii.gz $T2DIR/$subjid/T2_refT1_brain.nii.gz -m #-m = sort un mask binaire _mask
		fi

		#3eme etape : determine ce qui depasse sur le T1
		if [ ! -e $T2DIR/$subjid/T1_brain_mask_bext_d.nii.gz ]
		then
			echo "Third step: T1 Extraction"
			mris_calc -o $T2DIR/$subjid/T1_brain_mask.nii.gz $SUBJECTS_DIR/$subjid/mri/brainmask.mgz masked $T2DIR/$subjid/T2_refT1_brain_mask.nii.gz #Prends le masque que FS a fait pour l'appliquer au mask T2
			mri_binarize --i $T2DIR/$subjid/T1_brain_mask.nii.gz --o $T2DIR/$subjid/T1_brain_mask_b.nii.gz --min 1 #Binarize le resultat
			mri_morphology $T2DIR/$subjid/T1_brain_mask_b.nii.gz erode 1 $T2DIR/$subjid/T1_brain_mask_e.nii.gz
			mris_calc -o $T2DIR/$subjid/T1_brain_mask_bext.nii.gz $T2DIR/$subjid/T1_brain_mask_b.nii.gz sub $T2DIR/$subjid/T1_brain_mask_e.nii.gz
			mri_morphology $T2DIR/$subjid/T1_brain_mask_bext.nii.gz dilate 1 $T2DIR/$subjid/T1_brain_mask_bext_d.nii.gz
		fi	

		#4eme etape : Segmenter T2
		if [ ! -e $T2DIR/$subjid/T2_refT1_brain_seg_3.nii.gz ]
		then
			echo "Fourth step: T2 Segmentation"
			fast -t 2 -n 4 -H 0.1 -I 4 -l 20.0 -g --nopve -o $T2DIR/$subjid/T2_refT1_brain $T2DIR/$subjid/T2_refT1_brain #Segmente le T2 pour séparer le crâne, wm, gm, et csf
		fi

		#5eme : Supp
		if [ ! -e $T2DIR/$subjid/T1_brain_mask_final.mgz ]
		then
			echo "Fifth step: Brain Mask "
			mris_calc -o $T2DIR/$subjid/out.mgz $T2DIR/$subjid/T1_brain_mask_bext_d.nii.gz masked $T2DIR/$subjid/T2_refT1_brain_seg_3.nii.gz
			mris_calc -o $T2DIR/$subjid/out.mgz $T2DIR/$subjid/T1_brain_mask.nii.gz masked $T2DIR/$subjid/out.mgz 
			mris_calc -o $T2DIR/$subjid/out.mgz $T2DIR/$subjid/T1_brain_mask.nii.gz sub $T2DIR/$subjid/out.mgz
			mv $T2DIR/$subjid/out.mgz $T2DIR/$subjid/T1_brain_mask_final.mgz  #Sortie de mris_calc=out donc changement de nom
			mri_convert $T2DIR/$subjid/out.mgz $T2DIR/$subjid/T1_brain_mask_final.nii.gz	
		fi
	else
	      echo 'Pbs ' $subjid 
		echo 'Pbs ' $subjid >> $FilePbT2
	fi
done < $FileT2



