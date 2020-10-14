#! /bin/bash

# ## Description 
#   
# This script, PreFreeSurferPipeline.sh, is the first of 3 sub-parts of the 
# Structural Preprocessing phase of the [HCP][HCP] Minimal Preprocessing Pipelines.
#
# See [Glasser et al. 2013][GlasserEtAl].
#
# This script implements the PreFreeSurfer Pipeline referred to in that publication.
#
# The primary purposes of the PreFreeSurfer Pipeline are:
#
# 1. To average any image repeats (i.e. multiple T1w or T2w images available)
# 2. To create a native, undistorted structural volume space for the subject
#    * Subject images in this native space will be distortion corrected
#      for gradient and b0 distortions and rigidly aligned to the axes 
#      of the MNI space. "Native, undistorted structural volume space" 
#      is sometimes shortened to the "subject's native space" or simply
#      "native space".
# 3. To provide an initial robust brain extraction
# 4. To align the T1w and T2w structural images (register them to the native space)
# 5. To perform bias field correction
# 6. To register the subject's native space to the MNI space 
#
# ## Prerequisites:
# 
# ### Installed Software
#
# * [FSL][FSL] - FMRIB's Software Library (version 5.0.6) 
#
# ### Environment Variables
#
# * HCPPIPEDIR
# 
#   The "home" directory for the version of the HCP Pipeline Tools product 
#   being used. E.g. /nrgpackages/tools.release/hcp-pipeline-tools-V3.0
#   
# * HCPPIPEDIR_PreFS
#   
#   Location of PreFreeSurfer sub-scripts that are used to carry out some of 
#   steps of the PreFreeSurfer pipeline
#
# * HCPPIPEDIR_Global
#
#   Location of shared sub-scripts that are used to carry out some of the
#   steps of the PreFreeSurfer pipeline and are also used to carry out 
#   some steps of other pipelines. 
#
# * FSLDIR
#
#   Home directory for [FSL][FSL] the FMRIB Software Library from Oxford 
#   University
#
# ### Image Files
#
# At least one T1 weighted image and one T2 weighted image are required
# for this script to work.
#
# ### Output Directories
#
# Command line arguments are used to specify the StudyFolder (--path) and 
# the Subject (--subject).  All outputs are generated within the tree rooted
# at ${StudyFolder}/${Subject}.  The main output directories are:
#
# * The T1wFolder: ${StudyFolder}/${Subject}/T1w
# * The T2wFolder: ${StudyFolder}/${Subject}/T2w
# * The AtlasSpaceFolder: ${StudyFolder}/${Subject}/MNINonLinear
# 
# All outputs are generated in directories at or below these three main 
# output directories.  The full list of output directories is:
#
# * ${T1wFolder}/T1w${i}_GradientDistortionUnwarp
# * ${T1wFolder}/AverageT1wImages
# * ${T1wFolder}/ACPCAlignment
# * ${T1wFolder}/BrainExtraction_FNIRTbased
# * ${T1wFolder}/xfms - transformation matrices and warp fields
#
# * ${T2wFolder}/T2w${i}_GradientDistortionUnwarp
# * ${T2wFolder}/AverageT1wImages
# * ${T2wFolder}/ACPCAlignment
# * ${T2wFolder}/BrainExtraction_FNIRTbased
# * ${T2wFolder}/xfms - transformation matrices and warp fields
#   
# * ${T2wFolder}/T2wToT1wDistortionCorrectAndReg
# * ${T1wFolder}/BiasFieldCorrection_sqrtT1wXT1w
#   
# * ${AtlasSpaceFolder}
# * ${AtlasSpaceFolder}/xfms
#
# Note that no assumptions are made about the input paths with respect to the
# output directories. All specification of input files is done via command
# line arguments specified when this script is invoked.
#
# Also note that the following output directories are created:
#
# * T1wFolder, which is created by concatenating the following three option
#   values: --path / --subject / --t1
# * T2wFolder, which is created by concatenating the following three option
#   values: --path / --subject / --t2
#
# These two output directories must be different. Otherwise, various output
# files with standard names contained in such subdirectories, e.g. 
# full2std.mat, would overwrite each other).  If this script is modified,
# then those two output directories must be kept distinct.
#
# ### Output Files
#
# * T1wFolder Contents: _
#	acpc -> ACPC align T1w or T2w image to MNI Template to create native volume space
#	_dc -> distortion correction
#	_restore -> bias field correction
# * T2wFolder Contents: 
#	acpc -> ACPC align T1w or T2w image to MNI Template to create native volume space
#	_dc -> distortion correction
#	_restore -> bias field correction
# * AtlasSpaceFolder Contents: 
#	_restore -> registration to MNI152 (input _acpc_dc_restore)
#
# <!-- References -->
# [HCP]: http://www.humanconnectome.org
# [GlasserEtAl]: http://www.ncbi.nlm.nih.gov/pubmed/23668970
# [FSL]: http://fsl.fmrib.ox.ac.uk
#

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: T1_HCP_PreFreeSurferPipeline.sh -path <SUBJECTS_DIR>  -subject <SUBJ_ID>  -t1 <file>  -t2 <file>  [-t1template <file>  -t1templatebrain <file>  -t1template2mm <file>  -t2template <file>  -t2templatebrain <file>  -t2template2mm <file>  -templatemask <file>  -template2mmmask <file> -brainsize <value>  -fnirtconfig <file>  -fmapmag <file>  -fmapphase <file>  -fmapgeneralelectric <value>  -echodiff <value>  -SEPhaseNeg <se_file>  -SEPhasePos <se_file>  -echospacing <value>  -seunwarpdir <value>  -t1samplespacing <value>  -t2samplespacing <value>  -unwarpdir <value>  -fmrires <value>  -gdcoeffs <value>  -avgrdcmethod <name>  -topupconfig <file> ]"
	echo ""
	echo "  -path                        : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subject                     : Subject id "
	echo "  -t1                          : t1w file (.nii.gz or list of multiple files) "
	echo "  -t2	                     : t2w file (.nii.gz or list of multiple files) "
	echo " "
	echo "  OPTIONS                                            "
	echo "  -t1template		     : Hires T1w MNI template "
	echo "  -t1templatebrain	     : Hires brain extracted MNI template "
	echo "  -t1template2mm		     : Lowres T1w MNI template "
	echo "  -t2template		     : Hires T2w MNI template "
	echo "  -t2templatebrain	     : Hires brain extracted MNI template "
	echo "  -t2template2mm		     : Lowres T2w MNI template "
	echo "  -templatemask		     : Hires MNI brain mask template "
	echo "  -template2mmmask	     : Lowres MNI brain mask template "
	echo "  -brainsize		     : BrainSize in mm, 150 for humans (Default: 150) "
	echo "  -fnirtconfig		     : FNIRT 2mm T1w Config "
	echo "  -fmapmag                     : Expects 4D Magnitude volume with two 3D timepoints (.nii.gz), set to NONE if using TOPUP (Default: NONE) "
	echo "  -fmapphase                   : Expects a 3D Phase volume (.nii.gz), set to NONE if using TOPUP (Default: NONE)"
	echo "  -fmapgeneralelectric         : Path to General Electric style B0 fieldmap with two volumes 1. field map in degrees 2. magnitude "
	echo "                                 Set to NONE if not using GeneralElectricFieldMap as the value for the DistortionCorrection variable (Default: NONE) "
	echo "	-echodiff		     : 2.46ms for 3T, 1.02ms for 7T, set to NONE if using TOPUP (Default: NONE) "
	echo "  -SEPhaseNeg                  : The spin echo field map volume with a negative phase encoding direction (.nii.gz), set to NONE if using regular FIELDMAP (Default: NONE) "
	echo "  -SEPhasePos                  : The spin echo field map volume with a positive phase encoding direction (.nii.gz), set to NONE if using regular FIELDMAP (Default: NONE) "
	echo "	-echospacing                 : Echo Spacing or Dwelltime of fMRI image (in secs), set to NONE if not used. Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples): " 
	echo "				       DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode, DICOM field (0051,100b) AcquisitionMatrixText first value (# of phase encoding samples). "
	echo "				       On Siemens, iPAT/GRAPPA factors have already been accounted for. (Default: 0.0004245758)"
	echo "  -sewarpdir                   : Spin Echo Unwarping Direction (Default: NONE) "
	echo "  -t1samplespacing             : T1 sampling space (Default: NONE) "
	echo "  -t2samplespacing             : T2 sampling space (Default: NONE) "
	echo "  -unwarpdir                   : Direction of phase encoding (ex: x, x-, y, y-, z or z-) (Default: y-) "
	echo "  -gdcoeffs                    : Gradient distortion correction coefficents, set to NONE to turn off (Default: NONE) "
	echo "  -avgdcmethod                 : FIELDMAP, SiemensFieldMap, GeneralElectricFieldMap, or TOPUP: distortion correction is required for accurate processing (Default: NONE) "
	echo "  -topupconfig                 : Configuration file of TOPUP (Default: /NAS/tupac/renaud/HCP/scripts/Pipelines-3.13.1/global/config/b02b0.cnf) "
	echo ""
	echo "Usage: T1_HCP_PreFreeSurferPipeline.sh -path <SUBJECTS_DIR>  -subject <SUBJ_ID>  -t1 <file>  -t2 <file>  [-t1template <file>  -t1templatebrain <file>  -t1template2mm <file>  -t2template <file>  -t2templatebrain <file>  -t2template2mm <file>  -templatemask <file>  -template2mmmask <file> -brainsize <value>  -fnirtconfig <file>  -fmapmag <file>  -fmapphase <file>  -fmapgeneralelectric <value>  -echodiff <value>  -SEPhaseNeg <se_file>  -SEPhasePos <se_file>  -echospacing <value>  -seunwarpdir <value>  -t1samplespacing <value>  -t2samplespacing <value>  -unwarpdir <value>  -fmrires <value>  -gdcoeffs <value>  -avgrdcmethod <name>  -topupconfig <file> ]"
	echo ""
	exit 1
