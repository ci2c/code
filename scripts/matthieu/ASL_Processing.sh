#!/bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage:  ASL_Processing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
	echo ""
	echo "	-id		: Input directory containing raw subjects data "
	echo "  -sd		: FS5.3 subjects directory "
	echo "  -subj       	: Subject name "
	echo "  -tpdir       	: Directory containing the T1 template "
	echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
	echo ""
	echo "Usage:  ASL_Processing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - November 2016"
	echo ""
	exit 1
fi

index=1
# ANTSPATH=/home/matthieu/programs/CodeANTs/bin/ants/bin/

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  ASL_Processing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
		echo ""
		echo "	-id		: Input directory containing raw subjects data "
		echo "  -sd		: FS5.3 subjects directory "
		echo "  -subj       	: Subject name "
		echo "  -tpdir       	: Directory containing the T1 template "
		echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
		echo ""
		echo "Usage:  ASL_Processing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - November 2016"
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
		echo "Usage:  ASL_Processing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
		echo ""
		echo "	-id		: Input directory containing raw subjects data "
		echo "  -sd		: FS5.3 subjects directory "
		echo "  -subj       	: Subject name "
		echo "  -tpdir       	: Directory containing the T1 template "
		echo "  -wd       	: Working directory name of the subject ASL data pre and post processing "
		echo ""
		echo "Usage:  ASL_Processing.sh  -id <inputdir> -sd <path> -subj <patientname> -tpdir <T1templatedir> -wd <asldirname>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - November 2016"
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
#export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
#. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

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
DIR=${FS_DIR}/${SUBJECT_ID}

# # =====================================================================================
# #                                 Prepare ASL data
# # =====================================================================================


