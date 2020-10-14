#!/bin/bash

VERSION="0.0"

# Check dependencies

PROGRAM_DEPENDENCIES=( 'antsRegistration' 'antsApplyTransforms' 'N4BiasFieldCorrection' )
SCRIPTS_DEPENDENCIES=( 'antsBrainExtraction.sh' )

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

function Usage {
    cat <<USAGE

`basename $0` performs T1 anatomical brain processing where the following steps are currently applied:

  1. Brain extraction
  2. Brain bias field N4 correction
  3. Registration to a template

Usage:

`basename $0` -d imageDimension
              -a anatomicalImage
              -e brainTemplate
              -m brainExtractionProbabilityMask
              -p brainSegmentationPriors
              <OPTARGS>
              -o outputPrefix

Example:

  bash $0 -d 3 -a t1.nii.gz -e brainWithSkullTemplate.nii.gz -m brainPrior.nii.gz -p segmentationPriors%d.nii.gz -o output

Required arguments:

We use *intensity* to denote the original anatomical image of the brain.

We use *probability* to denote a probability image with values in range 0 to 1.

We use *label* to denote a label image with values in range 0 to N.

     -d:  Image dimension                       2 or 3 (for 2- or 3-dimensional image)
     -a:  Anatomical image                      Structural *intensity* image, typically T1.  If more than one
                                                anatomical image is specified, subsequently specified
                                                images are used during the segmentation process.  However,
                                                only the first image is used in the registration of priors.
                                                Our suggestion would be to specify the T1 as the first image.
     -e:  Brain template                        Anatomical *intensity* template (possibly created using a population
                                                data set with buildtemplateparallel.sh in ANTs).  This template is
                                                *not* skull-stripped.
     -m:  Brain extraction probability mask     Brain *probability* mask created using e.g. LPBA40 labels which
                                                have brain masks defined, and warped to anatomical template and
                                                averaged resulting in a probability image.
     -p:  Brain segmentation priors             Tissue *probability* priors corresponding to the image specified
                                                with the -e option.  Specified using c-style formatting, e.g.
                                                -p labelsPriors%02d.nii.gz.  We assume that the first four priors
                                                are ordered as follows
                                                  1:  csf
                                                  2:  cortical gm
                                                  3:  wm
                                                  4:  deep gm
     -o:  Output prefix                         The following images are created:
                                                  * ${OUTPUT_PREFIX}BrainExtractionMask.${OUTPUT_SUFFIX}
                                                  * ${OUTPUT_PREFIX}BrainSegmentation.${OUTPUT_SUFFIX}
                                                  * ${OUTPUT_PREFIX}BrainSegmentation*N4.${OUTPUT_SUFFIX} One for each anatomical input
                                                  * ${OUTPUT_PREFIX}BrainSegmentationPosteriors*1.${OUTPUT_SUFFIX}  CSF
                                                  * ${OUTPUT_PREFIX}BrainSegmentationPosteriors*2.${OUTPUT_SUFFIX}  GM
                                                  * ${OUTPUT_PREFIX}BrainSegmentationPosteriors*3.${OUTPUT_SUFFIX}  WM
                                                  * ${OUTPUT_PREFIX}BrainSegmentationPosteriors*4.${OUTPUT_SUFFIX}  DEEP GM
                                                  * ...
                                                  * ${OUTPUT_PREFIX}BrainSegmentationPosteriors*N.${OUTPUT_SUFFIX} where there are N priors
                                                  *                              Number formatting of posteriors matches that of the priors.

Optional arguments:

     -s:  image file suffix                     Any of the standard ITK IO formats e.g. nrrd, nii.gz (default), mhd
     -t:  template for t1 registration          Anatomical *intensity* template (assumed to be skull-stripped).  A common
                                                use case would be where this would be the same template as specified in the
                                                -e option which is not skull stripped.
                                                We perform the registration (fixed image = individual subject
                                                and moving image = template) to produce the files.
                                                The output from this step is
                                                  * ${OUTPUT_PREFIX}TemplateToSubject0GenericAffine.mat
                                                  * ${OUTPUT_PREFIX}TemplateToSubject1Warp.${OUTPUT_SUFFIX}
                                                  * ${OUTPUT_PREFIX}TemplateToSubject1InverseWarp.${OUTPUT_SUFFIX}
                                                  * ${OUTPUT_PREFIX}TemplateToSubjectLogJacobian.${OUTPUT_SUFFIX}
     -f:  extraction registration mask          Mask (defined in the template space) used during registration
                                                for brain extraction.
     -k:  keep temporary files                  Keep brain extraction/segmentation warps, etc (default = 0).
     -i:  max iterations for registration       ANTS registration max iterations (default = 100x100x70x20)
     -w:  Atropos prior segmentation weight     Atropos spatial prior *probability* weight for the segmentation (default = 0.25)
     -n:  number of segmentation iterations     N4 -> Atropos -> N4 iterations during segmentation (default = 3)
     -b:  posterior formulation                 Atropos posterior formulation and whether or not to use mixture model proportions.
                                                e.g 'Socrates[1]' (default) or 'Aristotle[1]'.  Choose the latter if you
                                                want use the distance priors (see also the -l option for label propagation
                                                control).
     -j:  use floating-point precision          Use floating point precision in registrations (default = 0)
     -u:  use random seeding                    Use random number generated from system clock in Atropos (default = 1)
     -v:  use b-spline smoothing                Use B-spline SyN for registrations and B-spline exponential mapping in DiReCT.
     -r:  cortical label image                  Cortical ROI labels to use as a prior for ATITH.
     -l:  label propagation                     Incorporate a distance prior one the posterior formulation.  Should be
                                                of the form 'label[lambda,boundaryProbability]' where label is a value
                                                of 1,2,3,... denoting label ID.  The label probability for anything
                                                outside the current label

                                                  = boundaryProbability * exp( -lambda * distanceFromBoundary )

                                                Intuitively, smaller lambda values will increase the spatial capture
                                                range of the distance prior.  To apply to all label values, simply omit
                                                specifying the label, i.e. -l [lambda,boundaryProbability].
     -c                                         Add prior combination to combined gray and white matters.  For example,
                                                when calling KK for normal subjects, we combine the deep gray matter
                                                segmentation/posteriors with the white matter segmentation/posteriors.
                                                An additional example would be performing cortical thickness in the presence
                                                of white matter lesions.  We can accommodate this by specifying a lesion mask
                                                posterior as an additional posterior (suppose label '7'), and then combine
                                                this with white matter by specifying '-c WM[7]' or '-c 3[7]'.
     -q:  Use quick registration parameters     If = 1, use antsRegistrationSyNQuick.sh as the basis for registration
                                                during brain extraction, brain segmentation, and (optional) normalization
                                                to a template.  Otherwise use antsRegistrationSyN.sh (default = 0).
     -z:  Test / debug mode                     If > 0, runs a faster version of the script. Only for testing. Implies -u 0.
                                                Requires single thread computation for complete reproducibility.
USAGE
    exit 1
}