fi

user=`whoami`

EnvironmentScript="/NAS/tupac/renaud/HCP/scripts/Pipelines-3.21.0/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script
##Set up pipeline environment variables and software
source ${EnvironmentScript}
# ------------------------------------------------------------------------------
#  Load Function Libraries
# ------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions

HOME=/home/${user}
index=1
T1wTemplate="${HCPPIPEDIR_Templates}/MNI152_T1_1mm.nii.gz"
T1wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T1_1mm_brain.nii.gz"
T1wTemplate2mm="${HCPPIPEDIR_Templates}/MNI152_T1_2mm.nii.gz"
T2wTemplate="${HCPPIPEDIR_Templates}/MNI152_T2_1mm.nii.gz"
T2wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T2_1mm_brain.nii.gz"
T2wTemplate2mm="${HCPPIPEDIR_Templates}/MNI152_T2_2mm.nii.gz"
TemplateMask="${HCPPIPEDIR_Templates}/MNI152_T1_1mm_brain_mask.nii.gz"
Template2mmMask="${HCPPIPEDIR_Templates}/MNI152_T1_2mm_brain_mask_dil.nii.gz"
BrainSize="150"
FNIRTConfig="${HCPPIPEDIR_Config}/T1_2_MNI152_2mm.cnf"
MagnitudeInputName="NONE"
PhaseInputName="NONE"
GEB0InputName="NONE"
TE=2.46
SpinEchoPhaseEncodeNegative="NONE"
SpinEchoPhaseEncodePositive="NONE"
DwellTime="NONE"
SEUnwarpDir="NONE"
T1wSampleSpacing="NONE"
T2wSampleSpacing="NONE"
UnwarpDir="NONE"
GradientDistortionCoeffs="NONE"
AvgrdcSTRING="NONE"
TopupConfig=${HCPPIPEDIR_Global}/config/b02b0.cnf

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: T1_HCP_PreFreeSurferPipeline.sh -path <SUBJECTS_DIR>  -subject <SUBJ_ID>  -t1 <file>  -t2 <file>  [-t1template <file>  -t1templatebrain <file>  -t1template2mm <file>  -t2template <file>  -t2templatebrain <file>  -t2template2mm <file>  -templatemask <file>  -template2mmmask <file> -brainsize <value>  -fnirtconfig <file>  -fmapmag <file>  -fmapphase <file>  -fmapgeneralelectric <value>  -echodiff <value>  -SEPhaseNeg <se_file>  -SEPhasePos <se_file>  -echospacing <value>  -seunwarpdir <value>  -t1samplespacing <value>  -t2samplespacing <value>  -unwarpdir <value>  -fmrires <value>  -gdcoeffs <value>  -avgrdcmethod <name>  -topupconfig <file> ]"
		echo ""
		echo "  -path                        : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subject                     : Subject id "
		echo "  -t1                          : t1w file (.nii.gz or list of multiple files) "
		echo "  -t2	                     : t2w file (.nii.gz or list of multiple files) "
		echo " "
		echo "  OPTIONS                                            "
		echo "  -t1template		     : Hires T1w MNI template "
		echo "  -t1templatebrain	     : Hires brain extracted MNI template "
		echo "  -t1template2mm		     : Lowres T1w MNI template "
		echo "  -t2template		     : Hires T2w MNI template "
		echo "  -t2templatebrain	     : Hires brain extracted MNI template "
		echo "  -t2template2mm		     : Lowres T2w MNI template "
		echo "  -templatemask		     : Hires MNI brain mask template "
		echo "  -template2mmmask	     : Lowres MNI brain mask template "
		echo "  -brainsize		     : BrainSize in mm, 150 for humans (Default: 150) "
		echo "  -fnirtconfig		     : FNIRT 2mm T1w Config "
		echo "  -fmapmag                     : Expects 4D Magnitude volume with two 3D timepoints (.nii.gz), set to NONE if using TOPUP (Default: NONE) "
		echo "  -fmapphase                   : Expects a 3D Phase volume (.nii.gz), set to NONE if using TOPUP (Default: NONE)"
		echo "  -fmapgeneralelectric         : Path to General Electric style B0 fieldmap with two volumes 1. field map in degrees 2. magnitude "
		echo "                                 Set to NONE if not using GeneralElectricFieldMap as the value for the DistortionCorrection variable (Default: NONE) "
		echo "	-echodiff		     : 2.46ms for 3T, 1.02ms for 7T, set to NONE if using TOPUP (Default: NONE) "
		echo "  -SEPhaseNeg                  : The spin echo field map volume with a negative phase encoding direction (.nii.gz), set to NONE if using regular FIELDMAP (Default: NONE) "
		echo "  -SEPhasePos                  : The spin echo field map volume with a positive phase encoding direction (.nii.gz), set to NONE if using regular FIELDMAP (Default: NONE) "
		echo "	-echospacing                 : Echo Spacing or Dwelltime of fMRI image (in secs), set to NONE if not used. Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples): " 
		echo "				       DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode, DICOM field (0051,100b) AcquisitionMatrixText first value (# of phase encoding samples). "
		echo "				       On Siemens, iPAT/GRAPPA factors have already been accounted for. (Default: 0.0004245758)"
		echo "  -sewarpdir                   : Spin Echo Unwarping Direction (Default: NONE) "
		echo "  -t1samplespacing             : T1 sampling space (Default: NONE) "
		echo "  -t2samplespacing             : T2 sampling space (Default: NONE) "
		echo "  -unwarpdir                   : Direction of phase encoding (ex: x, x-, y, y-, z or z-) (Default: y-) "
		echo "  -gdcoeffs                    : Gradient distortion correction coefficents, set to NONE to turn off (Default: NONE) "
		echo "  -avgdcmethod                 : FIELDMAP, SiemensFieldMap, GeneralElectricFieldMap, or TOPUP: distortion correction is required for accurate processing (Default: NONE) "
		echo "  -topupconfig                 : Configuration file of TOPUP (Default: /NAS/tupac/renaud/HCP/scripts/Pipelines-3.13.1/global/config/b02b0.cnf) "
		echo ""
		echo "Usage: T1_HCP_PreFreeSurferPipeline.sh -path <SUBJECTS_DIR>  -subject <SUBJ_ID>  -t1 <file>  -t2 <file>  [-t1template <file>  -t1templatebrain <file>  -t1template2mm <file>  -t2template <file>  -t2templatebrain <file>  -t2template2mm <file>  -templatemask <file>  -template2mmmask <file> -brainsize <value>  -fnirtconfig <file>  -fmapmag <file>  -fmapphase <file>  -fmapgeneralelectric <value>  -echodiff <value>  -SEPhaseNeg <se_file>  -SEPhasePos <se_file>  -echospacing <value>  -seunwarpdir <value>  -t1samplespacing <value>  -t2samplespacing <value>  -unwarpdir <value>  -fmrires <value>  -gdcoeffs <value>  -avgrdcmethod <name>  -topupconfig <file> ]"
		echo ""
		exit 1
		;;
	-path)
		index=$[$index+1]
		eval StudyFolder=\${$index}
		echo "SUBJECTS DIR : $StudyFolder"
		;;
	-subject)
		index=$[$index+1]
		eval Subject=\${$index}
		echo "SUBJECT ID : $Subject"
		;;
	-t1)
		index=$[$index+1]
		eval T1wInputImages=\${$index}
		echo "T1 : $T1wInputImages"
		;;
	-t2)
		index=$[$index+1]
		eval T2wInputImages=\${$index}
		echo "T2 : $T2wInputImages"
		;;
	-t1template)
		index=$[$index+1]
		eval T1wTemplate=\${$index}
		echo "T1 template : $T1wTemplate"
		;;
	-t1templatebrain)
		index=$[$index+1]
		eval T1wTemplateBrain=\${$index}
		echo "T1 template brain : $T1wTemplateBrain"
		;;
	-t1template2mm)
		index=$[$index+1]
		eval T1wTemplate2mm=\${$index}
		echo "T1 template 2mm : $T1wTemplate2mm"
		;;
	-t2template)
		index=$[$index+1]
		eval T2wTemplate=\${$index}
		echo "T2 template : $T2wTemplate"
		;;
	-t2templatebrain)
		index=$[$index+1]
		eval T1wTemplateBrain=\${$index}
		echo "T1 template brain : $T2wTemplateBrain"
		;;
	-t2template2mm)
		index=$[$index+1]
		eval T2wTemplate2mm=\${$index}
		echo "T2 template 2mm : $T2wTemplate2mm"
		;;
	-brainsize)
		index=$[$index+1]
		eval BrainSize=\${$index}
		echo "Brainsize : $BrainSize"
		;;
	-fnirtconfig)
		index=$[$index+1]
		eval FNIRTConfig=\${$index}
		echo "FNIRT config : $FNIRTConfig"
		;;
	-fmapmag)
		index=$[$index+1]
		eval MagnitudeInputName=\${$index}
		echo "MAGNITUDE FILE : $MagnitudeInputName"
		;;
	-fmapphase)
		index=$[$index+1]
		eval PhaseInputName=\${$index}
		echo "PHASE FILE : $PhaseInputName"
		;;
	-fmapgeneralelectric)
		index=$[$index+1]
		eval GEB0InputName=\${$index}
		echo "GE NAME : $GEB0InputName"
		;;
	-SEPhaseNeg)
		index=$[$index+1]
		eval SpinEchoPhaseEncodeNegative=\${$index}
		echo "SE NEG FILE : $SpinEchoPhaseEncodeNegative"
		;;
	-SEPhasePos)
		index=$[$index+1]
		eval SpinEchoPhaseEncodePositive=\${$index}
		echo "SE POS FILE : $SpinEchoPhaseEncodePositive"
		;;
	-echodiff)
		index=$[$index+1]
		eval TE=\${$index}
		echo "ECHO DIFF (sec) : $TE"
		;;
	-echospacing)
		index=$[$index+1]
		eval DwellTime=\${$index}
		echo "ECHO SPACING (sec) : $DwellTime"
		;;
	-t1samplespacing)
		index=$[$index+1]
		eval T1wSampleSpacing=\${$index}
		echo "T1 sample spacing : $T1wSampleSpacing"
		;;
	-t2samplespacing)
		index=$[$index+1]
		eval T2wSampleSpacing=\${$index}
		echo "T2 sample spacing : $T2wSampleSpacing"
		;;
	-unwarpdir)
		index=$[$index+1]
		eval UnwarpDir=\${$index}
		echo "UNWARP DIRECTION : $UnwarpDir"
		;;
	-sewarpdir)
		index=$[$index+1]
		eval SEUnwarpDir=\${$index}
		echo "SE UNWARP DIRECTION : $SEUnwarpDir"
		;;
	-gdcoeffs)
		index=$[$index+1]
		eval GradientDistortionCoeffs=\${$index}
		echo "GRAD DIST COEF : $GradientDistortionCoeffs"
		;;
	-avgdcmethod)
		index=$[$index+1]
		eval AvgrdcSTRING=\${$index}
		echo "DIST CORR METHOD : $AvgrdcSTRING"
		;;
	-topupconfig)
		index=$[$index+1]
		eval TopupConfig=\${$index}
		echo "TOPUP CONFIG : $TopupConfig"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: T1_HCP_PreFreeSurferPipeline.sh -path <SUBJECTS_DIR>  -subject <SUBJ_ID>  -t1 <file>  -t2 <file>  [-t1template <file>  -t1templatebrain <file>  -t1template2mm <file>  -t2template <file>  -t2templatebrain <file>  -t2template2mm <file>  -templatemask <file>  -template2mmmask <file> -brainsize <value>  -fnirtconfig <file>  -fmapmag <file>  -fmapphase <file>  -fmapgeneralelectric <value>  -echodiff <value>  -SEPhaseNeg <se_file>  -SEPhasePos <se_file>  -echospacing <value>  -seunwarpdir <value>  -t1samplespacing <value>  -t2samplespacing <value>  -unwarpdir <value>  -fmrires <value>  -gdcoeffs <value>  -avgrdcmethod <name>  -topupconfig <file> ]"
		echo ""
		echo "  -path                        : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subject                     : Subject id "
		echo "  -t1                          : t1w file (.nii.gz or list of multiple files) "
		echo "  -t2	                     : t2w file (.nii.gz or list of multiple files) "
		echo " "
		echo "  OPTIONS                                            "
		echo "  -t1template		     : Hires T1w MNI template "
		echo "  -t1templatebrain	     : Hires brain extracted MNI template "
		echo "  -t1template2mm		     : Lowres T1w MNI template "
		echo "  -t2template		     : Hires T2w MNI template "
		echo "  -t2templatebrain	     : Hires brain extracted MNI template "
		echo "  -t2template2mm		     : Lowres T2w MNI template "
		echo "  -templatemask		     : Hires MNI brain mask template "
		echo "  -template2mmmask	     : Lowres MNI brain mask template "
		echo "  -brainsize		     : BrainSize in mm, 150 for humans (Default: 150) "
		echo "  -fnirtconfig		     : FNIRT 2mm T1w Config "
		echo "  -fmapmag                     : Expects 4D Magnitude volume with two 3D timepoints (.nii.gz), set to NONE if using TOPUP (Default: NONE) "
		echo "  -fmapphase                   : Expects a 3D Phase volume (.nii.gz), set to NONE if using TOPUP (Default: NONE)"
		echo "  -fmapgeneralelectric         : Path to General Electric style B0 fieldmap with two volumes 1. field map in degrees 2. magnitude "
		echo "                                 Set to NONE if not using GeneralElectricFieldMap as the value for the DistortionCorrection variable (Default: NONE) "
		echo "	-echodiff		     : 2.46ms for 3T, 1.02ms for 7T, set to NONE if using TOPUP (Default: NONE) "
		echo "  -SEPhaseNeg                  : The spin echo field map volume with a negative phase encoding direction (.nii.gz), set to NONE if using regular FIELDMAP (Default: NONE) "
		echo "  -SEPhasePos                  : The spin echo field map volume with a positive phase encoding direction (.nii.gz), set to NONE if using regular FIELDMAP (Default: NONE) "
		echo "	-echospacing                 : Echo Spacing or Dwelltime of fMRI image (in secs), set to NONE if not used. Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples): " 
		echo "				       DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode, DICOM field (0051,100b) AcquisitionMatrixText first value (# of phase encoding samples). "
		echo "				       On Siemens, iPAT/GRAPPA factors have already been accounted for. (Default: 0.0004245758)"
		echo "  -sewarpdir                   : Spin Echo Unwarping Direction (Default: NONE) "
		echo "  -t1samplespacing             : T1 sampling space (Default: NONE) "
		echo "  -t2samplespacing             : T2 sampling space (Default: NONE) "
		echo "  -unwarpdir                   : Direction of phase encoding (ex: x, x-, y, y-, z or z-) (Default: y-) "
		echo "  -gdcoeffs                    : Gradient distortion correction coefficents, set to NONE to turn off (Default: NONE) "
		echo "  -avgdcmethod                 : FIELDMAP, SiemensFieldMap, GeneralElectricFieldMap, or TOPUP: distortion correction is required for accurate processing (Default: NONE) "
		echo "  -topupconfig                 : Configuration file of TOPUP (Default: /NAS/tupac/renaud/HCP/scripts/Pipelines-3.13.1/global/config/b02b0.cnf) "
		echo ""
		echo "Usage: T1_HCP_PreFreeSurferPipeline.sh -path <SUBJECTS_DIR>  -subject <SUBJ_ID>  -t1 <file>  -t2 <file>  [-t1template <file>  -t1templatebrain <file>  -t1template2mm <file>  -t2template <file>  -t2templatebrain <file>  -t2template2mm <file>  -templatemask <file>  -template2mmmask <file> -brainsize <value>  -fnirtconfig <file>  -fmapmag <file>  -fmapphase <file>  -fmapgeneralelectric <value>  -echodiff <value>  -SEPhaseNeg <se_file>  -SEPhasePos <se_file>  -echospacing <value>  -seunwarpdir <value>  -t1samplespacing <value>  -t2samplespacing <value>  -unwarpdir <value>  -fmrires <value>  -gdcoeffs <value>  -avgrdcmethod <name>  -topupconfig <file> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

