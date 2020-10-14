#! /bin/bash
SUBJECTS_DIR=/NAS/tupac/protocoles/Strokdem/FS5.1
par_dir=/NAS/tupac/protocoles/Strokdem/par
SubjectDIR=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask
T2_dir=/NAS/tupac/protocoles/Strokdem/T2


#Attribution
index=1

while [ $index -le $# ]
do

	eval arg=\${$index}
	case "$arg" in 
	-subj)
		index=$[$index+1]
		eval subjid=\${$index}
		echo "Subj = $subjid"
		;;
	esac
	index=$[$index+1]
done

echo $subjid

space=`expr index "$subjid" "_"`
subj=${subjid:0:$((($space)-1))}

#=====================================================================
#           Run 1rst part : FS recon-all from 3DT1
#=====================================================================

T1_im=$(ls ${par_dir}/${subj}/${subjid}/3DT1_ISO_1mm_HR/*nii* 2> /dev/null)


if [ ! -e $SUBJECTS_DIR/$subjid ] && [ -e $T1_im ]; then

	echo "RUN Recon-all first step : "
	echo `basename $im`
	recon-all -all -sd $SUBJECTS_DIR -subjid $subjid -i $T1_im -numintensitycor-3T
 

else 
	echo "$subjid folder already exist"
fi

#=====================================================================
#           Run 2nd part : Brain mask correction from T2 
#=====================================================================

#### T2 preparation ####

T2_Vdir=$(ls -d ${par_dir}/${subj}/${subjid}/*T2*VISTA*/ 2> /dev/null)
T2_Edir=$(ls -d ${par_dir}/${subj}/${subjid}/*T2*ETOILE*/ 2> /dev/null)

T2_test=$(ls ${T2_dir}/${subjid} | sed -e "/\.$/d" | wc -l)
echo $T2_test
echo $T2_Edir


