#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: FMRI_Topup.sh -d <folder>  -phaseone <SE epi>  -phasetwo <SE epi>  -scout <GE epi>  -echospacing <value>  -unwarpdir <dir>  [-owarp <file>  -ojacobian <file>  -topupconfig <file>  -ofmapmag <file>  -ofmapmagbrain <file>  -ofmap <file>  -no-shift  -sedti]"
	echo ""
	echo "  -d              : working directory "
	echo "  -phaseone       : SE EPI image: with -y PE direction (PA) "
	echo "  -phasetwo       : SE EPI image: with +y PE direction (AP) "
	echo "  -scout          : scout input image: should be corrected for gradient non-linear distortions "
	echo "  -echospacing    : effective echo spacing of EPI (ms) "
	echo "  -unwarpdir      : PE direction for unwarping: x/y/z/-x/-y/-z "
	echo " Options "
	echo "  -owarp          : output warpfield image: scout to distortion corrected SE EPI "
	echo "  -ojacobian      : output Jacobian image "
	echo "  -topupconfig    : topup config file "
	echo "  -ofmapmag       : output 'Magnitude' image: scout to distortion corrected SE EPI "
	echo "  -ofmapmagbrain  : output 'Magnitude' brain image: scout to distortion corrected SE EPI "
	echo "  -ofmap          : output scaled topup field map image"
	echo "  -no-shift       : Does not apply the voxel shifting. Used only for Philips images"
	echo "                                    (default : Does apply voxel shift)"
	echo "  -sedti          : spin-echo images from DTI (Default: no)"
	echo ""
	echo "Usage: FMRI_Topup.sh -d <folder>  -phaseone <SE epi>  -phasetwo <SE epi>  -scout <GE epi>  -echospacing <value>  -unwarpdir <dir>  [-owarp <file>  -ojacobian <file>  -topupconfig <file>  -ofmapmag <file>  -ofmapmagbrain <file>  -ofmap <file>  -no-shift  -sedti]"
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1

SEDTI=0

# --------------------------------------------------------------------------------
#  Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR_Global/log.shlib # Logging related functions

