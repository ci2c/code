#!/bin/bash 
set -e

# Requirements for this script
#  installed versions of: FSL (version 5.0.6)
#  environment: FSLDIR

################################################ SUPPORT FUNCTIONS ##################################################

Usage() {
  echo "`basename $0`: Tool for non-linearly registering T1w to MNI space"
  echo " "
  echo "Usage: `basename $0` [--workingdir=<working dir>]"
  echo "                --t1=<t1w image>"
  echo "                --t1brain=<bias corrected, brain extracted t1w image>"
  echo "                --refbrain=<reference brain image>"
  echo "                [--ref2mm=<reference 2mm image>]"
  echo "                [--ref2mmmask=<reference 2mm brain mask>]"
  echo "                --owarp=<output warp>"
  echo "                --oinvwarp=<output inverse warp>"
  echo "                [--fnirtconfig=<FNIRT configuration file>]"
}

# function for parsing options
getopt1() {
    sopt="$1"
    shift 1
    for fn in $@ ; do
	if [ `echo $fn | grep -- "^${sopt}=" | wc -w` -gt 0 ] ; then
	    echo $fn | sed "s/^${sopt}=//"
	    return 0
	fi
    done
}

defaultopt() {
    echo $1
}

################################################### OUTPUT FILES #####################################################

# Outputs (in $WD):  xfms/acpc2MNILinear.mat  
#                    xfms/${T1wBrainBasename}_to_MNILinear  
#                    xfms/NonlinearReg.txt  xfms/NonlinearIntensities.nii.gz  
#                    xfms/NonlinearReg.nii.gz 
# Outputs (not in $WD): ${OutputTransform} ${OutputInvTransform}   

################################################## OPTION PARSING #####################################################

# Just give usage if no arguments specified
if [ $# -eq 0 ] ; then Usage; exit 0; fi
# check for correct options
if [ $# -lt 6 ] ; then Usage; exit 1; fi

# parse arguments
WD=`getopt1 "--workingdir" $@`  # "$1"
T1wImage=`getopt1 "--t1" $@`  # "$2"
T1wBrainImage=`getopt1 "--t1brain" $@`  # "$2"
ReferenceBrain=`getopt1 "--refbrain" $@`  # "$9"
Reference2mm=`getopt1 "--ref2mm" $@`  # "${11}"
Reference2mmMask=`getopt1 "--ref2mmmask" $@`  # "${12}"
OutputTransform=`getopt1 "--owarp" $@`  # "${13}"
OutputInvTransform=`getopt1 "--oinvwarp" $@`  # "${14}"
FNIRTConfig=`getopt1 "--fnirtconfig" $@`  # "${21}"

# default parameters
WD=`defaultopt $WD .`
Reference2mm=`defaultopt $Reference2mm ${HCPPIPEDIR_Templates}/MNI152_T1_2mm.nii.gz`
Reference2mmMask=`defaultopt $Reference2mmMask ${HCPPIPEDIR_Templates}/MNI152_T1_2mm_brain_mask_dil.nii.gz`
FNIRTConfig=`defaultopt $FNIRTConfig ${HCPPIPEDIR_Config}/T1_2_MNI152_2mm.cnf`


T1wBasename=`remove_ext $T1wImage`;
T1wBasename=`basename $T1wBasename`;
T1wBrainBasename=`remove_ext $T1wBrainImage`;
T1wBrainBasename=`basename $T1wBrainBasename`;

echo " "
echo " START: AtlasRegistration to MNI152"

mkdir -p $WD

# Record the input options in a log file
echo "$0 $@" >> $WD/xfms/log.txt
echo "PWD = `pwd`" >> $WD/xfms/log.txt
echo "date: `date`" >> $WD/xfms/log.txt
echo " " >> $WD/xfms/log.txt

########################################## DO WORK ########################################## 

# Linear then non-linear registration to MNI
${FSLDIR}/bin/flirt -interp spline -dof 12 -in ${T1wBrainImage} -ref ${ReferenceBrain} -omat ${WD}/xfms/acpc2MNILinear.mat -out ${WD}/xfms/${T1wBrainBasename}_to_MNILinear

${FSLDIR}/bin/fnirt --in=${T1wImage} --ref=${Reference2mm} --aff=${WD}/xfms/acpc2MNILinear.mat --refmask=${Reference2mmMask} --fout=${OutputTransform} --jout=${WD}/xfms/NonlinearRegJacobians.nii.gz --refout=${WD}/xfms/IntensityModulatedT1.nii.gz --iout=${WD}/xfms/2mmReg.nii.gz --logout=${WD}/xfms/NonlinearReg.txt --intout=${WD}/xfms/NonlinearIntensities.nii.gz --cout=${WD}/xfms/NonlinearReg.nii.gz --config=${FNIRTConfig}

# Input and reference spaces are the same, using 2mm reference to save time
${FSLDIR}/bin/invwarp -w ${OutputTransform} -o ${OutputInvTransform} -r ${Reference2mm}

echo " "
echo " END: AtlasRegistration to MNI152"
echo " END: `date`" >> $WD/xfms/log.txt

