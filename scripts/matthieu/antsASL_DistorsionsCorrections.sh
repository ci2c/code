#!/bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage:  antsASL_DistorsionsCorrections.sh  -id <inputdir> -od <path> -dn <dirname> -subj <patientname> (-b <docorrection> -fs <fsdir>) "
	echo ""
	echo "	-id		: Input directory containing raw data "
	echo "  -od		: Output ASL directory "
	echo "	-dn		: Name of the output directory contained in the output ASL directory "
	echo "  -subj       	: Subject name "
	echo ""	
	echo "Optional : "
	echo "  -b       	: bool to not activate distorsion correction "	
	echo "	-fs		: freesurfer output directory containing previous DC data if -b isn't activated "
	echo ""		
	echo "Usage:  antsASL_DistorsionsCorrections.sh  -id <inputdir> -od <path> -dn <dirname> -subj <patientname> (-b <docorrection> -fs <fsdir>)"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - September 2014"
	echo ""
	exit 1
fi

index=1
DoCOR=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  antsASL_DistorsionsCorrections.sh  -id <inputdir> -od <path> -dn <dirname> -subj <patientname> (-b <docorrection> -fs <fsdir>) "
		echo ""
		echo "	-id		: Input directory containing raw data "
		echo "  -od		: Output ASL directory "
		echo "	-dn		: Name of the output directory contained in the output ASL directory "
		echo "  -subj       	: Subject name "
		echo ""	
		echo "Optional : "
		echo "  -b       	: bool to not activate distorsion correction "	
		echo "	-fs		: freesurfer output directory containing previous DC data if -b isn't activated "
		echo ""		
		echo "Usage:  antsASL_DistorsionsCorrections.sh  -id <inputdir> -od <path> -dn <dirname> -subj <patientname> (-b <docorrection> -fs <fsdir>)"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - September 2014"
		echo ""
		exit 1
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Input directory containing raw data : ${INPUT_DIR}"
		;;	
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "Output ASL directory : ${OUTPUT_DIR}"
		;;
	-dn)
		index=$[$index+1]
		eval DIR_NAME=\${$index}
		echo "Name of the output directory contained in the output ASL directory : ${DIR_NAME}"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ_ID=\${$index}
		echo "Subject name : ${SUBJ_ID}"
		;;
	-b)
		index=$[$index+1]
		eval DoCOR=\${$index}
		echo "Activate distorsion correction : ${DoCOR}"
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "Freesurfer output direcctory : ${FS_DIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  antsASL_DistorsionsCorrections.sh  -id <inputdir> -od <path> -dn <dirname> -subj <patientname> (-b <docorrection> -fs <fsdir>) "
		echo ""
		echo "	-id		: Input directory containing raw data "
		echo "  -od		: Output ASL directory "
		echo "	-dn		: Name of the output directory contained in the output ASL directory "
		echo "  -subj       	: Subject name "
		echo ""	
		echo "Optional : "
		echo "  -b       	: bool to not activate distorsion correction "	
		echo "	-fs		: freesurfer output directory containing previous DC data if -b isn't activated "
		echo ""		
		echo "Usage:  antsASL_DistorsionsCorrections.sh  -id <inputdir> -od <path> -dn <dirname> -subj <patientname> (-b <docorrection> -fs <fsdir>)"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - September 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
fi
if [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi
if [ -z ${DIR_NAME} ]
then
	 echo "-dn argument mandatory"
	 exit 1
fi
if [ -z ${SUBJ_ID} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

# ========================
#      Extract ASL data
# ========================

if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME} ]
then
	mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}