echoParameters() {
    cat <<PARAMETERS

    Using antsBE_SEG_REGTemp with the following arguments:
      image dimension         = ${DIMENSION}
      anatomical image        = ${ANATOMICAL_IMAGES[@]}
      brain template          = ${BRAIN_TEMPLATE}
      extraction prior        = ${EXTRACTION_PRIOR}
      extraction reg. mask    = ${EXTRACTION_REGISTRATION_MASK}
      segmentation prior      = ${SEGMENTATION_PRIOR}
      output prefix           = ${OUTPUT_PREFIX}
      output image suffix     = ${OUTPUT_SUFFIX}
      registration template   = ${REGISTRATION_TEMPLATE}

    ANTs parameters:
      metric                  = ${ANTS_METRIC}[fixedImage,movingImage,${ANTS_METRIC_PARAMS}]
      regularization          = ${ANTS_REGULARIZATION}
      transformation          = ${ANTS_TRANSFORMATION}
      max iterations          = ${ANTS_MAX_ITERATIONS}

    Other parameters:
      run quick               = ${RUN_QUICK}
      debug mode              = ${DEBUG_MODE}
      float precision         = ${USE_FLOAT_PRECISION}
      use random seeding      = ${USE_RANDOM_SEEDING}
      prior combinations      = ${PRIOR_COMBINATIONS[@]}

PARAMETERS
}

# Echos a command to stdout, then runs it
# Will immediately exit on error unless you set debug flag here
DEBUG_MODE=0

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
      if [[ ! $DEBUG_MODE -gt 0 ]];
        then
          exit 1
        fi
    fi

  echo "END   <<<<<<<<<<<<<<<<<<<<"
  echo
  echo

  return $cmdExit
}

################################################################################
#
# Main routine
#
################################################################################

