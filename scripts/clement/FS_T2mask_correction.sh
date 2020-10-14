#! /bin/bash
FS_DIR=/NAS/tupac/protocoles/Strokdem/FS5.1
par_dir=/NAS/tupac/protocoles/Strokdem/par
FS_DIR=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask
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

	-T1_im)
		index=$[$index+1]
		eval T1_im=\${$index}
		echo "3DT1 vol = $T1_im"
		;;

	-T2_im)
		index=$[$index+1]
		eval T2_file=\${$index}
		echo "T2 vol = $T2_file"
		;;
	-FS_DIR)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "FreeSurfer output directory = $FS_DIR"
		;;
	esac
	index=$[$index+1]
done


echo "=========================================================="
echo "---------------------RUN ${subjid}------------------------"
echo "=========================================================="


#=================================================================================================================================================================================
#         														  Run 1rst part : FS recon-all from 3DT1
#=================================================================================================================================================================================



if [ ! -e ${FS_DIR}/${subjid}_1step ] && [ -e $T1_im ]; then


	echo "RUN Recon-all first step : "
	recon-all -all -sd $FS_DIR -subjid ${subjid}_1step -i $T1_im -nuintensitycor-3T
fi

#=================================================================================================================================================================================
#           												  Run 2nd part : Brain mask correction from T2 
#=================================================================================================================================================================================

FSTEP_DIR=${FS_DIR}/${subjid}_1step/

TEMPDIR=`mktemp -d --tmpdir=${FSTEP_DIR}`

SUBJECTS_DIR=${FS_DIR}


#### Brain mask correction ####

if [ -e ${T2_file} ] & [ -e ${FS_DIR}/${subjid}_1step/mri/T1.mgz ] &  [ -e ${FS_DIR}/${subjid}_1step/surf/rh.white ]; then 
		echo $subjid
		#1ere etape : Mettre T2 ref T1 en mm^3
		if [ ! -e  ${TEMPDIR}/T2_refT1.nii.gz	]; then
			#echo $subjid
			echo "===First step: Registration==="
			echo "bbregister --s $subjid --mov $T2_file --init-header --t2 --reg ${TEMPDIR}/T2reg.dat --o ${TEMPDIR}/T2_refT1.nii.gz"
			bbregister --s ${subjid}_1step --mov $T2_file --init-header --t2 --reg ${TEMPDIR}/T2reg.dat --o ${TEMPDIR}/T2_refT1.nii.gz	#--s : nom du sujet, --mov : volume à charger, --init-header : initialise la registration en fonction de la géométire du header
			# --t2 : contraste t2, --reg : output registration file --o : output
		fi
	
		#2eme etape : Extraire Cerveau de T2 recalee = enleve crane etc
		if [ ! -e ${TEMPDIR}/T2_refT1_brain.nii.gz ]; then
			echo "===Second step: T2 Extraction==="
			echo "bet ${TEMPDIR}/T2_refT1.nii.gz ${TEMPDIR}/T2_refT1_brain.nii.gz -m"
			bet ${TEMPDIR}/T2_refT1.nii.gz ${TEMPDIR}/T2_refT1_brain.nii.gz -m #-m = sort un mask binaire _mask
		fi

		#3eme etape : determine ce qui depasse sur le T1
		if [ ! -e ${TEMPDIR}/T1_brain_mask_bext_d.nii.gz ]; then
			echo "===Third step: T1 Extraction==="
			mris_calc -o ${TEMPDIR}/T1_brain_mask.nii.gz ${FS_DIR}/${subjid}_1step/mri/brainmask.mgz masked ${TEMPDIR}/T2_refT1_brain_mask.nii.gz #Prends le masque que FS a fait pour l'appliquer au mask T2
			mri_binarize --i ${TEMPDIR}/T1_brain_mask.nii.gz --o ${TEMPDIR}/T1_brain_mask_b.nii.gz --min 1 #Binarize le resultat
			mri_morphology ${TEMPDIR}/T1_brain_mask_b.nii.gz erode 1 ${TEMPDIR}/T1_brain_mask_e.nii.gz
			mris_calc -o ${TEMPDIR}/T1_brain_mask_bext.nii.gz ${TEMPDIR}/T1_brain_mask_b.nii.gz sub ${TEMPDIR}/T1_brain_mask_e.nii.gz
			mri_morphology ${TEMPDIR}/T1_brain_mask_bext.nii.gz dilate 1 ${TEMPDIR}/T1_brain_mask_bext_d.nii.gz
		fi	

		#4eme etape : Segmenter T2
		if [ ! -e ${TEMPDIR}/T2_refT1_brain_seg_3.nii.gz ]; then
			echo "===Fourth step: T2 Segmentation==="
			fast -t 2 -n 4 -H 0.1 -I 4 -l 20.0 -g --nopve -o ${TEMPDIR}/T2_refT1_brain ${TEMPDIR}/T2_refT1_brain #Segmente le T2 pour séparer le crâne, wm, gm, et csf
		fi

		#5eme : Supp
		if [ ! -e ${TEMPDIR}/T1_brain_mask_final.mgz ]; then
			echo "===Fifth step: Brain Mask==="
			mris_calc -o ${TEMPDIR}/out.mgz ${TEMPDIR}/T1_brain_mask_bext_d.nii.gz masked ${TEMPDIR}/T2_refT1_brain_seg_3.nii.gz
			mris_calc -o ${TEMPDIR}/out.mgz ${TEMPDIR}/T1_brain_mask.nii.gz masked ${TEMPDIR}/out.mgz 
			mris_calc -o ${TEMPDIR}/out.mgz ${TEMPDIR}/T1_brain_mask.nii.gz sub ${TEMPDIR}/out.mgz
			mv ${TEMPDIR}/out.mgz ${TEMPDIR}/T1_brain_mask_final.mgz  #Sortie de mris_calc=out donc changement de nom
			mri_convert ${TEMPDIR}/out.mgz ${TEMPDIR}/T1_brain_mask_final.nii.gz	
		fi
else
	echo 'Pbs ' $subjid 
fi


#=================================================================================================================================================================================
#           												Run 3rd part : FS using T2 correction 
#=================================================================================================================================================================================


if [ -e ${FS_DIR}/${subjid}_1step ] & [ -e ${TEMPDIR}/T1_brain_mask_final.mgz ] & [ ! -e ${FS_DIR}/${subjid} ]; then
	echo $subjid
	mv ${FS_DIR}/${subjid}_1step ${FS_DIR}/${subjid}
	mv ${TEMPDIR}/T1_brain_mask_final.mgz ${FS_DIR}/${subjid}/mri/brainmask.mgz
	recon-all -subjid $subjid -sd $FS_DIR -autorecon2 -autorecon3 -no-isrunning
fi

rm -rf ${TEMPDIR}