vox_shift=1
TopupConfig="${HCPPIPEDIR_Config}"/b02b0.cnf


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_Topup.sh -d <folder>  -phaseone <SE epi>  -phasetwo <SE epi>  -scout <GE epi>  -echospacing <value>  -unwarpdir <dir>  [-owarp <file>  -ojacobian <file>  -topupconfig <file>  -ofmapmag <file>  -ofmapmagbrain <file>  -ofmap <file>  -no-shift  -sedti]"
		echo ""
		echo "  -d              : working directory "
		echo "  -phaseone       : SE EPI image: with -y PE direction (PA) "
		echo "  -phasetwo       : SE EPI image: with +y PE direction (AP) "
		echo "  -scout          : scout input image: should be corrected for gradient non-linear distortions "
		echo "  -echospacing    : effective echo spacing of EPI (ms) "
		echo "  -unwarpdir      : PE direction for unwarping: x/y/z/-x/-y/-z "
		echo " Options "
		echo "  -owarp          : output warpfield image: scout to distortion corrected SE EPI "
		echo "  -ojacobian      : output Jacobian image "
		echo "  -topupconfig    : topup config file "
		echo "  -ofmapmag       : output 'Magnitude' image: scout to distortion corrected SE EPI "
		echo "  -ofmapmagbrain  : output 'Magnitude' brain image: scout to distortion corrected SE EPI "
		echo "  -ofmap          : output scaled topup field map image"
		echo "  -no-shift       : Does not apply the voxel shifting. Used only for Philips images"
		echo "                                    (default : Does apply voxel shift)"
		echo "  -sedti          : spin-echo images from DTI (Default: no)"
		echo ""
		echo "Usage: FMRI_Topup.sh -d <folder>  -phaseone <SE epi>  -phasetwo <SE epi>  -scout <GE epi>  -echospacing <value>  -unwarpdir <dir>  [-owarp <file>  -ojacobian <file>  -topupconfig <file>  -ofmapmag <file>  -ofmapmagbrain <file>  -ofmap <file>  -no-shift  -sedti]"
		echo ""
		exit 1
		;;
	-d)
		index=$[$index+1]
		eval WD=\${$index}
		echo "WD : $WD"
		;;
	-phaseone)
		index=$[$index+1]
		eval PhaseEncodeOne=\${$index}
		echo "PhaseEncodeOne : $PhaseEncodeOne"
		;;
	-phasetwo)
		index=$[$index+1]
		eval PhaseEncodeTwo=\${$index}
		echo "PhaseEncodeTwo : $PhaseEncodeTwo"
		;;
	-scout)
		index=$[$index+1]
		eval ScoutInputName=\${$index}
		echo "ScoutInputName : $ScoutInputName"
		;;
	-echospacing)
		index=$[$index+1]
		eval DwellTime=\${$index}
		echo "DwellTime : $DwellTime"
		;;
	-unwarpdir)
		index=$[$index+1]
		eval UnwarpDir=\${$index}
		echo "UnwarpDir : $UnwarpDir"
		;;
	-owarp)
		index=$[$index+1]
		eval DistortionCorrectionWarpFieldOutput=\${$index}
		echo "DistortionCorrectionWarpFieldOutput : $DistortionCorrectionWarpFieldOutput"
		;;
	-ojacobian)
		index=$[$index+1]
		eval JacobianOutput=\${$index}
		echo "JacobianOutput : $JacobianOutput"
		;;
	-topupconfig)
		index=$[$index+1]
		eval TopupConfig=\${$index}
		echo "TopupConfig : $TopupConfig"
		;;
	-ofmapmag)
		index=$[$index+1]
		eval DistortionCorrectionMagnitudeOutput=\${$index}
		echo "DistortionCorrectionMagnitudeOutput : $DistortionCorrectionMagnitudeOutput"
		;;
	-ofmap)
		index=$[$index+1]
		eval DistortionCorrectionFieldOutput=\${$index}
		echo "DistortionCorrectionFieldOutput : $DistortionCorrectionFieldOutput"
		;;
	-ofmapmagbrain)
		index=$[$index+1]
		eval DistortionCorrectionMagnitudeBrainOutput=\${$index}
		echo "DistortionCorrectionMagnitudeBrainOutput : $DistortionCorrectionMagnitudeBrainOutput"
		;;
	-no-shift)
		vox_shift=0
		echo "  |-------> Disabled voxel shift"
		;;
	-sedti)
		SEDTI=1
		echo "  |-------> SE from DTI"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_Topup.sh -d <folder>  -phaseone <SE epi>  -phasetwo <SE epi>  -scout <GE epi>  -echospacing <value>  -unwarpdir <dir>  [-owarp <file>  -ojacobian <file>  -topupconfig <file>  -ofmapmag <file>  -ofmapmagbrain <file>  -ofmap <file>  -no-shift  -sedti]"
		echo ""
		echo "  -d              : working directory "
		echo "  -phaseone       : SE EPI image: with -y PE direction (PA) "
		echo "  -phasetwo       : SE EPI image: with +y PE direction (AP) "
		echo "  -scout          : scout input image: should be corrected for gradient non-linear distortions "
		echo "  -echospacing    : effective echo spacing of EPI (ms) "
		echo "  -unwarpdir      : PE direction for unwarping: x/y/z/-x/-y/-z "
		echo " Options "
		echo "  -owarp          : output warpfield image: scout to distortion corrected SE EPI "
		echo "  -ojacobian      : output Jacobian image "
		echo "  -topupconfig    : topup config file "
		echo "  -ofmapmag       : output 'Magnitude' image: scout to distortion corrected SE EPI "
		echo "  -ofmapmagbrain  : output 'Magnitude' brain image: scout to distortion corrected SE EPI "
		echo "  -ofmap          : output scaled topup field map image"
		echo "  -no-shift       : Does not apply the voxel shifting. Used only for Philips images"
		echo "                                    (default : Does apply voxel shift)"
		echo "  -sedti          : spin-echo images from DTI (Default: no)"
		echo ""
		echo "Usage: FMRI_Topup.sh -d <folder>  -phaseone <SE epi>  -phasetwo <SE epi>  -scout <GE epi>  -echospacing <value>  -unwarpdir <dir>  [-owarp <file>  -ojacobian <file>  -topupconfig <file>  -ofmapmag <file>  -ofmapmagbrain <file>  -ofmap <file>  -no-shift  -sedti]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done



