#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_LempProcess.sh  -fs  <SubjDir>  -subj  <SubjName>  -labels <labels_list.txt> [-lmax <lmax>  -N <Nfiber> -no_FA_proj]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -labels Labels_list          : Path to a file containing label info (.txt)"
	echo " "
	echo "Options :"
	echo "  -lmax lmax                   : Maximum harmonic order (default : 2)"
	echo "  -N Nfiber                    : Number of fibers (default : 1500000)"
	echo "  -no_FA_proj                  : does not produce the Connectum and FA projection"	
	echo " "
	echo "Important : To make the script working, please create the directory dti within SubjDir/SubjName"
	echo "            And copy the Diffusion weighted images and gradient files."
	echo "            There sould be 3 files in the dti directory prior to running the script :"
	echo "            1. dti.nii.gz      [Forward acquisition]"
	echo "            2. dti.bval        [B-values of the forward acquisition]"
	echo "            3. dti.bec         [Directions of the gradients of the forward DWI]"
	echo " "
	echo "If these 3 files can not be found, the script will fail."
	echo ""
	echo "Usage: DTI_LempProcess.sh  -fs  <SubjDir>  -subj  <SubjName>  -labels <labels_list.txt> [-lmax <lmax>  -N <Nfiber> -no_FA_proj]"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
lmax=2
Nfiber=1500000
no_FA_proj=0
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_LempProcess.sh  -fs  <SubjDir>  -subj  <SubjName>  -labels <labels_list.txt> [-lmax <lmax>  -N <Nfiber> -no_FA_proj]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -labels Labels_list          : Path to a file containing label info (.txt)"
		echo " "
		echo "Options :"
		echo "  -lmax lmax                   : Maximum harmonic order (default : 2)"
		echo "  -N Nfiber                    : Number of fibers (default : 1500000)"
		echo "  -no_FA_proj                  : does not produce the Connectum and FA projection"	
		echo " "
		echo "Important : To make the script working, please create the directory dti within SubjDir/SubjName"
		echo "            And copy the Diffusion weighted images and gradient files."
		echo "            There sould be 3 files in the dti directory prior to running the script :"
		echo "            1. dti.nii.gz      [Forward acquisition]"
		echo "            2. dti.bval        [B-values of the forward acquisition]"
		echo "            3. dti.bec         [Directions of the gradients of the forward DWI]"
		echo " "
		echo "If these 3 files can not be found, the script will fail."
		echo ""
		echo "Usage: DTI_LempProcess.sh  -fs  <SubjDir>  -subj  <SubjName>  -labels <labels_list.txt> [-lmax <lmax>  -N <Nfiber> -no_FA_proj]"
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-labels)
		LOI=`expr $index + 1`
		eval LOI=\${$LOI}
		echo "  |-------> Labels list : ${LOI}"
		index=$[$index+1]
		;;
	-lmax)
		lmax=`expr $index + 1`
		eval lmax=\${$lmax}
		echo "  |-------> Optional lmax : ${lmax}"
		index=$[$index+1]
		;;
	-N)
		Nfiber=`expr $index + 1`
		eval Nfiber=\${$Nfiber}
		echo "  |-------> Optional N : ${Nfiber}"
		index=$[$index+1]
		;;
	-no_FA_proj)
		no_FA_proj=1
		echo "  |-------> no_FA_proj activated"
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################

## Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

## Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh


# Check inputs
DIR=${fs}/${subj}
if [ ! -e ${DIR} ]
then
	echo "Can not find ${DIR} directory"
	exit 1
fi

DTI=${DIR}/dti
if [ ! -e ${DTI} ]
then
	echo "Can not find ${DTI} directory"
fi

for_dti=${DTI}/dti.nii.gz
if [ ! -e ${for_dti} ]
then
	echo "Can not find file ${for_dti}"
	exit 1
fi

bval=${DTI}/dti.bval
if [ ! -e ${bval} ]
then
	echo "Can not find file ${bval}"
	exit 1
fi

bvec=${DTI}/dti.bvec
if [ ! -e ${bvec} ]
then
	echo "Can not find file ${bvec}"
	exit 1
fi

# Step 1. Eddy current correction
if [ ! -e ${DTI}/dti_eddycor.ecclog ]
then
	echo "eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0"
	eddy_correct ${DTI}/dti.nii.gz ${DTI}/dti_eddycor 0
