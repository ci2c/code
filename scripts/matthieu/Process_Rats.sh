#! /bin/bash

if [ $# -lt 18 ]
then
	echo ""
	echo "Usage: Process_Rats.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
	echo ""
	echo "	-id	: input directory of the timepoint subject "
	echo "	-od	: output directory of the timepoint subject "
	echo "	-t	: path of the template file TemplateRat.nii "
	echo " 	-fx	: flip to apply along the x direction"
	echo " 	-fy	: flip to apply along the y direction"
	echo " 	-fz	: flip to apply along the z direction"
	echo " 	-rx	: resize to apply along the x direction"
	echo " 	-ry	: resize to apply along the y direction"
	echo " 	-rz	: resize to apply along the z direction"
	echo ""
	echo "Usage: Process_Rats.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
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
		echo "Usage: Process_Rats.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
		echo ""
		echo "	-id	: input directory of the timepoint subject "
		echo "	-od	: output directory of the timepoint subject "
		echo "	-t	: path of the template file TemplateRat.nii "
		echo " 	-fx	: flip to apply along the x direction"
		echo " 	-fy	: flip to apply along the y direction"
		echo " 	-fz	: flip to apply along the z direction"
		echo " 	-rx	: resize to apply along the x direction"
		echo " 	-ry	: resize to apply along the y direction"
		echo " 	-rz	: resize to apply along the z direction"
		echo ""
		echo "Usage: Process_Rats.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
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
	-fx)
		index=$[$index+1]
		eval FX=\${$index}
		echo "flip to apply along the x direction : ${FX}"
		;;
	-fy)
		index=$[$index+1]
		eval FY=\${$index}
		echo "flip to apply along the y direction : ${FY}"
		;;
	-fz)
		index=$[$index+1]
		eval FZ=\${$index}
		echo "flip to apply along the z direction : ${FZ}"
		;;
	-rx)
		index=$[$index+1]
		eval RX=\${$index}
		echo "resize to apply along the x direction : ${RX}"
		;;
	-ry)
		index=$[$index+1]
		eval RY=\${$index}
		echo "resize to apply along the y direction : ${RY}"
		;;
	-rz)
		index=$[$index+1]
		eval RZ=\${$index}
		echo "resize to apply along the z direction : ${RZ}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Process_Rats.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
		echo ""
		echo "	-id	: input directory of the timepoint subject "
		echo "	-od	: output directory of the timepoint subject "
		echo "	-t	: path of the template file TemplateRat.nii "
		echo " 	-fx	: flip to apply along the x direction"
		echo " 	-fy	: flip to apply along the y direction"
		echo " 	-fz	: flip to apply along the z direction"
		echo " 	-rx	: resize to apply along the x direction"
		echo " 	-ry	: resize to apply along the y direction"
		echo " 	-rz	: resize to apply along the z direction"
		echo ""
		echo "Usage: Process_Rats.sh -id <inputsubjdir> -od <outputsubjdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
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
elif [ -z ${FX} ]
then
	 echo "-fx argument mandatory"
	 exit 1
elif [ -z ${FY} ]
then
	 echo "-fy argument mandatory"
	 exit 1
elif [ -z ${FZ} ]
then
	 echo "-fz argument mandatory"
	 exit 1
elif [ -z ${RX} ]
then
	 echo "-rx argument mandatory"
	 exit 1
elif [ -z ${RY} ]
then
	 echo "-ry argument mandatory"
	 exit 1
elif [ -z ${RZ} ]
then
	 echo "-rz argument mandatory"
	 exit 1
fi				

# Creation of the output directories						
mkdir -p ${OUTSUBJ_DIR}/TEP
						
## Conversion of PET Dicom files to nifti file(s)
ls ${INSUBJ_DIR}/PET > ${INSUBJ_DIR}/PET/TmpTep
nbdfilesp=$(cat ${INSUBJ_DIR}/PET/TmpTep | wc -l)
echo $nbdfilesp
while read dfilesp
do
	echo "${INSUBJ_DIR}/PET/${dfilesp}" >> ${OUTSUBJ_DIR}/TEP/PathsDFilesPET
done < ${INSUBJ_DIR}/PET/TmpTep
rm -f ${INSUBJ_DIR}/PET/TmpTep
SPM_DICOM_Convert.sh -f ${OUTSUBJ_DIR}/TEP/PathsDFilesPET -od ${OUTSUBJ_DIR}/TEP
rm -f ${OUTSUBJ_DIR}/TEP/PathsDFilesPET

# Mean of the PET files (nifti)
ls ${OUTSUBJ_DIR}/TEP > ${OUTSUBJ_DIR}/TEP/TmpTep
nbniifiles=$(cat ${OUTSUBJ_DIR}/TEP/TmpTep | wc -l)
echo $nbniifiles
while read niifile
do
	echo "${OUTSUBJ_DIR}/TEP/${niifile}" >> ${OUTSUBJ_DIR}/TEP/PathsNiiFilesPET
done < ${OUTSUBJ_DIR}/TEP/TmpTep
rm -f ${OUTSUBJ_DIR}/TEP/TmpTep
SPM_Mean_Images.sh -f ${OUTSUBJ_DIR}/TEP/PathsNiiFilesPET
rm -f ${OUTSUBJ_DIR}/TEP/PathsNiiFilesPET