echo "==============================="
echo "START: FMRI_Topup.sh"
echo "==============================="


GlobalScripts=${HCPPIPEDIR_Global}


# --------------------------------------------------------------------------------
#  Init 1
# --------------------------------------------------------------------------------

if [ -d $WD ]; then rm -rf $WD; fi
mkdir -p $WD

# Record the input options in a log file
echo "PWD = `pwd`" 
echo "date: `date`"
echo " "

# PhaseOne and PhaseTwo are sets of SE EPI images with opposite phase encodes
echo "PhaseOne and PhaseTwo are sets of SE EPI images with opposite phase encodes"
${FSLDIR}/bin/imcp $PhaseEncodeOne ${WD}/PhaseOne.nii.gz
${FSLDIR}/bin/imcp $PhaseEncodeTwo ${WD}/PhaseTwo.nii.gz
${FSLDIR}/bin/imcp $ScoutInputName ${WD}/SBRef.nii.gz

# Displacement correction due to Philips acquisition (unexplained)
if (( $vox_shift > 0 )); then

	echo "Do shift"

	gunzip -f ${WD}/PhaseOne.nii.gz ${WD}/PhaseTwo.nii.gz ${WD}/SBRef.nii.gz

	PhaseDir=`dirname ${WD}/PhaseTwo.nii`
	PhaseName=`basename ${WD}/PhaseTwo.nii`
	PhaseNameOne=`basename ${WD}/PhaseOne.nii`

	if [ ${SEDTI} -eq 0 ]; then

		curdir=`pwd`
		cd ${WD}

matlab -nodisplay <<EOF

		FMRI_EPIshift_and_flip('${PhaseName}', 's${PhaseName}');

EOF

		gzip ${WD}/s${PhaseName} ${WD}/${PhaseNameOne} ${WD}/SBRef.nii 

		cd ${curdir}

		rm -f ${WD}/PhaseTwo.nii
		mv ${WD}/sPhaseTwo.nii.gz ${WD}/PhaseTwo.nii.gz

	else

		curdir=`pwd`
		cd ${WD}

matlab -nodisplay <<EOF

		EPIshift_and_flip('${PhaseName}', 'r${PhaseName}', 's${PhaseName}', ${vox_shift});

		spm_get_defaults;
		spm_jobman('initcfg');
		clear matlabbatch 
		matlabbatch = {};

		matlabbatch{end+1}.spm.spatial.coreg.write.ref = {'SBRef.nii,1'};
		matlabbatch{end}.spm.spatial.coreg.write.source = {
						                 's${PhaseName},1'
						                 '${PhaseNameOne},1'
						                 };
		matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 4;
		matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
		matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
		matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

		spm_jobman('run',matlabbatch);
	
EOF

		gzip ${WD}/${PhaseName} ${WD}/rs${PhaseName} ${WD}/r${PhaseNameOne} ${WD}/SBRef.nii 

		cd ${curdir}

		rm -f ${WD}/PhaseTwo.nii.gz ${WD}/rPhaseTwo.nii ${WD}/sPhaseTwo.nii ${WD}/PhaseOne.nii
		mv ${WD}/rsPhaseTwo.nii.gz ${WD}/PhaseTwo.nii.gz
		mv ${WD}/rPhaseOne.nii.gz ${WD}/PhaseOne.nii.gz

	fi

fi


# --------------------------------------------------------------------------------
#  CHECK
# --------------------------------------------------------------------------------


#check dimensions of phase versus sbref images
if [[ `fslhd ${WD}/PhaseOne | grep '^dim[123]'` != `fslhd $ScoutInputName | grep '^dim[123]'` ]]
then
    echo "Error: Spin echo fieldmap has different dimensions than scout image, this requires a manual fix"
    exit 1