fi

# Step 2. Rotate bvec
if [ ! -e ${DTI}/dti.bvec_old ]
then
	echo "rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}"
	rotate_bvecs ${DTI}/dti_eddycor.ecclog ${bvec}
fi

# Step 3. Compute DTI fit on DTI
if [ ! -e ${DTI}/dti_finalcor_brain_mask.nii.gz ]
then
	echo "bet ${DTI}/dti_eddycor.nii.gz ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m"
	bet ${DTI}/dti_eddycor.nii.gz ${DTI}/dti_finalcor_brain -F -f 0.25 -g 0 -m
	
	echo "dtifit --data=${DTI}/dti_eddycor.nii.gz --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval"
	dtifit --data=${DTI}/dti_eddycor.nii.gz --out=${DTI}/dti_finalcor --mask=${DTI}/dti_finalcor_brain_mask.nii.gz --bvecs=${DTI}/dti.bvec --bvals=${DTI}/dti.bval
fi

# # Step 4. Performs tractography
# 	# Step 4.1 Convert images and bvec
# if [ ! -e ${DTI}/dti_finalcor.mif ]
# then
# 	# dti
# 	gunzip -f ${DTI}/dti_eddycor.nii.gz
# 	echo "mrconvert ${DTI}/dti_eddycor.nii ${DTI}/dti_finalcor.mif"
# 	mrconvert ${DTI}/dti_eddycor.nii ${DTI}/dti_finalcor.mif
# 	gzip -f ${DTI}/dti_eddycor.nii
# 	
# 	# brain mask
# 	gunzip -f ${DTI}/dti_finalcor_brain_mask.nii.gz
# 	echo "mrconvert ${DTI}/dti_finalcor_brain_mask.nii ${DTI}/mask.mif"
# 	mrconvert ${DTI}/dti_finalcor_brain_mask.nii ${DTI}/mask.mif
# 	gzip -f ${DTI}/dti_finalcor_brain_mask.nii
# # 	echo "average ${DTI}/dti_finalcor.mif -axis 3 - | threshold - - | median3D - - | median3D - ${DTI}/mask.mif"
# # 	average ${DTI}/dti_finalcor.mif -axis 3 - | threshold - - | median3D - - | median3D - ${DTI}/mask.mif
# 	
# 	# bvec
# 	cp ${DTI}/dti.bvec ${DTI}/temp.txt
# 	cat ${DTI}/dti.bval >> ${DTI}/temp.txt
# 	matlab -nodisplay <<EOF
# 	bvecs_to_mrtrix('${DTI}/temp.txt', '${DTI}/bvecs_mrtrix');
# EOF
# 	
# 	rm -f ${DTI}/temp.txt		
# fi
# 
# 	# Step 4.2 All steps until the response estimate
# if [ ! -e ${DTI}/response.txt ]
# then
# 	# Calculate tensors
# 	rm -f ${DTI}/dt.mif
# 	echo "dwi2tensor ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif"
# 	dwi2tensor ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/dt.mif
# 	
# 	# Calculate FA
# 	rm -f ${DTI}/fa.mif
# 	echo "tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/mask.mif ${DTI}/fa.mif"
# 	tensor2FA ${DTI}/dt.mif - | mrmult - ${DTI}/mask.mif ${DTI}/fa.mif
# 	
# 	# Calculate highly anisotropic voxels
# 	rm -f ${DTI}/sf.mif
# 	echo "erode ${DTI}/mask.mif - | erode - - | mrmult ${DTI}/fa.mif - - | threshold - -abs 0.7 ${DTI}/sf.mif"
# 	erode ${DTI}/mask.mif - | erode - - | mrmult ${DTI}/fa.mif - - | threshold - -abs 0.7 ${DTI}/sf.mif
# 	
# 	# Estimate response function
# 	echo "estimate_response ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/sf.mif -lmax ${lmax} ${DTI}/response.txt"
# 	estimate_response ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/sf.mif -lmax ${lmax} ${DTI}/response.txt
# fi
# 
# 	# Step 4.3 Spherical deconvolution
# if [ ! -e ${DTI}/CSD${lmax}.mif ]
# then
# 	# Local computations to reduce bandwidth usage
# 	# csdeconv ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/response.txt -lmax ${lmax} -mask ${DTI}/rwm_mask_dti.mif ${DTI}/CSD${lmax}.mif
# 	rm -f /tmp/${subj}_CSD${lmax}.mif
# 	csdeconv ${DTI}/dti_finalcor.mif -grad ${DTI}/bvecs_mrtrix ${DTI}/response.txt -lmax ${lmax} -mask ${DTI}/mask.mif /tmp/${subj}_CSD${lmax}.mif
# 	cp -f /tmp/${subj}_CSD${lmax}.mif ${DTI}/CSD${lmax}.mif
# 	rm -f /tmp/${subj}_CSD${lmax}.mif
# fi
# 
# # ------------------------------------------------------------------------------------ #
# 
# 	# Step 4.4 Fiber tracking
# if [ ! -e ${DTI}/whole_brain_${lmax}_${Nfiber}.tck ]
# then
# 	# Stream locally to avoid RAM filling
# 	# Loop fiber tracking to generate lighter files
# 	Nfile=`echo "scale=0; ${Nfiber} / 10000" | bc -l`
# 	Ifile=1
# 	while [ ${Ifile} -le ${Nfile} ]
# 	do
# 		fID=`printf '%.6d' ${Ifile}`
# 		rm -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}_part${fID}.tck
# 		echo "Streaming whole_brain_${lmax}_${Nfiber}_part${fID}.tck"
# 		streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/mask.mif -mask ${DTI}/mask.mif /tmp/${subj}_whole_brain_${lmax}_${Nfiber}_part${fID}.tck -num 10000
# 		cp -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}_part${fID}.tck ${DTI}/whole_brain_${lmax}_${Nfiber}_part${fID}.tck
# 		rm -f /tmp/${subj}_whole_brain_${lmax}_${Nfiber}_part${fID}.tck
# 		Ifile=$[${Ifile}+1]
# 	done
# 	touch ${DTI}/whole_brain_${lmax}_${Nfiber}.tck
# fi
# 
# # # Step 5. Save cortical surfaces in volume space
# # if [ ! -e ${DIR}/surf/lh.white.ras ]
# # then
# # 
# # mri_convert ${DIR}/mri/T1.mgz ${DIR}/mri/t1_ras.nii --out_orientation RAS
# # 
# # matlab -nodisplay <<EOF
# # surf = surf_to_ras_nii('${DIR}/surf/lh.white', '${DIR}/mri/t1_ras.nii');
# # SurfStatWriteSurf('${DIR}/surf/lh.white.ras', surf, 'b');
# # 
# # surf = surf_to_ras_nii('${DIR}/surf/rh.white', '${DIR}/mri/t1_ras.nii');
# # SurfStatWriteSurf('${DIR}/surf/rh.white.ras', surf, 'b');
# # EOF
# # 
# # rm -f ${DIR}/mri/t1_ras.nii
# # 
# # fi
# 
# # Step 6. Extract labels to ROIs into one labels volume
# if [ ! -e ${DTI}/labels_dti_ras.nii ]
# then
# 	echo "mri_label2vol --label ${DTI}/cc.label --label ${DTI}/masque_calleux.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_CC.nii.gz"
# 	mri_label2vol --label ${DTI}/cc.label --label ${DTI}/masque_calleux.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_CC.nii.gz
# 
# 	echo "mri_label2vol --label ${DTI}/left_central.label --label ${DTI}/left_capsule.label --label ${DTI}/left_tronc.label --label ${DTI}/masque_exclusion_FCS.label --label ${DTI}/right_central.label --label ${DTI}/right_capsule.label --label ${DTI}/right_tronc.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_FCS.nii.gz"
# 	mri_label2vol --label ${DTI}/left_central.label --label ${DTI}/left_capsule.label --label ${DTI}/left_tronc.label --label ${DTI}/masque_exclusion_FCS.label --label ${DTI}/right_central.label --label ${DTI}/right_capsule.label --label ${DTI}/right_tronc.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_FCS.nii.gz
# 	
# 	echo "mri_convert ${DTI}/labels_dti_CC.nii.gz ${DTI}/labels_dti_CC_ras.nii.gz --out_orientation RAS"
# 	mri_convert ${DTI}/labels_dti_CC.nii.gz ${DTI}/labels_dti_CC_ras.nii.gz --out_orientation RAS
# 
# 	echo "mri_convert ${DTI}/labels_dti_FCS.nii.gz ${DTI}/labels_dti_FCS_ras.nii.gz --out_orientation RAS"
# 	mri_convert ${DTI}/labels_dti_FCS.nii.gz ${DTI}/labels_dti_FCS_ras.nii.gz --out_orientation RAS
# 	
# 	gunzip ${DTI}/labels_dti_CC_ras.nii.gz ${DTI}/labels_dti_FCS_ras.nii.gz
# fi
# 
# # Step 7. Compute connectum with labels file as input, save tracks in each ROI and project FA/MD/L1/L2/L3 on tracks
# if [ ! -f ${DTI}/fa.nii ]
# then
# 	mrconvert ${DTI}/fa.mif ${DTI}/fa.nii
# fi
# 
# if [ ! -f ${DTI}/MD.nii ]
# then
# 	tensor2ADC ${DTI}/dt.mif - | mrmult - ${DTI}/mask.mif ${DTI}/MD.mif
# 	mrconvert ${DTI}/MD.mif ${DTI}/MD.nii
# fi
# 
# gunzip ${DTI}/dti_finalcor_L1.nii.gz ${DTI}/dti_finalcor_L2.nii.gz ${DTI}/dti_finalcor_L3.nii.gz
# 
# if [ ${no_FA_proj} -eq 0 ]
# then
# 	echo " "
# 	echo "---------------------------------"
# 	echo "Connectome = getVolumeFibersROIs('${DTI}/labels_dti_CC_ras.nii', '${DTI}', '/NAS/dumbo/protocoles/LEMP/LOI_LEMP_CC.txt', 30);"
# 	echo " "
# 	echo "---------------------------------"
# 	echo "SaveROIfibersAndMap('${DTI}', '${DTI}/labels_dti_CC_ras.nii', '${DTI}/fa.nii', '${DTI}/MD.nii', '${DTI}/dti_finalcor_L1.nii', '${DTI}/dti_finalcor_L2.nii', '${DTI}/dti_finalcor_L3.nii', Connectome, 0, '/NAS/dumbo/protocoles/LEMP/LOI_LEMP_CC.txt', thresh);"
# 	echo " "
# 	echo "---------------------------------"
# 	echo "Connectome = getVolumeFibersROIs('${DTI}/labels_dti_FCS_ras.nii', '${DTI}', '/NAS/dumbo/protocoles/LEMP/LOI_LEMP_FCS.txt', 30);"
# 	echo " "
# 	echo "---------------------------------"
# 	echo "SaveROIfibersAndMap('${DTI}', '${DTI}/labels_dti_FCS_ras.nii', '${DTI}/fa.nii', '${DTI}/MD.nii', '${DTI}/dti_finalcor_L1.nii', '${DTI}/dti_finalcor_L2.nii', '${DTI}/dti_finalcor_L3.nii', Connectome, 1, '/NAS/dumbo/protocoles/LEMP/LOI_LEMP_FCS.txt', thresh);"
# 	matlab -nodisplay <<EOF
# 	cd ${HOME}
# 	p = pathdef;
# 	addpath(p);
# 	cd ${DTI}
# 	
# 	Connectome = getVolumeFibersROIs('${DTI}/labels_dti_CC_ras.nii', '${DTI}', '/NAS/dumbo/protocoles/LEMP/LOI_LEMP_CC.txt', 30);
# 	save Connectome_${subj}_CC Connectome -v7.3
# 	
# 	SaveROIfibersAndMap('${DTI}', '${DTI}/labels_dti_CC_ras.nii', '${DTI}/fa.nii', '${DTI}/MD.nii', '${DTI}/dti_finalcor_L1.nii', '${DTI}/dti_finalcor_L2.nii', '${DTI}/dti_finalcor_L3.nii', Connectome, 0, '/NAS/dumbo/protocoles/LEMP/LOI_LEMP_CC.txt', thresh);
# 	
# 	clear all;
# 	
# 	Connectome = getVolumeFibersROIs('${DTI}/labels_dti_FCS_ras.nii', '${DTI}', '/NAS/dumbo/protocoles/LEMP/LOI_LEMP_FCS.txt', 30);
# 	save Connectome_${subj}_RL_FCS Connectome -v7.3
# 	
# 	SaveROIfibersAndMap('${DTI}', '${DTI}/labels_dti_FCS_ras.nii', '${DTI}/fa.nii', '${DTI}/MD.nii', '${DTI}/dti_finalcor_L1.nii', '${DTI}/dti_finalcor_L2.nii', '${DTI}/dti_finalcor_L3.nii', Connectome, 1, '/NAS/dumbo/protocoles/LEMP/LOI_LEMP_FCS.txt', thresh);
# EOF
# fi
# 
# # ---------------------------------------------------------------------------------------------- #
# 
# # 	# Step 4.4 Extract labels into labels volumes
# # if [ ! -e ${DTI}/labels_dti_exclusion_FCS_ras.nii.gz ]
# # then
# # 	echo "mri_label2vol --label ${DTI}/cc.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_CC.nii.gz"
# # 	mri_label2vol --label ${DTI}/cc.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_CC.nii.gz
# # 
# # 	echo "mri_label2vol --label ${DTI}/masque_calleux.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_exclusion_CC.nii.gz"
# # 	mri_label2vol --label ${DTI}/masque_calleux.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_exclusion_CC.nii.gz
# # 	
# # 	echo "mri_label2vol --label ${DTI}/left_central.label --label ${DTI}/left_capsule.label --label ${DTI}/left_tronc.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_LFCS.nii.gz"
# # 	mri_label2vol --label ${DTI}/left_central.label --label ${DTI}/left_capsule.label --label ${DTI}/left_tronc.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_LFCS.nii.gz
# # 
# # 	echo "mri_label2vol --label ${DTI}/right_central.label --label ${DTI}/right_capsule.label --label ${DTI}/right_tronc.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_RFCS.nii.gz"
# # 	mri_label2vol --label ${DTI}/right_central.label --label ${DTI}/right_capsule.label --label ${DTI}/right_tronc.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_RFCS.nii.gz
# # 	
# # 	echo "mri_label2vol --label ${DTI}/masque_exclusion_FCS.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_exclusion_FCS.nii.gz"
# # 	mri_label2vol --label ${DTI}/masque_exclusion_FCS.label --temp ${DTI}/dti_finalcor_FA.nii.gz --identity --o ${DTI}/labels_dti_exclusion_FCS.nii.gz
# # 	
# # 	echo "mri_binarize --i ${DTI}/labels_dti_LFCS.nii.gz --min 0.1 --o ${DTI}/labels_dti_LFCS.nii.gz"
# # 	mri_binarize --i ${DTI}/labels_dti_LFCS.nii.gz --min 0.1 --o ${DTI}/labels_dti_LFCS.nii.gz
# # 	
# # 	echo "mri_binarize --i ${DTI}/labels_dti_RFCS.nii.gz --min 0.1 --o ${DTI}/labels_dti_RFCS.nii.gz"
# # 	mri_binarize --i ${DTI}/labels_dti_RFCS.nii.gz --min 0.1 --o ${DTI}/labels_dti_RFCS.nii.gz	
# # 	
# # 	echo "mri_convert ${DTI}/labels_dti_CC.nii.gz ${DTI}/labels_dti_CC_ras.nii.gz --out_orientation RAS"
# # 	mri_convert ${DTI}/labels_dti_CC.nii.gz ${DTI}/labels_dti_CC_ras.nii.gz --out_orientation RAS
# # 	
# # 	echo "mri_convert ${DTI}/labels_dti_exclusion_CC.nii.gz ${DTI}/labels_dti_exclusion_CC_ras.nii.gz --out_orientation RAS"
# # 	mri_convert ${DTI}/labels_dti_exclusion_CC.nii.gz ${DTI}/labels_dti_exclusion_CC_ras.nii.gz --out_orientation RAS
# # 	
# # 	echo "mri_convert ${DTI}/labels_dti_LFCS.nii.gz ${DTI}/labels_dti_LFCS_ras.nii.gz --out_orientation RAS"
# # 	mri_convert ${DTI}/labels_dti_LFCS.nii.gz ${DTI}/labels_dti_LFCS_ras.nii.gz --out_orientation RAS
# # 	
# # 	echo "mri_convert ${DTI}/labels_dti_RFCS.nii.gz ${DTI}/labels_dti_RFCS_ras.nii.gz --out_orientation RAS"
# # 	mri_convert ${DTI}/labels_dti_RFCS.nii.gz ${DTI}/labels_dti_RFCS_ras.nii.gz --out_orientation RAS
# # 	
# # 	echo "mri_convert ${DTI}/labels_dti_exclusion_FCS.nii.gz ${DTI}/labels_dti_exclusion_FCS_ras.nii.gz --out_orientation RAS"
# # 	mri_convert ${DTI}/labels_dti_exclusion_FCS.nii.gz ${DTI}/labels_dti_exclusion_FCS_ras.nii.gz --out_orientation RAS
# # 
# # fi
# # 
# # 	# Step 4.5 Convert labels images to .mif
# # if [ ! -e ${DTI}/labels_dti_exclusion_FCS_ras.mif ]
# # then
# # 	# CC
# # 	gunzip -f ${DTI}/labels_dti_CC_ras.nii.gz
# # 	echo "mrconvert ${DTI}/labels_dti_CC_ras.nii ${DTI}/labels_dti_CC_ras.mif"
# # 	mrconvert ${DTI}/labels_dti_CC_ras.nii ${DTI}/labels_dti_CC_ras.mif
# # 	gzip -f ${DTI}/labels_dti_CC_ras.nii
# # 	
# # 	# exclusion CC
# # 	gunzip -f ${DTI}/labels_dti_exclusion_CC_ras.nii.gz
# # 	echo "mrconvert ${DTI}/labels_dti_exclusion_CC_ras.nii ${DTI}/labels_dti_exclusion_CC_ras.mif"
# # 	mrconvert ${DTI}/labels_dti_exclusion_CC_ras.nii ${DTI}/labels_dti_exclusion_CC_ras.mif
# # 	gzip -f ${DTI}/labels_dti_exclusion_CC_ras.nii
# # 
# # 	# Left FCS
# # 	gunzip -f ${DTI}/labels_dti_LFCS_ras.nii.gz
# # 	echo "mrconvert ${DTI}/labels_dti_LFCS_ras.nii ${DTI}/labels_dti_LFCS_ras.mif"
# # 	mrconvert ${DTI}/labels_dti_LFCS_ras.nii ${DTI}/labels_dti_LFCS_ras.mif
# # 	gzip -f ${DTI}/labels_dti_LFCS_ras.nii
# # 	
# # 	# Right FCS
# # 	gunzip -f ${DTI}/labels_dti_RFCS_ras.nii.gz
# # 	echo "mrconvert ${DTI}/labels_dti_RFCS_ras.nii ${DTI}/labels_dti_RFCS_ras.mif"
# # 	mrconvert ${DTI}/labels_dti_RFCS_ras.nii ${DTI}/labels_dti_RFCS_ras.mif
# # 	gzip -f ${DTI}/labels_dti_RFCS_ras.nii
# # 	
# # 	# exclusion FCS
# # 	gunzip -f ${DTI}/labels_dti_exclusion_FCS_ras.nii.gz
# # 	echo "mrconvert ${DTI}/labels_dti_exclusion_FCS_ras.nii ${DTI}/labels_dti_exclusion_FCS_ras.mif"
# # 	mrconvert ${DTI}/labels_dti_exclusion_FCS_ras.nii ${DTI}/labels_dti_exclusion_FCS_ras.mif
# # 	gzip -f ${DTI}/labels_dti_exclusion_FCS_ras.nii
# # fi
# # 
# #  	# Step 4.6 Fiber tracking ROI seed based
# # 
# # # Corps Callosum tractography
# # qbatch -N DTI_CC_${subj} -q M32_q -oe /NAS/dumbo/matthieu/Logdir DTI_Tracto_ROI.sh CC ${subj} ${DTI} ${lmax} 10000 0.1 exclusion_CC
# # # streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/rFNL_dti.mif -mask ${DTI}/rwm_mask_dti.mif ${DTI}/FNL_${lmax}_1000.tck
# # 
# # # Left FCS tractography
# # qbatch -N DTI_LFCS_${subj} -q M32_q -oe /NAS/dumbo/matthieu/Logdir DTI_Tracto_ROI.sh LFCS ${subj} ${DTI} ${lmax} 1000 0.1 exclusion_FCS
# # 
# # # Right FCS tractography
# # qbatch -N DTI_RFCS_${subj} -q M32_q -oe /NAS/dumbo/matthieu/Logdir DTI_Tracto_ROI.sh RFCS ${subj} ${DTI} ${lmax} 1000 0.1 exclusion_FCS
# 