HOSTNAME=`hostname`
DATE=`date`

CURRENT_DIR=`pwd`/
OUTPUT_DIR=${CURRENT_DIR}/tmp$RANDOM/
OUTPUT_PREFIX=${OUTPUT_DIR}/tmp
OUTPUT_SUFFIX="nii.gz"

KEEP_TMP_IMAGES=0

DIMENSION=3

ANATOMICAL_IMAGES=()
REGISTRATION_TEMPLATE=""
DO_REGISTRATION_TO_TEMPLATE=0

USE_RANDOM_SEEDING=1
RUN_QUICK=0

BRAIN_TEMPLATE=""
EXTRACTION_PRIOR=""
EXTRACTION_REGISTRATION_MASK=""
SEGMENTATION_PRIOR=""

CSF_MATTER_LABEL=1
GRAY_MATTER_LABEL=2
WHITE_MATTER_LABEL=3
DEEP_GRAY_MATTER_LABEL=4

################################################################################
#
# Programs and their parameters
#
################################################################################

ANTS=${ANTSPATH}antsRegistration
ANTS_MAX_ITERATIONS="100x100x70x20"
ANTS_TRANSFORMATION="SyN[0.1,3,0]"
ANTS_LINEAR_METRIC_PARAMS="1,32,Regular,0.25"
ANTS_LINEAR_CONVERGENCE="[1000x500x250x100,1e-8,10]"
ANTS_METRIC="CC"
ANTS_METRIC_PARAMS="1,4"

WARP=${ANTSPATH}antsApplyTransforms

USE_FLOAT_PRECISION=0
USE_BSPLINE_SMOOTHING=0

if [[ $# -lt 3 ]] ; then
  Usage >&2
  exit 1
else
  while getopts "a:b:c:d:e:f:h:i:j:k:l:m:n:o:p:q:r:s:t:u:v:w:z:" OPT
    do
      case $OPT in
          a) #anatomical t1 image
       ANATOMICAL_IMAGES[${#ANATOMICAL_IMAGES[@]}]=$OPTARG
       ;;
          b) # posterior formulation
       ATROPOS_SEGMENTATION_POSTERIOR_FORMULATION=$OPTARG
       ;;
          c) # prior combinations
       PRIOR_COMBINATIONS[${#PRIOR_COMBINATIONS[@]}]=$OPTARG
       ;;
          d) #dimensions
       DIMENSION=$OPTARG
       if [[ ${DIMENSION} -gt 3 || ${DIMENSION} -lt 2 ]];
         then
           echo " Error:  ImageDimension must be 2 or 3 "
           exit 1
         fi
       ;;
          e) #brain extraction anatomical image
       BRAIN_TEMPLATE=$OPTARG
       ;;
          f) #brain extraction registration mask
       EXTRACTION_REGISTRATION_MASK=$OPTARG
       ;;
          h) #help
       Usage >&2
       exit 0
       ;;
          i) #max_iterations
       ANTS_MAX_ITERATIONS=$OPTARG
       ;;
          j) #use floating point precision
       USE_FLOAT_PRECISION=$OPTARG
       ;;
          k) #keep tmp images
       KEEP_TMP_IMAGES=$OPTARG
       ;;
          l)
       ATROPOS_SEGMENTATION_LABEL_PROPAGATION[${#ATROPOS_SEGMENTATION_LABEL_PROPAGATION[@]}]=$OPTARG
       ;;
          m) #brain extraction prior probability mask
       EXTRACTION_PRIOR=$OPTARG
       ;;
          n) #atropos segmentation iterations
       ATROPOS_SEGMENTATION_NUMBER_OF_ITERATIONS=$OPTARG
       ;;
          o) #output prefix
       OUTPUT_PREFIX=$OPTARG
       ;;
          p) #brain segmentation label prior image
       SEGMENTATION_PRIOR=$OPTARG
       ;;
          q) # run quick
       RUN_QUICK=$OPTARG
       ;;
          s) #output suffix
       OUTPUT_SUFFIX=$OPTARG
       ;;
          t) #template registration image
       REGISTRATION_TEMPLATE=$OPTARG
       DO_REGISTRATION_TO_TEMPLATE=1
       ;;
          u) #use random seeding
       USE_RANDOM_SEEDING=$OPTARG
       ;;
          v) #use b-spline smoothing in registration and direct
       USE_BSPLINE_SMOOTHING=$OPTARG
       ;;
          w) #atropos prior weight
       ATROPOS_SEGMENTATION_PRIOR_WEIGHT=$OPTARG
       ;;
          z) #debug mode
       DEBUG_MODE=$OPTARG
       ;;
          *) # getopts issues an error message
       echo "ERROR:  unrecognized option -$OPT $OPTARG"
       exit 1
       ;;
      esac
  done