fi
#for kicks, check that the spin echo images match
if [[ `fslhd ${WD}/PhaseTwo | grep '^dim[123]'` != `fslhd ${WD}/PhaseOne | grep '^dim[123]'` ]]
then
    echo "Error: Spin echo fieldmap images have different dimensions!"
    exit 1
fi


# --------------------------------------------------------------------------------
#  Init 2
# --------------------------------------------------------------------------------

fslmerge -t ${WD}/BothPhases ${WD}/PhaseOne ${WD}/PhaseTwo
fslmaths ${WD}/PhaseOne.nii.gz -mul 0 -add 1 ${WD}/Mask

# Set up text files with all necessary parameters
echo "Set up text files with all necessary parameters"
txtfname=${WD}/acqparams.txt
if [ -e $txtfname ] ; then
  rm $txtfname
fi

dimtOne=`${FSLDIR}/bin/fslval ${WD}/PhaseOne dim4`
dimtTwo=`${FSLDIR}/bin/fslval ${WD}/PhaseTwo dim4`

# Calculate the readout time and populate the parameter file appropriately
echo "Calculate the readout time and populate the parameter file appropriately"
# X direction phase encode
if [[ $UnwarpDir = "x" || $UnwarpDir = "x-" || $UnwarpDir = "-x" ]] ; then
	dimx=`${FSLDIR}/bin/fslval ${WD}/PhaseOne dim1`
	nPEsteps=$(($dimx - 1))
	#Total_readout=Echo_spacing*(#of_PE_steps-1)
	#Note: the above calculation implies full k-space acquisition for SE EPI. In case of partial Fourier/k-space acquisition (though not recommended), $dimx-1 does not equal to nPEsteps. 
	ro_time=`echo "scale=6; ${DwellTime} * ${nPEsteps}" | bc -l` #Compute Total_readout in secs with up to 6 decimal places
	ro_time=`echo "scale=6; ${ro_time} / 1000" | bc -l`
	echo "Total readout time is $ro_time secs"
	i=1
	while [ $i -le $dimtOne ] ; do
		echo "-1 0 0 $ro_time" >> $txtfname
		ShiftOne="x-"
		i=`echo "$i + 1" | bc`
	done
	i=1
	while [ $i -le $dimtTwo ] ; do
		echo "1 0 0 $ro_time" >> $txtfname
		ShiftTwo="x"
		i=`echo "$i + 1" | bc`
	done
# Y direction phase encode
elif [[ $UnwarpDir = "y" || $UnwarpDir = "y-" || $UnwarpDir = "-y" ]] ; then
	dimy=`${FSLDIR}/bin/fslval ${WD}/PhaseOne dim2`
	nPEsteps=$(($dimy - 1))
	ro_time=`echo "scale=6; ${DwellTime} * ${nPEsteps}" | bc -l` #Compute Total_readout in secs with up to 6 decimal places
	ro_time=`echo "scale=6; ${ro_time} / 1000" | bc -l`
	echo "Total readout time is $ro_time secs"
	i=1
	while [ $i -le $dimtOne ] ; do
		echo "0 1 0 $ro_time" >> $txtfname
		ShiftOne="y"
		i=`echo "$i + 1" | bc`
	done
	i=1
	while [ $i -le $dimtTwo ] ; do
		echo "0 -1 0 $ro_time" >> $txtfname
		ShiftTwo="y-"
		i=`echo "$i + 1" | bc`
	done
fi


# Pad in Z by one slice if odd so that topup does not complain (slice consists of zeros that will be dilated by following step)
echo "Pad in Z by one slice if odd so that topup does not complain (slice consists of zeros that will be dilated by following step)"
numslice=`fslval ${WD}/BothPhases dim3`
if [ ! $(($numslice % 2)) -eq "0" ] ; then
	echo "Padding Z by one slice"
	for Image in ${WD}/BothPhases ${WD}/Mask ; do
		fslroi ${Image} ${WD}/slice.nii.gz 0 -1 0 -1 0 1 0 -1
		fslmaths ${WD}/slice.nii.gz -mul 0 ${WD}/slice.nii.gz
		fslmerge -z ${Image} ${Image} ${WD}/slice.nii.gz
		rm ${WD}/slice.nii.gz
	done
