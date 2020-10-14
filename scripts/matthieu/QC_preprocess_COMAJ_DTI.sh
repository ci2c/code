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

# # Zip, copy and rename dticorrection file
# DtiCorr=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTICORRECT*.nii*)
# if [ -n "${DtiCorr}" ]
# then
# 	if [ $(ls -1 ${INPUT_DIR}/${SUBJ_ID}/*DTICORRECT*.nii | wc -l) -gt 0 ]
# 	then
# 		gzip ${INPUT_DIR}/${SUBJ_ID}/*DTICORRECT*.nii
# 		DtiCorr=${DtiCorr}.gz
# 	fi 
# 	cp -t ${FS_DIR}/${SUBJ_ID}/dti ${DtiCorr}
# 	mv ${FS_DIR}/${SUBJ_ID}/dti/*DTICORRECT*.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
# fi	

if [ ${flagBadFile[1]} -eq 1 ] && [ ${flagBadFile[2]} -eq 1 ]
then
	echo "Les deux fichiers DTI_15dir ne sont pas exploitables"
	exit 1
elif [ ${DoMergeDTI} -eq 0 ] && [ ${flagBadFile[1]} -eq 0 ] && [ ${flagBadFile[2]} -eq 0 ]
then
	for iteration in 1 2
	do
		#############################################################
		## Step 2. Eddy current correction on dti${iteration}.nii.gz
		#############################################################

		if [ ! -e ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor.ecclog ]
		then
			echo "eddy_correct ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor 0"
			eddy_correct ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor 0
		fi

		#############################
		## Step 3. Rotate bvec files
		#############################

		if [ ! -e ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec_old ]
		then
			echo "rotate_bvecs ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor.ecclog ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec"
			rotate_bvecs ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor.ecclog ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec
		fi

		############################
		## Step 4. Compute DTI fit
		############################

		if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
		then
			echo "bet ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor_brain -F -f 0.25 -g 0 -m"
			bet ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor_brain -F -f 0.25 -g 0 -m
			
			echo "dtifit --data=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor.nii.gz --out=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor --mask=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor_brain_mask.nii.gz --bvecs=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec --bvals=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval"
			dtifit --data=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor.nii.gz --out=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor --mask=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}_eddycor_brain_mask.nii.gz --bvecs=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bvec --bvals=${FS_DIR}/${SUBJ_ID}/dti/dti${iteration}.bval
		fi
	done
	
