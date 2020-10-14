#! /bin/bash

# Naming Conventions

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
T2wFolder="$StudyFolder"/"$Subject"/"$T2wFolder" 
AtlasSpaceFolder="$StudyFolder"/"$Subject"/"$AtlasSpaceFolder"
FreeSurferFolder="$T1wFolder"/"$FreeSurferFolder"
AtlasTransform="$AtlasSpaceFolder"/xfms/"$AtlasTransform"
InverseAtlasTransform="$AtlasSpaceFolder"/xfms/"$InverseAtlasTransform"

# Conversion of FreeSurfer Volumes and Surfaces to NIFTI and GIFTI and Create Caret Files and Registration
echo "Conversion of FreeSurfer Volumes and Surfaces to NIFTI and GIFTI and Create Caret Files and Registration"
T1_FreeSurfer2CaretConvertAndRegisterNonlinear.sh "$StudyFolder" "$Subject" "$T1wFolder" "$AtlasSpaceFolder" "$NativeFolder" "$FreeSurferFolder" "$FreeSurferInput" "$T1wRestoreImage" "$SurfaceAtlasDIR" "$HighResMesh" "$LowResMeshes" "$AtlasTransform" "$InverseAtlasTransform" "$AtlasSpaceT1wImage" "$T1wImageBrainMask" "$FreeSurferLabels" "$GrayordinatesSpaceDIR" "$GrayordinatesResolutions" "$SubcorticalGrayLabels" "$RegName"