fi

# Extrapolate the existing values beyond the mask (adding 1 just to avoid smoothing inside the mask)
echo "Extrapolate the existing values beyond the mask (adding 1 just to avoid smoothing inside the mask)"
${FSLDIR}/bin/fslmaths ${WD}/BothPhases -abs -add 1 -mas ${WD}/Mask -dilM -dilM -dilM -dilM -dilM ${WD}/BothPhases



# --------------------------------------------------------------------------------
#  TOPUP
# --------------------------------------------------------------------------------

# RUN TOPUP
# Needs FSL (version 5.0.6)
echo ""
echo "RUN TOPUP"

${FSLDIR}/bin/topup --imain=${WD}/BothPhases --datain=$txtfname --config=${TopupConfig} --out=${WD}/Coefficents --iout=${WD}/Magnitudes --fout=${WD}/TopupField --dfout=${WD}/WarpField --rbmout=${WD}/MotionMatrix --jacout=${WD}/Jacobian -v 


# Remove Z slice padding if needed
echo "Remove Z slice padding if needed"
if [ ! $(($numslice % 2)) -eq "0" ] ; then
	echo "Removing Z slice padding"
	for Image in ${WD}/BothPhases ${WD}/Mask ${WD}/Coefficents_fieldcoef ${WD}/Magnitudes ${WD}/TopupField* ${WD}/WarpField* ${WD}/Jacobian* ; do
		fslroi ${Image} ${Image} 0 -1 0 -1 0 ${numslice} 0 -1
	done
fi

# UNWARP DIR = x,y
echo "UNWARP DIR = x,y"
if [[ $UnwarpDir = "x" || $UnwarpDir = "y" ]] ; then
	# select the first volume from PhaseTwo
	VolumeNumber=$(($dimtOne + 1))
	vnum=`${FSLDIR}/bin/zeropad $VolumeNumber 2`
	# register scout to SE input (PhaseTwo) + combine motion and distortion correction
	${FSLDIR}/bin/flirt -dof 6 -interp spline -in ${WD}/SBRef.nii.gz -ref ${WD}/PhaseTwo -omat ${WD}/SBRef2PhaseTwo.mat -out ${WD}/SBRef2PhaseTwo
	${FSLDIR}/bin/convert_xfm -omat ${WD}/SBRef2WarpField.mat -concat ${WD}/MotionMatrix_${vnum}.mat ${WD}/SBRef2PhaseTwo.mat
	${FSLDIR}/bin/convertwarp --relout --rel -r ${WD}/PhaseTwo --premat=${WD}/SBRef2WarpField.mat --warp1=${WD}/WarpField_${vnum} --out=${WD}/WarpField.nii.gz
	${FSLDIR}/bin/imcp ${WD}/Jacobian_${vnum}.nii.gz ${WD}/Jacobian.nii.gz
	SBRefPhase=Two
# UNWARP DIR = -x,-y
elif [[ $UnwarpDir = "x-" || $UnwarpDir = "-x" || $UnwarpDir = "y-" || $UnwarpDir = "-y" ]] ; then
	# select the first volume from PhaseOne
	VolumeNumber=$((0 + 1))
	vnum=`${FSLDIR}/bin/zeropad $VolumeNumber 2`
	# register scout to SE input (PhaseOne) + combine motion and distortion correction
	${FSLDIR}/bin/flirt -dof 6 -interp spline -in ${WD}/SBRef.nii.gz -ref ${WD}/PhaseOne -omat ${WD}/SBRef2PhaseOne.mat -out ${WD}/SBRef2PhaseOne
	${FSLDIR}/bin/convert_xfm -omat ${WD}/SBRef2WarpField.mat -concat ${WD}/MotionMatrix_${vnum}.mat ${WD}/SBRef2PhaseOne.mat
	${FSLDIR}/bin/convertwarp --relout --rel -r ${WD}/PhaseOne --premat=${WD}/SBRef2WarpField.mat --warp1=${WD}/WarpField_${vnum} --out=${WD}/WarpField.nii.gz
	${FSLDIR}/bin/imcp ${WD}/Jacobian_${vnum}.nii.gz ${WD}/Jacobian.nii.gz
	SBRefPhase=One