if [ $T2_test -eq 0 ]; then
	if [ -d $T2_Vdir ]; then
		echo"mv $T2_Vdir ${par_dir}/${subj}/${subjid}/T2_VISTA_HR_SENSE"
		mv $T2_Vdir ${par_dir}/${subj}/${subjid}/T2_VISTA_HR_SENSE
		T2_V=$(ls ${par_dir}/${subj}/${subjid}/T2_VISTA_HR_SENSE/*nii* 2> /dev/null)
		if [ ! -e $T2_V ]; then
			dcm2nii -o ${par_dir}/${subj}/${subjid}/T2_VISTA_HR_SENSE ${par_dir}/${subj}/${subjid}/T2_VISTA_HR_SENSE/*
			rm -rf ${par_dir}/${subj}/${subjid}/T2_VISTA_HR_SENSE/o*
		fi
		mkdir ${T2_dir}/${subjid}
		cp ${par_dir}/${subj}/${subjid}/T2_VISTA_HR_SENSE/*gz ${T2_dir}/${subjid}/
	fi
	if [ -d $T2_Edir ]; then
		echo "mv $T2_Edir ${par_dir}/${subj}/${subjid}/T2_ETOILE"
		mv $T2_Edir ${par_dir}/${subj}/${subjid}/T2_ETOILE
		T2_E=$(ls ${par_dir}/${subj}/${subjid}/T2_ETOILE/*nii* 2> /dev/null)
		if [ ! -e $T2_E ]; then
			dcm2niin -o ${par_dir}/${subj}/${subjid}/T2_ETOILE ${par_dir}/${subj}/${subjid}/T2_ETOILE/*
			rm -rf ${par_dir}/${subj}/${subjid}/T2_ETOILE/o*
		fi
		mkdir ${T2_dir}/${subjid}
		cp ${par_dir}/${subj}/${subjid}/T2_ETOILE/*gz ${T2_dir}/${subjid}/
	else echo "No T2 for $subjid"
	fi
fi

T2_file=$(ls ${T2_dir}/${subjid}/*nii*)

#### Brain mask correction ####

if [ -e $T2_file ] & [ -e $SUBJECTS_DIR/$subjid/mri/T1.mgz ] &  [ -e $SUBJECTS_DIR/$subjid/surf/rh.white ]; then 
		echo $subjid
		#1ere etape : Mettre T2 ref T1 en mm^3
		if [ ! -e  $T2_dir/$subjid/T2_refT1.nii.gz	]; then
			#echo $subjid
			echo "===First step: Registration==="
			echo "bbregister --s $subjid --mov $T2_file --init-header --t2 --reg $T2_dir/$subjid/T2reg.dat --o $T2_dir/$subjid/T2_refT1.nii.gz"
			bbregister --s $subjid --mov $T2_file --init-header --t2 --reg $T2_dir/$subjid/T2reg.dat --o $T2_dir/$subjid/T2_refT1.nii.gz	#--s : nom du sujet, --mov : volume à charger, --init-header : initialise la registration en fonction de la géométire du header
			# --t2 : contraste t2, --reg : output registration file --o : output
		fi
	
		#2eme etape : Extraire Cerveau de T2 recalee = enleve crane etc
		if [ ! -e $T2_dir/$subjid/T2_refT1_brain.nii.gz ]; then
			echo "===Second step: T2 Extraction==="
			echo "bet $T2_dir/$subjid/T2_refT1.nii.gz $T2_dir/$subjid/T2_refT1_brain.nii.gz -m"
			bet $T2_dir/$subjid/T2_refT1.nii.gz $T2_dir/$subjid/T2_refT1_brain.nii.gz -m #-m = sort un mask binaire _mask
		fi

		#3eme etape : determine ce qui depasse sur le T1
		if [ ! -e $T2_dir/$subjid/T1_brain_mask_bext_d.nii.gz ]; then
			echo "===Third step: T1 Extraction==="
			mris_calc -o $T2_dir/$subjid/T1_brain_mask.nii.gz $SUBJECTS_DIR/$subjid/mri/brainmask.mgz masked $T2_dir/$subjid/T2_refT1_brain_mask.nii.gz #Prends le masque que FS a fait pour l'appliquer au mask T2
			mri_binarize --i $T2_dir/$subjid/T1_brain_mask.nii.gz --o $T2_dir/$subjid/T1_brain_mask_b.nii.gz --min 1 #Binarize le resultat
			mri_morphology $T2_dir/$subjid/T1_brain_mask_b.nii.gz erode 1 $T2_dir/$subjid/T1_brain_mask_e.nii.gz
			mris_calc -o $T2_dir/$subjid/T1_brain_mask_bext.nii.gz $T2_dir/$subjid/T1_brain_mask_b.nii.gz sub $T2_dir/$subjid/T1_brain_mask_e.nii.gz
			mri_morphology $T2_dir/$subjid/T1_brain_mask_bext.nii.gz dilate 1 $T2_dir/$subjid/T1_brain_mask_bext_d.nii.gz
		fi	

		#4eme etape : Segmenter T2
		if [ ! -e $T2_dir/$subjid/T2_refT1_brain_seg_3.nii.gz ]; then
			echo "===Fourth step: T2 Segmentation==="
			fast -t 2 -n 4 -H 0.1 -I 4 -l 20.0 -g --nopve -o $T2_dir/$subjid/T2_refT1_brain $T2_dir/$subjid/T2_refT1_brain #Segmente le T2 pour séparer le crâne, wm, gm, et csf
		fi

		#5eme : Supp
		if [ ! -e $T2_dir/$subjid/T1_brain_mask_final.mgz ]; then
			echo "===Fifth step: Brain Mask==="
			mris_calc -o $T2_dir/$subjid/out.mgz $T2_dir/$subjid/T1_brain_mask_bext_d.nii.gz masked $T2_dir/$subjid/T2_refT1_brain_seg_3.nii.gz
			mris_calc -o $T2_dir/$subjid/out.mgz $T2_dir/$subjid/T1_brain_mask.nii.gz masked $T2_dir/$subjid/out.mgz 
			mris_calc -o $T2_dir/$subjid/out.mgz $T2_dir/$subjid/T1_brain_mask.nii.gz sub $T2_dir/$subjid/out.mgz
			mv $T2_dir/$subjid/out.mgz $T2_dir/$subjid/T1_brain_mask_final.mgz  #Sortie de mris_calc=out donc changement de nom
			mri_convert $T2_dir/$subjid/out.mgz $T2_dir/$subjid/T1_brain_mask_final.nii.gz	
		fi
else
	echo 'Pbs ' $subjid 
	echo 'Pbs ' $subjid
fi


#=====================================================================
#           Run 3rd part : FS using T2 correction 
#=====================================================================


if [ -e $SUBJECTS_DIR/$subjid ] & [ -e $T2_dir/$subjid/T1_brain_mask_final.mgz ] & [ ! -e $SubjectDIR/$subjid ]
then
	echo $subjid
	cp -rf $SUBJECTS_DIR/$subjid $SubjectDIR/$subjid
	cp $T2_dir/$subjid/T1_brain_mask_final.mgz $SubjectDIR/$subjid/mri/brainmask.mgz
	recon-all -subjid $subjid -sd $SubjectDIR -autorecon2 -autorecon3 -no-isrunning
fi