RUN=""

queuing_command=""
PRINTCOM=""

if [ ! $T2wInputImages = "NONE" ] ; then

      log_Msg "Performing T1 and T2 processing"
      
${queuing_command} ${HCPPIPEDIR}/PreFreeSurfer/PreFreeSurferPipeline.sh \
      --path="$StudyFolder" \
      --subject="$Subject" \
      --t1="$T1wInputImages" \
      --t2="$T2wInputImages" \
      --t1template="$T1wTemplate" \
      --t1templatebrain="$T1wTemplateBrain" \
      --t1template2mm="$T1wTemplate2mm" \
      --t2template="$T2wTemplate" \
      --t2templatebrain="$T2wTemplateBrain" \
      --t2template2mm="$T2wTemplate2mm" \
      --templatemask="$TemplateMask" \
      --template2mmmask="$Template2mmMask" \
      --brainsize="$BrainSize" \
      --fnirtconfig="$FNIRTConfig" \
      --fmapmag="$MagnitudeInputName" \
      --fmapphase="$PhaseInputName" \
      --fmapgeneralelectric="$GEB0InputName" \
      --echodiff="$TE" \
      --SEPhaseNeg="$SpinEchoPhaseEncodeNegative" \
      --SEPhasePos="$SpinEchoPhaseEncodePositive" \
      --echospacing="$DwellTime" \
      --seunwarpdir="$SEUnwarpDir" \
      --t1samplespacing="$T1wSampleSpacing" \
      --t2samplespacing="$T2wSampleSpacing" \
      --unwarpdir="$UnwarpDir" \
      --gdcoeffs="$GradientDistortionCoeffs" \
      --avgrdcmethod="$AvgrdcSTRING" \
      --topupconfig="$TopupConfig" \
      --printcom=$PRINTCOM
      
