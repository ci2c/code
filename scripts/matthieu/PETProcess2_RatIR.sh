#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: PETProcess2_RatIR.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath>"
	echo ""
	echo "	-id	: input directory of the timepoint subject "
	echo ""
	echo "	-od	: output directory of the timepoint subject "
	echo ""
	echo "	-t	: path of the template file TemplateRat.nii "
	echo ""
	echo "Usage: PETProcess2_RatIR.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath>"
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
		echo "Usage: PETProcess2_RatIR.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath>"
		echo ""
		echo "	-id	: input directory of the timepoint subject "
		echo ""
		echo "	-od	: output directory of the timepoint subject "
		echo ""
		echo "	-t	: path of the template file TemplateRat.nii "
		echo ""
		echo "Usage: PETProcess2_RatIR.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath>"
		echo ""
		exit 1
		;;
	-id)
		index=$[$index+1]
		eval INSUBJ_DIR=\${$index}
		echo "input directory of the timepoint subject : ${INSUBJ_DIR}"
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
		echo "Usage: PETProcess2_RatIR.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath>"
		echo ""
		echo "	-id	: input directory of the timepoint subject "
		echo ""
		echo "	-od	: output directory of the timepoint subject "
		echo ""
		echo "	-t	: path of the template file TemplateRat.nii "
		echo ""
		echo "Usage: PETProcess2_RatIR.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INSUBJ_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
elif [ -z ${OUTSUBJ_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
elif [ -z ${TEMP_PATH} ]
then
	 echo "-t argument mandatory"
	 exit 1
fi				

## Calculus of the files PetCropped.nii, rPetCropped.nii, srPetCropped.nii and csrPetCropped.nii
if [ -e ${OUTSUBJ_DIR}/TEP/BrainRatMaskCustom.nii -a -s ${OUTSUBJ_DIR}/TEP/BrainRatMaskCustom.nii ]
then
	## Creation of the output directory					
	mkdir ${OUTSUBJ_DIR}/Coregister	

	## Extraction of the PetCropped.nii from mask BrainRatMaskCustom.nii
	fslmaths ${OUTSUBJ_DIR}/TEP/mean*.nii -mul ${OUTSUBJ_DIR}/TEP/BrainRatMaskCustom.nii ${OUTSUBJ_DIR}/Coregister/PetCropped.nii
	gunzip ${OUTSUBJ_DIR}/Coregister/PetCropped.nii.gz

	## Flip according z and resize PET subject images on MRI template
	if [ -s ${TEMP_PATH}/TemplateRat.nii ]
	then	
		cp ${TEMP_PATH}/TemplateRat.nii ${OUTSUBJ_DIR}/Coregister
		OrientLAS=$(mri_info ${OUTSUBJ_DIR}/Coregister/PetCropped.nii | grep 'LAS' | wc -l)
		OrientRPS=$(mri_info ${OUTSUBJ_DIR}/Coregister/PetCropped.nii | grep 'RPS' | wc -l)
		if [ ${OrientLAS} = 1 ]
		then
			/usr/local/matlab11/bin/matlab -nodisplay <<EOF
	
			spm_jobman('initcfg'); % SPM8 only

			matlabbatch{1}.spm.util.reorient.srcfiles = {
						      '${OUTSUBJ_DIR}/Coregister/PetCropped.nii,1'
						      };
			matlabbatch{1}.spm.util.reorient.transform.transM = [	1 0 0 0
										0 1 0 0
										0 0 -1 0
										0 0 0 1];
			matlabbatch{1}.spm.util.reorient.prefix = 'r';

			fprintf('Setup reorient subject PET to template OK');
			fprintf('\n');

			rigid_coeff = [0 0 0 0 0 0];
			resize_coeff = [10 10 8];
			affine_coeff = [0 0 0];

			matlabbatch{2}.spm.util.reorient.srcfiles = {'${OUTSUBJ_DIR}/Coregister/rPetCropped.nii,1'
								      };
			matlabbatch{2}.spm.util.reorient.transform.transprm = [rigid_coeff resize_coeff affine_coeff];
			matlabbatch{2}.spm.util.reorient.prefix = 's';

			fprintf('Setup resize subject PET to template OK');
			fprintf('\n');

			spm('defaults', 'FMRI');
			spm_jobman('run',matlabbatch);
EOF
		elif [ ${OrientRPS} = 1 ]
		then
			/usr/local/matlab11/bin/matlab -nodisplay <<EOF
	
			spm_jobman('initcfg'); % SPM8 only

			matlabbatch{1}.spm.util.reorient.srcfiles = {
						      '${OUTSUBJ_DIR}/Coregister/PetCropped.nii,1'
						      };
			matlabbatch{1}.spm.util.reorient.transform.transM = [	-1 0 0 0
										0 -1 0 0
										0 0 -1 0
										0 0 0 1];
			matlabbatch{1}.spm.util.reorient.prefix = 'r';

			fprintf('Setup reorient subject PET to template OK');
			fprintf('\n');

			rigid_coeff = [0 0 0 0 0 0];
			resize_coeff = [10 10 8];
			affine_coeff = [0 0 0];

			matlabbatch{2}.spm.util.reorient.srcfiles = {'${OUTSUBJ_DIR}/Coregister/rPetCropped.nii,1'
								      };
			matlabbatch{2}.spm.util.reorient.transform.transprm = [rigid_coeff resize_coeff affine_coeff];
			matlabbatch{2}.spm.util.reorient.prefix = 's';

			fprintf('Setup resize subject PET to template OK');
			fprintf('\n');

			spm('defaults', 'FMRI');
			spm_jobman('run',matlabbatch);
EOF
		fi
		## Calculation of the affine registration from srPetCropped.nii to MRI template
		ANTS 3 -m MI[${OUTSUBJ_DIR}/Coregister/TemplateRat.nii,${OUTSUBJ_DIR}/Coregister/srPetCropped.nii,1,32] -i 0 -o ${OUTSUBJ_DIR}/Coregister/MriToPet

		## Apply the affine registration to srPetCropped.nii : creation of the csrPetCropped.nii file
		WarpImageMultiTransform 3 ${OUTSUBJ_DIR}/Coregister/srPetCropped.nii ${OUTSUBJ_DIR}/Coregister/csrPetCropped.nii ${OUTSUBJ_DIR}/Coregister/MriToPetAffine.txt -R ${OUTSUBJ_DIR}/Coregister/TemplateRat.nii
	else
		echo "Le fichier TemplateRat.nii est vide" >> ${OUTSUBJ_DIR}/../../LogRats
	fi
else
	echo "Le fichier ${OUTSUBJ_DIR}/TEP/BrainRatMaskCustom.nii n'existe pas ou est vide" >> ${OUTSUBJ_DIR}/../../LogRats
fi