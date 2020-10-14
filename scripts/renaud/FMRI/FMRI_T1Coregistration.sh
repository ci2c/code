#! /bin/bash
set -e

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_T1Coregistration.sh  -fmri <path>  -t1 <path>  -t1brain <path>  -o <folder>  [-sd <folder>  -subj <name>  -surf <name>  -dist <folder>  -jac  ]  "
	echo ""
	echo "  -fmri                       : Scout fmri file "
	echo "  -t1                         : t1 file (has to ACPC line)"
	echo "  -t1brain                    : t1 brain file (has to ACPC line) "
	echo "  -o                          : output folder "
	echo "  Options "
	echo "  -sd                         : subject's dir (Default: '')"
	echo "  -subj                       : subject's id (Default: '')"
	echo "  -surf                       : surface name (Default: 'white.deformed')"
	echo "  -dist                       : distortion correction folder (Default: '') "
	echo "  -jac                        : use of jacobian (Default: false) "
	echo ""
	echo "Usage: FMRI_T1Coregistration.sh  -epi <path>  -t1 <path>  -t1brain <path>  -o <folder>  [-sd <folder>  -subj <name>  -surf <name>  -dist <folder>  -jac  ] "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1

dof="6"
DISTDIR=""
SD=""
SUBJ=""
USEOFJAC="false"
surf="white.deformed"


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_T1Coregistration.sh  -fmri <path>  -t1 <path>  -t1brain <path>  -o <folder>  [-sd <folder>  -subj <name>  -surf <name>  -dist <folder>  -jac  ]  "
		echo ""
		echo "  -fmri                       : Scout fmri file "
		echo "  -t1                         : t1 file (has to ACPC line)"
		echo "  -t1brain                    : t1 brain file (has to ACPC line) "
		echo "  -o                          : output folder "
		echo "  Options "
		echo "  -sd                         : subject's dir (Default: '')"
		echo "  -subj                       : subject's id (Default: '')"
		echo "  -surf                       : surface name (Default: 'white.deformed')"
		echo "  -dist                       : distortion correction folder (Default: '') "
		echo "  -jac                        : use of jacobian (Default: false) "
		echo ""
		echo "Usage: FMRI_T1Coregistration.sh  -epi <path>  -t1 <path>  -t1brain <path>  -o <folder>  [-sd <folder>  -subj <name>  -surf <name>  -dist <folder>  -jac  ] "
		echo ""
		exit 1
		;;
	-fmri)
		index=$[$index+1]
		eval FMRI=\${$index}
		echo "FMRI file : ${FMRI}"
		;;
	-t1)
		index=$[$index+1]
		eval T1=\${$index}
		echo "T1 file : ${T1}"
		;;
	-t1brain)
		index=$[$index+1]
		eval T1BRAIN=\${$index}
		echo "t1 brain file : ${T1BRAIN}"
		;;
	-o)
		index=$[$index+1]
		eval OUTDIR=\${$index}
		echo "output folder : ${OUTDIR}"
		;;
	-dist)
		index=$[$index+1]
		eval DISTDIR=\${$index}
		echo "dist corr folder : ${DISTDIR}"
		;;
	-surf)
		index=$[$index+1]
		eval surf=\${$index}
		echo "surface name : ${surf}"
		;;
	-jac)
		USEOFJAC="true"
		echo "use of jacobian : ${USEOFJAC}"
		;;
	-sd)
		index=$[$index+1]
		eval SD=\${$index}
		echo "subject's dir : ${SD}"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "subject id : ${SUBJ}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_T1Coregistration.sh  -fmri <path>  -t1 <path>  -t1brain <path>  -o <folder>  [-sd <folder>  -subj <name>  -surf <name>  -dist <folder>  -jac  ]  "
		echo ""
		echo "  -fmri                       : Scout fmri file "
		echo "  -t1                         : t1 file (has to ACPC line)"
		echo "  -t1brain                    : t1 brain file (has to ACPC line) "
		echo "  -o                          : output folder "
		echo "  Options "
		echo "  -sd                         : subject's dir (Default: '')"
		echo "  -subj                       : subject's id (Default: '')"
		echo "  -surf                       : surface name (Default: 'white.deformed')"
		echo "  -dist                       : distortion correction folder (Default: '') "
		echo "  -jac                        : use of jacobian (Default: false) "
		echo ""
		echo "Usage: FMRI_T1Coregistration.sh  -epi <path>  -t1 <path>  -t1brain <path>  -o <folder>  [-sd <folder>  -subj <name>  -surf <name>  -dist <folder>  -jac  ] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# --------------------------------------------------------------------------------
#                         Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR_Global/log.shlib # Logging related functions


# --------------------------------------------------------------------------------
#                                   INIT
# --------------------------------------------------------------------------------

if [ ! -d ${OUTDIR} ]; then mkdir -p ${OUTDIR}; fi



# --------------------------------------------------------------------------------
#                           INITIAL REGISTRATION
# --------------------------------------------------------------------------------


echo ""
echo "START: FMRI_T1Coregistration.sh"
echo ""


