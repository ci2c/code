#!/bin/bash
	
if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: DTI_AlexcisProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -subjid		: Subject ID"
	echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -od		: Path to output directory (processing results)"
	echo ""
	echo "Usage: DTI_AlexcisProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
	echo ""
	exit 1
fi

index=1

# Set default parameters
lmax=6
Nfiber=250000
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_AlexcisProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: DTI_AlexcisProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
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
		echo "Usage: DTI_AlexcisProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: DTI_AlexcisProcess.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir> -od <OutputDir>"
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

# ################################
# ## Step 1. Prepare DTI data in ${OUTPUT_DIR}/${SUBJ_ID}/dti directory
# ################################
# 
# # Prepare DTI data : Use of temporary directory, calculus of bval/bvec and nii files associated, conversion REC/PAR to nii and rename dti files 
# 
# # Search of dti rec/par files
# DtiMin=$(ls ${INPUT_DIR}/${SUBJ_ID}/*dti*.par)
# DtiMaj=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI*.PAR)
# if [ -n "${DtiMin}" ] || [ -n "${DtiMaj}" ]
# then
# 	# Creation of a temporary source directory
# 	if [ ! -d /tmp/${SUBJ_ID}/DTI ]
# 	then
# 		mkdir -p /tmp/${SUBJ_ID}/DTI
# 	else
# 		rm -rf /tmp/${SUBJ_ID}/DTI/*
# 	fi
# 	
# 	# Move of dti rec/par in temporary source directory
# 	if [ -n "${DtiMin}" ]
# 	then
# 		cp -t /tmp/${SUBJ_ID}/DTI ${INPUT_DIR}/${SUBJ_ID}/*dti*.rec ${INPUT_DIR}/${SUBJ_ID}/*dti*.par
# 	elif [ -n "${DtiMaj}" ]
# 	then
# 		cp -t /tmp/${SUBJ_ID}/DTI ${INPUT_DIR}/${SUBJ_ID}/*DTI*.REC ${INPUT_DIR}/${SUBJ_ID}/*DTI*.PAR
# 	fi
# 	
# 	# Search of dti_32dir MAJ or min rec/par files
# 	DtiDirMin=$(ls /tmp/${SUBJ_ID}/DTI/*dti32*.par)
# 	DtiDirMaj=$(ls /tmp/${SUBJ_ID}/DTI/*DTI32*.PAR)
# 	
# 	iteration=1
# 	
# 	# Calculus of the bval, bvec and nii files from dti_32dir rec/par files
# 	if [ -n "${DtiDirMin}" ] || [ -n "${DtiDirMaj}" ]
# 	then
# 		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti ]
# 		then
# 			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti
# 		else
# 			rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/*
# 		fi
# 	
# 		if [ -n "${DtiDirMin}" ]
# 		then
# 			
# 			for dti in $(ls /tmp/${SUBJ_ID}/DTI/*dti32*.par)
# 			do
# 				base=`basename ${dti}`
# 				base=${base%.par}
# 				cd /tmp/${SUBJ_ID}/DTI
# 				par2bval.sh ${dti}
# 				fbval=/tmp/${SUBJ_ID}/DTI/${base}.bval
# 				fbvec=/tmp/${SUBJ_ID}/DTI/${base}.bvec
# 				fnii=/tmp/${SUBJ_ID}/DTI/${base}.nii.gz
# 				NbCol=$(cat ${fbval} | wc -w)
# 				if [ ${NbCol} -ne 33 ]
# 				then
# 					rm -f ${fbval} ${fbvec} ${fnii}
# 				else
# 					# Move and rename files from input to output /dti directory
# 					mv -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec} ${fnii}
# 					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz
# 					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
# 					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
# 					iteration=$[${iteration}+1]
# 				fi
# 			done
# 		elif [ -n "${DtiDirMaj}" ]
# 		then
# 			for dti in $(ls /tmp/${SUBJ_ID}/DTI/*DTI32*.PAR)
# 			do
# 				base=`basename ${dti}`
# 				base=${base%.PAR}
# 				cd /tmp/${SUBJ_ID}/DTI
# 				par2bval.sh ${dti}
# 				fbval=/tmp/${SUBJ_ID}/DTI/${base}.bval
# 				fbvec=/tmp/${SUBJ_ID}/DTI/${base}.bvec
# 				fnii=/tmp/${SUBJ_ID}/DTI/${base}.nii.gz
# 				NbCol=$(cat ${fbval} | wc -w)
# 				if [ ${NbCol} -ne 33 ]
# 				then
# 					rm -f ${fbval} ${fbvec} ${fnii}
# 				else
# 					# Move and rename files from input to output /dti directory
# 					mv -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec} ${fnii}
# 					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz
# 					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
# 					mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
# 					iteration=$[${iteration}+1]
# 				fi
# 			done
# 		fi
# 	fi
# 	
# 	# Convert and rename dticorrection files
# 	dcm2nii -f Y -o ${OUTPUT_DIR}/${SUBJ_ID}/dti /tmp/${SUBJ_ID}/DTI/*dticorrect*.par
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/*dticorrect*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
# 	
# 	rm -rf /tmp/${SUBJ_ID}
# 	
# else
# 	iteration=1
# 	if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti ]
# 	then
# 		mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti
# 	else
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/*
# 	fi
# 	DtiNii=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI32*.nii*)
# 	for dti in ${DtiNii}
# 	do
# 		if [[ ${dti} == *DTI32*.nii ]]
# 		then
# 			gzip ${dti}
# 			dti=${dti}.gz
# 		fi
# 		base=`basename ${dti}`
# 		base=${base%.nii.gz}
# 		fbval=${INPUT_DIR}/${SUBJ_ID}/${base}.bval
# 		fbvec=${INPUT_DIR}/${SUBJ_ID}/${base}.bvec
# 		NbCol=$(cat ${fbval} | wc -w)
# 		if [ ${NbCol} -eq 33 ]
# 		then				
# 			# Copy and rename files from input to output /dti directory
# 			cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec} ${dti}
# 			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz
# 			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
# 			mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
# 			iteration=$[${iteration}+1]
# 		fi
# 	done
# 	
# 	# Zip, copy and rename dticorrection file
# 	DtiCorr=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTICORRECT*.nii*)
# 	if [ -n "${DtiCorr}" ]
# 	then
# 		if [ $(ls -1 ${INPUT_DIR}/${SUBJ_ID}/*DTICORRECT*.nii | wc -l) -gt 0 ]
# 		then
# 			gzip ${INPUT_DIR}/${SUBJ_ID}/*DTICORRECT*.nii
# 			DtiCorr=${DtiCorr}.gz
# 		fi 
# 		cp -t ${OUTPUT_DIR}/${SUBJ_ID}/dti ${DtiCorr}
# 		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/*DTICORRECT*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
# 	fi	
# fi	
# 
# cd ${OUTPUT_DIR}/${SUBJ_ID}/dti
# DimZ1=$(mri_info dti1.nii.gz | grep dimensions | awk '{print $6}')
# echo "Nb coupes en Z dti1 : ${DimZ1}"
# DimZb=$(mri_info dti_back.nii.gz | grep dimensions | awk '{print $6}')
# echo "Nb coupes en Z dti_back : ${DimZb}"
# 
# # Manage input dti files : merge dti frames
# if [ $(ls -1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz | wc -l) -gt 1 ]
# then 
# 	cd ${OUTPUT_DIR}/${SUBJ_ID}/dti
# 	DimZ2=$(mri_info dti2.nii.gz | grep dimensions | awk '{print $6}')
#  	echo "Nb coupes en Z dti2 : ${DimZ2}"
# 	if [ ${DimZ1} -eq ${DimZ2} ]
# 	then
# 		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz
# 	elif [ ${DimZ1} -gt ${DimZ2} ] && [ ${DimZ1} -eq ${DimZb} ]
# 	then
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.bvec
# 		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
# 	elif [ ${DimZ2} -gt ${DimZ1} ] && [ ${DimZ2} -eq ${DimZb} ]
# 	then
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec
# 		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
# 		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec
# 		mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec
# 	elif [ ${DimZ2} -eq ${DimZb} ]
# 	then
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz -rl ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz
# 		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz
# 	elif [ ${DimZ1} -eq ${DimZb} ]
# 	then
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti2.nii.gz -rl ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz
# 		fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz
# 	fi
# else
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
# fi
# 
# ################################
# ## Step 2. Eddy current correction on dti.nii.gz
# ################################
# 
# # Eddy current correction
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ]
# then
# 	echo "eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor 0"
# 	eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor 0
# fi
# 
# ################################
# ## Step 3. Mean B0 frames, merge bval/bvec files and build final eddy corrected dti for multiple files
# ################################
# 
# if [ $(ls -1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz | wc -l) -gt 1 ]
# then
# 	# Create temp directory in output /dti dir
# 	mkdir ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp
# 	
# 	# Write in a file all B0 frames from multiple dti and delete B0 frame from bval/bvec files
# 	fslsplit ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor -t
# 	
# 	index_B0=0
# 	for dti in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz)
# 	do
# 		base=`basename ${dti}`
# 		base=${base%.nii.gz}
# 		
# 		# Search B0 split frames, unzip and stock path in a temporary file
# 		if [ ${index_B0} -le 9 ]
# 		then
# 			gunzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor000${index_B0}.nii.gz
# 			echo "${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor000${index_B0}.nii" >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
# 		elif [ ${index_B0} -le 99 ]
# 		then
# 			gunzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor00${index_B0}.nii.gz
# 			echo "${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor00${index_B0}.nii" >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
# 		fi
# 		index_B0=$[${index_B0}+16]
# 		
# 		# Delete B0 frames from bval/bvec files associated to dti[i>1]
# 		if [ "${base}" != "dti1" ]
# 		then
# 			while read col1 col2    # col2 se voit attribuer tout le reste des colonnes
# 			do
# 				echo $col2 > ${OUTPUT_DIR}/${SUBJ_ID}/dti/n${base}.bval
# 			done < ${OUTPUT_DIR}/${SUBJ_ID}/dti/${base}.bval
# 		fi
# 	done
# 	
# 	# Mean of all B0 frames
# 	SPM_Mean_Images.sh -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/PathNiiFiles
# 	
# 	# Rename B0 mean file in output /dti dir
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean*.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii
# 	
# 	# Zip B0 mean file
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii
# 	
# 	# Merge of multiple dti files : Mean B0 at first frame and concatenation of all dti frames
# 	fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/mean_b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor*.nii.gz
# 	
# 	# Delete temp dir in ouput /dti dir
# 	rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/dti/tmp
# 	
# 	# Merge bval/bvec files
# 	paste ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/ndti[2-9].bval > ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/ndti[2-9].bval
# 	paste ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[2-9].bvec > ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
# else
# 	# Case of one single dti file : rename bval/bvec and dti files
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti1.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
# 	
# fi
# 
# ################################
# ## Step 4. Rotate bvec and build final bvec file
# ################################
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec_old ]
# then
# # 	echo "rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec"
# 	rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
# fi
# if [ $(ls -1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti[1-9].nii.gz | wc -l) -gt 1 ]
# then
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec
# 	awk '{$17="";print}' ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec > ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec
# fi

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

# ################################
# ## Step 6. Compute DTI fit on fully corrected DTI
# ################################
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz ]
# then
# 	echo "bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain -F -f 0.25 -g 0 -m"
# 	bet ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain -F -f 0.25 -g 0 -m
# 	
# 	echo "dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval"
# 	dtifit --data=${final_dti} --out=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval
# fi
# 
# ################################
# ## Step 7. Get freesurfer WM mask and Alexcis ROIs
# ################################
# 
# init_fs5.3
# export FREESURFER_HOME=/home/matthieu/programs/freesurfer5.3/
# . ${FREESURFER_HOME}/SetUpFreeSurfer.sh
# 
# if [ ! -e ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz ]
# then
# 	echo "Freesurfer was not fully processed"
# 	echo "Script terminated"
# 	exit 1
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii.gz ]
# then
# 	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz"
# 	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/lh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz
# 	
# 	echo "mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz"
# 	mris_fill -r 0.5 -c ${FS_DIR}/${SUBJ_ID}/surf/rh.white ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz
# 	
# 	echo "mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz"
# 	mri_or ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz
# 	
# 	echo "mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz"
# 	mri_morphology ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz dilate 1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz
# 	
# 	echo "mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii --out_orientation RAS"
# 	mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii --out_orientation RAS
# 	
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/lh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rh.white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/white_dil.mgz
# 	
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.nii.gz ]
# then
# 	mri_extract_label -dilate 1 -exit_none_found ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz 11129 12129 ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.mgz > ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi1.txt
# 	if [ $(grep 'No voxels with specified label were found' ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi1.txt | wc -l) -gt 0 ]
# 	then
# 		echo "Le mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.mgz est vide"
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	else
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	fi
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.nii.gz ]
# then
# 	mri_extract_label -dilate 1 -exit_none_found ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz 11134 12134 ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.mgz > ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi2.txt
# 	if [ $(grep 'No voxels with specified label were found' ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi2.txt | wc -l) -gt 0 ]
# 	then
# 		echo "Le mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.mgz est vide"
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	else
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	fi
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.nii.gz ]
# then
# 	mri_extract_label -dilate 1 -exit_none_found ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz 11128 12128 ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.mgz > ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi3.txt
# 	if [ $(grep 'No voxels with specified label were found' ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi3.txt | wc -l) -gt 0 ]
# 	then
# 		echo "Le mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.mgz est vide"
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	else
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	fi
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.nii.gz ]
# then
# 	mri_extract_label -dilate 1 -exit_none_found ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz 11145 12145 ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.mgz > ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi4.txt
# 	if [ $(grep 'No voxels with specified label were found' ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi4.txt | wc -l) -gt 0 ]
# 	then
# 		echo "Le mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.mgz est vide"
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	else
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	fi
# fi
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi1.txt ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi2.txt ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi3.txt ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi4.txt ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.nii*
# 
# ################################
# ## Step 8. Register T1, WM mask and Alexcis ROIs to DTI
# ################################
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz ]
# then
# 	echo "mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_ras.nii --out_orientation RAS"
# 	mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_ras.nii --out_orientation RAS
# 	
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_ras.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_ras.nii
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii.gz
# 	
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask_dti.nii.gz
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask_dti.nii.gz
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask_dti.nii.gz
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask_dti.nii.gz
# 		
# 	fslroi ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0 0 1
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask_dti.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask_dti.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask_dti.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask_dti.nii.gz
# 	
# 	# SPM coregister estimation
# 	# Then reslice T1, brain mask and ROIs to DTI space
# 	matlab -nodisplay <<EOF
# 	spm('defaults', 'FMRI');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 	
# 	matlabbatch{end+1}.spm.spatial.coreg.estwrite.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.source = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_ras.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.other = {
# 							      '${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii,1'
# 							      '${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask_dti.nii,1'
# 							      '${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask_dti.nii,1'
# 							      '${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask_dti.nii,1'
# 							      '${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask_dti.nii,1'
# 							      };
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.interp = 1;
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.mask = 0;
# 	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
# 	
# 	spm_jobman('run',matlabbatch);
# EOF
# 	
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii
# 	
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	
# 	# Remove NaNs
# 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz"
# 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz
# 	
# 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz"
# 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz
# 	
# 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii.gz"
# 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii.gz
# 	
# 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii.gz"
# 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii.gz
# 	
# 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii.gz"
# 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii.gz
# 	
# 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii.gz"
# 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii.gz
# 	
# fi
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_ras.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/wm_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask_dti.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_mask_dti.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_ras.nii*
# 
# ################################
# ## Step 9. Performs tractography
# ################################
# 
# 	# Step 9.1 Convert images and bvec
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif ]
# then
# 	# dti
# 	gunzip -f ${final_dti}
# 	echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif"
# 	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif
# 	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii
# 	
# 	# wm mask
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii.gz
# 	echo "mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif"
# 	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif
# 	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii
# 	echo "threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif"
# 	threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif
# 	mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif
# 	
# 	# precentral_mask
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii.gz
# 	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.mif
# 	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii
# 	threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif
# 	mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.mif
# 	
# 	# G_temp_sup_lateral_mask
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii.gz
# 	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.mif
# 	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii
# 	threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif
# 	mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.mif
# 	
# 	# G_postcentral_mask
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii.gz
# 	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.mif
# 	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii
# 	threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif
# 	mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.mif
# 	
# 	# S_calcarine_mask
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii.gz
# 	mrconvert ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.mif
# 	gzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii
# 	threshold ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.mif -abs 0.1 ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif
# 	mv -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.mif
# 	
# 	# bvec
# 	cp ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
# 	cat ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti.bval >> ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
# 	matlab -nodisplay <<EOF
# 	bvecs_to_mrtrix('${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt', '${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix');
# EOF
# 	
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/temp.txt
# 		
# fi
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rprecentral_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_temp_sup_lateral_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rG_postcentral_mask_dti.mif
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/rS_calcarine_mask_dti.mif
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix
# 
# 	# Step 9.2 All steps until the response estimate
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt ]
# then
# 	# Calculate tensors
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif
# 	echo "dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif"
# 	dwi2tensor ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif
# 	
# 	# Calculate FA
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif
# 	echo "tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif"
# 	tensor2FA ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif
# 	
# 	# Calculate EV
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif
# 	echo "tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif"
# 	tensor2vector ${OUTPUT_DIR}/${SUBJ_ID}/dti/dt.mif - | mrmult - ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/ev.mif
# 	
# 	# Calculate highly anisotropic voxels
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif
# 	echo "erode ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif"
# 	erode ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif - | erode - - | mrmult ${OUTPUT_DIR}/${SUBJ_ID}/dti/fa.mif - - | threshold - -abs 0.7 ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif
# 	
# 	# Estimate response function
# 	echo "estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt"
# 	estimate_response ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/sf.mif -lmax ${lmax} ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt
# fi
# 
# 	# Step 9.3 Spherical deconvolution
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif ]
# then
# 	# Local computations to reduce bandwidth usage
# 	# csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif
# 	rm -f /tmp/${SUBJ_ID}_CSD${lmax}.mif
# 	csdeconv ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor.mif -grad ${OUTPUT_DIR}/${SUBJ_ID}/dti/bvecs_mrtrix ${OUTPUT_DIR}/${SUBJ_ID}/dti/response.txt -lmax ${lmax} -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/rwm_mask_dti.mif /tmp/${SUBJ_ID}_CSD${lmax}.mif
# 	cp -f /tmp/${SUBJ_ID}_CSD${lmax}.mif ${OUTPUT_DIR}/${SUBJ_ID}/dti/CSD${lmax}.mif
# 	rm -f /tmp/${SUBJ_ID}_CSD${lmax}.mif
# fi
# 
# 	# Step 9.4 Fiber tracking & Cut the fiber file into small matlab files
# for NameRoi in precentral G_temp_sup_lateral G_postcentral S_calcarine
# do  
# 	qbatch -N DTI_Trac_${SUBJ_ID}_${NameRoi} -q M32_q -oe ~/Logdir DTI_Tracto_ROI.sh ${NameRoi} ${SUBJ_ID} ${OUTPUT_DIR} ${lmax} ${Nfiber}
# 	sleep 1
# done
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_${lmax}_${Nfiber}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/precentral_${lmax}_${Nfiber}.vtk
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_${lmax}_${Nfiber}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_temp_sup_lateral_${lmax}_${Nfiber}.vtk
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_${lmax}_${Nfiber}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/G_postcentral_${lmax}_${Nfiber}.vtk
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_${lmax}_${Nfiber}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/S_calcarine_${lmax}_${Nfiber}.vtk
# 
# # ################################
# # ## Step 10. Save cortical surfaces in volume space
# # ################################	
# # 
# # if [ ! -e ${FS_DIR}/${SUBJ_ID}/surf/lh.white.ras ]
# # then
# # 
# # mri_convert ${FS_DIR}/${SUBJ_ID}/mri/T1.mgz ${FS_DIR}/${SUBJ_ID}/mri/t1_ras.nii --out_orientation RAS
# # 
# # matlab -nodisplay <<EOF
# # surf = surf_to_ras_nii('${FS_DIR}/${SUBJ_ID}/surf/lh.white', '${FS_DIR}/${SUBJ_ID}/mri/t1_ras.nii');
# # SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}/surf/lh.white.ras', surf, 'b');
# # 
# # surf = surf_to_ras_nii('${FS_DIR}/${SUBJ_ID}/surf/rh.white', '${FS_DIR}/${SUBJ_ID}/mri/t1_ras.nii');
# # SurfStatWriteSurf('${FS_DIR}/${SUBJ_ID}/surf/rh.white.ras', surf, 'b');
# # 
# # % surf = SurfStatReadSurf({'${FS_DIR}/${SUBJ_ID}/surf/lh.white.ras','${FS_DIR}/${SUBJ_ID}/surf/rh.white.ras'});
# # % save_surface_vtk(surf,'${FS_DIR}/${SUBJ_ID}/surf/white_ras.vtk');
# # EOF
# # 
# # # rm -f ${FS_DIR}/${SUBJ_ID}/mri/t1_ras.nii ${FS_DIR}/${SUBJ_ID}/surf/white_ras.vtk
# # 
# # fi
# 
# ###############################
# ## Step 11. Extract, Coregister and Binarize Corps Callosum mask
# ###############################	
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.nii.gz ]
# then
# 	mri_extract_label -exit_none_found ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz 251 252 253 254 255 ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.mgz > ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi5.txt
# 	if [ $(grep 'No voxels with specified label were found' ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi5.txt | wc -l) -gt 0 ]
# 	then
# 		echo "Le mask ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.mgz est vide"
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	else
# 		mri_convert ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.nii --out_orientation RAS
# 		rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.mgz
# 		gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	fi
# fi
# 
# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_maskb_dti.nii* ]
# then
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask_dti.nii.gz
# 	cp -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_native_ras.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_CC_ras.nii.gz
# 	
# 	fslroi ${final_dti} ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0 0 1
# 	
# 	gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_CC_ras.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask_dti.nii.gz
# 	
# 	# SPM coregister estimation
# 	# Then reslice CC to DTI space
# 	matlab -nodisplay <<EOF
# 	spm('defaults', 'FMRI');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 	
# 	matlabbatch{end+1}.spm.spatial.coreg.estimate.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.estimate.source = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_CC_ras.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.estimate.other = {
# 							      '${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask_dti.nii,1'
# 							      };
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
# 	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
# 	
# 	matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii,1'};
# 	matlabbatch{end}.spm.spatial.coreg.write.source = {
# 							    '${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask_dti.nii,1'
# 							    };
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 1;
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
# 	
# 	spm_jobman('run',matlabbatch);
# EOF
# 	
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/b0.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/t1_dti_CC_ras.nii
# 	
# 	gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii
# 	
# 	# Remove NaNs
# 	echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_dti.nii.gz"
# 	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_mask_dti.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_mask_dti.nii.gz
# 	mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_mask_dti.nii.gz --min 0.1 --o ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_maskb_dti.nii.gz
# fi
# 
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Roi5.txt ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask.nii*
# # rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_mask_dti.nii*  ${OUTPUT_DIR}/${SUBJ_ID}/dti/CorpsCalleux_maskb_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_mask_dti.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_maskb_dti.nii*

###############################
## Step 12. Get fibers probability map for each ROI linked to Corpus Callosum
###############################	

# gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_maskb_dti.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_FA.nii.gz
# for NameRoi in precentral G_temp_sup_lateral G_postcentral S_calcarine
# do  
# # 	qbatch -N DTI_Prob_${SUBJ_ID}_${NameRoi} -q M32_q -oe ~/Logdir 
# 	DTI_Prob_Fibers_ROI.sh ${NameRoi} ${SUBJ_ID} ${OUTPUT_DIR} ${lmax} ${Nfiber}
# # 	sleep 1
# # 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/TDI_${NameRoi}_CC.nii* ${OUTPUT_DIR}/${SUBJ_ID}/dti/${NameRoi}_CC.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti/${NameRoi}_CC.vtk ${OUTPUT_DIR}/${SUBJ_ID}/dti/Prob_${NameRoi}_CC.nii*
# done

# JOBS=`qstat | grep DTI_Prob | wc -l`
# while [ ${JOBS} -ge 1 ]
# do
# echo "DTI_Prob pas encore fini"
# sleep 30
# JOBS=`qstat | grep DTI_Prob | wc -l`
# done

# gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii

rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Prob_*_CC.nii.gz

###############################
## Step 13. Thresh fibers probability maps, normalize maps to T1 template and calculate overlap between subjects for each ROI
###############################

# gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Prob_*_CC.nii.gz
# for ProbMap in $(ls ${OUTPUT_DIR}/${SUBJ_ID}/dti/Prob_*_CC.nii)
# do  
# 	base=`basename ${ProbMap}`
# 	base=${base%.nii}
# 	
# 	matlab -nodisplay <<EOF
# 	V = spm_vol('${ProbMap}');
# 	nii = spm_read_vols(V);
# 
# 	if strcmp('${base}','Prob_G_temp_sup_lateral_CC')
# 		nii_thresh = (nii >= 0.0061321);
# 	elseif strcmp('${base}','Prob_S_calcarine_CC')
# 		nii_thresh = (nii >= 0.0119);
# 	elseif strcmp('${base}','Prob_precentral_CC')
# 		nii_thresh = (nii >= 0.0055139);
# 	elseif strcmp('${base}','Prob_G_postcentral_CC')
# 		nii_thresh = (nii >= 0.0082847);
# 	end
# 	
# 	W = V;
# 	W.fname = '${OUTPUT_DIR}/${SUBJ_ID}/dti/Thresh_${base}.nii';
# 	spm_write_vol(W,nii_thresh);
# 	
# EOF
# done

rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Thresh_*.nii

# gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/Thresh_*_CC.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii.gz
# 
# matlab -nodisplay <<EOF
# 
# spm('defaults', 'FMRI');
# spm_jobman('initcfg');
# matlabbatch={};
# 
# matlabbatch{end+1}.spm.spatial.normalise.estwrite.subj.vol = {'${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii,1'};
# matlabbatch{end}.spm.spatial.normalise.estwrite.subj.resample = {
#                                                                '${OUTPUT_DIR}/${SUBJ_ID}/dti/rt1_dti_ras.nii,1'
#                                                                '${OUTPUT_DIR}/${SUBJ_ID}/dti/Thresh_Prob_precentral_CC.nii,1'
#                                                                '${OUTPUT_DIR}/${SUBJ_ID}/dti/Thresh_Prob_S_calcarine_CC.nii,1'
#                                                                '${OUTPUT_DIR}/${SUBJ_ID}/dti/Thresh_Prob_G_temp_sup_lateral_CC.nii,1'
#                                                                '${OUTPUT_DIR}/${SUBJ_ID}/dti/Thresh_Prob_G_postcentral_CC.nii,1'
#                                                                };
# matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
# matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
# matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
# matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
# matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
# matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
# matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
# matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
#                                                              78 76 85];
# matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
# matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.interp = 1;
# 
# spm_jobman('run',matlabbatch);
# EOF
# 
# gzip ${OUTPUT_DIR}/${SUBJ_ID}/dti/*.nii

rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_*_CC.nii.gz

# # Remove NaNs
# echo "fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/wrt1_dti_ras.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/wrt1_dti_ras.nii.gz"
# fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/wrt1_dti_ras.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/wrt1_dti_ras.nii.gz
# fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_precentral_CC.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_precentral_CC.nii.gz
# fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_S_calcarine_CC.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_S_calcarine_CC.nii.gz
# fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_G_temp_sup_lateral_CC.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_G_temp_sup_lateral_CC.nii.gz
# fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_G_postcentral_CC.nii.gz -nan ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_G_postcentral_CC.nii.gz
# 
# # Binarize normalized maps
# echo "mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_precentral_CC.nii.gz --min 0.1 --o ${OUTPUT_DIR}/${SUBJ_ID}/dti/bwThresh_Prob_precentral_CC.nii.gz"
# mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_precentral_CC.nii.gz --min 0.1 --o ${OUTPUT_DIR}/${SUBJ_ID}/dti/bwThresh_Prob_precentral_CC.nii.gz
# mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_S_calcarine_CC.nii.gz --min 0.1 --o ${OUTPUT_DIR}/${SUBJ_ID}/dti/bwThresh_Prob_S_calcarine_CC.nii.gz
# mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_G_temp_sup_lateral_CC.nii.gz --min 0.1 --o ${OUTPUT_DIR}/${SUBJ_ID}/dti/bwThresh_Prob_G_temp_sup_lateral_CC.nii.gz
# mri_binarize --i ${OUTPUT_DIR}/${SUBJ_ID}/dti/wThresh_Prob_G_postcentral_CC.nii.gz --min 0.1 --o ${OUTPUT_DIR}/${SUBJ_ID}/dti/bwThresh_Prob_G_postcentral_CC.nii.gz

# gunzip -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/bwThresh_*_CC.nii.gz

rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/bwThresh_*_CC.nii