elif [ ${flagBadFile[1]} -eq 0 -a ${flagBadFile[2]} -eq 1 ]
then
	#############################################################
	## Step 2. Eddy current correction on dti1.nii.gz
	#############################################################
	if [ ! -e ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor.ecclog ]
	then
		echo "eddy_correct ${FS_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor 0"
		eddy_correct ${FS_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor 0
	fi

	#############################
	## Step 3. Rotate bvec files
	#############################

	if [ ! -e ${FS_DIR}/${SUBJ_ID}/dti/dti1.bvec_old ]
	then
		echo "rotate_bvecs ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor.ecclog ${FS_DIR}/${SUBJ_ID}/dti/dti1.bvec"
		rotate_bvecs ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor.ecclog ${FS_DIR}/${SUBJ_ID}/dti/dti1.bvec
	fi

	############################
	## Step 4. Compute DTI fit
	############################

	if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
	then
		echo "bet ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor_brain -F -f 0.25 -g 0 -m"
		bet ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor_brain -F -f 0.25 -g 0 -m
		
		echo "dtifit --data=${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor.nii.gz --out=${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor --mask=${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor_brain_mask.nii.gz --bvecs=${FS_DIR}/${SUBJ_ID}/dti/dti1.bvec --bvals=${FS_DIR}/${SUBJ_ID}/dti/dti1.bval"
		dtifit --data=${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor.nii.gz --out=${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor --mask=${FS_DIR}/${SUBJ_ID}/dti/dti1_eddycor_brain_mask.nii.gz --bvecs=${FS_DIR}/${SUBJ_ID}/dti/dti1.bvec --bvals=${FS_DIR}/${SUBJ_ID}/dti/dti1.bval
	fi
	
elif [ ${flagBadFile[1]} -eq 1 -a ${flagBadFile[2]} -eq 0 ]
then
	#############################################################
	## Step 2. Eddy current correction on dti2.nii.gz
	#############################################################
	if [ ! -e ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor.ecclog ]
	then
		echo "eddy_correct ${FS_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor 0"
		eddy_correct ${FS_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor 0
	fi

	#############################
	## Step 3. Rotate bvec files
	#############################

	if [ ! -e ${FS_DIR}/${SUBJ_ID}/dti/dti2.bvec_old ]
	then
		echo "rotate_bvecs ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor.ecclog ${FS_DIR}/${SUBJ_ID}/dti/dti2.bvec"
		rotate_bvecs ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor.ecclog ${FS_DIR}/${SUBJ_ID}/dti/dti2.bvec
	fi

	############################
	## Step 4. Compute DTI fit
	############################

	if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
	then
		echo "bet ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor_brain -F -f 0.25 -g 0 -m"
		bet ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor_brain -F -f 0.25 -g 0 -m
		
		echo "dtifit --data=${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor.nii.gz --out=${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor --mask=${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor_brain_mask.nii.gz --bvecs=${FS_DIR}/${SUBJ_ID}/dti/dti2.bvec --bvals=${FS_DIR}/${SUBJ_ID}/dti/dti2.bval"
		dtifit --data=${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor.nii.gz --out=${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor --mask=${FS_DIR}/${SUBJ_ID}/dti/dti2_eddycor_brain_mask.nii.gz --bvecs=${FS_DIR}/${SUBJ_ID}/dti/dti2.bvec --bvals=${FS_DIR}/${SUBJ_ID}/dti/dti2.bval
	fi
	
elif [ ${DoMergeDTI} -eq 1 ] && [ ${flagBadFile[1]} -eq 0 ] && [ ${flagBadFile[2]} -eq 0 ]
then
	DimZ1=$(mri_info ${FS_DIR}/${SUBJ_ID}/dti/dti1.nii.gz | grep dimensions | awk '{print $6}')
	echo "Nb coupes en Z dti1 : ${DimZ1}"
	DimF1=$(mri_info ${FS_DIR}/${SUBJ_ID}/dti/dti1.nii.gz | grep dimensions | awk '{print $8}')
	echo "Nb de frames dti1: ${DimF1}"
	# DimZb=$(mri_info dti_back.nii.gz | grep dimensions | awk '{print $6}')
	# echo "Nb coupes en Z dti_back : ${DimZb}"

	# Manage input dti files : merge dti frames and format bval/bvecs files
	if [ $(ls -1 ${FS_DIR}/${SUBJ_ID}/dti/dti[1-2].nii.gz | wc -l) -gt 1 ]
	then 
		DimZ2=$(mri_info ${FS_DIR}/${SUBJ_ID}/dti/dti2.nii.gz | grep dimensions | awk '{print $6}')
		echo "Nb coupes en Z dti2 : ${DimZ2}"
		DimF2=$(mri_info ${FS_DIR}/${SUBJ_ID}/dti/dti2.nii.gz | grep dimensions | awk '{print $8}')
		echo "Nb de frames dti2 : ${DimF2}"
		if [ ${DimF1} -eq 16 ] && [ ${DimF2} -eq 16 ]
		then
			if [ ${DimZ1} -eq ${DimZ2} ]
			then
				fslmerge -t ${FS_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti[1-2].nii.gz
				
				# Delete B0 frames from bval files associated to dti[i=2]
				while read col1 col2    # col2 se voit attribuer tout le reste des colonnes
				do
					echo $col2 > ${FS_DIR}/${SUBJ_ID}/dti/ndti2.bval
				done < ${FS_DIR}/${SUBJ_ID}/dti/dti2.bval
				
				# Merge bval/bvec files
				paste ${FS_DIR}/${SUBJ_ID}/dti/dti1.bval ${FS_DIR}/${SUBJ_ID}/dti/ndti2.bval > ${FS_DIR}/${SUBJ_ID}/dti/dti.bval
				rm -f ${FS_DIR}/${SUBJ_ID}/dti/ndti2.bval
				
				paste ${FS_DIR}/${SUBJ_ID}/dti/dti1.bvec ${FS_DIR}/${SUBJ_ID}/dti/dti2.bvec > ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec
			else
				echo "Les deux fichiers DTI_15dir n'ont pas le même nombre de coupes en Z"
				exit 1
			fi
		elif [ ${DimF1} -eq 16 ]
		then
			cp ${FS_DIR}/${SUBJ_ID}/dti/dti1.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
			echo "Il n'y a qu'un seul fichier DTI ayant 15 dir : serie 1"
			
			# Case of one single dti file : rename bval/bvec and dti files
			cp ${FS_DIR}/${SUBJ_ID}/dti/dti1.bval ${FS_DIR}/${SUBJ_ID}/dti/dti.bval
			cp ${FS_DIR}/${SUBJ_ID}/dti/dti1.bvec ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec
		elif [ ${DimF2} -eq 16 ]
		then
			cp ${FS_DIR}/${SUBJ_ID}/dti/dti2.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
			echo "Il n'y a qu'un seul fichier DTI ayant 15 dir : serie 2"

			# Case of one single dti file : rename bval/bvec and dti files
			cp ${FS_DIR}/${SUBJ_ID}/dti/dti2.bval ${FS_DIR}/${SUBJ_ID}/dti/dti.bval
			cp ${FS_DIR}/${SUBJ_ID}/dti/dti2.bvec ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec
		else
			echo "Aucun des fichiers DTI_15dir n'a un B0 + 15 dir"
			exit 1	
		fi
	else
		cp ${FS_DIR}/${SUBJ_ID}/dti/dti[1-2].nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz
		echo "Il n'y a qu'un seul fichier DTI 15 dir"
		
		# Case of one single dti file : rename bval/bvec and dti files
		cp ${FS_DIR}/${SUBJ_ID}/dti/dti[1-2].bval ${FS_DIR}/${SUBJ_ID}/dti/dti.bval
		cp ${FS_DIR}/${SUBJ_ID}/dti/dti[1-2].bvec ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec
				
	fi

	########################################################
	## Step 2. Eddy current correction on dti_global.nii.gz
	########################################################

	if [ ! -e ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ]
	then
		echo "eddy_correct ${FS_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycor 0"
		eddy_correct ${FS_DIR}/${SUBJ_ID}/dti/dti_global.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycor 0
	fi

	#######################################################################################################
	## Step 3. Mean B0 frames and build final eddy corrected dti for multiple files
	#######################################################################################################

	DimFg=$(mri_info ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycor.nii.gz | grep dimensions | awk '{print $8}')
	echo "Nb de frames dti_eddycor: ${DimFg}"
	if [ ${DimFg} -gt 16 ]
	then
		# Create temp directory in output /dti dir
		mkdir ${FS_DIR}/${SUBJ_ID}/dti/tmp
		
		# Write in a file all B0 frames from multiple dti and delete B0 frame from bval/bvec files
		fslsplit ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycor.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor -t
		
		# Mean of all B0 frames
		mv ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor0000.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/tmp/B0_1.nii.gz 
		mv ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor0016.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/tmp/B0_2.nii.gz 
		fslmerge -t ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_B0.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/tmp/B0_1.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/tmp/B0_2.nii.gz 
		echo "fslmaths ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_B0.nii.gz -Tmean ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_B0_mean.nii.gz"
		fslmaths ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_B0.nii.gz -Tmean ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_B0_mean.nii.gz
		
		# Merge of multiple dti files : Mean B0 at first frame and concatenation of all dti frames
		fslmerge -t ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_B0_mean.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/tmp/dti_eddycor*.nii.gz
		
		# Delete temp dir in ouput /dti dir
	# 	rm -rf ${FS_DIR}/${SUBJ_ID}/dti/tmp
	else
		# Case of one single dti file : rename dti file
		mv ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycor.nii.gz ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz
	fi

	final_dti=${FS_DIR}/${SUBJ_ID}/dti/dti_eddycorf.nii.gz

	######################################################
	## Step 4. Rotate bvec file and build final bvec file
	######################################################

	if [ ! -e ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec_old ]
	then
		echo "rotate_bvecs ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec"
		rotate_bvecs ${FS_DIR}/${SUBJ_ID}/dti/dti_eddycor.ecclog ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec
	fi

	DimFf=$(mri_info ${final_dti} | grep dimensions | awk '{print $8}')
	echo "Nb de frames dti_eddycorf: ${DimFf}"
	if [ ${DimFf} -gt 16 ]
	then
		mv ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec ${FS_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec
		awk '{$17="";print}' ${FS_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec > ${FS_DIR}/${SUBJ_ID}/dti/dti.bvec
		rm -f ${FS_DIR}/${SUBJ_ID}/dti/dti_tmp.bvec
	fi

	##################################################
	## Step 5. Compute DTI fit on corrected DTI
	##################################################

	if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
	then
		echo "bet ${final_dti} ${FS_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain -F -f 0.25 -g 0 -m"
		bet bet ${final_dti} ${FS_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain -F -f 0.25 -g 0 -m
		
		echo "dtifit --data=${final_dti} --out=${FS_DIR}/${SUBJ_ID}/dti/dti_finalcor --mask=${FS_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz --bvecs=${FS_DIR}/${SUBJ_ID}/dti/dti.bvec --bvals=${FS_DIR}/${SUBJ_ID}/dti/dti.bval"
		dtifit --data=${final_dti} --out=${FS_DIR}/${SUBJ_ID}/dti/dti_finalcor --mask=${FS_DIR}/${SUBJ_ID}/dti/dti_finalcor_brain_mask.nii.gz --bvecs=${FS_DIR}/${SUBJ_ID}/dti/dti.bvec --bvals=${FS_DIR}/${SUBJ_ID}/dti/dti.bval
	fi
fi