FMRINAME=`basename ${FMRI}`

${HCPPIPEDIR_Global}/epi_reg_dof --dof=${dof} --epi=${FMRI} --t1=${T1} --t1brain=${T1BRAIN} --out=${OUTDIR}/${FMRINAME}2T1w_init

# copy the initial registration into the final affine's filename, as it is pretty good
# we need something to get between the spaces to compute an initial bias field
echo "cp ${OUTDIR}/${FMRINAME}2T1w_init.mat ${OUTDIR}/fMRI2str.mat"
cp ${OUTDIR}/${FMRINAME}2T1w_init.mat ${OUTDIR}/fMRI2str.mat

echo "inverse final transformation"
echo "convert_xfm -omat "$OUTDIR"/str2diff.mat -inverse "$OUTDIR"/diff2str.mat"
${FSLDIR}/bin/convert_xfm -omat "$OUTDIR"/str2fMRI.mat -inverse "$OUTDIR"/fMRI2str.mat

if [ ! -z ${DISTDIR} ]; then

	# generate combined warpfields and spline interpolated images + apply bias field correction
	echo "generate combined warpfields and spline interpolated images and apply bias field correction"
	convertwarp --relout --rel -r ${T1} --warp1=${DISTDIR}/WarpField.nii.gz --postmat=${OUTDIR}/${FMRINAME}2T1w_init.mat -o ${OUTDIR}/${FMRINAME}2T1w_init_warp
	applywarp --rel --interp=spline -i ${DISTDIR}/Jacobian.nii.gz -r ${T1} --premat=${OUTDIR}/${FMRINAME}2T1w_init.mat -o ${OUTDIR}/Jacobian2T1w.nii.gz
	#1-step resample from input (gdc) scout - NOTE: no longer includes jacobian correction, if specified
	applywarp --rel --interp=spline -i ${FMRI} -r ${T1} -w ${OUTDIR}/${FMRINAME}2T1w_init_warp -o ${OUTDIR}/${FMRINAME}2T1w_init

	# apply Jacobian correction to scout image
	if [[ $USEOFJAC == "true" ]] ; then
	    	echo "apply Jacobian correction to scout image"
		fslmaths ${OUTDIR}/${FMRINAME}2T1w_init -mul ${OUTDIR}/Jacobian2T1w.nii.gz ${OUTDIR}/${FMRINAME}2T1w_init.nii.gz
	fi

else

	# generate combined warpfields and spline interpolated images + apply bias field correction
	echo "generate combined warpfields and spline interpolated images and apply bias field correction"
	convertwarp --relout --rel -r ${T1} --premat=${OUTDIR}/${FMRINAME}2T1w_init.mat -o ${OUTDIR}/${FMRINAME}2T1w_init_warp
	# 1-step resample from input (gdc) scout - NOTE: no longer includes jacobian correction, if specified
	applywarp --rel --interp=spline -i ${FMRI} -r ${T1} -w ${OUTDIR}/${FMRINAME}2T1w_init_warp -o ${OUTDIR}/${FMRINAME}2T1w_init

fi



# --------------------------------------------------------------------------------
#                           FreeSurfer BBregister
# --------------------------------------------------------------------------------

if [ -z ${SD} ]; then

	echo "do not BBregister"

	mv ${OUTDIR}/${FMRINAME}2T1w_init_warp.nii.gz ${OUTDIR}/fMRI2str.nii.gz
	mv ${OUTDIR}/${FMRINAME}2T1w_init.nii.gz ${OUTDIR}/${FMRINAME}2T1w.nii.gz

