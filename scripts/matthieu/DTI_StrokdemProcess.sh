#!/bin/bash
	
if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: DTI_StrokdemProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -subjid		: Subject ID"
	echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -od		: Path to output directory (processing results)"
	echo ""
	echo "Usage: DTI_StrokdemProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
	echo ""
	exit 1
fi

index=1

# Set default parameters
lmax=4
Nfiber=1500000
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_StrokdemProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: DTI_StrokdemProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		exit 1
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "Path to FS output directory (equivalent to SUBJECTS_DIR) : ${FS_DIR}"
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Input directory containing the rec/par files : ${INPUT_DIR}"
		;;
	-subjid)
		index=$[$index+1]
		eval SUBJ_ID=\${$index}
		echo "Subject ID : ${SUBJ_ID}"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "Path to output directory (processing results) : ${OUTPUT_DIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: DTI_StrokdemProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: DTI_StrokdemProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${FS_DIR} ]
then
	 echo "-fs argument mandatory"
	 exit 1
elif [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
elif [ -z ${SUBJ_ID} ]
then
	 echo "-subjid argument mandatory"
	 exit 1
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi				

################################
## Step 1. Prepare DTI and T1 data in ${OUTPUT_DIR}/${SUBJ_ID}/dti directory
################################

# Prepare DTI and T1 data : Use of temporary directory, calculus of bval/bvec and nii files associated, conversion REC/PAR to nii and rename dti/anat files 
DtiNii=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI15*.nii*)
if [ -z "${DtiNii}" ]
then
	# Creation of a temporary source directory
	mkdir ${INPUT_DIR}/${SUBJ_ID}/DTI_T1
	
	# Search of dti rec/par files
	DtiMin=$(ls ${INPUT_DIR}/${SUBJ_ID}/*dti*.par)
	DtiMaj=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI*.PAR)

	
	# Move of dti and 3dt1 rec/par in temporary source directory
	if [ -n "${DtiMin}" ]
	then
		mv -t ${INPUT_DIR}/${SUBJ_ID}/DTI_T1 ${INPUT_DIR}/${SUBJ_ID}/*dti*.rec ${INPUT_DIR}/${SUBJ_ID}/*dti*.par
	elif [ -n "${DtiMaj}" ]
	then
		mv -t ${INPUT_DIR}/${SUBJ_ID}/DTI_T1 ${INPUT_DIR}/${SUBJ_ID}/*DTI*.REC ${INPUT_DIR}/${SUBJ_ID}/*DTI*.PAR
	fi
	
	# Search of dti_15dir MAJ or min rec/par files
	DtiDirMin=$(ls ${INPUT_DIR}/${SUBJ_ID}/DTI_T1/*dti_15*.par)
	DtiDirMaj=$(ls ${INPUT_DIR}/${SUBJ_ID}/DTI_T1/*DTI_15*.PAR)
	
	iteration=1
	
	# Calculus of the bval, bvec and nii files from dti_15dir rec/par files
	if [ -n "${DtiDirMin}" ] || [ -n "${DtiDirMaj}" ]
	then
		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti ]
		then
			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti
		fi
	
		# Conversion from rec/par to nii files
		dcm2nii -f Y -o ${OUTPUT_DIR}/${SUBJ_ID}/dti ${INPUT_DIR}/${SUBJ_ID}/DTI_T1/* 
		
		if [ -n "${DtiDirMin}" ]
		then
			
			for dti in $(ls ${INPUT_DIR}/${SUBJ_ID}/DTI_T1/*dti_15*.par)
			do
				base=`basename ${dti}`
				base=${base%.par}
				cd ${INPUT_DIR}/${SUBJ_ID}/DTI_T1
				par2bval.sh ${dti}
				fbval=${INPUT_DIR}/${SUBJ_ID}/DTI_T1/${base}.bval
				fbvec=${INPUT_DIR}/${SUBJ_ID}/DTI_T1/${base}.bvec
				fnii=${INPUT_DIR}/${SUBJ_ID}/DTI_T1/${base}.nii*
				NbCol=$(cat ${fbval} | wc -w)
				if [ ${NbCol} -ne 16 ]
				then
					rm -f ${fbval} ${fbvec} ${fnii}
					rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/*${base}*.nii.gz
				else
					# Move and rename files from input to output /dti directory
					rm -f ${fnii}
					mv -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec}
					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/*${base}*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz
					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
					iteration=$[${iteration}+1]
				fi
			done
		elif [ -n "${DtiDirMaj}" ]
		then
			for dti in $(ls ${INPUT_DIR}/${SUBJ_ID}/DTI_T1/*DTI_15*.PAR)
			do
				base=`basename ${dti}`
				base=${base%.PAR}
				cd ${INPUT_DIR}/${SUBJ_ID}/DTI_T1
				par2bval.sh ${dti}
				fbval=${INPUT_DIR}/${SUBJ_ID}/DTI_T1/${base}.bval
				fbvec=${INPUT_DIR}/${SUBJ_ID}/DTI_T1/${base}.bvec
				fnii=${INPUT_DIR}/${SUBJ_ID}/DTI_T1/${base}.nii*
				NbCol=$(cat ${fbval} | wc -w)
				if [ ${NbCol} -ne 16 ]
				then
					rm -f ${fbval} ${fbvec} ${fnii}
					rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/*${base}*.nii.gz
				else
					# Move and rename files from input to output /dti directory
					rm -f ${fnii}
					mv -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec}
					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/*${base}*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz
					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
					iteration=$[${iteration}+1]
				fi
			done
		fi
	fi
	
	# Rename dticorrection files
	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/*dticorrection*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
	
	# Move back rec/par files from temp input directory to input dir, and delete temp directory
	mv -t ${INPUT_DIR}/${SUBJ_ID} ${INPUT_DIR}/${SUBJ_ID}/DTI_T1/*
	rm -rf ${INPUT_DIR}/${SUBJ_ID}/DTI_T1
else
	iteration=1
	if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti ]
	then
		mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti
	fi
	for dti in ${DtiNii}
	do
		if [[ ${dti} == *DTI15*.nii ]]
		then
			gzip ${dti}
			dti=${dti}.gz
		fi
		base=`basename ${dti}`
		base=${base%.nii.gz}
		fbval=${INPUT_DIR}/${SUBJ_ID}/${base}.bval
		fbvec=${INPUT_DIR}/${SUBJ_ID}/${base}.bvec
		NbCol=$(cat ${fbval} | wc -w)
		if [ ${NbCol} -eq 16 ]
		then				
			# Copy and rename files from input to output /dti directory
			cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec} ${dti}
			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz
			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
			iteration=$[${iteration}+1]
		fi
	done
	
	# Zip, copy and rename dticorrection file
	DtiCorr=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTIcorrection*.nii*)
	if [ -n "${DtiCorr}" ]
	then
		if [ $(ls -1 ${INPUT_DIR}/${SUBJ_ID}/*DTIcorrection*.nii | wc -l) -gt 0 ]
		then
			gzip ${INPUT_DIR}/${SUBJ_ID}/*DTIcorrection*.nii
			DtiCorr=${DtiCorr}.gz
		fi 
		cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${DtiCorr}
		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/*DTIcorrection*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
	fi	
fi	

cd ${OUTPUT_DIR}/${SUBJ_ID}/dti
DimZ1=$(mri_info dti1.nii.gz | grep dimensions | awk '{print $6}')
echo "Nb coupes en Z dti1 : ${DimZ1}"
DimZb=$(mri_info dti_back.nii.gz | grep dimensions | awk '{print $6}')
echo "Nb coupes en Z dti_back : ${DimZb}"

# Manage input dti files : merge dti frames
if [ $(ls -1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz | wc -l) -gt 1 ]
then 
	cd ${OUTPUT_DIR}/${SUBJ_ID}/dti
	DimZ2=$(mri_info dti2.nii.gz | grep dimensions | awk '{print $6}')
 	echo "Nb coupes en Z dti2 : ${DimZ2}"
	if [ ${DimZ1} -eq ${DimZ2} ]
	then
		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz
	elif [ ${DimZ1} -gt ${DimZ2} ] && [ ${DimZ1} -eq ${DimZb} ]
	then
		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.bvec
		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
	elif [ ${DimZ2} -gt ${DimZ1} ] && [ ${DimZ2} -eq ${DimZb} ]
	then
		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec
		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec
		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec
	elif [ ${DimZ2} -eq ${DimZb} ]
	then
		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz -rl ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz
		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz
	elif [ ${DimZ1} -eq ${DimZb} ]
	then
		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz -rl ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz
		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz
	fi
else
	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
fi

################################
## Step 2. Eddy current correction on dti.nii.gz
################################

# Eddy current correction
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ]
then
	echo "eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor 0"
	eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor 0
fi

################################
## Step 3. Mean B0 frames, merge bval/bvec files and build final eddy corrected dti for multiple files
################################

if [ $(ls -1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz | wc -l) -gt 1 ]
then
	# Create temp directory in output /dti dir
	mkdir ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp
	
	# Write in a file all B0 frames from multiple dti and delete B0 frame from bval/bvec files
	fslsplit ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor -t
	
	index_B0=0
	for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz)
	do
		base=`basename ${dti}`
		base=${base%.nii.gz}
		
		# Search B0 split frames, unzip and stock path in a temporary file
		if [ ${index_B0} -le 9 ]
		then
			gunzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor000${index_B0}.nii.gz
			echo "${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor000${index_B0}.nii" >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
		elif [ ${index_B0} -le 99 ]
		then
			gunzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor00${index_B0}.nii.gz
			echo "${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor00${index_B0}.nii" >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
		fi
		index_B0=$[${index_B0}+16]
		
		# Delete B0 frames from bval/bvec files associated to dti[i>1]
		if [ "${base}" != "dti1" ]
		then
			while read col1 col2    # col2 se voit attribuer tout le reste des colonnes
			do
				echo $col2 > ${OUTPUT_DIR}/${SUBJ_ID}/dti/n${base}.bval
			done < ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval
		fi
	done
	
	# Mean of all B0 frames
	SPM_Mean_Images.sh -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
	
	# Rename B0 mean file in output /dti dir
	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean*.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii
	
	# Zip B0 mean file
	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii
	
	# Merge of multiple dti files : Mean B0 at first frame and concatenation of all dti frames
	fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor*.nii.gz
	
	# Delete temp dir in ouput /dti dir
	rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp
	
	# Merge bval/bvec files
	paste ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/ndti[2-9].bval > ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/ndti[2-9].bval
	paste ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[2-9].bvec > ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
else
	# Case of one single dti file : rename bval/bvec and dti files
	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz
	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
	
fi

################################
## Step 4. Rotate bvec and build final bvec file
################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec_old ]
then
# 	echo "rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec"
	rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
fi
if [ $(ls -1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz | wc -l) -gt 1 ]
then
	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec
	awk '{$17="";print}' ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec > ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec
fi

################################
## Step 5. Correct distortions
################################

for_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz
rev_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
bval=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
bvec=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
final_dti=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii.gz
DCDIR=${OUTPUT_DIR}/${SUBJ_ID}/DC

if [ -e ${rev_dti} ]
then
	# Estimate distortion corrections
	if [ ! -e ${DCDIR}/b0_norm_unwarp.nii.gz ]
	then
		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/DC ]
		then
			mkdir ${OUTPUT_DIR}/${SUBJ_ID}/DC
		else
			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/DC/*
		fi
		echo "fslroi ${for_dti} ${DCDIR}/b0 0 1"
		fslroi ${for_dti} ${DCDIR}/b0 0 1
		echo "fslroi ${rev_dti} ${DCDIR}/b0_back 0 1"
		fslroi ${rev_dti} ${DCDIR}/b0_back 0 1
		
		gunzip -f ${DCDIR}/*gz
		
		# Shift the reverse DWI by 1 voxel
		# Only for Philips images, for *unknown* reason
		# Then AP-flip the image for CMTK
		matlab -nodisplay <<EOF
		cd ${DCDIR}
		EPIshift_and_flip('b0_back.nii', 'rb0_back.nii', 'sb0_back.nii');
EOF

		# Normalize the signal
		S=`fslstats ${DCDIR}/b0.nii -m`
		fslmaths ${DCDIR}/b0.nii -div $S -mul 1000 ${DCDIR}/b0_norm -odt double
		
		S=`fslstats ${DCDIR}/rb0_back.nii -m`
		fslmaths ${DCDIR}/rb0_back.nii -div $S -mul 1000 ${DCDIR}/rb0_back_norm -odt double
		
		# Launch CMTK
		echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
		cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
		
		gzip -f ${DCDIR}/*.nii
	fi
	
	# Apply distortion corrections to the whole DWI
	if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii.gz ]
	then
		echo "fslsplit ${for_dti} ${DCDIR}/voltmp -t"
		fslsplit ${for_dti} ${DCDIR}/voltmp -t
		
		for I in `ls ${DCDIR} | grep voltmp`
		do
			echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
			cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd
			
			echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
			cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
			
			rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
		done
		
		echo "fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
		
		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
		gzip -f ${DCDIR}/*.nii	
	fi
else
	# Rename dti_eddycorf.nii.gz to dti_finalcor.nii.gz
	echo "mv ${for_dti} ${final_dti}"
	mv ${for_dti} ${final_dti}
fi

################################
## Step 6. Compute DTI fit on fully corrected DTI
################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz ]
then
	echo "bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain -F -f 0.25 -g 0 -m"
	bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain -F -f 0.25 -g 0 -m
	
	echo "dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval"
	dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
fi

################################
## Step 7. Get freesurfer WM mask
################################

# init_fs5.1
export FREESURFER_HOME=/home/global/freesurfer5.1/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

if [ ! -e ${FS_DIR}/${SUBJ_ID}_M6/mri/aparc.a2009s+aseg.mgz ]
then
	echo "Freesurfer was not fully processed"
	echo "Script terminated"
	exit 1
fi

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii.gz ]
then
	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}_M6/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz"
	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}_M6/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz
	
	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}_M6/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz"
	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}_M6/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz
	
	echo "mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz"
	mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz
	
	echo "mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz"
	mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz
	
	echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii --out_orientation RAS"
	mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii --out_orientation RAS
	
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz
	
	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
fi

################################
## Step 8. Register T1 to DTI
################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz ]
then
	echo "mri_convert ${FS_DIR}/${SUBJ_ID}_M6/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_ras.nii --out_orientation RAS"
	mri_convert ${FS_DIR}/${SUBJ_ID}_M6/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_ras.nii --out_orientation RAS
	
	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_ras.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_ras.nii
	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii.gz
	
	fslroi ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0 0 1
	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii.gz
	
	# SPM coregister estimation
	# Then reslice T1 and brain mask to DTI space
	matlab -nodisplay <<EOF
	spm('defaults', 'FMRI');
	spm_jobman('initcfg');
	matlabbatch={};
	
	matlabbatch{end+1}.spm.spatial.coreg.estwrite.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estwrite.source = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_ras.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estwrite.other = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii,1'};
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.interp = 4;
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
	
	spm_jobman('run',matlabbatch);
EOF
	
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii
	
	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
	
	# Remove NaNs
	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_ras.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_ras.nii.gz"
	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz
	
	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii.gz"
	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz
fi

################################
## Step 9. Performs tractography
################################

	# Step 9.1 Convert images and bvec
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif ]
then
	# dti
	gunzip -f ${final_dti}
	echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif"
	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif
	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii
	
	# wm mask
	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz
	echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif"
	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif
	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii
	echo "threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif"
	threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif
	mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif
	
	# bvec
	cp ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
	cat ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
	matlab -nodisplay <<EOF
	bvecs_to_mrtrix('${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt', '${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix');
EOF
	
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
		
fi

	# Step 9.2 All steps until the response estimate
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt ]
then
	# Calculate tensors
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif
	echo "dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif"
	dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif
	
	# Calculate FA
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif
	echo "tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif"
	tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif
	
	# Calculate EV
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif
	echo "tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif"
	tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif
	
	# Calculate highly anisotropic voxels
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif
	echo "erode ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif"
	erode ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif
	
	# Estimate response function
	echo "estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt"
	estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt
fi

	# Step 9.3 Spherical deconvolution
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif ]
then
	# Local computations to reduce bandwidth usage
	# csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif
	rm -f /tmp/${SUBJ_ID}_CSD${lmax}.mif
	csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif /tmp/${SUBJ_ID}_CSD${lmax}.mif
	cp -f /tmp/${SUBJ_ID}_CSD${lmax}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif
	rm -f /tmp/${SUBJ_ID}_CSD${lmax}.mif
fi

	# Step 9.4 Fiber tracking
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/whole_brain_${lmax}_${Nfiber}.tck ]
then
	# Stream locally to avoid RAM filling
	# streamtrack SD_PROB ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif -seed ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/whole_brain_${lmax}_${Nfiber}.tck -num ${Nfiber}
	rm -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}.tck
	streamtrack SD_PROB ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif -seed ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}.tck -num ${Nfiber}
	
	cp -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/whole_brain_${lmax}_${Nfiber}.tck
	rm -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}.tck
fi

	# Step 9.5 Cut the fiber file into small matlab files
if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/whole_brain_${lmax}_${Nfiber}_part000001.tck ]
then
	
matlab -nodisplay <<EOF
split_fibers('${OUTPUT_DIR}/${SUBJ_ID}/dti/whole_brain_${lmax}_${Nfiber}.tck', '${OUTPUT_DIR}/${SUBJ_ID}/dti', 'whole_brain_${lmax}_${Nfiber}');
EOF
	
fi

################################
## Step 10. Save cortical surfaces in volume space
################################	

if [ ! -e ${FS_DIR}/${SUBJ_ID}_M6/surf/lh.white.ras ]
then

mri_convert ${FS_DIR}/${SUBJ_ID}_M6/mri/T1.mgz ${FS_DIR}/${SUBJ_ID}_M6/mri/t1_ras.nii --out_orientation RAS

matlab -nodisplay <<EOF
surf = surf_to_ras_nii('${FS_DIR}/${SUBJ_ID}_M6/surf/lh.white', '${FS_DIR}/${SUBJ_ID}_M6/mri/t1_ras.nii');
SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}_M6/surf/lh.white.ras', surf, 'b');

surf = surf_to_ras_nii('${FS_DIR}/${SUBJ_ID}_M6/surf/rh.white', '${FS_DIR}/${SUBJ_ID}_M6/mri/t1_ras.nii');
SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}_M6/surf/rh.white.ras', surf, 'b');
EOF

rm -f ${FS_DIR}/${SUBJ_ID}_M6/mri/t1_ras.nii

fi