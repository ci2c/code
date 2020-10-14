#!/bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage:  FSL_ASLProcessing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
	echo ""
	echo "	-id		: Input directory containing raw subjects data "
	echo "  -sd		: FS5.3 subjects directory "
	echo "  -subj       	: Subject name "
	echo "  -tpdir       	: Directory containing the T1 template "
	echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
	echo ""
	echo "Usage:  FSL_ASLProcessing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - February 2015"
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
		echo "Usage:  FSL_ASLProcessing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
		echo ""
		echo "	-id		: Input directory containing raw subjects data "
		echo "  -sd		: FS5.3 subjects directory "
		echo "  -subj       	: Subject name "
		echo "  -tpdir       	: Directory containing the T1 template "
		echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
		echo ""
		echo "Usage:  FSL_ASLProcessing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - February 2015"
		echo ""
		exit 1
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
# 		echo "input data : ${INPUT_DIR}"
		;;	
	-sd)
		index=$[$index+1]
		eval FS_DIR=\${$index}
# 		echo "FS data : ${FS_DIR}"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJECT_ID=\${$index}
# 		echo "subject name : ${SUBJECT_ID}"
		;;
	-tpdir)
		index=$[$index+1]
		eval TEMPLATE_DIR=\${$index}
# 		echo "template dir : ${TEMPLATE_DIR}"
		;;
	-wd)
		index=$[$index+1]
		eval asldir=\${$index}