else

      log_Msg "Performing only T1 processing"
      
${queuing_command} T1_PreFreeSurferPipelineWithoutT2.sh \
      --path="$StudyFolder" \
      --subject="$Subject" \
      --t1="$T1wInputImages" \
      --t1template="$T1wTemplate" \
      --t1templatebrain="$T1wTemplateBrain" \
      --t1template2mm="$T1wTemplate2mm" \
      --templatemask="$TemplateMask" \
      --template2mmmask="$Template2mmMask" \
      --brainsize="$BrainSize" \
      --fnirtconfig="$FNIRTConfig" \
      --fmapmag="$MagnitudeInputName" \
      --fmapphase="$PhaseInputName" \
      --fmapgeneralelectric="$GEB0InputName" \
      --echodiff="$TE" \
      --SEPhaseNeg="$SpinEchoPhaseEncodeNegative" \
      --SEPhasePos="$SpinEchoPhaseEncodePositive" \
      --echospacing="$DwellTime" \
      --seunwarpdir="$SEUnwarpDir" \
      --t1samplespacing="$T1wSampleSpacing" \
      --unwarpdir="$UnwarpDir" \
      --gdcoeffs="$GradientDistortionCoeffs" \
      --avgrdcmethod="$AvgrdcSTRING" \
      --topupconfig="$TopupConfig" \
      --printcom=$PRINTCOM

fi
