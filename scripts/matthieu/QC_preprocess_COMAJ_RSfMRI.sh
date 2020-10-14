#!/bin/bash

FS_DIR=/NAS/tupac/matthieu/QC_DTI
SUBJ_ID=207030_M2_2012-04-25
INPUT_DIR=/NAS/tupac/protocoles/COMAJ/data/nifti
flagBadFile[1]=0
flagBadFile[2]=0
DoMergeDTI=0

######################################################################
## Step 1. Prepare DTI data in ${FS_DIR}/${SUBJ_ID}/dti directory
######################################################################

if [ ! -d ${FS_DIR}/${SUBJ_ID}/dti ]
then
	mkdir -p ${FS_DIR}/${SUBJ_ID}/dti
else
	rm -f ${FS_DIR}/${SUBJ_ID}/dti/*
fi

iteration=1
DtiNii1=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI_15dir_serie_1/2*WIPDTI15dirserie1SENSE*.nii*)
DtiNii2=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI_15dir_serie_2/2*WIPDTI15dirserie2SENSE*.nii*)

for dti in ${DtiNii1} ${DtiNii2}
do
	if [ ! -s ${dti} ]
	then
		if [[ ${dti} == *2*WIPDTI15dirserie[0-9]SENSE*.nii ]]
		then
			gzip ${dti}
			dti=${dti}.gz
		fi
		
		base=`basename ${dti}`
		base=${base%.nii.gz}
		rep=`dirname ${dti}`
		fbval=${rep}/${base}.bval
		fbvec=${rep}/${base}.bvec
		NbCol=$(cat ${fbval} | wc -w)
		
		if [ ${NbCol} -eq 16 ]
		then				
			# Copy and rename files from input to output /dti directory
			cp -t ${FS_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec} ${dti}
			mv ${FS_DIR}/${SUBJ_ID}/dti/${base}.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz
			mv ${FS_DIR}/${SUBJ_ID}/dti/${base}.bval ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
			mv ${FS_DIR}/${SUBJ_ID}/dti/${base}.bvec ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
		else
			echo "Le fichier DTI serie ${iteration} a moins de 15 DIR"
			flagBadFile[${iteration}]=1
		fi
	else
		echo "Le fichier DTI serie ${iteration} n'existe pas"
		flagBadFile[${iteration}]=1
	fi
	iteration=$[${iteration}+1]
done

#=========================================
#            Initialization...
#=========================================

# TR value
if [ ${TRtmp} -eq 0 ]
then
	TR=$(mri_info ${epi} | grep TR | awk '{print $2}')
	TR=$(echo "$TR/1000" | bc -l)
else
	TR=${TRtmp}
fi

# Number of slices
nslices=$(mri_info ${epi} | grep dimensions | awk '{print $6}')

Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`

echo $TR
echo $nslices
echo $Sigma

DIR=${SUBJECTS_DIR}/${SUBJ}

if [ ! -d ${DIR}/${outdir} ]
then
	mkdir ${DIR}/${outdir}
fi
if [ ! -d ${DIR}/${outdir}/run01 ]
then
	mkdir ${DIR}/${outdir}/run01
fi

cp ${epi} ${DIR}/${outdir}/
mri_convert ${DIR}/mri/T1.mgz ${DIR}/${outdir}/T1_las.nii --out_orientation LAS

filename=$(basename "$epi")
extension="${filename##*.}"
if [ "${extension}" == "gz" ]
then
	gunzip -f ${DIR}/${outdir}/${filename}
	filename="${filename%.*}"
fi
epi=${DIR}/${outdir}/${filename}

# Remove N first frames
mkdir ${DIR}/${outdir}/run01/tmp
echo "fslsplit ${epi} ${DIR}/${outdir}/run01/tmp/epi_ -t"
fslsplit ${epi} ${DIR}/${outdir}/run01/tmp/epi_ -t
for ((ind = 0; ind < ${remframe}; ind += 1))
do
	filename=`ls -1 ${DIR}/${outdir}/run01/tmp/ | sed -ne "1p"`
	rm -f ${DIR}/${outdir}/run01/tmp/${filename}
done

echo "fslmerge -t ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/tmp/epi_*"
fslmerge -t ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/tmp/epi_*

echo "gunzip -f ${DIR}/${outdir}/run01/*.gz"
gunzip -f ${DIR}/${outdir}/run01/*.gz
echo "rm -rf ${DIR}/${outdir}/run01/tmp"
rm -rf ${DIR}/${outdir}/run01/tmp


# ========================================================================================================================================
#                                                        RUNNING ...
# ========================================================================================================================================

if [ $DoTemplate -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/template.nii ]
then

	# Make EPI template file
	echo "mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/template.nii --frame 0"
	mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/template.nii --frame 0
	echo "mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/template.nii --mid-frame"
	mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/template.nii --mid-frame
	#cp ${DIR}/${outdir}/template.nii ${DIR}/${outdir}/run01/template.nii

fi


# ========================================================================================================================================
#            COMMON PREPROCESSING (motion correction - slice-timing correction - coregistration T1-EPI - spatial normalization)
# ========================================================================================================================================

if [ $DoMC -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/repi.nii ]
then

	mc-afni2 --i ${DIR}/${outdir}/run01/epi.nii --t ${DIR}/${outdir}/run01/template.nii --o ${DIR}/${outdir}/run01/repi.nii --mcdat ${DIR}/${outdir}/run01/repi.mcdat

	# Making external regressor from mc params
	mcdat2mcextreg --i ${DIR}/${outdir}/run01/repi.mcdat --o ${DIR}/${outdir}/run01/mcprextreg

fi