fi



################################################################################
#
# Preliminaries:
#  1. Check existence of inputs
#  2. Figure out output directory and mkdir if necessary
#  3. See if $REGISTRATION_TEMPLATE is the same as $BRAIN_TEMPLATE
#
################################################################################

for (( i = 0; i < ${#ANATOMICAL_IMAGES[@]}; i++ ))
  do
  if [[ ! -f ${ANATOMICAL_IMAGES[$i]} ]];
    then
      echo "The specified image \"${ANATOMICAL_IMAGES[$i]}\" does not exist."
      exit 1
    fi
  done

if [[ ! -f ${BRAIN_TEMPLATE} ]];
  then
    echo "The extraction template doesn't exist:"
    echo "   $BRAIN_TEMPLATE"
    exit 1
  fi
if [[ ! -f ${EXTRACTION_PRIOR} ]];
  then
    echo "The brain extraction prior doesn't exist:"
    echo "   $EXTRACTION_PRIOR"
    exit 1
  fi

if [[ $DO_REGISTRATION_TO_TEMPLATE -eq 1 ]];
  then
    if [[ ! -f ${REGISTRATION_TEMPLATE} ]]
      then
        echo "Template for registration, ${REGISTRATION_TEMPLATE}, does not exist."
        exit 1
      fi
  fi

OUTPUT_DIR=${OUTPUT_PREFIX%\/*}
if [[ ! -d $OUTPUT_DIR ]];
  then
    echo "The output directory \"$OUTPUT_DIR\" does not exist. Making it."
    mkdir -p $OUTPUT_DIR
  fi


echoParameters >&2

echo "---------------------  Running `basename $0` on $HOSTNAME  ---------------------"

time_start=`date +%s`


################################################################################
#
# Output images
#
################################################################################

BRAIN_EXTRACTION_MASK=${OUTPUT_PREFIX}BrainExtractionMask.${OUTPUT_SUFFIX}

# ################################################################################
# #
# # Brain extraction
# #
# ################################################################################
# 
# if [[ ! -f ${BRAIN_EXTRACTION_MASK} ]];
#   then
#         logCmd ${ANTSPATH}/antsBrainExtraction.sh \
#           -d ${DIMENSION} \
#           -a ${ANATOMICAL_IMAGES[0]} \
#           -e ${BRAIN_TEMPLATE} \
#           -m ${EXTRACTION_PRIOR} \
#           -o ${OUTPUT_PREFIX} \
#           -k ${KEEP_TMP_IMAGES} \
#           -s ${OUTPUT_SUFFIX} \
#           -q ${USE_FLOAT_PRECISION} \
#           -u ${USE_RANDOM_SEEDING} \
#           -z ${DEBUG_MODE}
#   fi
# 
# EXTRACTED_SEGMENTATION_BRAIN=${OUTPUT_PREFIX}BrainExtractionBrain.${OUTPUT_SUFFIX}
# if [[ ! -f ${EXTRACTED_SEGMENTATION_BRAIN} ]];
#   then
#     logCmd ${ANTSPATH}/ImageMath ${DIMENSION} ${EXTRACTED_SEGMENTATION_BRAIN} m ${ANATOMICAL_IMAGES[0]} ${BRAIN_EXTRACTION_MASK}
#   fi
# 
# # #############################################################################################
# # 
# # Brain segmentation : Compute probability tissues maps and T1 bias field corrected image 
# # 
# # #############################################################################################
# 
# # OUTPUT_DIR=/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Bricout_Josette/ASLProcessing/FSL_BASIL/T1_SPM
# gunzip ${OUTPUT_DIR}/T1.nii.gz
# 
# ## SPM SEGMENTATION OF T1
# /usr/local/matlab11/bin/matlab -nodisplay <<EOF
# 
# 	t1_path='${OUTPUT_DIR}/T1.nii';
# 
# 	%% Initialise SPM defaults    
# 	spm('defaults', 'FMRI');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 	  
# 	matlabbatch{end+1}.spm.spatial.preproc.channel.vols = {[t1_path ',1']};
# 	matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.0001;
# 	matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
# 	matlabbatch{end}.spm.spatial.preproc.channel.write = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,1'};
# 	matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 2;
# 	matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,2'};
# 	matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 2;
# 	matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,3'};
# 	matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
# 	matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,4'};
# 	matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
# 	matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,5'};
# 	matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
# 	matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,6'};
# 	matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus = 2;
# 	matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.warp.mrf = 1;
# 	matlabbatch{end}.spm.spatial.preproc.warp.cleanup = 1;
# 	matlabbatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
# 	matlabbatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
# 	matlabbatch{end}.spm.spatial.preproc.warp.fwhm = 0;
# 	matlabbatch{end}.spm.spatial.preproc.warp.samp = 3;
# 	matlabbatch{end}.spm.spatial.preproc.warp.write = [0 0];
# 	
# 	spm_jobman('run',matlabbatch);
# 	
# EOF
# 
# N4BiasFieldCorrection -d 3 -i ${OUTPUT_DIR}/T1.nii -o ${OUTPUT_PREFIX}BrainSegmentation0N4.${OUTPUT_SUFFIX} -s 4
# # fslmaths T1_N4.nii.gz -mul ../Brain_Extraction/T1Proc_BrainExtractionMask.nii.gz T1_N4_brain.nii.gz
# gzip ${OUTPUT_DIR}/T1.nii

################################################################################
#
# Registration to a template
#
################################################################################

# These affect output; keep them consistent with usage function
REGISTRATION_TEMPLATE_OUTPUT_PREFIX=${OUTPUT_PREFIX}SubjectToTemplate
REGISTRATION_TEMPLATE_GENERIC_AFFINE=${REGISTRATION_TEMPLATE_OUTPUT_PREFIX}0GenericAffine.mat
REGISTRATION_TEMPLATE_WARP=${REGISTRATION_TEMPLATE_OUTPUT_PREFIX}1Warp.${OUTPUT_SUFFIX}
REGISTRATION_TEMPLATE_INVERSE_WARP=${REGISTRATION_TEMPLATE_OUTPUT_PREFIX}1InverseWarp.${OUTPUT_SUFFIX}
REGISTRATION_LOG_JACOBIAN=${REGISTRATION_TEMPLATE_OUTPUT_PREFIX}LogJacobian.${OUTPUT_SUFFIX}

# Want to have transforms for both directions
REGISTRATION_SUBJECT_OUTPUT_PREFIX=${OUTPUT_PREFIX}TemplateToSubject
REGISTRATION_SUBJECT_GENERIC_AFFINE=${REGISTRATION_SUBJECT_OUTPUT_PREFIX}1GenericAffine.mat
REGISTRATION_SUBJECT_WARP=${REGISTRATION_SUBJECT_OUTPUT_PREFIX}0Warp.${OUTPUT_SUFFIX}

if [[ -f ${REGISTRATION_TEMPLATE} ]] && [[ ! -f $REGISTRATION_LOG_JACOBIAN ]];
  then

    TMP_FILES=()

    # Use first N4 corrected segmentation image, which we assume to be T1
    HEAD_N4_IMAGE=${OUTPUT_PREFIX}BrainSegmentation0N4.${OUTPUT_SUFFIX}

    echo
    echo "--------------------------------------------------------------------------------------"
    echo " Registration brain masked ${HEAD_N4_IMAGE} to ${REGISTRATION_TEMPLATE} "
    echo "--------------------------------------------------------------------------------------"
    echo

    EXTRACTED_SEGMENTATION_BRAIN_N4_IMAGE=${OUTPUT_PREFIX}ExtractedBrain0N4.nii.gz

    logCmd ${ANTSPATH}/ImageMath ${DIMENSION} ${EXTRACTED_SEGMENTATION_BRAIN_N4_IMAGE} m ${HEAD_N4_IMAGE} ${BRAIN_EXTRACTION_MASK}

    TMP_FILES=( ${TMP_FILES[@]} ${EXTRACTED_SEGMENTATION_BRAIN_N4_IMAGE} )

    time_start_template_registration=`date +%s`

    basecall=''
    if [[ ${RUN_QUICK} -ne 0 ]];
      then
        TMP_FILES=( ${TMP_FILES[@]} "${REGISTRATION_TEMPLATE_OUTPUT_PREFIX}Warped.nii.gz" )

        basecall="${ANTSPATH}/antsRegistrationSyNQuick.sh -d ${DIMENSION} -f ${REGISTRATION_TEMPLATE}"
        basecall="${basecall} -m ${EXTRACTED_SEGMENTATION_BRAIN_N4_IMAGE} -o ${REGISTRATION_TEMPLATE_OUTPUT_PREFIX} -j 1"
        if [[ ${USE_FLOAT_PRECISION} -ne 0 ]];
          then
            basecall="${basecall} -p f"
          fi
      else
        IMAGES="${REGISTRATION_TEMPLATE},${EXTRACTED_SEGMENTATION_BRAIN_N4_IMAGE}"
        basecall="${ANTS} -d ${DIMENSION} -u 1 -w [0.01,0.99] -o ${REGISTRATION_TEMPLATE_OUTPUT_PREFIX} -r [${IMAGES},1] --float ${USE_FLOAT_PRECISION}"
        stage1="-m MI[${IMAGES},${ANTS_LINEAR_METRIC_PARAMS}] -c ${ANTS_LINEAR_CONVERGENCE} -t Rigid[0.1] -f 8x4x2x1 -s 3x2x1x0"
        stage2="-m MI[${IMAGES},${ANTS_LINEAR_METRIC_PARAMS}] -c ${ANTS_LINEAR_CONVERGENCE} -t Affine[0.1] -f 8x4x2x1 -s 3x2x1x0"
        stage3="-m CC[${IMAGES},1,4] -c [${ANTS_MAX_ITERATIONS},1e-9,15] -t ${ANTS_TRANSFORMATION} -f 6x4x2x1 -s 3x2x1x0"
        basecall="${basecall} ${stage1} ${stage2} ${stage3}"
      fi
    exe_template_registration_1="${basecall}"

    if [[ ! -f ${REGISTRATION_TEMPLATE_WARP} ]];
      then
        logCmd $exe_template_registration_1
      fi

    ## check to see if the output registration transforms exist
    if [[ ! -f ${REGISTRATION_TEMPLATE_GENERIC_AFFINE} ]];
      then
        echo "The registration component of the segmentation step didn't complete properly."
        echo "The transform file ${REGISTRATION_TEMPLATE_GENERIC_AFFINE} does not exist."
        exit 1
      fi

    if [[ ! -f ${REGISTRATION_TEMPLATE_WARP} ]];
      then
        echo "The registration component of the segmentation step didn't complete properly."
        echo "The transform file ${REGISTRATION_TEMPLATE_WARP} does not exist."
        exit 1
      fi

    ## Create symmetric transforms for template to subject warping
    if [[ -s ${REGISTRATION_TEMPLATE_INVERSE_WARP} ]] && [[ ! -s ${REGISTRATION_SUBJECT_WARP} ]] ; then 
      logCmd mv ${REGISTRATION_TEMPLATE_INVERSE_WARP} ${REGISTRATION_SUBJECT_WARP}
    fi
    if [[ ! -s  ${REGISTRATION_SUBJECT_WARP} ]] ; then
      echo "The transform file ${REGISTRATION_SUBJECT_WARP} does not exist."
      exit 1      
    fi
    logCmd ${ANTSPATH}antsApplyTransforms -d ${DIMENSION} -o Linear[$REGISTRATION_SUBJECT_GENERIC_AFFINE,1] -t $REGISTRATION_TEMPLATE_GENERIC_AFFINE

    time_end_template_registration=`date +%s`
    time_elapsed_template_registration=$((time_end_template_registration - time_start_template_registration))

    echo
    echo "--------------------------------------------------------------------------------------"
    echo " Done with registration:  $(( time_elapsed_template_registration / 3600 ))h $(( time_elapsed_template_registration %3600 / 60 ))m $(( time_elapsed_template_registration % 60 ))s"
    echo "--------------------------------------------------------------------------------------"
    echo

    if [[ $KEEP_TMP_IMAGES -eq 0 ]];
      then
        for f in ${TMP_FILES[@]}
          do
            if [[ -e $f ]];
             then
              logCmd rm $f
            else
              echo "WARNING: expected temp file doesn't exist: $f"
            fi
        done
      fi
  fi # if registration template & jacobian check
  

################################################################################
#
# End of main routine
#
################################################################################

time_end=`date +%s`
time_elapsed=$((time_end - time_start))

echo
echo "--------------------------------------------------------------------------------------"
echo " Done with T1 Preprocessing pipeline"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s"
echo "--------------------------------------------------------------------------------------"

exit 0