# 		echo "ASL working dir : ${asldir}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo ""
		echo "Usage:  FSL_ASLProcessing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
		echo ""
		echo "	-id		: Input directory containing raw subjects data "
		echo "  -sd		: FS5.3 subjects directory "
		echo "  -subj       	: Subject name "
		echo "  -tpdir       	: Directory containing the T1 template "
		echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
		echo ""
		echo "Usage:  FSL_ASLProcessing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - February 2015"
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
if [ -z ${FS_DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi
if [ -z ${SUBJECT_ID} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi
if [ -z ${TEMPLATE_DIR} ]
then
	 echo "-tpdir argument mandatory"
	 exit 1
fi
if [ -z ${asldir} ]
then
	 echo "-wd argument mandatory"
	 exit 1
fi

## Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

## Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl509
. ${FSLDIR}/etc/fslconf/fsl.sh

## Check dependencies
PROGRAM_DEPENDENCIES=( 'antsRegistration' 'antsApplyTransforms' 'N4BiasFieldCorrection' )
SCRIPTS_DEPENDENCIES=( 'antsBrainExtraction.sh' 'antsIntermodalityIntrasubject.sh' )

for D in ${PROGRAM_DEPENDENCIES[@]};
  do
    if [[ ! -s ${ANTSPATH}/${D} ]];
      then
        echo "Error:  we can't find the $D program."
        echo "Perhaps you need to \(re\)define \$ANTSPATH in your environment."
        exit
      fi
  done

for D in ${SCRIPT_DEPENDENCIES[@]};
  do
    if [[ ! -s ${ANTSPATH}/${D} ]];
      then
        echo "We can't find the $D script."
        echo "Perhaps you need to \(re\)define \$ANTSPATH in your environment."
        exit
      fi
  done

## Create log function
function logCmd() {
  cmd="$*"
  echo "BEGIN >>>>>>>>>>>>>>>>>>>>"
  echo $cmd
  $cmd

  cmdExit=$?

  if [[ $cmdExit -gt 0 ]];
  then
      echo "ERROR: command exited with nonzero status $cmdExit"
      echo "Command: $cmd"
      echo
  fi

  echo "END   <<<<<<<<<<<<<<<<<<<<"
  echo
  echo

  return $cmdExit
}

## Initialize parameters
remframe=4
ANTS_MAX_ITERATIONS="100x100x70x20"
ANTS_TRANSFORMATION="SyN[0.1,3,0]"
ANTS_LINEAR_METRIC_PARAMS="1,32,Regular,0.25"
ANTS_LINEAR_CONVERGENCE="[1000x500x250x100,1e-8,10]"
DIR=${FS_DIR}/${SUBJECT_ID}

# # # =====================================================================================
# # #                                 Prepare ASL data
# # # =====================================================================================
# 
# 
# ## Create ASL directory in FreeSurfer subject directory
# if [ -d ${DIR}/${asldir} ]
# then
#     rm -rf ${DIR}/${asldir}/*
# else
#     mkdir ${DIR}/${asldir}
# fi
# 
# ## Convert T1.mgz from FS recon-all to file T1.nii in ASL directory 
# echo "mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/T1.nii.gz --out_orientation LAS"
# mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/T1.nii.gz --out_orientation LAS
# 
# ## Copy ASL nifti files to ASL directory and rename them
# Asl=$(ls ${INPUT_DIR}/${SUBJECT_ID}/*PCASLSENSE*.nii.gz)
# AslCorr=$(ls ${INPUT_DIR}/${SUBJECT_ID}/*PCASLCORRECTIONSENSE*.nii.gz)
# if [ -n "${Asl}" ]
# then
# 	echo "cp ${Asl} ${DIR}/${asldir}/asl.nii.gz"
# 	cp ${Asl} ${DIR}/${asldir}/asl.nii.gz
# else
# 	echo "ASL file does not exist"
# 	exit 1
# fi
# if [ -n "${AslCorr}" ]
# then
# 	echo "cp ${AslCorr} ${DIR}/${asldir}/asl_back.nii.gz"
# 	cp ${AslCorr} ${DIR}/${asldir}/asl_back.nii.gz
# else
# 	echo "ASLCorr file does not exist"
# 	exit 1
# fi
# 
# 
# # # =====================================================================================
# # #                        Distorsions Corrections and Re-order ASL data
# # # =====================================================================================
# 
# ## Estimate distorsions and apply corrections
# for_asl=${DIR}/${asldir}/asl.nii.gz
# rev_asl=${DIR}/${asldir}/asl_back.nii.gz
# distcor_asl=${DIR}/${asldir}/asl_distcor.nii.gz
# DCDIR=${DIR}/${asldir}/DC
# 
# if [ -e ${rev_asl} ]
# then
# 	# Estimate distortion corrections
# 	if [ ! -e ${DIR}/${asldir}/DC/aslC0_norm_unwarp.nii.gz ]
# 	then
# 		if [ ! -d ${DIR}/${asldir}/DC ]
# 		then
# 			mkdir ${DIR}/${asldir}/DC
# 		else
# 			rm -rf ${DIR}/${asldir}/DC/*
# 		fi
# 		echo "fslroi ${for_asl} ${DCDIR}/aslC0 0 1"
# 		fslroi ${for_asl} ${DCDIR}/aslC0 0 1
# 		echo "fslroi ${rev_asl} ${DCDIR}/aslC0_back 0 1"
# 		fslroi ${rev_asl} ${DCDIR}/aslC0_back 0 1
# 				
# 		gunzip -f ${DCDIR}/*gz
# 		# Shift the reverse DWI by 1 voxel AP
# 		# Only for Philips images, for *unknown* reason
# 		# Then LR-flip the image for CMTK
# 				
# 		matlab -nodisplay <<EOF
# 		cd ${DCDIR}
# 		V = spm_vol('aslC0_back.nii');
# 		Y = spm_read_vols(V);
# 		
# 		Y = circshift(Y, [0 -1 0]);
# 		V.fname = 'saslC0_back.nii';
# 		spm_write_vol(V,Y);
# 		
# 		Y = flipdim(Y, 1);
# 		V.fname = 'raslC0_back.nii';
# 		spm_write_vol(V,Y);
# EOF
# 
# 		# Normalize the signal
# 		S=`fslstats ${DCDIR}/aslC0.nii -m`
# 		fslmaths ${DCDIR}/aslC0.nii -div $S -mul 1000 ${DCDIR}/aslC0_norm -odt double
# 		
# 		S=`fslstats ${DCDIR}/raslC0_back.nii -m`
# 		fslmaths ${DCDIR}/raslC0_back.nii -div $S -mul 1000 ${DCDIR}/raslC0_back_norm -odt double
# 		
# 		# Launch CMTK
# 		echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 -x --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
# 		cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 -x --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/aslC0_norm.nii.gz ${DCDIR}/raslC0_back_norm.nii.gz ${DCDIR}/aslC0_norm_unwarp.nii ${DCDIR}/raslC0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
# 		
# 		gzip -f ${DCDIR}/*.nii
# 	fi
# 			
# 	# Apply distortion corrections to the whole ASL
# 	if [ ! -e ${DIR}/${asldir}/asl_distcor.nii.gz ]
# 	then
# 		echo "fslsplit ${for_asl} ${DCDIR}/voltmp -t"
# 		fslsplit ${for_asl} ${DCDIR}/voltmp -t
# 		
# 		for I in `ls ${DCDIR} | grep voltmp`
# 			do
# 			echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
# 			cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/aslC0_norm.nii.gz ${DCDIR}/dfield.nrrd
# 			
# 			echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
# 			cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
# 			
# 			rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
# 		done
# 				
# 		echo "fslmerge -t ${DIR}/${asldir}/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
# 		fslmerge -t ${DIR}/${asldir}/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
# 		
# 		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
# 		gzip -f ${DCDIR}/*.nii	
# 	fi
# fi
# 
# ## Re-order ASL data for FSL oxford_asl command : 0-tag 1-control
# if [ ! -d ${DIR}/${asldir}/split ]
# then
# 	mkdir ${DIR}/${asldir}/split
# else
# 	rm -f ${DIR}/${asldir}/split/*
# fi
# echo "fslsplit ${DIR}/${asldir}/asl_distcor.nii.gz ${DIR}/${asldir}/split/asl_ -t"
# fslsplit ${DIR}/${asldir}/asl_distcor.nii.gz ${DIR}/${asldir}/split/asl_ -t
# 
# AslNii=$(ls ${DIR}/${asldir}/split/asl_00*.nii.gz)
# IndexAsl=0
# 
# for asl in ${AslNii}
# do
# 	if [[ ${IndexAsl}%2 -eq 0 ]]
# 	then
# 		NIndexAsl=$[${IndexAsl}+1]
# 		echo "IndexAsl : ${IndexAsl} NIndexAsl : ${NIndexAsl}"
# 		if [ ${NIndexAsl} -ge 10 ]
# 		then		
# 			mv ${asl} ${DIR}/${asldir}/temp_00${NIndexAsl}.nii.gz
# 		else
# 			mv ${asl} ${DIR}/${asldir}/temp_000${NIndexAsl}.nii.gz
# 		fi
# 	else
# 		NIndexAsl=$[${IndexAsl}-1]
# 		echo "IndexAsl : ${IndexAsl} NIndexAsl : ${NIndexAsl}"
# 		if [ ${NIndexAsl} -ge 10 ]
# 		then
# 			mv ${asl} ${DIR}/${asldir}/temp_00${NIndexAsl}.nii.gz
# 		else
# 			mv ${asl} ${DIR}/${asldir}/temp_000${NIndexAsl}.nii.gz
# 		fi
# 	fi
# 	IndexAsl=$[${IndexAsl}+1]
# done
# 
# echo "fslmerge -t ${DIR}/${asldir}/rasl_distcor.nii.gz ${DIR}/${asldir}/temp_00*.nii.gz"
# fslmerge -t ${DIR}/${asldir}/rasl_distcor.nii.gz ${DIR}/${asldir}/temp_00*.nii.gz
# 
# echo "rm -f ${DIR}/${asldir}/temp_00*.nii.gz"
# rm -f ${DIR}/${asldir}/temp_00*.nii.gz
# 
# 
# # # =====================================================================================
# # #                                    Preprocess
# # # =====================================================================================
# 
# # # ------------------------------------------------------------------------
# # # Preprocess ASL data step 1 : Exclude first frames and motion correction
# # #-------------------------------------------------------------------------
# 
# rm -f ${DIR}/${asldir}/split/*
# 
# echo "fslsplit ${DIR}/${asldir}/rasl_distcor.nii.gz ${DIR}/${asldir}/split/ -t"
# fslsplit ${DIR}/${asldir}/rasl_distcor.nii.gz ${DIR}/${asldir}/split/ -t
# 
# ## Exclude first 4 frames
# echo "Exclude first 4 frames"
# for ((ind = 0; ind < ${remframe}; ind += 1))
# do
# 	filename=`ls -1 ${DIR}/${asldir}/split/ | sed -ne "1p"`
# 	rm -f ${DIR}/${asldir}/split/${filename}
# done
# 
# echo "fslmerge -t ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/split/*"
# fslmerge -t ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/split/*
# 
# ## Motion correct ASL acquisition
# fslmaths ${DIR}/${asldir}/asl.rem -Tmean ${DIR}/${asldir}/asl.rem_mean
# gunzip ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/asl.rem_mean.nii.gz
# mc-afni2 --i ${DIR}/${asldir}/asl.rem.nii --t ${DIR}/${asldir}/asl.rem_mean.nii --o ${DIR}/${asldir}/asl.rem.mc.nii --mcdat ${DIR}/${asldir}/asl.rem.mc.mcdat
# gzip ${DIR}/${asldir}/*.nii
# 
# # # ----------------------------------------------------------------------------------------------------------------
# # # Preprocess T1 image : N4 bias field correction, brain extraction, and normalization to skull-stripped template
# # #-----------------------------------------------------------------------------------------------------------------
# 
# # # Method 1 : only use of BET brain extraction
# # echo "${ANTSPATH}/N4BiasFieldCorrection -d 3 -i ${DIR}/${asldir}/T1.nii.gz -o ${DIR}/${asldir}/N4BFC_T1.nii.gz -s 4"
# # ${ANTSPATH}/N4BiasFieldCorrection -d 3 -i ${DIR}/${asldir}/T1.nii.gz -o ${DIR}/${asldir}/N4BFC_T1.nii.gz -s 4
# # 
# # echo "bet ${DIR}/${asldir}/N4BFC_T1.nii.gz ${DIR}/${asldir}/N4BFC_T1_brain.nii.gz -R -f 0.5 -m"
# # bet ${DIR}/${asldir}/N4BFC_T1.nii.gz ${DIR}/${asldir}/N4BFC_T1_brain.nii.gz -R -f 0.5 -m
# # 
# # echo "bet ${TEMPLATE_DIR}/T_template_3DT1.nii ${TEMPLATE_DIR}/T1_template_brain -R -f 0.5 -m"
# # bet ${TEMPLATE_DIR}/T_template_3DT1.nii ${TEMPLATE_DIR}/T1_template_brain -R -f 0.5 -m
# 
# ## Method 2 : use antsBrainExtraction.sh
# if [ ! -d ${DIR}/${asldir}/T1_preprocessing ]
# then
# 	mkdir ${DIR}/${asldir}/T1_preprocessing
# else
# 	rm -f ${DIR}/${asldir}/T1_preprocessing/*
# fi
# 
# BRAIN_EXTRACTION_MASK=${DIR}/${asldir}/T1_preprocessing/BrainExtractionMask.nii.gz
# 
# if [[ ! -f ${BRAIN_EXTRACTION_MASK} ]];
# then
#         logCmd ${ANTSPATH}/antsBrainExtraction.sh \
#           -d 3 \
#           -a ${DIR}/${asldir}/T1.nii.gz \
#           -e ${TEMPLATE_DIR}/T_template_3DT1.nii \
#           -m ${TEMPLATE_DIR}/T_templateProbabilityMask.nii.gz \
#           -o ${DIR}/${asldir}/T1_preprocessing/ \
#           -k 0 \
#           -s nii.gz \
#           -q 0 \
#           -u 1 \
#           -z 0
# fi
# 
# # ## Run N4BiasFieldCorrection
# # ${ANTSPATH}/N4BiasFieldCorrection -d 3 -i ${DIR}/${asldir}/T1.nii.gz -o ${DIR}/${asldir}/T1_preprocessing/N4BFC_T1.nii.gz -s 4
# # fslmaths ${DIR}/${asldir}/T1_preprocessing/N4BFC_T1.nii.gz -mul ${BRAIN_EXTRACTION_MASK} ${DIR}/${asldir}/T1_preprocessing/N4BFC_T1_brain.nii.gz
# 
# ## Registration to a template
# 
# # These affect output; keep them consistent with usage function
# REGISTRATION_TEMPLATE_OUTPUT_PREFIX=${DIR}/${asldir}/T1_preprocessing/SubjectToTemplate
# REGISTRATION_TEMPLATE_GENERIC_AFFINE=${REGISTRATION_TEMPLATE_OUTPUT_PREFIX}0GenericAffine.mat
# REGISTRATION_TEMPLATE_WARP=${REGISTRATION_TEMPLATE_OUTPUT_PREFIX}1Warp.nii.gz
# REGISTRATION_TEMPLATE_INVERSE_WARP=${REGISTRATION_TEMPLATE_OUTPUT_PREFIX}1InverseWarp.nii.gz
# 
# # Want to have transforms for both directions
# REGISTRATION_SUBJECT_OUTPUT_PREFIX=${DIR}/${asldir}/T1_preprocessing/TemplateToSubject
# REGISTRATION_SUBJECT_GENERIC_AFFINE=${REGISTRATION_SUBJECT_OUTPUT_PREFIX}1GenericAffine.mat
# REGISTRATION_SUBJECT_WARP=${REGISTRATION_SUBJECT_OUTPUT_PREFIX}0Warp.nii.gz
# 
# if [[ -f ${TEMPLATE_DIR}/T_templateSkullStripped.nii.gz ]];
#   then
# 
#     echo
#     echo "------------------------------------------------------------------------------------------------------------------------------"
#     echo " Registration ${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain.nii.gz to ${TEMPLATE_DIR}/T_templateSkullStripped.nii.gz "
#     echo "------------------------------------------------------------------------------------------------------------------------------"
#     echo
# 
#     time_start_template_registration=`date +%s`
# 
#     basecall=''
#     
#     IMAGES="${TEMPLATE_DIR}/T_templateSkullStripped.nii.gz,${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain.nii.gz"
#     basecall="${ANTSPATH}/antsRegistration -d 3 -u 1 -w [0.01,0.99] -o ${REGISTRATION_TEMPLATE_OUTPUT_PREFIX} -r [${IMAGES},1] --float 0"
#     stage1="-m MI[${IMAGES},${ANTS_LINEAR_METRIC_PARAMS}] -c ${ANTS_LINEAR_CONVERGENCE} -t Rigid[0.1] -f 8x4x2x1 -s 3x2x1x0"
#     stage2="-m MI[${IMAGES},${ANTS_LINEAR_METRIC_PARAMS}] -c ${ANTS_LINEAR_CONVERGENCE} -t Affine[0.1] -f 8x4x2x1 -s 3x2x1x0"
#     stage3="-m CC[${IMAGES},1,4] -c [${ANTS_MAX_ITERATIONS},1e-9,15] -t ${ANTS_TRANSFORMATION} -f 6x4x2x1 -s 3x2x1x0"
#     basecall="${basecall} ${stage1} ${stage2} ${stage3}"
#     
#     exe_template_registration_1="${basecall}"
# 
#     if [[ ! -f ${REGISTRATION_TEMPLATE_WARP} ]];
#       then
#         logCmd $exe_template_registration_1
#       fi
# 
#     ## check to see if the output registration transforms exist
#     if [[ ! -f ${REGISTRATION_TEMPLATE_GENERIC_AFFINE} ]];
#       then
#         echo "The registration component of the segmentation step didn't complete properly."
#         echo "The transform file ${REGISTRATION_TEMPLATE_GENERIC_AFFINE} does not exist."
#         exit 1
#       fi
# 
#     if [[ ! -f ${REGISTRATION_TEMPLATE_WARP} ]];
#       then
#         echo "The registration component of the segmentation step didn't complete properly."
#         echo "The transform file ${REGISTRATION_TEMPLATE_WARP} does not exist."
#         exit 1
#       fi
# 
#     ## Create symmetric transforms for template to subject warping
#     if [[ -s ${REGISTRATION_TEMPLATE_INVERSE_WARP} ]] && [[ ! -s ${REGISTRATION_SUBJECT_WARP} ]] ; then 
#       logCmd mv ${REGISTRATION_TEMPLATE_INVERSE_WARP} ${REGISTRATION_SUBJECT_WARP}
#     fi
#     if [[ ! -s  ${REGISTRATION_SUBJECT_WARP} ]] ; then
#       echo "The transform file ${REGISTRATION_SUBJECT_WARP} does not exist."
#       exit 1      
#     fi
#     logCmd ${ANTSPATH}/antsApplyTransforms -d 3 -o Linear[$REGISTRATION_SUBJECT_GENERIC_AFFINE,1] -t $REGISTRATION_TEMPLATE_GENERIC_AFFINE
# 
#     time_end_template_registration=`date +%s`
#     time_elapsed_template_registration=$((time_end_template_registration - time_start_template_registration))
# 
#     echo
#     echo "--------------------------------------------------------------------------------------"
#     echo " Done with registration:  $(( time_elapsed_template_registration / 3600 ))h $(( time_elapsed_template_registration %3600 / 60 ))m $(( time_elapsed_template_registration % 60 ))s"
#     echo "--------------------------------------------------------------------------------------"
#     echo
# fi
# 
# # # ---------------------------------------------------------------------------
# # # Preprocess ASL data step 2 : registration of preprocessed ASL data to T1
# # #----------------------------------------------------------------------------
# 
#### Using ANTs method for registration ####
# ## Registration of skull-stripped asl.rem.mc_mean to T1Proc_BrainExtractionBrain
# fslmaths ${DIR}/${asldir}/asl.rem.mc -Tmean ${DIR}/${asldir}/asl.rem.mc_mean
# 
# echo "bet ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz ${DIR}/${asldir}/pCASL_brain -R -m -f 0.5"
# bet ${DIR}/${asldir}/asl.rem.mc_mean ${DIR}/${asldir}/pCASL_brain -R -m -f 0.5
# 
# if [ ! -d ${DIR}/${asldir}/ASL_T1_registration ]
# then
# 	mkdir ${DIR}/${asldir}/ASL_T1_registration
# else
# 	rm -f ${DIR}/${asldir}/ASL_T1_registration/*
# fi
# 
# ${ANTSPATH}/ResampleImageBySpacing 3 ${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain.nii.gz ${DIR}/${asldir}/ASL_T1_registration/T1_downsample_brain.nii.gz 2.0 2.0 2.0
# INTERSUBJECT_PARAMS=" -d 3 -i ${DIR}/${asldir}/pCASL_brain.nii.gz -r ${DIR}/${asldir}/ASL_T1_registration/T1_downsample_brain.nii.gz -R ${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain.nii.gz -x ${BRAIN_EXTRACTION_MASK} -w ${REGISTRATION_TEMPLATE_OUTPUT_PREFIX} -t 2 -o ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_ -T ${TEMPLATE_DIR}/T_templateSkullStripped.nii.gz "
# ${ANTSPATH}/antsIntermodalityIntrasubject.sh $INTERSUBJECT_PARAMS

#### Using bbregister method for registration ####
SUBJECTS_DIR=${FS_DIR}

if [ ! -d ${DIR}/${asldir}/bbr ]
then
	mkdir ${DIR}/${asldir}/bbr
else
	rm -Rf ${DIR}/${asldir}/bbr/*
fi

## Estimate registration 6-dof ASL onto T1 
bbregister  --s ${SUBJECT_ID} --init-fsl --t2 --mov ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz --reg ${DIR}/${asldir}/bbr/Perf2T1.register.dof6.dat \
--init-reg-out ${DIR}/${asldir}/bbr/Perf2T1.BS7.init.register.dof6.dat --o ${DIR}/${asldir}/bbr/rasl.rem.mc_mean.nii.gz > ${DIR}/${asldir}/bbr/bbregister_log.txt
    
# # =====================================================================================
# #                    Compute perfusion, CBF and PVC-CBF maps
# # =====================================================================================

# ## Get the control images
# rm -f ${DIR}/${asldir}/split/*
# 
# fslsplit ${DIR}/${asldir}/asl.rem.mc.nii.gz ${DIR}/${asldir}/split/asl -t
# 
# fslmerge -t ${DIR}/${asldir}/control.nii.gz ${DIR}/${asldir}/split/asl00{01..55..2}.nii.gz
# 
# AslControlNii=$(ls ${DIR}/${asldir}/split/asl00{01..55..2}.nii.gz)
# Index=0
# IndexTag=0
# 
# ## Compute perfusion images
# for asl in ${AslControlNii}
# do
# 	if [ ${IndexTag} -ge 10 ]
# 	then		
# 		if [ ${Index} -ge 10 ]
# 		then
# 			fslmaths ${asl} -sub ${DIR}/${asldir}/split/asl00${IndexTag}.nii.gz ${DIR}/${asldir}/split/perf00${Index}.nii.gz
# 		else
# 			fslmaths ${asl} -sub ${DIR}/${asldir}/split/asl00${IndexTag}.nii.gz ${DIR}/${asldir}/split/perf000${Index}.nii.gz
# 		fi
# 	else
# 		fslmaths ${asl} -sub ${DIR}/${asldir}/split/asl000${IndexTag}.nii.gz ${DIR}/${asldir}/split/perf000${Index}.nii.gz
# 	fi
# 	Index=$[${Index}+1]
# 	IndexTag=$[${IndexTag}+2]
# done
# 
# fslmerge -t ${DIR}/${asldir}/diffdata.nii.gz ${DIR}/${asldir}/split/perf*.nii.gz
# 
# fslmaths ${DIR}/${asldir}/diffdata.nii.gz -Tmean ${DIR}/${asldir}/diffdata_mean.nii.gz
# 
# fslmaths ${DIR}/${asldir}/diffdata_mean.nii.gz -nan ${DIR}/${asldir}/diffdata_mean.nii.gz

# ## Skull-strip control images for calibration and registration
# 
# # # Use BET to extract the control images
# # rm -f ${DIR}/${asldir}/split/*
# # 
# # fslsplit ${DIR}/${asldir}/control.nii.gz ${DIR}/${asldir}/split/control_ -t
# # 
# # for ctrl in $(ls ${DIR}/${asldir}/split/control_*.nii.gz)
# # do
# # 	base=`basename ${ctrl}`
# # 	base=${base%.nii.gz}
# # 	
# # 	echo "bet ${ctrl} ${DIR}/${asldir}/split/${base}_brain -f 0.5 -R"
# # 	bet ${ctrl} ${DIR}/${asldir}/split/${base}_brain -f 0.5 -R
# # done
# # fslmerge -t ${DIR}/${asldir}/control_brain.nii.gz ${DIR}/${asldir}/control/control_*_brain.nii.gz

# #### Using ANTs method for registration ####
# 
# # Use ASL_T1_brainmask to skull-strip the control images
# fslmaths ${DIR}/${asldir}/control.nii.gz -mul ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_brainmask.nii.gz ${DIR}/${asldir}/control_brain.nii.gz
# 
# # Use ASL_T1_brainmask to skull-strip the asl.rem.mc_mean image
# fslmaths ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz -mul ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_brainmask.nii.gz ${DIR}/${asldir}/asl.rem.mc_mean_brain.nii.gz
# 
# ## Compute smoothed cbf images without partial volume correction
# bash oxford_asl -i ${DIR}/${asldir}/diffdata -o ${DIR}/${asldir}/cbf_smooth --tis 3.175 --bolus 1.650 --casl -c ${DIR}/${asldir}/control_brain -s ${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain --tr 4.05 --te 14 --regfrom ${DIR}/${asldir}/asl.rem.mc_mean_brain --spatial
# 
# ## Compute smoothed cbf images with partial volume correction
# bash oxford_asl -i ${DIR}/${asldir}/diffdata -o ${DIR}/${asldir}/cbf_pvc_smooth --tis 3.175 --bolus 1.650 --casl -c ${DIR}/${asldir}/control_brain -s ${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain --tr 4.05 --te 14 --regfrom ${DIR}/${asldir}/asl.rem.mc_mean_brain --spatial --pvcorr 

#### Using bbregister method for registration ####

mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/bbr/T1.las.nii.gz --out_orientation LAS

## N4 Correction (pre brain extraction)
echo
echo "--------------------------------------------------------------------------------------"
echo " Bias correction of anatomical images (pre brain extraction)"
echo "   1) pre-process by truncating the image intensities"
echo "   2) run N4"
echo "--------------------------------------------------------------------------------------"
echo

time_start_n4_correction=`date +%s`
  
DIMENSION=3
OUTPUT_PREFIX=${DIR}/${asldir}/bbr/T1_
OUTPUT_SUFFIX="nii.gz"
N4=${ANTSPATH}/N4BiasFieldCorrection
N4_CONVERGENCE_1="[50x50x50x50,0.0000001]"
N4_SHRINK_FACTOR_1=4
N4_BSPLINE_PARAMS="[200]"
    
N4_TRUNCATED_IMAGE=${OUTPUT_PREFIX}N4Truncated.${OUTPUT_SUFFIX}
N4_CORRECTED_IMAGE=${OUTPUT_PREFIX}N4Corrected.${OUTPUT_SUFFIX}

if [[ ! -f ${N4_CORRECTED_IMAGE} ]];
then
	logCmd ${ANTSPATH}/ImageMath ${DIMENSION} ${N4_TRUNCATED_IMAGE} TruncateImageIntensity ${DIR}/${asldir}/bbr/T1.las.nii.gz 0.01 0.999 256

        exe_n4_correction="${N4} -d ${DIMENSION} -i ${N4_TRUNCATED_IMAGE} -s ${N4_SHRINK_FACTOR_1} -c ${N4_CONVERGENCE_1} -b ${N4_BSPLINE_PARAMS} -o ${N4_CORRECTED_IMAGE} --verbose 1"
        logCmd $exe_n4_correction
fi
          
time_end_n4_correction=`date +%s`
time_elapsed_n4_correction=$((time_end_n4_correction - time_start_n4_correction))

echo
echo "--------------------------------------------------------------------------------------"
echo " Done with N4 correction (pre brain extraction):  $(( time_elapsed_n4_correction / 3600 ))h $(( time_elapsed_n4_correction %3600 / 60 ))m $(( time_elapsed_n4_correction % 60 ))s"
echo "--------------------------------------------------------------------------------------"
echo

## Use BET to extract skull-stripped T1_N4Corrected.nii.gz
# mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/bbr/T1.las.nii.gz --out_orientation LAS
bet ${N4_CORRECTED_IMAGE} ${DIR}/${asldir}/bbr/T1.las.brain -f 0.3 -R -m

# Use BET T1 mask to extract skull-stripped ASL data
# mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/bbr/T1.lia.nii.gz
# bet  ${DIR}/${asldir}/bbr/T1.lia.nii.gz ${DIR}/${asldir}/bbr/T1.lia.brain -f 0.3 -R -m
# # mri_morphology ${DIR}/${asldir}/bbr/T1.las.brain_mask.nii.gz dilate 1 ${DIR}/${asldir}/bbr/T1.las.brain_mask.dil.nii.gz
# mri_vol2vol --mov ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz --targ ${DIR}/${asldir}/bbr/T1.lia.brain_mask.nii.gz --o ${DIR}/${asldir}/bbr/rT1.las.brain_mask.nii.gz --inv --reg ${DIR}/${asldir}/bbr/Perf2T1.register.dof6.dat --no-save-reg --nearest

# # Use brainmask.mgz to extract skull-stripped T1
# mri_convert --i ${DIR}/mri/brainmask.mgz ${DIR}/${asldir}/bbr/T1.las.brain.nii.gz --out_orientation LAS
# # mri_binarize --i ${DIR}/mri/brainmask.mgz --min 0.001 --o ${DIR}/${asldir}/bbr/T1.lia.brain_mask.nii.gz
# # mri_vol2vol --mov ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz --targ ${DIR}/${asldir}/bbr/T1.lia.brain_mask.nii.gz --o ${DIR}/${asldir}/bbr/rT1.las.brain_mask.nii.gz --inv --reg ${DIR}/${asldir}/bbr/Perf2T1.register.dof6.dat --no-save-reg --nearest

## Use pCASL_brain_mask.nii.gz to skull-strip the control images
fslmaths ${DIR}/${asldir}/control.nii.gz -mul ${DIR}/${asldir}/pCASL_brain_mask.nii.gz ${DIR}/${asldir}/bbr/control_brain.nii.gz
# fslmaths ${DIR}/${asldir}/control.nii.gz -mul ${DIR}/${asldir}/bbr/rT1.las.brain_mask.nii.gz ${DIR}/${asldir}/bbr/control_brain.nii.gz

## Use pCASL_brain_mask.nii.gz to skull-strip the asl.rem.mc_mean.nii.gz
fslmaths ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz -mul ${DIR}/${asldir}/pCASL_brain_mask.nii.gz ${DIR}/${asldir}/bbr/asl.rem.mc_mean_brain.nii.gz
# fslmaths ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz -mul ${DIR}/${asldir}/bbr/rT1.las.brain_mask.nii.gz ${DIR}/${asldir}/bbr/asl.rem.mc_mean_brain.nii.gz

## Compute smoothed cbf images without partial volume correction
bash oxford_asl -i ${DIR}/${asldir}/diffdata -o ${DIR}/${asldir}/bbr/cbf_s --tis 3.175 --bolus 1.650 --casl -c ${DIR}/${asldir}/bbr/control_brain -s ${DIR}/${asldir}/bbr/T1.las.brain --tr 4.05 --te 14 --regfrom ${DIR}/${asldir}/bbr/asl.rem.mc_mean_brain --spatial

## Compute smoothed cbf images with partial volume correction
bash oxford_asl -i ${DIR}/${asldir}/diffdata -o ${DIR}/${asldir}/bbr/cbf_pvc_s --tis 3.175 --bolus 1.650 --casl -c ${DIR}/${asldir}/bbr/control_brain -s ${DIR}/${asldir}/bbr/T1.las.brain --tr 4.05 --te 14 --regfrom ${DIR}/${asldir}/bbr/asl.rem.mc_mean_brain --spatial --pvcorr

## Apply cbf_pvc_s registration onto T1
mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/bbr/T1.lia.nii.gz
mri_vol2vol --mov ${DIR}/${asldir}/bbr/cbf_pvc_s/native_space/perfusion_calib.nii.gz --reg ${DIR}/${asldir}/bbr/Perf2T1.register.dof6.dat --targ ${DIR}/${asldir}/bbr/T1.lia.nii.gz --o ${DIR}/${asldir}/bbr/rcbf_pvc_s.nii.gz  --no-save-reg --trilin

# # # =====================================================================================
# # #         Compute Warped perfusion, CBF and PVC-CBF to T1 subject and template
# # # =====================================================================================
# 
# if [ ! -d ${DIR}/${asldir}/Surface_Analyses ]
# then
# 	mkdir ${DIR}/${asldir}/Surface_Analyses
# else
# 	rm -f ${DIR}/${asldir}/Surface_Analyses/*
# fi
# 
# # Use ASL_T1_brainmask to skull-strip the perfusion mean
# fslmaths ${DIR}/${asldir}/diffdata_mean.nii.gz -mul ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_brainmask.nii.gz ${DIR}/${asldir}/diffdata_mean_brain.nii.gz
# 
# ## Warp on T1 subject
# ${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-i ${DIR}/${asldir}/diffdata_mean_brain.nii.gz \
# 	-r ${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain.nii.gz \
# 	-o ${DIR}/${asldir}/Surface_Analyses/perfusion_brain.nii.gz \
# 	-n Linear \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_0GenericAffine.mat
# 	
# ${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-i ${DIR}/${asldir}/cbf_smooth/native_space/perfusion_calib.nii.gz \
# 	-r ${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain.nii.gz \
# 	-o ${DIR}/${asldir}/Surface_Analyses/cbf_s.nii.gz \
# 	-n Linear \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_0GenericAffine.mat
# 	
# ${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-i ${DIR}/${asldir}/cbf_pvc_smooth/native_space/perfusion_calib.nii.gz \
# 	-r ${DIR}/${asldir}/T1_preprocessing/BrainExtractionBrain.nii.gz \
# 	-o ${DIR}/${asldir}/Surface_Analyses/cbf_pvc_s.nii.gz \
# 	-n Linear \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_0GenericAffine.mat
# 
# if [ ! -d ${DIR}/${asldir}/Volumetric_Analyses ]
# then
# 	mkdir ${DIR}/${asldir}/Volumetric_Analyses
# else
# 	rm -f ${DIR}/${asldir}/VolumetriSUBJECTS_DIRc_Analyses/*
# fi
# 
# ## Warp on T1 template
# ${ANTSPATH}antsApplyTransforms -d 3 \
# 	-i ${DIR}/${asldir}/diffdata_mean_brain.nii.gz \
# 	-r ${TEMPLATE_DIR}/T_templateSkullStripped.nii.gz \
# 	-o ${DIR}/${asldir}/Volumetric_Analyses/perfusion_brain.nii.gz \
# 	-n Linear \
# 	-t ${DIR}/${asldir}/T1_preprocessing/SubjectToTemplate1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/T1_preprocessing/SubjectToTemplate0GenericAffine.mat \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_0GenericAffine.mat 
# 
# ${ANTSPATH}antsApplyTransforms -d 3 \
# 	-i ${DIR}/${asldir}/cbf_smooth/native_space/perfusion_calib.nii.gz \
# 	-r ${TEMPLATE_DIR}/T_templateSkullStripped.nii.gz \
# 	-o ${DIR}/${asldir}/Volumetric_Analyses/cbf_s.nii.gz \
# 	-n Linear \
# 	-t ${DIR}/${asldir}/T1_preprocessing/SubjectToTemplate1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/T1_preprocessing/SubjectToTemplate0GenericAffine.mat \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_0GenericAffine.mat 
# 
# ${ANTSPATH}antsApplyTransforms -d 3 \
# 	-i ${DIR}/${asldir}/cbf_pvc_smooth/native_space/perfusion_calib.nii.gz \
# 	-r ${TEMPLATE_DIR}/T_templateSkullStripped.nii.gz \
# 	-o ${DIR}/${asldir}/Volumetric_Analyses/cbf_pvc_s.nii.gz \
# 	-n Linear \
# 	-t ${DIR}/${asldir}/T1_preprocessing/SubjectToTemplate1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/T1_preprocessing/SubjectToTemplate0GenericAffine.mat \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_1Warp.nii.gz \
# 	-t ${DIR}/${asldir}/ASL_T1_registration/ASL_T1_0GenericAffine.mat 
	
# =======================================================================================
#  Project ASL based data warped to T1 on fsaverage surface : FWHM=[0,3,6,9,12,15,18]
# =======================================================================================

# #### Using ANTs method for registration ####
# 
# ## First method : projection on white fsaverage surface with projfrac = 0.5 ##
# 
# echo "mri_morphology ${DIR}/${asldir}/T1_preprocessing/BrainExtractionMask.nii.gz dilate 1 ${DIR}/${asldir}/T1_preprocessing/BrainExtractionMask_dil.nii.gz" 
# mri_morphology ${DIR}/${asldir}/T1_preprocessing/BrainExtractionMask.nii.gz dilate 1 ${DIR}/${asldir}/T1_preprocessing/BrainExtractionMask_dil.nii.gz
# 
# # Assign new value of SUBJECTS_DIR
# SUBJECTS_DIR=${FS_DIR}
# 
# # Project T1 brain mask on fsaverage
# mri_vol2surf --mov ${DIR}/${asldir}/T1_preprocessing/BrainExtractionMask_dil.nii.gz --regheader ${SUBJECT_ID} --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/${asldir}/Surface_Analyses/brain.fsaverage.lh.mgh --noreshape --cortex --surfreg sphere.reg
# mri_vol2surf --mov ${DIR}/${asldir}/T1_preprocessing/BrainExtractionMask_dil.nii.gz --regheader ${SUBJECT_ID} --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/${asldir}/Surface_Analyses/brain.fsaverage.rh.mgh --noreshape --cortex --surfreg sphere.reg
# 
# # Project ASL based data warped to T1 on fsaverage surface and smooth
# for var in perfusion_brain cbf_s cbf_pvc_s
# do
# 	mri_vol2surf --mov ${DIR}/${asldir}/Surface_Analyses/${var}.nii.gz --regheader ${SUBJECT_ID} --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${asldir}/Surface_Analyses/lh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
# 	mri_vol2surf --mov ${DIR}/${asldir}/Surface_Analyses/${var}.nii.gz --regheader ${SUBJECT_ID} --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${asldir}/Surface_Analyses/rh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
# 
# # 	for FWHM in 0 3 6 9 10 12 15
# 	for FWHM in 5
# 	do
# 		mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${asldir}/Surface_Analyses/lh.fsaverage.${var}.mgh --fwhm ${FWHM} --o ${DIR}/${asldir}/Surface_Analyses/lh.fwhm${FWHM}.fsaverage.${var}.mgh --mask ${DIR}/${asldir}/Surface_Analyses/brain.fsaverage.lh.mgh
# 		mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${asldir}/Surface_Analyses/rh.fsaverage.${var}.mgh --fwhm ${FWHM} --o ${DIR}/${asldir}/Surface_Analyses/rh.fwhm${FWHM}.fsaverage.${var}.mgh --mask ${DIR}/${asldir}/Surface_Analyses/brain.fsaverage.rh.mgh
# 	done	
# done
# 
# # # Smooth thickness on fsaverage
# # mri_surf2surf --s fsaverage --hemi lh --fwhm 3 --sval ${DIR}/surf/lh.thickness.fsaverage.mgh --tval ${DIR}/surf/lh.thickness.fwhm3.fsaverage.mgh --cortex
# # mri_surf2surf --s fsaverage --hemi rh --fwhm 3 --sval ${DIR}/surf/rh.thickness.fsaverage.mgh --tval ${DIR}/surf/rh.thickness.fwhm3.fsaverage.mgh --cortex

# ## Second method : projection on mid fsaverage surface ##
# 
# # rm -f ${DIR}/surf/lh.mid ${DIR}/surf/rh.mid
# # 
# # matlab -nodisplay <<EOF
# # 	% Load Matlab Path
# # 	cd ${HOME}
# # 	p = pathdef;
# # 	addpath(p);
# # 	cd ${DIR}
# # 	 
# # 	inner_surf = SurfStatReadSurf('${DIR}/surf/lh.white');
# # 	outer_surf = SurfStatReadSurf('${DIR}/surf/lh.pial');
# # 
# # 	mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
# # 	mid_surf.tri = inner_surf.tri;
# # 
# # 	freesurfer_write_surf('${DIR}/surf/lh.mid', mid_surf.coord', mid_surf.tri);
# # 
# # 	inner_surf = SurfStatReadSurf('${DIR}/surf/rh.white');
# # 	outer_surf = SurfStatReadSurf('${DIR}/surf/rh.pial');
# # 
# # 	mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
# # 	mid_surf.tri = inner_surf.tri;
# # 
# # 	freesurfer_write_surf('${DIR}/surf/rh.mid', mid_surf.coord', mid_surf.tri);
# # EOF
# # 
# # for var in perfusion cbf cbf_pvc perfusion_brain cbf_s cbf_pvc_s
# # do
# # 	mri_vol2surf --mov ${DIR}/${asldir}/Surface_Analyses/${var}.nii.gz  --hemi lh --surf mid --o ${DIR}/${asldir}/Surface_Analyses_v2/lh.fsaverage.${var}.mgh --regheader ${SUBJECT_ID} --trgsubject fsaverage --cortex
# # 	mri_vol2surf --mov ${DIR}/${asldir}/Surface_Analyses/${var}.nii.gz  --hemi rh --surf mid --o ${DIR}/${asldir}/Surface_Analyses_v2/rh.fsaverage.${var}.mgh --regheader ${SUBJECT_ID} --trgsubject fsaverage --cortex
# # 
# # 	for FWHM in 0 3 6 9 12 15 18
# # 	do
# # 		mri_surf2surf --hemi lh --s fsaverage --sval ${DIR}/${asldir}/Surface_Analyses_v2/lh.fsaverage.${var}.mgh --fwhm ${FWHM} --cortex --tval ${DIR}/${asldir}/Surface_Analyses_v2/lh.fwhm${FWHM}.fsaverage.${var}.mgh
# # 		mri_surf2surf --hemi rh --s fsaverage --sval ${DIR}/${asldir}/Surface_Analyses_v2/rh.fsaverage.${var}.mgh --fwhm ${FWHM} --cortex --tval ${DIR}/${asldir}/Surface_Analyses_v2/rh.fwhm${FWHM}.fsaverage.${var}.mgh
# # 	done
# # done

# ## Projection of Surface_Analyses/cbf_s on white anatomical surface for LTLE and RTLE patients ##
# if [ ! -d ${DIR}/xhemi ]
# then
# 	echo "${DIR}/xhemi existe"
# fi

#### Using bbregister method for registration ####

if [ ! -d ${DIR}/${asldir}/bbr/Surface_Analyses ]
then
	mkdir ${DIR}/${asldir}/bbr/Surface_Analyses
else
	rm -f ${DIR}/${asldir}/bbr/Surface_Analyses/*
fi

# Project ASL data on fsaverage surface and smooth
for var in cbf_s cbf_pvc_s
do
	## Resample onto fsaverage
	mri_vol2surf --mov ${DIR}/${asldir}/bbr/${var}/native_space/perfusion_calib.nii.gz --reg ${DIR}/${asldir}/bbr/Perf2T1.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${asldir}/bbr/Surface_Analyses/lh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg
	mri_vol2surf --mov ${DIR}/${asldir}/bbr/${var}/native_space/perfusion_calib.nii.gz --reg ${DIR}/${asldir}/bbr/Perf2T1.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${asldir}/bbr/Surface_Analyses/rh.fsaverage.${var}.mgh --noreshape --cortex --surfreg sphere.reg

	# smooth
	for FWHM in 0 3 5 10 12
	do
		mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${asldir}/bbr/Surface_Analyses/lh.fsaverage.${var}.mgh --fwhm ${FWHM} --o ${DIR}/${asldir}/bbr/Surface_Analyses/lh.fwhm${FWHM}.fsaverage.${var}.mgh --cortex
		mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${asldir}/bbr/Surface_Analyses/rh.fsaverage.${var}.mgh --fwhm ${FWHM} --o ${DIR}/${asldir}/bbr/Surface_Analyses/rh.fwhm${FWHM}.fsaverage.${var}.mgh --cortex
	done	
done

# # # ====================================================================================
# # # 	Smooth volumetric ASL based data warped on T1 template (FWHM=[0,3,6,9,12,15,18])
# # # ====================================================================================
# 
# for fwhmvol in 0 3 6 9 10 12 15
# do
# 	Sigma=`echo "${fwhmvol} / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
# 	
# 	fslmaths ${DIR}/${asldir}/Volumetric_Analyses/perfusion_brain.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/${asldir}/Volumetric_Analyses/s${fwhmvol}_perfusion_brain.nii.gz
# 	fslmaths ${DIR}/${asldir}/Volumetric_Analyses/cbf_s.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/${asldir}/Volumetric_Analyses/s${fwhmvol}_cbf_s.nii.gz
# 	fslmaths ${DIR}/${asldir}/Volumetric_Analyses/cbf_pvc_s.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/${asldir}/Volumetric_Analyses/s${fwhmvol}_cbf_pvc_s.nii.gz
# done
# 
# gunzip ${DIR}/${asldir}/Volumetric_Analyses/*.nii.gz
# 
# rm -rf ${DIR}/${asldir}/split/