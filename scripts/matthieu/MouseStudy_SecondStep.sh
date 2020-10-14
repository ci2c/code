#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: MouseStudy_SecondStep.sh -od <outputsubjdir> -t <templatepath>"
	echo ""
	echo "	-od	: output directory of the timepoint subject "
	echo ""
	echo "	-t	: path of the template file TemplateMouse.nii "
	echo ""
	echo "Usage: MouseStudy_SecondStep.sh -od <outputsubjdir> -t <templatepath>"
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
		echo "Usage: MouseStudy_SecondStep.sh -od <outputsubjdir> -t <templatepath>"
		echo ""
		echo "	-od	: output directory of the timepoint subject "
		echo ""
		echo "	-t	: path of the template file TemplateMouse.nii "
		echo ""
		echo "Usage: MouseStudy_SecondStep.sh -od <outputsubjdir> -t <templatepath>"
		echo ""
		exit 1
		;;
	-od)
		index=$[$index+1]
		eval OUTSUBJ_DIR=\${$index}
		echo "output directory of the timepoint subject : ${OUTSUBJ_DIR}"
		;;
	-t)
		index=$[$index+1]
		eval TEMP_PATH=\${$index}
		echo "path of the template file TemplateRat.nii : ${TEMP_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: MouseStudy_SecondStep.sh -od <outputsubjdir> -t <templatepath>"
		echo ""
		echo "	-od	: output directory of the timepoint subject "
		echo ""
		echo "	-t	: path of the template file TemplateMouse.nii "
		echo ""
		echo "Usage: MouseStudy_SecondStep.sh -od <outputsubjdir> -t <templatepath>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${OUTSUBJ_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
elif [ -z ${TEMP_PATH} ]
then
	 echo "-t argument mandatory"
	 exit 1
fi				

## Calculation of the CT/PET masked volume and normalize on MRI template
if [ -e ${OUTSUBJ_DIR}/Crop/BrainMouseMaskCustom.nii -a -s ${OUTSUBJ_DIR}/Crop/BrainMouseMaskCustom.nii ]
then
	fslmaths ${OUTSUBJ_DIR}/CT/s*ct*.nii -mul ${OUTSUBJ_DIR}/Crop/BrainMouseMaskCustom.nii ${OUTSUBJ_DIR}/Crop/CtCropped.nii
	gunzip ${OUTSUBJ_DIR}/Crop/CtCropped.nii.gz
	mv ${OUTSUBJ_DIR}/TEP/mean*.nii ${OUTSUBJ_DIR}/TEP/MeanPet.nii

	## Reslice of the BrainMouseMaskCustom.nii to PET resolution and calculation of the PET masked volume
	/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	spm_jobman('initcfg'); % SPM8 only

	matlabbatch{1}.spm.spatial.coreg.write.ref = {'${OUTSUBJ_DIR}/TEP/MeanPet.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.write.source = {'${OUTSUBJ_DIR}/Crop/BrainMouseMaskCustom.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'Pet';

	spm('defaults', 'FMRI');
	spm_jobman('run',matlabbatch);

EOF
	fslmaths ${OUTSUBJ_DIR}/TEP/MeanPet.nii -mul ${OUTSUBJ_DIR}/Crop/PetBrainMouseMaskCustom.nii ${OUTSUBJ_DIR}/Crop/PetCropped.nii
	gunzip ${OUTSUBJ_DIR}/Crop/PetCropped.nii.gz
	
	## Normalise CT and PET subject images on MRI template
	if [ -s ${TEMP_PATH}/TemplateMouse.nii ]
	then	
		mkdir ${OUTSUBJ_DIR}/Normalise
		cp ${TEMP_PATH}/TemplateMouse.nii ${OUTSUBJ_DIR}/Normalise

		LASMask=$(mri_info ${OUTSUBJ_DIR}/TEP/MeanPet.nii | grep 'LAS' | wc -l)
		RPSMask=$(mri_info ${OUTSUBJ_DIR}/TEP/MeanPet.nii | grep 'RPS' | wc -l)
		if [ ${LASMask} -eq 1 ]
		then 
			/usr/local/matlab11/bin/matlab -nodisplay <<EOF
	
			spm_jobman('initcfg'); % SPM8 only

			matlabbatch{1}.spm.util.reorient.srcfiles = {
								      '${OUTSUBJ_DIR}/Crop/CtCropped.nii,1'
								      '${OUTSUBJ_DIR}/Crop/PetCropped.nii,1'
								      };
			matlabbatch{1}.spm.util.reorient.transform.transM = [	1 0 0 0
										0 1 0 0
										0 0 -1 0
										0 0 0 1];
			matlabbatch{1}.spm.util.reorient.prefix = 'r_';

			spm('defaults', 'FMRI');
			spm_jobman('run',matlabbatch);
EOF
		elif [ ${RPSMask} -eq 1 ]
		then
			/usr/local/matlab11/bin/matlab -nodisplay <<EOF
	
			spm_jobman('initcfg'); % SPM8 only

			matlabbatch{1}.spm.util.reorient.srcfiles = {
								      '${OUTSUBJ_DIR}/Crop/CtCropped.nii,1'
								      '${OUTSUBJ_DIR}/Crop/PetCropped.nii,1'
								      };
			matlabbatch{1}.spm.util.reorient.transform.transM = [-1 0 0 0
										0 -1 0 0
										0 0 -1 0
										0 0 0 1];
			matlabbatch{1}.spm.util.reorient.prefix = 'r_';

			spm('defaults', 'FMRI');
			spm_jobman('run',matlabbatch);
EOF
		fi
		mv ${OUTSUBJ_DIR}/Crop/r_CtCropped.nii ${OUTSUBJ_DIR}/Normalise
		mv ${OUTSUBJ_DIR}/Crop/r_PetCropped.nii ${OUTSUBJ_DIR}/Normalise

		ANTS 3 -m MI[${OUTSUBJ_DIR}/Normalise/TemplateMouse.nii,${OUTSUBJ_DIR}/Normalise/r_CtCropped.nii,1,32] -i 20x10x5 -o ${OUTSUBJ_DIR}/Normalise/MriToCt -t SyN[0.25] -r Gauss[3,0] 

		WarpImageMultiTransform 3 ${OUTSUBJ_DIR}/Normalise/r_CtCropped.nii ${OUTSUBJ_DIR}/Normalise/nr_CtCropped.nii -R ${OUTSUBJ_DIR}/Normalise/TemplateMouse.nii ${OUTSUBJ_DIR}/Normalise/MriToCtWarp.nii.gz ${OUTSUBJ_DIR}/Normalise/MriToCtAffine.txt
		WarpImageMultiTransform 3 ${OUTSUBJ_DIR}/Normalise/r_PetCropped.nii ${OUTSUBJ_DIR}/Normalise/nr_PetCropped.nii -R ${OUTSUBJ_DIR}/Normalise/TemplateMouse.nii ${OUTSUBJ_DIR}/Normalise/MriToCtWarp.nii.gz ${OUTSUBJ_DIR}/Normalise/MriToCtAffine.txt
	else
		echo "Le fichier TemplateMouse.nii est vide" >> ~/Logdir/LogMouses2
	fi
else
	echo "Le fichier ${OUTSUBJ_DIR}/Crop/BrainMouseMaskCustom.nii n'existe pas ou est vide" >> ~/Logdir/LogMouses2
fi