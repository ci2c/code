#!/bin/bash
set -e

# Requirements for this script
#  installed versions of: FSL (version 5.0.6), FreeSurfer (version 5.3.0-HCP), gradunwarp (HCP version 1.0.1)
#  environment: FSLDIR , FREESURFER_HOME , HCPPIPEDIR , CARET7DIR , PATH (for gradient_unwarp.py)

########################################## PIPELINE OVERVIEW ########################################## 

#TODO

########################################## OUTPUT DIRECTORIES ########################################## 

#TODO

# --------------------------------------------------------------------------------
#  Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions

########################################## SUPPORT FUNCTIONS ########################################## 

# --------------------------------------------------------------------------------
#  Usage Description Function
# --------------------------------------------------------------------------------

show_usage() {
    echo "Usage information To Be Written"
    exit 1
}

# --------------------------------------------------------------------------------
#   Establish tool name for logging
# --------------------------------------------------------------------------------
log_SetToolName "PostFreeSurferPipeline.sh"

################################################## OPTION PARSING #####################################################

opts_ShowVersionIfRequested $@

if opts_CheckForHelpRequest $@; then
    show_usage
fi

log_Msg "Parsing Command Line Options"

# Input Variables
StudyFolder=`opts_GetOpt1 "--path" $@`
Subject=`opts_GetOpt1 "--subject" $@`
SurfaceAtlasDIR=`opts_GetOpt1 "--surfatlasdir" $@`
GrayordinatesSpaceDIR=`opts_GetOpt1 "--grayordinatesdir" $@`
GrayordinatesResolutions=`opts_GetOpt1 "--grayordinatesres" $@`
HighResMesh=`opts_GetOpt1 "--hiresmesh" $@`
LowResMeshes=`opts_GetOpt1 "--lowresmesh" $@`
SubcorticalGrayLabels=`opts_GetOpt1 "--subcortgraylabels" $@`
FreeSurferLabels=`opts_GetOpt1 "--freesurferlabels" $@`
ReferenceMyelinMaps=`opts_GetOpt1 "--refmyelinmaps" $@`
CorrectionSigma=`opts_GetOpt1 "--mcsigma" $@`
RegName=`opts_GetOpt1 "--regname" $@`

log_Msg "RegName: ${RegName}"

# default parameters
CorrectionSigma=`opts_DefaultOpt $CorrectionSigma $(echo "sqrt ( 200 )" | bc -l)`
RegName=`opts_DefaultOpt $RegName FS`

PipelineScripts=${HCPPIPEDIR_PostFS}

#Naming Conventions
T1wImage="T1w_acpc_dc"
T1wFolder="T1w" #Location of T1w images 
AtlasSpaceFolder="MNINonLinear"
NativeFolder="Native"
FreeSurferFolder="$Subject"
FreeSurferInput="T1w_acpc_dc_restore_1mm"
AtlasTransform="acpc_dc2standard"
InverseAtlasTransform="standard2acpc_dc"
AtlasSpaceT1wImage="T1w_restore"
T1wRestoreImage="T1w_acpc_dc_restore"
OrginalT1wImage="T1w"
T1wImageBrainMask="brainmask_fs"
InitialT1wTransform="acpc.mat"
dcT1wTransform="T1w_dc.nii.gz"
BiasField="BiasField_acpc_dc"
OutputT1wImage="T1w_acpc_dc"
OutputT1wImageRestore="T1w_acpc_dc_restore"
OutputT1wImageRestoreBrain="T1w_acpc_dc_restore_brain"
OutputMNIT1wImage="T1w"
OutputMNIT1wImageRestore="T1w_restore"
OutputMNIT1wImageRestoreBrain="T1w_restore_brain"
OutputOrigT1wToT1w="OrigT1w2T1w.nii.gz"
OutputOrigT1wToStandard="OrigT1w2standard.nii.gz" #File was OrigT2w2standard.nii.gz, regnerate and apply matrix
BiasFieldOutput="BiasField"
Jacobian="NonlinearRegJacobians.nii.gz"

T1wFolder="$StudyFolder"/"$Subject"/"$T1wFolder"  
AtlasSpaceFolder="$StudyFolder"/"$Subject"/"$AtlasSpaceFolder"
FreeSurferFolder="$T1wFolder"/"$FreeSurferFolder"
AtlasTransform="$AtlasSpaceFolder"/xfms/"$AtlasTransform"
InverseAtlasTransform="$AtlasSpaceFolder"/xfms/"$InverseAtlasTransform"

#Conversion of FreeSurfer Volumes and Surfaces to NIFTI and GIFTI and Create Caret Files and Registration
log_Msg "Conversion of FreeSurfer Volumes and Surfaces to NIFTI and GIFTI and Create Caret Files and Registration"
log_Msg "RegName: ${RegName}"
echo "\n T1_FreeSurfer2CaretConvertAndRegisterNonlinearWithoutT2.sh "$StudyFolder" "$Subject" "$T1wFolder" "$AtlasSpaceFolder" "$NativeFolder" "$FreeSurferFolder" "$FreeSurferInput" "$T1wRestoreImage" "$SurfaceAtlasDIR" "$HighResMesh" "$LowResMeshes" "$AtlasTransform" "$InverseAtlasTransform" "$AtlasSpaceT1wImage" "$T1wImageBrainMask" "$FreeSurferLabels" "$GrayordinatesSpaceDIR" "$GrayordinatesResolutions" "$SubcorticalGrayLabels" "$RegName""
T1_FreeSurfer2CaretConvertAndRegisterNonlinearWithoutT2.sh "$StudyFolder" "$Subject" "$T1wFolder" "$AtlasSpaceFolder" "$NativeFolder" "$FreeSurferFolder" "$FreeSurferInput" "$T1wRestoreImage" "$SurfaceAtlasDIR" "$HighResMesh" "$LowResMeshes" "$AtlasTransform" "$InverseAtlasTransform" "$AtlasSpaceT1wImage" "$T1wImageBrainMask" "$FreeSurferLabels" "$GrayordinatesSpaceDIR" "$GrayordinatesResolutions" "$SubcorticalGrayLabels" "$RegName"

#Create FreeSurfer ribbon file at full resolution
log_Msg "Create FreeSurfer ribbon file at full resolution"
echo "\n "$PipelineScripts"/CreateRibbon.sh "$StudyFolder" "$Subject" "$T1wFolder" "$AtlasSpaceFolder" "$NativeFolder" "$AtlasSpaceT1wImage" "$T1wRestoreImage" "$FreeSurferLabels""
"$PipelineScripts"/CreateRibbon.sh "$StudyFolder" "$Subject" "$T1wFolder" "$AtlasSpaceFolder" "$NativeFolder" "$AtlasSpaceT1wImage" "$T1wRestoreImage" "$FreeSurferLabels"

