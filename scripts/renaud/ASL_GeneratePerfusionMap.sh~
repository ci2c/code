#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: ASL_GeneratePerfusionMap.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -i <input>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -rmframe <value>  -sub <value>  -te <value> -pld <value>  -dur <value>  -doPve  -doCor  -pvenew "
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -i                           : input folder "
	echo "  -o                           : output folder "
	echo "  -fwhmsurf                    : smoothing value (volume) before projection "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -rmframe                     : frame for removal "
	echo "  -sub                         : subtraction method (0: simple, 1: surround, 2: sinc)"
	echo "  -te                          : TE value (ms) "
	echo "  -pld                         : value of post-labeling delay (ms) "
	echo "  -dur                         : value of labeling duration (ms) "
	echo "  -doPve                       : do partial volume correction "
	echo "  -doCor                       : do distorsion correction "
	echo "  -pvenew                      : do new PVE correction "
	echo ""
	echo "Usage: ASL_GeneratePerfusionMap.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -i <input>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -rmframe <value>  -sub <value>  -te <value> -pld <value>  -dur <value>  -doPve  -doCor  -pvenew "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmsurf=6
fwhmvol=6
remframe=4
subMethod=1
PLD=1525
LabelDur=1650
TE=14
interp=trilin
DoPVE=0
DoCOR=0
DoPVEnew=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: ASL_GeneratePerfusionMap.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -i <input>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -rmframe <value>  -sub <value>  -te <value> -pld <value>  -dur <value>  -doPve  -doCor  -pvenew "
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -i                           : input folder "
		echo "  -o                           : output folder "
		echo "  -fwhmsurf                    : smoothing value (volume) before projection "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -rmframe                     : frame for removal "
		echo "  -sub                         : subtraction method (0: simple, 1: surround, 2: sinc)"
		echo "  -te                          : TE value (ms) "
		echo "  -pld                         : value of post-labeling delay (ms) "
		echo "  -dur                         : value of labeling duration (ms) "
		echo "  -doPve                       : do partial volume correction "
		echo "  -doCor                       : do distorsion correction "
		echo "  -pvenew                      : do new PVE correction "
		echo ""
		echo "Usage: ASL_GeneratePerfusionMap.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -i <input>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -rmframe <value>  -sub <value>  -te <value> -pld <value>  -dur <value>  -doPve  -doCor  -pvenew "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "SUBJECTS DIR : $SUBJECTS_DIR"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subject's name : $SUBJ"
		;;
	-i)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "input folder : $INPUT_DIR"
		;;
	-fwhmsurf)
		index=$[$index+1]
		eval fwhmsurf=\${$index}
		echo "fwhm surface : ${fwhmsurf}"
		;;
	-o)
		index=$[$index+1]
		eval asldir=\${$index}
		echo "output folder : $asldir"
		;;
	-fwhmvol)
		index=$[$index+1]
		eval fwhmvol=\${$index}
		echo "fwhm volume : ${fwhmvol}"
		;;
	-te)
		index=$[$index+1]
		eval TE=\${$index}
		echo "TE value : ${TE}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-sub)
		index=$[$index+1]
		eval subMethod=\${$index}
		echo "subtraction type : ${subMethod}"
		;;
	-pld)
		index=$[$index+1]
		eval PLD=\${$index}
		echo "PLD value : ${PLD}"
		;;
	-dur)
		index=$[$index+1]
		eval LabelDur=\${$index}
		echo "Labeling duration : ${LabelDur}"
		;;
	-doPve)
		DoPVE=1
		echo "do PVE process"
		;;
	-doCor)
		DoCOR=1
		echo "do distorsion correction"
		;;
	-pvenew)
		DoPVEnew=1
		echo "do new PVE correction"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: ASL_GeneratePerfusionMap.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -i <input>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -rmframe <value>  -sub <value>  -te <value> -pld <value>  -dur <value>  -doPve  -doCor  -pvenew "
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -i                           : asl file "
		echo "  -o                           : output folder "
		echo "  -fwhmsurf                    : smoothing value (volume) before projection "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -rmframe                     : frame for removal "
		echo "  -sub                         : subtraction method (0: simple, 1: surround, 2: sinc)"
		echo "  -te                          : TE value (ms) "
		echo "  -pld                         : value of post-labeling delay (ms) "
		echo "  -dur                         : value of labeling duration (ms) "
		echo "  -doPve                       : do partial volume correction "
		echo "  -doCor                       : do distorsion correction "
		echo "  -pvenew                      : do new PVE correction "
		echo ""
		echo "Usage: ASL_GeneratePerfusionMap.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -i <input>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -rmframe <value>  -sub <value>  -te <value> -pld <value>  -dur <value>  -doPve  -doCor  -pvenew "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