## Coregister flipped mean PET image to Mri.nii, resize Mri.nii and PetCoregMri.nii and Non-Linear Transform of rMri.nii/rPetCoregMri.nii to TemplateRat.nii					
if [ -d ${INSUBJ_DIR}/irm -a $(ls -A ${INSUBJ_DIR}/irm | wc -c) -ne 0 ]
then
	## Creation of the output directories						
	mkdir ${OUTSUBJ_DIR}/{IRM,Coregister}								

	## Conversion of Dicom files from MRI to nifti file(s)
	ls ${INSUBJ_DIR}/irm > ${INSUBJ_DIR}/irm/TmpIrm
	nbdfilesm=$(cat ${INSUBJ_DIR}/irm/TmpIrm | wc -l)
	echo $nbdfilesm
	while read dfilesm
	do
		echo "${INSUBJ_DIR}/irm/${dfilesm}" >> ${OUTSUBJ_DIR}/IRM/PathsDFilesMRI
	done < ${INSUBJ_DIR}/irm/TmpIrm
	rm -f ${INSUBJ_DIR}/irm/TmpIrm
	SPM_DICOM_Convert.sh -f ${OUTSUBJ_DIR}/IRM/PathsDFilesMRI -od ${OUTSUBJ_DIR}/IRM
	rm -f ${OUTSUBJ_DIR}/IRM/PathsDFilesMRI

	## Flip the mean PET file according to MRI
	MeanPet=$(ls ${OUTSUBJ_DIR}/TEP/mean*.nii)
	SPM12_FlipPet.sh -i ${MeanPet} -fx ${FX} -fy ${FY} -fz ${FZ}

	## Coregister flipped mean PET file on MRI
	cp ${OUTSUBJ_DIR}/IRM/s*.nii ${OUTSUBJ_DIR}/Coregister
	mv ${OUTSUBJ_DIR}/Coregister/s*.nii ${OUTSUBJ_DIR}/Coregister/Mri.nii
	FIm=$(ls ${OUTSUBJ_DIR}/Coregister/Mri.nii)
	MIm=$(ls ${OUTSUBJ_DIR}/TEP/fmean*.nii)
	ANTS 3 -m MI[${FIm},${MIm},1,32] -o ${OUTSUBJ_DIR}/Coregister/MriToPet -i 0 --rigid-affine true
	WarpImageMultiTransform 3 ${MIm} ${OUTSUBJ_DIR}/Coregister/PetCoregMri.nii ${OUTSUBJ_DIR}/Coregister/MriToPetAffine.txt -R ${FIm}
# 	ANTS 3 -m MI[${FIm},${MIm},1,32] -i 30x20x10 -o ${OUTSUBJ_DIR}/Coregister/MriToPet -t SyN[0.15] -r Gauss[3,0] 
# 	WarpImageMultiTransform 3 ${MIm} ${OUTSUBJ_DIR}/Coregister/PetCoregMri.nii -R ${FIm} ${OUTSUBJ_DIR}/Coregister/MriToPetWarp.nii.gz ${OUTSUBJ_DIR}/Coregister/MriToPetAffine.txt

	## Normalise MRI and PET subject images on MRI template
	if [ -s ${TEMP_PATH}/TemplateRat.nii ]
	then	
		## Create Normalise directory et copy template file into this		
		mkdir ${OUTSUBJ_DIR}/Normalise
		cp ${TEMP_PATH}/TemplateRat.nii ${OUTSUBJ_DIR}/Normalise
		
		## Resize PET and MRI images on template
		SPM12_ResizeToTemplate.sh -o ${OUTSUBJ_DIR} -rx ${RX} -ry ${RY} -rz ${RZ}

		## Move resized images to Normalise directory
		mv ${OUTSUBJ_DIR}/Coregister/rMri.nii ${OUTSUBJ_DIR}/Normalise
		mv ${OUTSUBJ_DIR}/Coregister/rPetCoregMri.nii ${OUTSUBJ_DIR}/Normalise

		## Normalisation of PET and MRI to template TemplateRat.nii
		ANTS 3 -m MI[${OUTSUBJ_DIR}/Normalise/TemplateRat.nii,${OUTSUBJ_DIR}/Normalise/rMri.nii,1,32] -i 30x20x10 -o ${OUTSUBJ_DIR}/Normalise/Norm -t SyN[0.15] -r Gauss[3,0] 
		WarpImageMultiTransform 3 ${OUTSUBJ_DIR}/Normalise/rMri.nii ${OUTSUBJ_DIR}/Normalise/nrMri.nii -R ${OUTSUBJ_DIR}/Normalise/TemplateRat.nii ${OUTSUBJ_DIR}/Normalise/NormWarp.nii.gz ${OUTSUBJ_DIR}/Normalise/NormAffine.txt
		WarpImageMultiTransform 3 ${OUTSUBJ_DIR}/Normalise/rPetCoregMri.nii ${OUTSUBJ_DIR}/Normalise/nrPetCoregMri.nii -R ${OUTSUBJ_DIR}/Normalise/TemplateRat.nii ${OUTSUBJ_DIR}/Normalise/NormWarp.nii.gz ${OUTSUBJ_DIR}/Normalise/NormAffine.txt
	else
		echo "Le fichier TemplateRat.nii est vide" >> ${OUTSUBJ_DIR}/../LogRats
	fi
else
	echo "Le répertoire ${INSUBJ_DIR}/irm n'existe pas ou est vide" >> ${OUTSUBJ_DIR}/../LogRats
fi