else
# 	mv ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}_back
# 	mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}
	rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/*
fi

AslSplit1=$(ls ${INPUT_DIR}/${SUBJ_ID}/ASL/*PCASLSENSE*x1.nii.gz)
AslSplit2=$(ls ${INPUT_DIR}/${SUBJ_ID}/ASL/*PCASLSENSE*x2.nii.gz)
AslCorrSplit1=$(ls ${INPUT_DIR}/${SUBJ_ID}/ASL/*PCASLCORRECTION*x1.nii.gz)
AslCorrSplit2=$(ls ${INPUT_DIR}/${SUBJ_ID}/ASL/*PCASLCORRECTION*x2.nii.gz)

if [ -n "${AslSplit1}" ] && [ -n "${AslSplit2}" ]
then
	echo "fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl.nii.gz ${AslSplit1} ${AslSplit2}"
	fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl.nii.gz ${AslSplit1} ${AslSplit2}
	
	echo "fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_back.nii.gz ${AslCorrSplit1} ${AslCorrSplit2}"
	fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_back.nii.gz ${AslCorrSplit1} ${AslCorrSplit2}
else
	Asl=$(ls ${INPUT_DIR}/${SUBJ_ID}/ASL/*PCASLSENSE*.nii.gz)
	AslCorr=$(ls ${INPUT_DIR}/${SUBJ_ID}/ASL/*PCASLCORRECTIONSENSE*.nii.gz)
	if [ -n "${Asl}" ]
	then
		echo "cp ${Asl} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl.nii.gz"
		cp ${Asl} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl.nii.gz
		
		echo "cp ${AslCorr} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_back.nii.gz"
		cp ${AslCorr} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_back.nii.gz
	else
		echo "Le fichier ASL n'existe pas"
		exit 1
	fi
fi

# ===========================================
#	Correct distorsions from ASL data
# ===========================================

for_asl=${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl.nii.gz
rev_asl=${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_back.nii.gz
distcor_asl=${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_distcor.nii.gz
DCDIR=${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/DC

if [ $DoCOR -eq 1 ]
then
	if [ -e ${rev_asl} ]
	then
		# Estimate distortion corrections
		if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/DC/aslC0_norm_unwarp.nii.gz ]
		then
			if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/DC ]
			then
				mkdir ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/DC
			else
				rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/DC/*
			fi
			echo "fslroi ${for_asl} ${DCDIR}/aslC0 0 1"
			fslroi ${for_asl} ${DCDIR}/aslC0 0 1
			echo "fslroi ${rev_asl} ${DCDIR}/aslC0_back 0 1"
			fslroi ${rev_asl} ${DCDIR}/aslC0_back 0 1
					
			gunzip -f ${DCDIR}/*gz

			# Shift the reverse DWI by 1 voxel AP
			# Only for Philips images, for *unknown* reason
			# Then LR-flip the image for CMTK
					
			matlab -nodisplay <<EOF
			cd ${DCDIR}
			V = spm_vol('aslC0_back.nii');
			Y = spm_read_vols(V);
			
			Y = circshift(Y, [0 -1 0]);
			V.fname = 'saslC0_back.nii';
			spm_write_vol(V,Y);
			
			Y = flipdim(Y, 1);
			V.fname = 'raslC0_back.nii';
			spm_write_vol(V,Y);
EOF

			# Normalize the signal
			S=`fslstats ${DCDIR}/aslC0.nii -m`
			fslmaths ${DCDIR}/aslC0.nii -div $S -mul 1000 ${DCDIR}/aslC0_norm -odt double
			
			S=`fslstats ${DCDIR}/raslC0_back.nii -m`
			fslmaths ${DCDIR}/raslC0_back.nii -div $S -mul 1000 ${DCDIR}/raslC0_back_norm -odt double
			
			# Launch CMTK
			echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 -x --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
			cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 -x --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/aslC0_norm.nii.gz ${DCDIR}/raslC0_back_norm.nii.gz ${DCDIR}/aslC0_norm_unwarp.nii ${DCDIR}/raslC0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
			
			gzip -f ${DCDIR}/*.nii
		fi
				
		# Apply distortion corrections to the whole ASL
		if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_distcor.nii.gz ]
		then
			echo "fslsplit ${for_asl} ${DCDIR}/voltmp -t"
			fslsplit ${for_asl} ${DCDIR}/voltmp -t
			
			for I in `ls ${DCDIR} | grep voltmp`
				do
				echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
				cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/aslC0_norm.nii.gz ${DCDIR}/dfield.nrrd
				
				echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
				cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
				
				rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
			done
					
			echo "fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
			fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
			
			rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
			gzip -f ${DCDIR}/*.nii	
		fi
		
		ASL=${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_distcor.nii.gz
	else
		ASL=${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl.nii.gz
	fi
else
	echo "cp ${FS_DIR}/${SUBJ_ID}/asl/asl_distcor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}"
	cp ${FS_DIR}/${SUBJ_ID}/asl/asl_distcor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}
	
	ASL=${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/asl_distcor.nii.gz
fi

# ======================================================================
#	Re-order ASL data for antsASLProcessing.sh : 0-tag 1-control
# ======================================================================

echo "fslsplit ${ASL} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/epi_ -t"
fslsplit ${ASL} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/epi_ -t

EpiNii=$(ls ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/epi_00*.nii.gz)
IndexEpi=0

if [ -n "${AslSplit1}" ] && [ -n "${AslSplit2}" ]
then
	for epi in ${EpiNii}
	do
		if [ ${IndexEpi} -le 29 ]
		then
			NIndexEpi=$[${IndexEpi}*2]
			echo "IndexEpi : ${IndexEpi} NIndexEpi : ${NIndexEpi}"
			if [ ${NIndexEpi} -ge 10 ]
			then		
				mv ${epi} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_00${NIndexEpi}.nii.gz
			else
				mv ${epi} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_000${NIndexEpi}.nii.gz
			fi
		else
			NIndexEpi=$[${IndexEpi}*2-59]
			echo "IndexEpi : ${IndexEpi} NIndexEpi : ${NIndexEpi}"
			if [ ${NIndexEpi} -ge 10 ]
			then
				mv ${epi} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_00${NIndexEpi}.nii.gz
			else
				mv ${epi} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_000${NIndexEpi}.nii.gz
			fi
		fi
		IndexEpi=$[${IndexEpi}+1]
	done
else
	for epi in ${EpiNii}
	do
		if [[ ${IndexEpi}%2 -eq 0 ]]
		then
			NIndexEpi=$[${IndexEpi}+1]
			echo "IndexEpi : ${IndexEpi} NIndexEpi : ${NIndexEpi}"
			if [ ${NIndexEpi} -ge 10 ]
			then		
				mv ${epi} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_00${NIndexEpi}.nii.gz
			else
				mv ${epi} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_000${NIndexEpi}.nii.gz
			fi
		else
			NIndexEpi=$[${IndexEpi}-1]
			echo "IndexEpi : ${IndexEpi} NIndexEpi : ${NIndexEpi}"
			if [ ${NIndexEpi} -ge 10 ]
			then
				mv ${epi} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_00${NIndexEpi}.nii.gz
			else
				mv ${epi} ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_000${NIndexEpi}.nii.gz
			fi
		fi
		IndexEpi=$[${IndexEpi}+1]
	done
fi

echo "fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/rasl_distcor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_00*.nii.gz"
fslmerge -t ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/rasl_distcor.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_00*.nii.gz

echo "rm -f ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_00*.nii.gz"
rm -f ${OUTPUT_DIR}/${SUBJ_ID}/${DIR_NAME}/temp_00*.nii.gz