fi


# PhaseTwo (first vol) - warp and Jacobian modulate to get distortion corrected output
echo "PhaseTwo (first vol) - warp and Jacobian modulate to get distortion corrected output"
VolumeNumber=$(($dimtOne + 1))
vnum=`${FSLDIR}/bin/zeropad $VolumeNumber 2`
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/PhaseTwo -r ${WD}/PhaseTwo --premat=${WD}/MotionMatrix_${vnum}.mat -w ${WD}/WarpField_${vnum} -o ${WD}/PhaseTwo_dc
${FSLDIR}/bin/fslmaths ${WD}/PhaseTwo_dc -mul ${WD}/Jacobian_${vnum} ${WD}/PhaseTwo_dc_jac

# PhaseOne (first vol) - warp and Jacobian modulate to get distortion corrected output
echo "PhaseOne (first vol) - warp and Jacobian modulate to get distortion corrected output"
VolumeNumber=$((0 + 1))
vnum=`${FSLDIR}/bin/zeropad $VolumeNumber 2`
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/PhaseOne -r ${WD}/PhaseOne --premat=${WD}/MotionMatrix_${vnum}.mat -w ${WD}/WarpField_${vnum} -o ${WD}/PhaseOne_dc
${FSLDIR}/bin/fslmaths ${WD}/PhaseOne_dc -mul ${WD}/Jacobian_${vnum} ${WD}/PhaseOne_dc_jac

# Scout - warp and Jacobian modulate to get distortion corrected output
echo "Scout - warp and Jacobian modulate to get distortion corrected output"
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/SBRef.nii.gz -r ${WD}/SBRef.nii.gz -w ${WD}/WarpField.nii.gz -o ${WD}/SBRef_dc.nii.gz
${FSLDIR}/bin/fslmaths ${WD}/SBRef_dc.nii.gz -mul ${WD}/Jacobian.nii.gz ${WD}/SBRef_dc_jac.nii.gz

# Calculate Equivalent Field Map
echo "Calculate Equivalent Field Map"
${FSLDIR}/bin/fslmaths ${WD}/TopupField -mul 6.283 ${WD}/TopupField
${FSLDIR}/bin/fslmaths ${WD}/Magnitudes.nii.gz -Tmean ${WD}/Magnitude.nii.gz
${FSLDIR}/bin/bet ${WD}/Magnitude ${WD}/Magnitude_brain -f 0.35 -m #Brain extract the magnitude image


# copy images to specified outputs
if [ ! -z ${DistortionCorrectionWarpFieldOutput} ] ; then
  ${FSLDIR}/bin/imcp ${WD}/WarpField.nii.gz ${DistortionCorrectionWarpFieldOutput}.nii.gz
fi
if [ ! -z ${JacobianOutput} ] ; then
  ${FSLDIR}/bin/imcp ${WD}/Jacobian.nii.gz ${JacobianOutput}.nii.gz
fi
if [ ! -z ${DistortionCorrectionFieldOutput} ] ; then
  ${FSLDIR}/bin/imcp ${WD}/TopupField.nii.gz ${DistortionCorrectionFieldOutput}.nii.gz
fi
if [ ! -z ${DistortionCorrectionMagnitudeOutput} ] ; then
  ${FSLDIR}/bin/imcp ${WD}/Magnitude.nii.gz ${DistortionCorrectionMagnitudeOutput}.nii.gz
fi
if [ ! -z ${DistortionCorrectionMagnitudeBrainOutput} ] ; then
  ${FSLDIR}/bin/imcp ${WD}/Magnitude_brain.nii.gz ${DistortionCorrectionMagnitudeBrainOutput}.nii.gz
fi


echo "==============================="
echo "END: FMRI_Topup.sh"
echo "==============================="