else

	echo "do BBregister"

	# FREESURFER BBR - found to be an improvement, probably due to better GM/WM boundary
	SUBJECTS_DIR=${SD}
	export SUBJECTS_DIR

	if [ ! -f ${SD}/${SUBJ}/mri/transforms/eye.dat ]; then
		echo "$SUBJ" > ${SD}/${SUBJ}/mri/transforms/eye.dat
		echo "1" >> ${SD}/${SUBJ}/mri/transforms/eye.dat
		echo "1" >> ${SD}/${SUBJ}/mri/transforms/eye.dat
		echo "1" >> ${SD}/${SUBJ}/mri/transforms/eye.dat
		echo "1 0 0 0" >> ${SD}/${SUBJ}/mri/transforms/eye.dat
		echo "0 1 0 0" >> ${SD}/${SUBJ}/mri/transforms/eye.dat
		echo "0 0 1 0" >> ${SD}/${SUBJ}/mri/transforms/eye.dat
		echo "0 0 0 1" >> ${SD}/${SUBJ}/mri/transforms/eye.dat
		echo "round" >> ${SD}/${SUBJ}/mri/transforms/eye.dat
	fi

	# Use "hidden" bbregister DOF options
	echo "Use \"hidden\" bbregister DOF options"
	echo "${FREESURFER_HOME}/bin/bbregister --s ${SUBJ} --mov ${OUTDIR}/${FMRINAME}2T1w_init.nii.gz --surf ${surf} --init-reg ${SD}/${SUBJ}/mri/transforms/eye.dat --bold --reg ${OUTDIR}/EPItoT1w.dat --${dof} --o ${OUTDIR}/${FMRINAME}2T1w.nii.gz"
	${FREESURFER_HOME}/bin/bbregister --s ${SUBJ} --mov ${OUTDIR}/${FMRINAME}2T1w_init.nii.gz --surf ${surf} --init-reg ${SD}/${SUBJ}/mri/transforms/eye.dat --bold --reg ${OUTDIR}/EPItoT1w.dat --${dof} --o ${OUTDIR}/${FMRINAME}2T1w.nii.gz

	# Create FSL-style matrix and then combine with existing warp fields
	echo "Create FSL-style matrix and then combine with existing warp fields"
	echo "${FREESURFER_HOME}/bin/tkregister2 --noedit --reg ${OUTDIR}/EPItoT1w.dat --mov ${OUTDIR}/${FMRINAME}2T1w_init.nii.gz --targ ${T1}.nii.gz --fslregout ${OUTDIR}/fMRI2str_refinement.mat"
	${FREESURFER_HOME}/bin/tkregister2 --noedit --reg ${OUTDIR}/EPItoT1w.dat --mov ${OUTDIR}/${FMRINAME}2T1w_init.nii.gz --targ ${T1}.nii.gz --fslregout ${OUTDIR}/fMRI2str_fs.mat

	echo "${FSLDIR}/bin/convertwarp --relout --rel --warp1=${OUTDIR}/${FMRINAME}2T1w_init_warp.nii.gz --ref=${T1} --postmat=${OUTDIR}/fMRI2str_refinement.mat --out=${OUTDIR}/fMRI2str.nii.gz"
	convertwarp --relout --rel --warp1=${OUTDIR}/${FMRINAME}2T1w_init_warp.nii.gz --ref=${T1} --postmat=${OUTDIR}/fMRI2str_fs.mat --out=${OUTDIR}/fMRI2str.nii.gz

	# create final affine from undistorted fMRI space to T1w space, will need it if it making SEBASED bias field
	# overwrite old version of ${WD}/fMRI2str.mat, as it was just the initial registration
	# ${WD}/${ScoutInputFile}_undistorted_initT1wReg.mat is from the above epi_reg_dof, initial registration from fMRI space to T1 space
	convert_xfm -omat ${OUTDIR}/fMRI2str.mat -concat ${OUTDIR}/fMRI2str_fs.mat ${OUTDIR}/${FMRINAME}2T1w_init.mat

	echo "inverse final transformation"
	echo "convert_xfm -omat "$OUTDIR"/str2diff.mat -inverse "$OUTDIR"/diff2str.mat"
	${FSLDIR}/bin/convert_xfm -omat "$OUTDIR"/str2fMRI.mat -inverse ${OUTDIR}/fMRI2str.mat

	# Create warped image with spline interpolation, and (optional) Jacobian modulation
	# NOTE: Jacobian2T1w should be only the topup or fieldmap warpfield's jacobian, not including the gdc warp
	# the input scout is the gdc scout, which should already have had the gdc jacobian applied by the main script
	echo "Create warped image with spline interpolation, and (optional) Jacobian modulation"
	applywarp --rel --interp=spline -i ${FMRI} -r ${T1}.nii.gz -w ${OUTDIR}/fMRI2str.nii.gz -o ${OUTDIR}/${FMRINAME}2T1w

fi

# resample fieldmap jacobian with new registration
if [[ $USEOFJAC == "true" ]]; then
	applywarp --rel --interp=spline -i ${DISTDIR}/Jacobian.nii.gz -r ${T1} --premat=${OUTDIR}/fMRI2str.mat -o ${OUTDIR}/Jacobian2T1w.nii.gz
	fslmaths ${OUTDIR}/${FMRINAME}2T1w -mul ${OUTDIR}/Jacobian2T1w.nii.gz ${OUTDIR}/${FMRINAME}2T1w
fi

# Inverse registration
${FSLDIR}/bin/invwarp -w ${OUTDIR}/fMRI2str.nii.gz -o ${OUTDIR}/str2fMRI.nii.gz -r ${FMRI}

# QA image (sqrt of EPI * T1w)
echo 'generating QA image (sqrt of EPI * T1w)'
fslmaths ${T1}.nii.gz -mul ${OUTDIR}/${FMRINAME}2T1w.nii.gz -sqrt ${OUTDIR}/T1xEPI.nii.gz


echo ""
echo "END: FMRI_T1Coregistration.sh"
echo ""


########################################## QA STUFF ########################################## 

if [ -e $OUTDIR/qa_reg.txt ] ; then rm -f $OUTDIR/qa_reg.txt ; fi
echo "cd `pwd`" >> $OUTDIR/qa_reg.txt
echo "# Check registration of EPI to T1w (with all corrections applied)" >> $OUTDIR/qa_reg.txt
echo "freeview ${T1}.nii.gz ${OUTDIR}/${FMRINAME}2T1w.nii.gz ${OUTDIR}/T1xEPI.nii.gz" >> $OUTDIR/qa_reg.txt

##############################################################################################

