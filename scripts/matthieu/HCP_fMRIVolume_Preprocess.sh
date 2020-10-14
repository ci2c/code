#!/bin/bash

# HCP_fMRIVolume_Preprocess.sh

# Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# Set up FSL (if not already done so in the running environment)
FSLDIR=/usr/share/fsl/5.0
. ${FSLDIR}/etc/fslconf/fsl.sh

SUBJECTS_DIR=/NAS/dumbo/matthieu/HCP/100307/T1w
export SUBJECTS_DIR

SUBJ="S1"
WD=/NAS/dumbo/matthieu/Phantom_Correctionfmri_X/S1
DwellTime="0.0008488" #Echo Spacing or Dwelltime of fMRI image. Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples): DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode, DICOM field (0051,100b) AcquisitionMatrixText first value (# of phase encoding samples).  
DoMC=1
UnwarpDir="y"

#=========================================
#            Initialization
#=========================================

if [ ! -d ${WD}/MC ]
then
	mkdir ${WD}/MC
else
	rm -rf ${WD}/MC/*
fi

if [ ! -d ${WD}/EPI_DC ]
then
	mkdir ${WD}/EPI_DC
else
	rm -rf ${WD}/EPI_DC/*
fi

# if [ ! -d ${WD}/T1w ]
# then
# 	mkdir ${WD}/T1w
# else
# 	rm -rf ${WD}/T1w/*
# fi

cp ${WD}/REST_PA_10.nii.gz ${WD}/MC/epi.nii.gz
fslmaths ${WD}/MC/epi -Tmean ${WD}/MC/mean_epi
cp ${WD}/MC/mean_epi.nii.gz ${WD}/MC/SBRef.nii.gz

cp ${WD}/MC/mean_epi.nii.gz ${WD}/EPI_DC/SBRef.nii.gz
cp ${WD}/SpinEchoPA.nii.gz ${WD}/EPI_DC/PhaseOne.nii.gz
cp ${WD}/SpinEchoAP.nii.gz ${WD}/EPI_DC/PhaseTwo_init.nii.gz
cp ${WD}/b02b0.cnf ${WD}/EPI_DC


# =====================================================================================
#            Correction of subject motion : realignment of the timeseries
# =====================================================================================

gunzip ${WD}/MC/*.gz

if [ $DoMC -eq 1 ]
then
# 	${FREESURFER_HOME}/fsfast/bin/
	mc-afni2 --i ${WD}/MC/epi.nii --t ${WD}/MC/SBRef.nii --o ${WD}/MC/repi.nii --mcdat ${WD}/MC/repi.mcdat

# 	# Making external regressor from mc params
	mcdat2mcextreg --i ${WD}/MC/repi.mcdat --o ${WD}/MC/mcprextreg
fi

gzip ${WD}/MC/*.nii

time_start=`date +%s`

# =====================================================================================
#            EPI distorsion correction : use of Topup (FSL > 5.0)
# =====================================================================================

dimtOne=`${FSLDIR}/bin/fslval ${WD}/EPI_DC/PhaseOne dim4`
dimtTwo=`${FSLDIR}/bin/fslval ${WD}/EPI_DC/PhaseTwo_init dim4`

# Shift the reverse SE by 1 voxel
# Only for Philips images, for *unknown* reason
gunzip -f ${WD}/EPI_DC/*gz

if [ ${dimtTwo} -eq 1 ]
then
	matlab -nodisplay <<EOF
		cd ${WD}/EPI_DC
		V = spm_vol('PhaseTwo_init.nii');
		Y = spm_read_vols(V);
				
		Y = circshift(Y, [-1 0 0]);
		V.fname = 'PhaseTwo.nii';
		spm_write_vol(V,Y);
EOF
else
	echo "${WD}/EPI_DC/PhaseTwo_init.nii.gz est une image 4D"
	exit 1
fi

gzip -f ${WD}/EPI_DC/*.nii

# Merge both sets of images
fslmerge -t ${WD}/EPI_DC/BothPhases ${WD}/EPI_DC/PhaseOne ${WD}/EPI_DC/PhaseTwo

# Set up text files with all necessary parameters
txtfname=${WD}/EPI_DC/acqparams.txt
if [ -e $txtfname ] ; then
	rm $txtfname
fi

# Calculate the readout time and populate the parameter file appropriately
# X direction phase encode
if [[ $UnwarpDir = "x" || $UnwarpDir = "x-" || $UnwarpDir = "-x" ]] ; then
	dimx=`${FSLDIR}/bin/fslval ${WD}/EPI_DC/PhaseOne dim1`
	nPEsteps=$(($dimx - 1))
	#Total_readout=Echo_spacing*(#of_PE_steps-1)
	ro_time=`echo "scale=6; ${DwellTime} * ${nPEsteps}" | bc -l` #Compute Total_readout in secs with up to 6 decimal places
	echo "Total readout time is $ro_time secs"
	i=1
	while [ $i -le $dimtOne ] ; do
		echo "1 0 0 $ro_time" >> $txtfname
		i=`echo "$i + 1" | bc`
	done
	i=1
	while [ $i -le $dimtTwo ] ; do
		echo "-1 0 0 $ro_time" >> $txtfname
		i=`echo "$i + 1" | bc`
	done
# Y direction phase encode
elif [[ $UnwarpDir = "y" || $UnwarpDir = "y-" || $UnwarpDir = "-y" ]] ; then
	dimy=`${FSLDIR}/bin/fslval ${WD}/EPI_DC/PhaseOne dim2`
	nPEsteps=$(($dimy - 1))
	#Total_readout=Echo_spacing*(#of_PE_steps-1)
	ro_time=`echo "scale=6; ${DwellTime} * ${nPEsteps}" | bc -l` #Compute Total_readout in secs with up to 6 decimal places
	i=1
	while [ $i -le $dimtOne ] ; do
	  echo "0 1 0 $ro_time" >> $txtfname
	  i=`echo "$i + 1" | bc`
	done
	i=1
	while [ $i -le $dimtTwo ] ; do
	  echo "0 -1 0 $ro_time" >> $txtfname
	  i=`echo "$i + 1" | bc`
	done
fi

# RUN TOPUP
# Needs FSL (version 5.0.6)
${FSLDIR}/bin/topup --imain=${WD}/EPI_DC/BothPhases --datain=$txtfname --config=${WD}/EPI_DC/b02b0.cnf --out=${WD}/EPI_DC/Coefficents --iout=${WD}/EPI_DC/Magnitudes --fout=${WD}/EPI_DC/TopupField --dfout=${WD}/EPI_DC/WarpField --rbmout=${WD}/EPI_DC/MotionMatrix --jacout=${WD}/EPI_DC/Jacobian -v

# UNWARP DIR = x,y
if [[ $UnwarpDir = "x" || $UnwarpDir = "y" ]] ; then
	# select the first volume from PhaseOne
	VolumeNumber=$((0 + 1))
	vnum=`${FSLDIR}/bin/zeropad $VolumeNumber 2`
	# register scout to SE input (PhaseOne) + combine motion and distortion correction
	${FSLDIR}/bin/flirt -dof 6 -interp spline -in ${WD}/EPI_DC/SBRef -ref ${WD}/EPI_DC/PhaseOne -omat ${WD}/EPI_DC/SBRef2PhaseOne.mat -out ${WD}/EPI_DC/SBRef2PhaseOne
	${FSLDIR}/bin/convert_xfm -omat ${WD}/EPI_DC/SBRef2WarpField.mat -concat ${WD}/EPI_DC/MotionMatrix_${vnum}.mat ${WD}/EPI_DC/SBRef2PhaseOne.mat
	${FSLDIR}/bin/convertwarp --relout --rel -r ${WD}/EPI_DC/PhaseOne --premat=${WD}/EPI_DC/SBRef2WarpField.mat --warp1=${WD}/EPI_DC/WarpField_${vnum} --out=${WD}/EPI_DC/WarpField.nii.gz
	${FSLDIR}/bin/imcp ${WD}/EPI_DC/Jacobian_${vnum}.nii.gz ${WD}/EPI_DC/Jacobian.nii.gz
# UNWARP DIR = -x
elif [[ $UnwarpDir = "x-" || $UnwarpDir = "-x" || $UnwarpDir = "y-" || $UnwarpDir = "-y" ]] ; then
	# select the first volume from PhaseTwo
	VolumeNumber=$(($dimtOne + 1))
	vnum=`${FSLDIR}/bin/zeropad $VolumeNumber 2`
	# register scout to SE input (PhaseTwo) + combine motion and distortion correction
	${FSLDIR}/bin/flirt -dof 6 -interp spline -in ${WD}/EPI_DC/SBRef -ref ${WD}/EPI_DC/PhaseTwo -omat ${WD}/EPI_DC/SBRef2PhaseTwo.mat -out ${WD}/EPI_DC/SBRef2PhaseTwo
	${FSLDIR}/bin/convert_xfm -omat ${WD}/EPI_DC/SBRef2WarpField.mat -concat ${WD}/EPI_DC/MotionMatrix_${vnum}.mat ${WD}/EPI_DC/SBRef2PhaseTwo.mat
	${FSLDIR}/bin/convertwarp --relout --rel -r ${WD}/EPI_DC/PhaseTwo --premat=${WD}/EPI_DC/SBRef2WarpField.mat --warp1=${WD}/EPI_DC/WarpField_${vnum} --out=${WD}/EPI_DC/WarpField.nii.gz
	${FSLDIR}/bin/imcp ${WD}/EPI_DC/Jacobian_${vnum}.nii.gz ${WD}/EPI_DC/Jacobian.nii.gz
	SBRefPhase=Two
fi

# PhaseTwo (first vol) - warp and Jacobian modulate to get distortion corrected output
VolumeNumber=$(($dimtOne + 1))
  vnum=`${FSLDIR}/bin/zeropad $VolumeNumber 2`
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/EPI_DC/PhaseTwo -r ${WD}/EPI_DC/PhaseTwo --premat=${WD}/EPI_DC/MotionMatrix_${vnum}.mat -w ${WD}/EPI_DC/WarpField_${vnum} -o ${WD}/EPI_DC/PhaseTwo_dc
${FSLDIR}/bin/fslmaths ${WD}/EPI_DC/PhaseTwo_dc -mul ${WD}/EPI_DC/Jacobian_${vnum} ${WD}/EPI_DC/PhaseTwo_dc_jac
# PhaseOne (first vol) - warp and Jacobian modulate to get distortion corrected output
VolumeNumber=$((0 + 1))
  vnum=`${FSLDIR}/bin/zeropad $VolumeNumber 2`
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/EPI_DC/PhaseOne -r ${WD}/EPI_DC/PhaseOne --premat=${WD}/EPI_DC/MotionMatrix_${vnum}.mat -w ${WD}/EPI_DC/WarpField_${vnum} -o ${WD}/EPI_DC/PhaseOne_dc
${FSLDIR}/bin/fslmaths ${WD}/EPI_DC/PhaseOne_dc -mul ${WD}/EPI_DC/Jacobian_${vnum} ${WD}/EPI_DC/PhaseOne_dc_jac

# Scout - warp and Jacobian modulate to get distortion corrected output
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/EPI_DC/SBRef.nii.gz -r ${WD}/EPI_DC/SBRef.nii.gz -w ${WD}/EPI_DC/WarpField.nii.gz -o ${WD}/EPI_DC/SBRef_dc.nii.gz
${FSLDIR}/bin/fslmaths ${WD}/EPI_DC/SBRef_dc.nii.gz -mul ${WD}/EPI_DC/Jacobian.nii.gz ${WD}/EPI_DC/SBRef_dc_jac.nii.gz

# repi - warp and Jacobian modulate to get distortion corrected output
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/MC/repi -r ${WD}/MC/repi -w ${WD}/EPI_DC/WarpField.nii.gz -o ${WD}/EPI_DC/repi_dc.nii.gz
${FSLDIR}/bin/fslmaths ${WD}/EPI_DC/repi_dc.nii.gz -mul ${WD}/EPI_DC/Jacobian.nii.gz ${WD}/EPI_DC/repi_dc_jac.nii.gz

time_end=`date +%s`
time_elapsed=$((time_end - time_start))

echo
echo "--------------------------------------------------------------------------------------"
echo " Done with Topup processing pipeline"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s"
echo "--------------------------------------------------------------------------------------"

# # ==============================================
# #            Coregistration T1-EPI
# # ==============================================
# 
# gunzip ${WD}/EPI_DC/SBRef_dc.nii.gz
# 
# # register undistorted scout image to T1
# bbregister --s ${SUBJ} --init-fsl --6 --bold --mov ${WD}/EPI_DC/SBRef_dc.nii --reg ${WD}/T1w/register.dof6.dat --init-reg-out ${WD}/T1w/init.register.dof6.dat --o ${WD}/T1w/SBRef_dc_T1w.nii
# 
# # convert register.dat matrix to register.mat matrix
# tkregister2 --s ${SUBJ} --mov ${WD}/EPI_DC/SBRef_dc.nii --reg ${WD}/T1w/register.dof6.dat --fslregout ${WD}/T1w/register.dof6.mat --noedit 
# mri_convert /NAS/dumbo/matthieu/HCP/100307/T1w/100307/mri/orig.mgz ${WD}/T1w/T1.nii.gz
# 
# # generate combined warpfield + T1 registration
# ${FSLDIR}/bin/convertwarp --relout --rel -r ${WD}/T1w/T1 --warp1=${WD}/EPI_DC/WarpField.nii.gz --postmat=${WD}/T1w/register.dof6.mat -o ${WD}/T1w/SBRef2T1
# 
# # apply Warp to T1 to Jacobian
# ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/EPI_DC/Jacobian -r ${WD}/T1w/T1 --premat=${WD}/T1w/register.dof6.mat -o ${WD}/T1w/Jacobian2T1w
# 
# # apply Warp to T1 to scout image + Jacobian correction
# ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/EPI_DC/SBRef -r ${WD}/T1w/T1 -w ${WD}/T1w/SBRef2T1 -o ${WD}/T1w/SBRefWtoT1
# ${FSLDIR}/bin/fslmaths ${WD}/T1w/SBRefWtoT1 -mul ${WD}/T1w/Jacobian2T1w ${WD}/T1w/SBRefWtoT1_jac
# 
# # test : apply all warps on repi
# ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/MC/repi -r ${WD}/T1w/T1 -w ${WD}/T1w/SBRef2T1 -o ${WD}/T1w/repiWtoT1
# ${FSLDIR}/bin/fslmaths ${WD}/T1w/repiWtoT1 -mul ${WD}/T1w/Jacobian2T1w ${WD}/T1w/repiWtoT1_jac