## Create ASL directory in FreeSurfer subject directory
if [ -d ${DIR}/${asldir} ]
then
    rm -rf ${DIR}/${asldir}/*
else
    mkdir ${DIR}/${asldir}
fi

## Convert T1.mgz from FS recon-all to file T1.nii in ASL directory 
echo "mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/T1.nii.gz --out_orientation LAS"
mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/T1.nii.gz --out_orientation LAS

## Copy ASL nifti files to ASL directory and rename them
Asl=$(ls ${INPUT_DIR}/${SUBJECT_ID}/*PCASLSENSE*.nii.gz)

if [ -n "${Asl}" ]
then
    echo "ASL file ok"
else
    Asl=$(ls ${INPUT_DIR}/${SUBJECT_ID}/*PCASLCACPSENSE*.nii.gz)
fi

if [ -n "${Asl}" ]
then
	echo "cp ${Asl} ${DIR}/${asldir}/asl.nii.gz"
	cp ${Asl} ${DIR}/${asldir}/asl.nii.gz
else
	echo "ASL file does not exist"
	exit 1
fi

AslCorr=$(ls ${INPUT_DIR}/${SUBJECT_ID}/*PCASLCORRECTIONSENSE*.nii.gz)

if [ -n "${AslCorr}" ]
then
	echo "cp ${AslCorr} ${DIR}/${asldir}/asl_back.nii.gz"
	cp ${AslCorr} ${DIR}/${asldir}/asl_back.nii.gz
else
	echo "ASLCorr file does not exist"
        #exit 1
fi

# # =====================================================================================
# #                        Distorsions Corrections and Re-order ASL data
# # =====================================================================================

## Estimate distorsions and apply corrections
for_asl=${DIR}/${asldir}/asl.nii.gz
rev_asl=${DIR}/${asldir}/asl_back.nii.gz
distcor_asl=${DIR}/${asldir}/asl_distcor.nii.gz
DCDIR=${DIR}/${asldir}/DC

if [ -e ${rev_asl} ]
then
	# Estimate distortion corrections
	if [ ! -e ${DIR}/${asldir}/DC/aslC0_norm_unwarp.nii.gz ]
	then
		if [ ! -d ${DIR}/${asldir}/DC ]
		then
			mkdir ${DIR}/${asldir}/DC
		else
			rm -rf ${DIR}/${asldir}/DC/*
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
	if [ ! -e ${DIR}/${asldir}/asl_distcor.nii.gz ]
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
				
		echo "fslmerge -t ${DIR}/${asldir}/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
		fslmerge -t ${DIR}/${asldir}/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
		
		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
		gzip -f ${DCDIR}/*.nii	
	fi
else
    cp ${DIR}/${asldir}/asl.nii.gz ${DIR}/${asldir}/asl_distcor.nii.gz
fi

## Re-order ASL data for FSL oxford_asl command : 0-tag 1-control
if [ ! -d ${DIR}/${asldir}/split ]
then
	mkdir ${DIR}/${asldir}/split
else
	rm -f ${DIR}/${asldir}/split/*
fi
echo "fslsplit ${DIR}/${asldir}/asl_distcor.nii.gz ${DIR}/${asldir}/split/asl_ -t"
fslsplit ${DIR}/${asldir}/asl_distcor.nii.gz ${DIR}/${asldir}/split/asl_ -t

AslNii=$(ls ${DIR}/${asldir}/split/asl_00*.nii.gz)
IndexAsl=0

for asl in ${AslNii}
do
	if [[ ${IndexAsl}%2 -eq 0 ]]
	then
		NIndexAsl=$[${IndexAsl}+1]
		echo "IndexAsl : ${IndexAsl} NIndexAsl : ${NIndexAsl}"
		if [ ${NIndexAsl} -ge 10 ]
		then		
			mv ${asl} ${DIR}/${asldir}/temp_00${NIndexAsl}.nii.gz
		else
			mv ${asl} ${DIR}/${asldir}/temp_000${NIndexAsl}.nii.gz
		fi
	else
		NIndexAsl=$[${IndexAsl}-1]
		echo "IndexAsl : ${IndexAsl} NIndexAsl : ${NIndexAsl}"
		if [ ${NIndexAsl} -ge 10 ]
		then
			mv ${asl} ${DIR}/${asldir}/temp_00${NIndexAsl}.nii.gz
		else
			mv ${asl} ${DIR}/${asldir}/temp_000${NIndexAsl}.nii.gz
		fi
	fi
	IndexAsl=$[${IndexAsl}+1]
done

echo "fslmerge -t ${DIR}/${asldir}/rasl_distcor.nii.gz ${DIR}/${asldir}/temp_00*.nii.gz"
fslmerge -t ${DIR}/${asldir}/rasl_distcor.nii.gz ${DIR}/${asldir}/temp_00*.nii.gz

echo "rm -f ${DIR}/${asldir}/temp_00*.nii.gz"
rm -f ${DIR}/${asldir}/temp_00*.nii.gz


# # =====================================================================================
# #                                    Preprocess
# # =====================================================================================

# # ------------------------------------------------------------------------
# # Preprocess ASL data step 1 : Exclude first frames and motion correction
# #-------------------------------------------------------------------------

rm -f ${DIR}/${asldir}/split/*

echo "fslsplit ${DIR}/${asldir}/rasl_distcor.nii.gz ${DIR}/${asldir}/split/ -t"
fslsplit ${DIR}/${asldir}/rasl_distcor.nii.gz ${DIR}/${asldir}/split/ -t

## Exclude first 4 frames
echo "Exclude first 4 frames"
for ((ind = 0; ind < ${remframe}; ind += 1))
do
	filename=`ls -1 ${DIR}/${asldir}/split/ | sed -ne "1p"`
	rm -f ${DIR}/${asldir}/split/${filename}
done

echo "fslmerge -t ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/split/*"
fslmerge -t ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/split/*

## Motion correct ASL acquisition
fslmaths ${DIR}/${asldir}/asl.rem -Tmean ${DIR}/${asldir}/asl.rem_mean

echo "gunzip ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/asl.rem_mean.nii.gz"
gunzip ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/asl.rem_mean.nii.gz

if [ ! -e ${DIR}/${asldir}/asl.rem_mean.nii ]
then
        echo "ERREUR de gunzip"
        exit 1
fi

which mc-afni2

echo "mc-afni2 --i ${DIR}/${asldir}/asl.rem.nii --t ${DIR}/${asldir}/asl.rem_mean.nii --o ${DIR}/${asldir}/asl.rem.mc.nii --mcdat ${DIR}/${asldir}/asl.rem.mc.mcdat"
mc-afni2 --i ${DIR}/${asldir}/asl.rem.nii --t ${DIR}/${asldir}/asl.rem_mean.nii --o ${DIR}/${asldir}/asl.rem.mc.nii --mcdat ${DIR}/${asldir}/asl.rem.mc.mcdat


if [ ! -e ${DIR}/${asldir}/asl.rem.mc.nii ]
then
        echo "ERREUR de mc-afni2"
        exit 1
fi

gzip ${DIR}/${asldir}/*.nii

# # ---------------------------------------------------------------------------
# # Preprocess ASL data step 2 : registration of preprocessed ASL data to T1
# #----------------------------------------------------------------------------

### Using bbregister method for registration ####

fslmaths ${DIR}/${asldir}/asl.rem.mc -Tmean ${DIR}/${asldir}/asl.rem.mc_mean

echo "bet ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz ${DIR}/${asldir}/pCASL_brain -R -m -f 0.5"
bet ${DIR}/${asldir}/asl.rem.mc_mean ${DIR}/${asldir}/pCASL_brain -R -m -f 0.5

SUBJECTS_DIR=${FS_DIR}

if [ ! -d ${DIR}/${asldir}/bbr ]
then
	mkdir ${DIR}/${asldir}/bbr
else
	rm -Rf ${DIR}/${asldir}/bbr/*
fi

# Estimate registration 6-dof ASL onto T1 
bbregister  --s ${SUBJECT_ID} --init-fsl --t2 --mov ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz --reg ${DIR}/${asldir}/bbr/Perf2T1.register.dof6.dat \
--init-reg-out ${DIR}/${asldir}/bbr/Perf2T1.BS7.init.register.dof6.dat --o ${DIR}/${asldir}/bbr/rasl.rem.mc_mean.nii.gz > ${DIR}/${asldir}/bbr/bbregister_log.txt
    
# =====================================================================================
#                    Compute perfusion, CBF and PVC-CBF maps
# =====================================================================================

## Get the control images
rm -f ${DIR}/${asldir}/split/*

fslsplit ${DIR}/${asldir}/asl.rem.mc.nii.gz ${DIR}/${asldir}/split/asl -t

fslmerge -t ${DIR}/${asldir}/control.nii.gz ${DIR}/${asldir}/split/asl00{01..55..2}.nii.gz

AslControlNii=$(ls ${DIR}/${asldir}/split/asl00{01..55..2}.nii.gz)
Index=0
IndexTag=0

## Compute perfusion images
for asl in ${AslControlNii}
do
	if [ ${IndexTag} -ge 10 ]
	then		
		if [ ${Index} -ge 10 ]
		then
			fslmaths ${asl} -sub ${DIR}/${asldir}/split/asl00${IndexTag}.nii.gz ${DIR}/${asldir}/split/perf00${Index}.nii.gz
		else
			fslmaths ${asl} -sub ${DIR}/${asldir}/split/asl00${IndexTag}.nii.gz ${DIR}/${asldir}/split/perf000${Index}.nii.gz
		fi
	else
		fslmaths ${asl} -sub ${DIR}/${asldir}/split/asl000${IndexTag}.nii.gz ${DIR}/${asldir}/split/perf000${Index}.nii.gz
	fi
	Index=$[${Index}+1]
	IndexTag=$[${IndexTag}+2]
done

fslmerge -t ${DIR}/${asldir}/diffdata.nii.gz ${DIR}/${asldir}/split/perf*.nii.gz

fslmaths ${DIR}/${asldir}/diffdata.nii.gz -Tmean ${DIR}/${asldir}/diffdata_mean.nii.gz

fslmaths ${DIR}/${asldir}/diffdata_mean.nii.gz -nan ${DIR}/${asldir}/diffdata_mean.nii.gz

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
echo "ICI"  
DIMENSION=3
OUTPUT_PREFIX=${DIR}/${asldir}/bbr/T1_
OUTPUT_SUFFIX="nii.gz"
N4=${ANTSPATH}/N4BiasFieldCorrection
N4_CONVERGENCE_1="[50x50x50x50,0.0000001]"
N4_SHRINK_FACTOR_1=4
N4_BSPLINE_PARAMS="[200]"
    
N4_TRUNCATED_IMAGE=${OUTPUT_PREFIX}N4Truncated.${OUTPUT_SUFFIX}
N4_CORRECTED_IMAGE=${OUTPUT_PREFIX}N4Corrected.${OUTPUT_SUFFIX}
echo "LA"
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
bet ${N4_CORRECTED_IMAGE} ${DIR}/${asldir}/bbr/T1.las.brain -f 0.5 -R -m

## Use pCASL_brain_mask.nii.gz to skull-strip the control images
fslmaths ${DIR}/${asldir}/control.nii.gz -mul ${DIR}/${asldir}/pCASL_brain_mask.nii.gz ${DIR}/${asldir}/bbr/control_brain.nii.gz

## Use pCASL_brain_mask.nii.gz to skull-strip the asl.rem.mc_mean.nii.gz
fslmaths ${DIR}/${asldir}/asl.rem.mc_mean.nii.gz -mul ${DIR}/${asldir}/pCASL_brain_mask.nii.gz ${DIR}/${asldir}/bbr/asl.rem.mc_mean_brain.nii.gz

## Compute smoothed cbf images without partial volume correction
bash oxford_asl -i ${DIR}/${asldir}/diffdata -o ${DIR}/${asldir}/bbr/cbf_s --tis 3.175 --bolus 1.650 --casl -c ${DIR}/${asldir}/bbr/control_brain -s ${DIR}/${asldir}/bbr/T1.las.brain --tr 4.05 --te 14 --regfrom ${DIR}/${asldir}/bbr/asl.rem.mc_mean_brain --spatial

## Compute smoothed cbf images with partial volume correction
bash oxford_asl -i ${DIR}/${asldir}/diffdata -o ${DIR}/${asldir}/bbr/cbf_pvc_s --tis 3.175 --bolus 1.650 --casl -c ${DIR}/${asldir}/bbr/control_brain -s ${DIR}/${asldir}/bbr/T1.las.brain --tr 4.05 --te 14 --regfrom ${DIR}/${asldir}/bbr/asl.rem.mc_mean_brain --spatial --pvcorr

## Apply cbf_pvc_s registration onto T1
mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/bbr/T1.lia.nii.gz
mri_vol2vol --mov ${DIR}/${asldir}/bbr/cbf_pvc_s/native_space/perfusion_calib.nii.gz --reg ${DIR}/${asldir}/bbr/Perf2T1.register.dof6.dat --targ ${DIR}/${asldir}/bbr/T1.lia.nii.gz --o ${DIR}/${asldir}/bbr/rcbf_pvc_s.nii.gz  --no-save-reg --trilin

# =======================================================================================
#  Project ASL based data warped to T1 on fsaverage surface : FWHM=[0,3,6,9,12,15,18]
# =======================================================================================

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
	for FWHM in 0 3 5 6 9 10 12 15
	do
		mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${asldir}/bbr/Surface_Analyses/lh.fsaverage.${var}.mgh --fwhm ${FWHM} --o ${DIR}/${asldir}/bbr/Surface_Analyses/lh.fwhm${FWHM}.fsaverage.${var}.mgh --cortex
		mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${asldir}/bbr/Surface_Analyses/rh.fsaverage.${var}.mgh --fwhm ${FWHM} --o ${DIR}/${asldir}/bbr/Surface_Analyses/rh.fwhm${FWHM}.fsaverage.${var}.mgh --cortex
	done	
done