DIR=${SUBJECTS_DIR}/${SUBJ}


if [ -d ${DIR}/${asldir} ]
then
    rm -rf ${DIR}/${asldir}/*
else
    mkdir ${DIR}/${asldir}
fi

echo "mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/T1.nii --out_orientation LAS"
mri_convert ${DIR}/mri/T1.mgz ${DIR}/${asldir}/T1.nii --out_orientation LAS


# =====================================================================================
#                                 Prepare ASL data
# =====================================================================================

BitRecPar=0

AslSplit1=$(ls ${INPUT_DIR}/*PCASLSENSE*x1.nii.gz)
AslSplit2=$(ls ${INPUT_DIR}/*PCASLSENSE*x2.nii.gz)
AslCorrSplit1=$(ls ${INPUT_DIR}/*PCASLCORRECTION*x1.nii.gz)
AslCorrSplit2=$(ls ${INPUT_DIR}/*PCASLCORRECTION*x2.nii.gz)

if [ -n "${AslSplit1}" ] && [ -n "${AslSplit2}" ]
then
	BitRecPar=1
	
	echo "fslmerge -t ${DIR}/${asldir}/asltmp.nii.gz ${AslSplit1} ${AslSplit2}"
	fslmerge -t ${DIR}/${asldir}/asltmp.nii.gz ${AslSplit1} ${AslSplit2}
	
	echo "fslmerge -t ${DIR}/${asldir}/asl_back.nii.gz ${AslCorrSplit1} ${AslCorrSplit2}"
	fslmerge -t ${DIR}/${asldir}/asl_back.nii.gz ${AslCorrSplit1} ${AslCorrSplit2}
	
	echo "gunzip ${DIR}/${asldir}/asltmp.nii.gz"
	gunzip ${DIR}/${asldir}/asltmp.nii.gz
	
	echo "range asl data"
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	[hdr,vol]=niak_read_vol('${DIR}/${asldir}/asltmp.nii');
	dim=size(vol);
	vol1=vol;
	vol1(:,:,:,2:2:dim(4))=vol(:,:,:,1:dim(4)/2);
	vol1(:,:,:,1:2:dim(4))=vol(:,:,:,dim(4)/2+1:end);
	hdr.file_name='${DIR}/${asldir}/asl.nii';
	niak_write_vol(hdr,vol1);
	
EOF
	
	echo "gzip ${DIR}/${asldir}/asl.nii"
	gzip ${DIR}/${asldir}/asl.nii
	echo "rm -f ${DIR}/${asldir}/asltmp.nii"
	rm -f ${DIR}/${asldir}/asltmp.nii
	
else
	Asl=$(ls ${INPUT_DIR}/*PCASLSENSE*.nii.gz)
	AslCorr=$(ls ${INPUT_DIR}/*PCASLCORRECTIONSENSE*.nii.gz)
	if [ -n "${Asl}" ]
	then
		echo "cp ${Asl} ${DIR}/${asldir}/asl.nii.gz"
		cp ${Asl} ${DIR}/${asldir}/asl.nii.gz
		
		echo "cp ${AslCorr} ${DIR}/${asldir}/asl_back.nii.gz"
		cp ${AslCorr} ${DIR}/${asldir}/asl_back.nii.gz
	else
		echo "ASL file does not exist"
		exit 1
	fi
fi


# =====================================================================================
#                               Distorsion Correction
# =====================================================================================

for_asl=${DIR}/${asldir}/asl.nii.gz
rev_asl=${DIR}/${asldir}/asl_back.nii.gz
distcor_asl=${DIR}/${asldir}/asl_distcor.nii.gz
DCDIR=${DIR}/${asldir}/DC

if [ $DoCOR -eq 1 ]
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
	
	ASL=${DIR}/${asldir}/asl_distcor.nii.gz
	
else

	echo "cp ${ASL} ${DIR}/${asldir}/asl.nii.gz"
	cp ${ASL} ${DIR}/${asldir}/asl.nii.gz
	ASL=${DIR}/${asldir}/asl.nii.gz
	
fi


# =====================================================================================
#                                    Preprocess
# =====================================================================================

echo "mkdir ${DIR}/${asldir}/split"
mkdir ${DIR}/${asldir}/split

echo "fslsplit ${ASL} ${DIR}/${asldir}/split/ -t"
fslsplit ${ASL} ${DIR}/${asldir}/split/ -t

# Exclude first 4 frames
echo "Exclude first 4 frames"
for ((ind = 0; ind < ${remframe}; ind += 1))
do
	filename=`ls -1 ${DIR}/${asldir}/split/ | sed -ne "1p"`
	rm -f ${DIR}/${asldir}/split/${filename}
done

echo "fslmerge -t ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/split/*"
fslmerge -t ${DIR}/${asldir}/asl.rem.nii.gz ${DIR}/${asldir}/split/*
echo "gunzip ${DIR}/${asldir}/asl.rem.nii.gz"
gunzip ${DIR}/${asldir}/asl.rem.nii.gz

# Calibration scan
echo "calibration scan..."
filename=`ls -1 ${DIR}/${asldir}/split/ | sed -ne "1p"`
cp ${DIR}/${asldir}/split/${filename} ${DIR}/${asldir}/aslcal.nii.gz
gunzip ${DIR}/${asldir}/aslcal.nii.gz

# Registration of calibration scan to anatomical space
echo "Registration of calibration scan to anatomical space"
bbregister --init-fsl --mov ${DIR}/${asldir}/aslcal.nii --t2 --s ${SUBJ} --reg ${DIR}/${asldir}/aslcal.reg

# Apply transformation
echo "Apply transformation" 
mri_vol2vol --mov ${DIR}/${asldir}/aslcal.nii --reg ${DIR}/${asldir}/aslcal.reg --fstarg --o ${DIR}/${asldir}/aslcal.anat.nii --interp ${interp} --no-save-reg --no-resample

# Motion correct ASL acquisition
echo "Motion correct ASL acquisition"
mri_convert ${DIR}/${asldir}/asl.rem.nii --mid-frame ${DIR}/${asldir}/asl.template.nii
mcflirt -reffile ${DIR}/${asldir}/asl.template.nii -in ${DIR}/${asldir}/asl.rem.nii -o ${DIR}/${asldir}/asl.rem.mc -mats -plots
gunzip ${DIR}/${asldir}/asl.rem.mc.nii.gz

# Registration of ASL to anatomical space
echo "Registration of ASL to anatomical space"
bbregister --init-fsl --mov ${DIR}/${asldir}/asl.template.nii --t2 --s ${SUBJ} --reg ${DIR}/${asldir}/asl.reg


# =====================================================================================
#                    Difference image (dM) and CBF map calculations
# =====================================================================================

# Smoothing
if [ ${fwhmvol} -gt 0 ]
then
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};
	[tempa,tempb,tempc] = fileparts('${DIR}/${asldir}/asl.rem.mc.nii');

	matlabbatch{end+1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	matlabbatch{end}.spm.spatial.smooth.fwhm   = [${fwhmvol} ${fwhmvol} ${fwhmvol}];
	matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
	matlabbatch{end}.spm.spatial.smooth.im     = 0;
	matlabbatch{end}.spm.spatial.smooth.prefix = ['s' num2str(${fwhmvol})];
	
	spm_jobman('run',matlabbatch);
	
EOF
else
     cp ${DIR}/${asldir}/asl.rem.mc.nii ${DIR}/${asldir}/s${fwhmvol}asl.rem.mc.nii
fi

ASL=${DIR}/${asldir}/s${fwhmvol}asl.rem.mc.nii

echo "bet ${DIR}/${asldir}/asl.rem.mc.nii.gz ${DIR}/${asldir}/asl -m -n -f 0.5"
bet ${DIR}/${asldir}/asl.rem.mc.nii ${DIR}/${asldir}/asl -m -n -f 0.5
echo "gunzip ${DIR}/${asldir}/asl_mask.nii.gz"
gunzip ${DIR}/${asldir}/asl_mask.nii.gz
echo "mri_morphology ${DIR}/${asldir}/asl_mask.nii dilate 1 ${DIR}/${asldir}/asl_mask_dil.nii" 
mri_morphology ${DIR}/${asldir}/asl_mask.nii dilate 1 ${DIR}/${asldir}/asl_mask_dil.nii

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

  % Load Matlab Path
  p = pathdef;
  addpath(p);
  
  FirstimageType = 1;
  
  Compute_PerfAndCBFMap_Bis('${ASL}','${DIR}/${asldir}/asl_mask_dil.nii',${PLD},${LabelDur},${TE},${subMethod},FirstimageType);
  
EOF

# Apply transformation
echo "Apply transformation" 
mri_vol2vol --mov ${DIR}/${asldir}/s${fwhmvol}asl.rem.mc.nii --reg ${DIR}/${asldir}/asl.reg --fstarg --o ${DIR}/${asldir}/s${fwhmvol}asl.rem.mc.anat.nii --interp ${interp} --no-save-reg --no-resample
mri_vol2vol --mov ${DIR}/${asldir}/asl_mask_dil.nii --reg ${DIR}/${asldir}/asl.reg --fstarg --o ${DIR}/${asldir}/asl_mask_dil.anat.nii --interp ${interp} --no-save-reg --no-resample
mri_vol2vol --mov ${DIR}/${asldir}/meanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.nii --reg ${DIR}/${asldir}/asl.reg --fstarg --o ${DIR}/${asldir}/meanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --interp ${interp} --no-save-reg --no-resample
mri_vol2vol --mov ${DIR}/${asldir}/meanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.nii --reg ${DIR}/${asldir}/asl.reg --fstarg --o ${DIR}/${asldir}/meanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --interp ${interp} --no-save-reg --no-resample


# =====================================================================================
#                                  PVE correction
# =====================================================================================

if [ $DoPVE -eq 1 ] 
then

    # reslice CBF and PERF maps
    if [ ! -f ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii ]
    then
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
	  
	  disp('reslice CBF');

	  spm_get_defaults;
	  spm_jobman('initcfg');
	  matlabbatch = {};
	  matlabbatch{end+1}.spm.spatial.coreg.write.ref  = cellstr('${DIR}/${asldir}/T1.nii');
	  matlabbatch{end}.spm.spatial.coreg.write.source{1,1} = '${DIR}/${asldir}/meanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii';
	  matlabbatch{end}.spm.spatial.coreg.write.source{1,2} = '${DIR}/${asldir}/meanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii';
	  matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 4;
	  matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
	  matlabbatch{end}.spm.spatial.coreg.write.roptions.mask   = 0;
	  matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

	  spm_jobman('run',matlabbatch);
EOF

	  # Remove NaNs
	  echo "fslmaths ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat -nan ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat"
	  fslmaths ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat -nan ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat
	  rm -f ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii
	  gunzip ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii.gz
	  
	  echo "fslmaths ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat -nan ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat"
	  fslmaths ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat -nan ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat
	  rm -f ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii
	  gunzip ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii.gz
    fi
    
    # PVE correction of CBF map
    echo "PVE correction of CBF map"
    if [ ${DoPVEnew} -eq 0 ]
    then
	ASL_PVECorrection.sh -sd ${SUBJECTS_DIR} -subj ${SUBJ} -i ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii -o ${DIR}/${asldir}/pve_cbf
    else
	ASL_PVECorrection.sh -sd ${SUBJECTS_DIR} -subj ${SUBJ} -i ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii -o ${DIR}/${asldir}/pve_cbf -new
    fi
    gzip ${DIR}/${asldir}/pve_cbf/*.nii
    mri_convert ${DIR}/${asldir}/pve_cbf/t1_MGRousset.img ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii
    
    
    # PVE correction of PERF map
    echo "PVE correction of PERF map"
    if [ ${DoPVEnew} -eq 0 ]
    then
	ASL_PVECorrection.sh -sd ${SUBJECTS_DIR} -subj ${SUBJ} -i ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii -o ${DIR}/${asldir}/pve_perf
    else
	ASL_PVECorrection.sh -sd ${SUBJECTS_DIR} -subj ${SUBJ} -i ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii -o ${DIR}/${asldir}/pve_perf -new
    fi    
    gzip ${DIR}/${asldir}/pve_perf/*.nii
    mri_convert ${DIR}/${asldir}/pve_perf/t1_MGRousset.img ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii
  
fi


# Smoothing
if [ ${fswhmsurf} -gt 0 ]
then
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	spm_get_defaults;
	spm_jobman('initcfg');
	
	matlabbatch = {};
	[tempa,tempb,tempc] = fileparts('${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii');
	matlabbatch{end+1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	matlabbatch{end}.spm.spatial.smooth.fwhm   = [${fwhmsurf} ${fwhmsurf} ${fwhmsurf}];
	matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
	matlabbatch{end}.spm.spatial.smooth.im     = 0;
	matlabbatch{end}.spm.spatial.smooth.prefix = ['s' num2str(${fwhmsurf})];	
	spm_jobman('run',matlabbatch);
	
	clear matlabbatch
	matlabbatch = {};
	[tempa,tempb,tempc] = fileparts('${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii');
	matlabbatch{end+1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	matlabbatch{end}.spm.spatial.smooth.fwhm   = [${fwhmsurf} ${fwhmsurf} ${fwhmsurf}];
	matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
	matlabbatch{end}.spm.spatial.smooth.im     = 0;
	matlabbatch{end}.spm.spatial.smooth.prefix = ['s' num2str(${fwhmsurf})];	
	spm_jobman('run',matlabbatch);
	
	if ${doPVE}==1
	    clear matlabbatch
	    matlabbatch = {};
	    [tempa,tempb,tempc] = fileparts('${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii');
	    matlabbatch{end+1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	    matlabbatch{end}.spm.spatial.smooth.fwhm   = [${fwhmsurf} ${fwhmsurf} ${fwhmsurf}];
	    matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
	    matlabbatch{end}.spm.spatial.smooth.im     = 0;
	    matlabbatch{end}.spm.spatial.smooth.prefix = ['s' num2str(${fwhmsurf})];	
	    spm_jobman('run',matlabbatch);
	    
	    clear matlabbatch
	    matlabbatch = {};
	    [tempa,tempb,tempc] = fileparts('${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii');
	    matlabbatch{end+1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	    matlabbatch{end}.spm.spatial.smooth.fwhm   = [${fwhmsurf} ${fwhmsurf} ${fwhmsurf}];
	    matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
	    matlabbatch{end}.spm.spatial.smooth.im     = 0;
	    matlabbatch{end}.spm.spatial.smooth.prefix = ['s' num2str(${fwhmsurf})];	
	    spm_jobman('run',matlabbatch);
	end
	
EOF
else
     cp ${DIR}/${asldir}/asl.rem.mc.nii ${DIR}/${asldir}/s${fwhmvol}asl.rem.mc.nii
fi


# =====================================================================================
#                 PROJECTION OF CBF AND PERF MAPS ON CORTICAL SURFACE
# =====================================================================================

# mask
mri_vol2surf --mov ${DIR}/${asldir}/asl_mask_dil.nii --reg ${DIR}/${asldir}/asl.reg --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/${asldir}/brain.fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
mri_binarize --i ${DIR}/${asldir}/brain.fsaverage.lh.nii --min .00001 --o ${DIR}/${asldir}/brain.fsaverage.lh.nii
mri_vol2surf --mov ${DIR}/${asldir}/asl_mask_dil.nii --reg ${DIR}/${asldir}/asl.reg --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/${asldir}/brain.fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
mri_binarize --i ${DIR}/${asldir}/brain.fsaverage.rh.nii --min .00001 --o ${DIR}/${asldir}/brain.fsaverage.rh.nii

# asl
mri_vol2surf --mov ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --regheader $SUBJ --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${asldir}/lh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --noreshape --cortex --surfreg sphere.reg
mri_vol2surf --mov ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --regheader $SUBJ --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${asldir}/rh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --noreshape --cortex --surfreg sphere.reg
mri_vol2surf --mov ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --regheader $SUBJ --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${asldir}/lh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --noreshape --cortex --surfreg sphere.reg
mri_vol2surf --mov ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --regheader $SUBJ --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${asldir}/rh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --noreshape --cortex --surfreg sphere.reg

# mri_vol2surf --regheader $SUBJ --trgsubject fsaverage --mov ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --hemi lh --noreshape --projfrac 0.5 --o ${DIR}/${asldir}/lh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii
# mri_vol2surf --regheader $SUBJ --trgsubject fsaverage --mov ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --hemi rh --noreshape --projfrac 0.5 --o ${DIR}/${asldir}/rh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii
# mri_vol2surf --regheader $SUBJ --trgsubject fsaverage --mov ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --hemi lh --noreshape --projfrac 0.5 --o ${DIR}/${asldir}/lh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii
# mri_vol2surf --regheader $SUBJ --trgsubject fsaverage --mov ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --hemi rh --noreshape --projfrac 0.5 --o ${DIR}/${asldir}/rh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii

# surface smoothing
mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${asldir}/lh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --fwhm ${fwhmsurf} --o ${DIR}/${asldir}/lh.s${fwhmsurf}rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --mask ${DIR}/${asldir}/brain.fsaverage.lh.nii
mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${asldir}/rh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --fwhm ${fwhmsurf} --o ${DIR}/${asldir}/lh.s${fwhmsurf}rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --mask ${DIR}/${asldir}/brain.fsaverage.rh.nii
mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${asldir}/lh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --fwhm ${fwhmsurf} --o ${DIR}/${asldir}/lh.s${fwhmsurf}rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --mask ${DIR}/${asldir}/brain.fsaverage.lh.nii
mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${asldir}/rh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --fwhm ${fwhmsurf} --o ${DIR}/${asldir}/rh.s${fwhmsurf}rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.nii --mask ${DIR}/${asldir}/brain.fsaverage.rh.nii

if [ $DoPVE -eq 1 ] 
then

    mri_vol2surf --mov ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --regheader $SUBJ --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${asldir}/lh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --noreshape --cortex --surfreg sphere.reg
    mri_vol2surf --mov ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --regheader $SUBJ --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${asldir}/rh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --noreshape --cortex --surfreg sphere.reg
    mri_vol2surf --mov ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --regheader $SUBJ --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${asldir}/lh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --noreshape --cortex --surfreg sphere.reg
    mri_vol2surf --mov ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --regheader $SUBJ --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${asldir}/rh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --noreshape --cortex --surfreg sphere.reg

    # surface smoothing
    mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${asldir}/lh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --fwhm ${fwhmsurf} --o ${DIR}/${asldir}/lh.s${fwhmsurf}rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --mask ${DIR}/${asldir}/brain.fsaverage.lh.nii
    mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${asldir}/rh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --fwhm ${fwhmsurf} --o ${DIR}/${asldir}/rh.s${fwhmsurf}rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --mask ${DIR}/${asldir}/brain.fsaverage.rh.nii
    mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${asldir}/lh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --fwhm ${fwhmsurf} --o ${DIR}/${asldir}/lh.s${fwhmsurf}rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --mask ${DIR}/${asldir}/brain.fsaverage.lh.nii
    mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${asldir}/rh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --fwhm ${fwhmsurf} --o ${DIR}/${asldir}/rh.s${fwhmsurf}rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --mask ${DIR}/${asldir}/brain.fsaverage.rh.nii

#     mri_vol2surf --regheader $SUBJ --trgsubject fsaverage --mov ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --hemi lh --noreshape --projfrac 0.5 --o ${DIR}/${asldir}/lh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.mgz
#     mri_vol2surf --regheader $SUBJ --trgsubject fsaverage --mov ${DIR}/${asldir}/rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --hemi rh --noreshape --projfrac 0.5 --o ${DIR}/${asldir}/rh.rmeanPERF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.mgz
#     mri_vol2surf --regheader $SUBJ --trgsubject fsaverage --mov ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --hemi lh --noreshape --projfrac 0.5 --o ${DIR}/${asldir}/lh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.mgz
#     mri_vol2surf --regheader $SUBJ --trgsubject fsaverage --mov ${DIR}/${asldir}/rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.nii --hemi rh --noreshape --projfrac 0.5 --o ${DIR}/${asldir}/rh.rmeanCBF_${subMethod}_s${fwhmvol}asl.rem.mc.anat.pve.mgz

fi