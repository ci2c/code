#! /bin/bash
par_dir=/NAS/tupac/protocoles/Strokdem/par

for subj in 430217YI_M6 611230FJ_72H 611230FJ_M6 661117OP_72H 371202DJP_M6 620204BD_M6 430109MD_M36 490531LS_72H 510718CP_M36 550721AL_M60
do


space=`expr index "$subj" "_"`
subjid=${subj:0:( ${space}-1 )}

#### T2 preparation ####


T2_Vdir=$(ls -d ${par_dir}/${subjid}/${subj}/*T2*VISTA*/ 2> /dev/null | wc -l )
T2_Edir=$(ls -d ${par_dir}/${subjid}/${subj}/*T2*ETOILE*/ 2> /dev/null | wc -l )


	
	if [ $T2_Edir -eq 1 ]; then

		T2_E=$(ls ${par_dir}/${subjid}/${subj}/T2_ETOILE/*nii* 2> /dev/null)
		T2_ck=$(ls ${par_dir}/${subjid}/${subj}/T2_ETOILE/*nii* | wc -l)
		if [ $T2_ck -eq 0 ]; then
			dcm2nii -o ${par_dir}/${subjid}/${subj}/T2_ETOILE ${par_dir}/${subjid}/${subj}/T2_ETOILE/*
			rm -rf ${par_dir}/${subjid}/${subj}/T2_ETOILE/o*
		fi

		T2_file=$(ls ${par_dir}/${subjid}/${subj}/T2_ETOILE/*nii* 2> /dev/null)
		echo "$subj : T2 STAR scan for correction : $T2_file"
	elif [ $T2_Vdir -eq 1 ]; then
		T2_V=$(ls ${par_dir}/${subjid}/${subj}/T2_VISTA_HR_SENSE/*nii* 2> /dev/null)
		T2_ck=$(ls ${par_dir}/${subjid}/${subj}/T2_VISTA_HR_SENSE/*nii* | wc -l)
		if [ $T2_ck -eq 0 ]; then
			dcm2nii -o ${par_dir}/${subjid}/${subj}/T2_VISTA_HR_SENSE ${par_dir}/${subjid}/${subj}/T2_VISTA_HR_SENSE/*
			rm -rf ${par_dir}/${subjid}/${subj}/T2_VISTA_HR_SENSE/o*
		fi
		T2_file=$(ls ${par_dir}/${subjid}/${subj}/T2_VISTA_HR_SENSE/*nii* 2> /dev/null)
		echo "$subj : T2 VISTA scan for correction : $T2_file"

	else 
		echo "No T2 for $subjid"

	fi



	qbatch -q fs_q -oe /home/clement/log/FS -N fs_$subjid FS_T2mask_correction.sh -subj $subj -T2_im $T2_file -T1_im /NAS/tupac/protocoles/Strokdem/par/${subjid}/${subj}/3DT1_ISO_1mm_HR/*gz -FS_DIR /NAS/tupac/protocoles/Strokdem/FS5.1_T2mask
	sleep 1
	
done
