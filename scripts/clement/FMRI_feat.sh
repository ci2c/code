#!/bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_feat.sh  -o  <Outdir>  -subj  <SubjName>  -epi  <file> -TR <value> -rmframe <value> -fwhm <value> -brain_mask <file>  -seed <file> -seed_name <name> -WM <file> -CSF <file> -FS_dir <dir> [-Prepro -useFix -SPMseg -PostStat -full] "
	echo ""
	echo "  -o                           : Path to output directory for FEAT analysis"
	echo "  -subj                        : Subject ID"
	echo "  -epi                         : epi volume (.nii or .nii.gz). If only PostStat use, insert preprocess epi"
	echo "  -TR                          : epi TR value (s)"
	echo "  -rmframe                     : number of frame to remove (default = 3)"
	echo "  -fwhm                        : spatial smoothing value. By default, no spatial smoothing for preprocessing"
    echo "  -brain_mask                  : brain mask from freesurfer"
    echo "  -seed                        : volume needed for seed analysis (if check, don't use -Prepro)"
    echo "  -seed_name                   : name of seed for file name"
    echo "  -WM                          : WM mask volume needed for seed analysis correction. Chedk -SPMseg if you don't have it"
    echo "  -CSF                         : CSF mask volume needed for seed analysis correction. Chedk -SPMseg if you don't have it"
    echo "  -FS_dir                      : FreeSurfer directory"
	echo ""
	echo "  Options "
	echo "  -Prepro                      : Will only perform FEAT preprocessing"
	echo "  -PostStat                    : Will only perform FEAT  post-stat, assuming that preprocessing FEAT folder is OUTPUT_DIR/FEAT/feat_pepro"
	echo "  -full                        : Will only perform full FEAT  analysis"
	echo "  -useFix                      : Use FSL Fix correction for atefacts (standard training file). Use ICA"
	echo "  -SPMseg                      : Use SPM segmentation for WM and CSF mask volume"
	echo ""
	echo "Usage: FMRI_feat.sh  -o  <Outdir>  -subj  <SubjName>  -epi  <file> -TR <value> -rmframe <value> -fwhm <value> -brain_mask <file>  -seed <file> -seed_name <name> -WM <file> -CSF <file> -FS_dir <dir> [-Prepro -useFix -SPMseg -PostStat -full]"
	echo ""
	echo " Clement Bournonville -- CI2C -- CHRUL -- Novembre 2015"
	exit 1
fi

# Default 
Prepro=0
PostStat=0
full=0
useFix=1
SPMseg=0


index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_feat.sh  -o  <Outdir>  -subj  <SubjName>  -epi  <file> -TR <value> -rmframe <value> -fwhm <value> -brain_mask <file>  -seed <file> -seed_name <name> -WM <file> -CSF <file> -FS_dir <dir> [-Prepro -useFix -SPMseg -PostStat -full] "
		echo ""
		echo "  -o                           : Path to output directory for FEAT analysis"
		echo "  -subj                        : Subject ID"
		echo "  -epi                         : epi volume (.nii or .nii.gz)"
		echo "  -TR                          : epi TR value (s)"
		echo "  -rmframe                     : number of frame to remove (default = 3)"
		echo "  -fwhm                        : spatial smoothing value. By default, no spatial smoothing for preprocessing"
    	echo "  -brain_mask                  : brain mask from freesurfer"
    	echo "  -seed                        : volume needed for seed analysis"
    	echo "  -seed_name                   : name of seed for file name"
    	echo "  -WM                          : WM mask volume needed for seed analysis correction. Chedk -SPMseg if you don't have it"
    	echo "  -CSF                         : CSF mask volume needed for seed analysis correction. Chedk -SPMseg if you don't have it"
    	echo "  -FS_dir                      : FreeSurfer directory"
		echo ""
		echo "  Options "
		echo "  -Prepro                      : Will only perform FEAT preprocessing"
		echo "  -PostStat                    : Will only perform FEAT  post-stat, assuming that preprocessing FEAT folder is OUTPUT_DIR/FEAT/feat_pepro"
		echo "  -full                        : Will only perform full FEAT  analysis"
		echo "  -useFix                      : Use FSL Fix correction for atefacts (standard training file). Use ICA"
		echo "  -SPMseg                      : Use SPM segmentation for WM and CSF mask volume"
		echo ""
		echo "Usage: FMRI_feat.sh  -o  <Outdir>  -subj  <SubjName>  -epi  <file> -TR <value> -rmframe <value> -fwhm <value> -brain_mask <file>  -seed <file> -seed_name <name> -WM <file> -CSF <file> -FS_dir <dir> [-Prepro -useFix -SPMseg -PostStat -full]"
		echo ""
		echo " Clement Bournonville -- CI2C -- CHRUL -- Novembre 2015"
		exit 1
		;;
	-o)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "OUTPUT's DIRECTORY : ${OUTPUT_DIR}"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "SUBJECT's NAME : ${SUBJ}"
		;;
	-epi)
		index=$[$index+1]
		eval EPI=\${$index}
		echo "EPI file : ${EPI}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-rmframe)
		index=$[$index+1]
		eval rmframe=\${$index}
		echo "frame removal : ${rmframe}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "spatial smoothing : ${fwhm}"
		;;	
	-brain_mask)
		index=$[$index+1]
		eval brain_mask=\${$index}
		echo "brain mask : ${brain_mask}"
		;;
	-seed)
		index=$[$index+1]
		eval seed_mask=\${$index}
		echo "seed file : ${seed_mask}"
		;;
	-seed_name)
		index=$[$index+1]
		eval seed_name=\${$index}
		echo "seed file : ${seed_name}"
		;;
	-WM)
		index=$[$index+1]
		eval WM_mask=\${$index}
		echo "WM : ${WM_mask}"
		;;	
	-CSF)
		index=$[$index+1]
		eval CSF_mask=\${$index}
		echo "CSF : ${CSF_mask}"
		;;
	-FS_dir)
		index=$[$index+1]
		eval FS_dir=\${$index}
		echo "FS directory : ${FS_dir}"
		;;
	-useFix)
		UseFix=1
		echo "Use FSL Fix correction for atefacts (standard training file). Use ICA"
		;;
	-Prepro)
		Prepro=1
		echo "Will only perform FEAT preprocessing"
		;;
	-PostStat)
		PostStat=1
		echo "Will only perform FEAT post-processing stats"
		;;
	-full)
		full=1
		echo "Will only perform full FEAT analysis"
		;;
	-SPMseg)
		SPMseg=1
		echo "Will perform SPM segmentation"
		;;

	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_feat.sh  -o  <Outdir>  -subj  <SubjName>  -epi  <file> -TR <value> -rmframe <value> -fwhm <value> -brain_mask <file>  -seed <file> -seed_name <name> -WM <file> -CSF <file> -FS_dir <dir> [-Prepro -useFix -SPMseg -PostStat -full] "
		echo ""
		echo "  -o                           : Path to output directory for FEAT analysis"
		echo "  -subj                        : Subject ID"
		echo "  -epi                         : epi volume (.nii or .nii.gz)"
		echo "  -TR                          : epi TR value (s)"
		echo "  -rmframe                     : number of frame to remove (default = 3)"
		echo "  -fwhm                        : spatial smoothing value. By default, no spatial smoothing for preprocessing"
    	echo "  -brain_mask                  : brain mask from freesurfer"
    	echo "  -seed                        : volume needed for seed analysis (if check, don't use -Prepro)"
    	echo "  -seed_name                   : name of seed for file name"
    	echo "  -WM                          : WM mask volume needed for seed analysis correction. Chedk -SPMseg if you don't have it"
    	echo "  -CSF                         : CSF mask volume needed for seed analysis correction. Chedk -SPMseg if you don't have it"
    	echo "  -FS_dir                      : FreeSurfer directory"
		echo ""
		echo "  Options "
		echo "  -Prepro                      : Will only perform FEAT preprocessing"
		echo "  -PostStat                    : Will only perform FEAT  post-stat, assuming that preprocessing FEAT folder is OUTPUT_DIR/FEAT/feat_pepro"
		echo "  -full                        : Will only perform full FEAT  analysis"
		echo "  -useFix                      : Use FSL Fix correction for atefacts (standard training file). Use ICA"
		echo "  -SPMseg                      : Use SPM segmentation for WM and CSF mask volume"
		echo ""
		echo "Usage: FMRI_feat.sh  -o  <Outdir>  -subj  <SubjName>  -epi  <file> -TR <value> -rmframe <value> -fwhm <value> -brain_mask <file>  -seed <file> -seed_name <name> -WM <file> -CSF <file> -FS_dir <dir> [-Prepro -useFix -SPMseg -PostStat -full]"
		echo ""
		echo " Clement Bournonville -- CI2C -- CHRUL -- Novembre 2015"
		exit 1
		;;
	esac
	index=$[$index+1]
done


echo "=========================================================="
echo "=====================RUN ${SUBJ}========================"
echo "=========================================================="


# frame number extraction
tmp=`mri_info ${EPI} | grep nframes:`
frm_nb=${tmp:16: (${#tmp})}


if [ $Prepro -eq 1 ] || [ $full -eq 1 ] && [ $PostStat -eq 0 ]; then

# -------------------------------------------------------------------------
#                          FEAT PREPROCESSING 
# -------------------------------------------------------------------------

# Create results dir in outputdir
if [ ! -d ${OUTPUT_DIR}/FEAT ]; then
mkdir ${OUTPUT_DIR}/FEAT
fi

echo "Final output : ${OUTPUT_DIR}/FEAT"

# Initialisation Pre-stat FEAT
rm -rf $OUTPUT_DIR/FEAT/design.fsf
mri_convert $brain_mask $brain_mask --out_orientation LAS


#FEAT design 
echo "
# FEAT version number
set fmri(version) 5.98

# Are we in MELODIC?
set fmri(inmelodic) 0

# Analysis level
# 1 : First-level analysis
# 2 : Higher-level analysis
set fmri(level) 1

# Which stages to run
# 0 : No first-level analysis (registration and/or group stats only)
# 7 : Full first-level analysis
# 1 : Pre-Stats
# 3 : Pre-Stats + Stats
# 2 :             Stats
# 6 :             Stats + Post-stats
# 4 :                     Post-stats
set fmri(analysis) 1

# Use relative filenames
set fmri(relative_yn) 0

# Balloon help
set fmri(help_yn) 1

# Run Featwatche
set fmri(featwatcher_yn) 1

# Cleanup first-level standard-space images
set fmri(sscleanup_yn) 0

# Output directory
set fmri(outputdir) "\"${OUTPUT_DIR}/FEAT/.\""

# TR(s)
set fmri(tr) ${TR}

# Total volumes
set fmri(npts) ${frm_nb}

# Delete volumes
set fmri(ndelete) ${rmframe}

# Perfusion tag/control order
set fmri(tagfirst) 1

# Number of first-level analyses
set fmri(multiple) 1

# Higher-level input type
# 1 : Inputs are lower-level FEAT directories
# 2 : Inputs are cope images from FEAT directories
set fmri(inputtype) 1

# Carry out pre-stats processing?
set fmri(filtering_yn) 1

# Brain/background threshold, %
set fmri(brain_thresh) 10

# Critical z for design efficiency calculation
set fmri(critical_z) 5.3

# Noise level
set fmri(noise) 0.66

# Noise AR(1)
set fmri(noisear) 0.34

# Post-stats-only directory copying
# 0 : Overwrite original post-stats results
# 1 : Copy original FEAT directory for new Contrasts, Thresholding, Rendering
set fmri(newdir_yn) 0

# Motion correction
# 0 : None
# 1 : MCFLIRT
set fmri(mc) 1

# Spin-history (currently obsolete)
set fmri(sh_yn) 0

# B0 fieldmap unwarping?
set fmri(regunwarp_yn) 0

# EPI dwell time (ms)
set fmri(dwell) 0.7

# EPI TE (ms)
set fmri(te) 35

# % Signal loss threshold
set fmri(signallossthresh) 10

# Unwarp direction
set fmri(unwarp_dir) y-

# Slice timing correction
# 0 : None
# 1 : Regular up (0, 1, 2, 3, ...)
# 2 : Regular down
# 3 : Use slice order file
# 4 : Use slice timings file
# 5 : Interleaved (0, 2, 4 ... 1, 3, 5 ... )
set fmri(st) 5

# Slice timings file
set fmri(st_file) ""

# BET brain extraction
set fmri(bet_yn) 1

# Spatial smoothing FWHM (mm)
set fmri(smooth) 0.0

# Intensity normalization
set fmri(norm_yn) 1

# Perfusion subtraction
set fmri(perfsub_yn) 0

# Highpass temporal filtering
set fmri(temphp_yn) 1

# Lowpass temporal filtering
set fmri(templp_yn) 0

# MELODIC ICA data exploration
set fmri(melodic_yn) 1

# Carry out main stats?
set fmri(stats_yn) 0

# Carry out prewhitening?
set fmri(prewhiten_yn) 1

# Add motion parameters to model
# 0 : No
# 1 : Yes
set fmri(motionevs) 0

# Robust outlier detection in FLAME?
set fmri(robust_yn) 0

# Higher-level modelling
# 3 : Fixed effects
# 0 : Mixed Effects: Simple OLS
# 2 : Mixed Effects: FLAME 1
# 1 : Mixed Effects: FLAME 1+2
set fmri(mixed_yn) 2

# Number of EVs
set fmri(evs_orig) 1
set fmri(evs_real) 2
set fmri(evs_vox) 0

# Number of contrasts
set fmri(ncon_orig) 1
set fmri(ncon_real) 1

# Number of F-tests
set fmri(nftests_orig) 0
set fmri(nftests_real) 0

# Add constant column to design matrix? (obsolete)
set fmri(constcol) 0

# Carry out post-stats steps?
set fmri(poststats_yn) 0

# Pre-threshold masking?
set fmri(threshmask) ""

# Thresholding
# 0 : None
# 1 : Uncorrected
# 2 : Voxel
# 3 : Cluster
set fmri(thresh) 3

# P threshold
set fmri(prob_thresh) 0.05

# Z threshold
set fmri(z_thresh) 2.3

# Z min/max for colour rendering
# 0 : Use actual Z min/max
# 1 : Use preset Z min/max
set fmri(zdisplay) 0

# Z min in colour rendering
set fmri(zmin) 2

# Z max in colour rendering
set fmri(zmax) 8

# Colour rendering type
# 0 : Solid blobs
# 1 : Transparent blobs
set fmri(rendertype) 1

# Background image for higher-level stats overlays
# 1 : Mean highres
# 2 : First highres
# 3 : Mean functional
# 4 : First functional
# 5 : Standard space template
set fmri(bgimage) 1

# Create time series plots
set fmri(tsplot_yn) 1

# Registration?
set fmri(reg_yn) 1

# Registration to initial structural
set fmri(reginitial_highres_yn) 0

# Search space for registration to initial structural
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(reginitial_highres_search) 90

# Degrees of Freedom for registration to initial structural
set fmri(reginitial_highres_dof) 3

# Registration to main structural
set fmri(reghighres_yn) 1

# Search space for registration to main structural
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(reghighres_search) 90

# Degrees of Freedom for registration to main structural
set fmri(reghighres_dof) 6

# Registration to standard image?
set fmri(regstandard_yn) 1

# Standard image
set fmri(regstandard) "\"/home/global//fsl/data/standard/MNI152_T1_2mm_brain\""

# Search space for registration to standard space
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(regstandard_search) 90

# Degrees of Freedom for registration to standard space
set fmri(regstandard_dof) 12

# Do nonlinear registration from structural to standard space?
set fmri(regstandard_nonlinear_yn) 0

# Control nonlinear warp field resolution
set fmri(regstandard_nonlinear_warpres) 10 

# High pass filter cutoff
set fmri(paradigm_hp) 100

# Number of lower-level copes feeding into higher-level analysis
set fmri(ncopeinputs) 0

# 4D AVW data or FEAT directory (1)
set feat_files(1) "\"${EPI}\""

# Add confound EVs text file
set fmri(confoundevs) 0

# Subject's structural image for analysis 1
set highres_files(1) "\"${brain_mask}\""

# EV 1 title
set fmri(evtitle1) "\"te\""

# Basic waveform shape (EV 1)
# 0 : Square
# 1 : Sinusoid
# 2 : Custom (1 entry per volume)
# 3 : Custom (3 column format)
# 4 : Interaction
# 10 : Empty (all zeros)
set fmri(shape1) 0

# Convolution (EV 1)
# 0 : None
# 1 : Gaussian
# 2 : Gamma
# 3 : Double-Gamma HRF
# 4 : Gamma basis functions
# 5 : Sine basis functions
# 6 : FIR basis functions
set fmri(convolve1) 2

# Convolve phase (EV 1)
set fmri(convolve_phase1) 0

# Apply temporal filtering (EV 1)
set fmri(tempfilt_yn1) 1

# Add temporal derivative (EV 1)
set fmri(deriv_yn1) 1

# Skip (EV 1)
set fmri(skip1) 0

# Off (EV 1)
set fmri(off1) 30

# On (EV 1)
set fmri(on1) 30

# Phase (EV 1)
set fmri(phase1) 0

# Stop (EV 1)
set fmri(stop1) -1

# Gamma sigma (EV 1)
set fmri(gammasigma1) 3

# Gamma delay (EV 1)
set fmri(gammadelay1) 6

# Orthogonalise EV 1 wrt EV 0
set fmri(ortho1.0) 0

# Orthogonalise EV 1 wrt EV 1
set fmri(ortho1.1) 0

# Contrast & F-tests mode
# real : control real EVs
# orig : control original EVs
set fmri(con_mode_old) orig
set fmri(con_mode) orig

# Display images for contrast_real 1
set fmri(conpic_real.1) 1

# Title for contrast_real 1
set fmri(conname_real.1) "\"contrast\""

# Real contrast_real vector 1 element 1
set fmri(con_real1.1) 1

# Real contrast_real vector 1 element 2
set fmri(con_real1.2) 0

# Display images for contrast_orig 1
set fmri(conpic_orig.1) 1

# Title for contrast_orig 1
set fmri(conname_orig.1) "\"contrast\""

# Real contrast_orig vector 1 element 1
set fmri(con_orig1.1) 1

# Contrast masking - use >0 instead of thresholding?
set fmri(conmask_zerothresh_yn) 0

# Do contrast masking at all?
set fmri(conmask1_1) 0

##########################################################
# Now options that don't appear in the GUI

# Alternative example_func image (not derived from input 4D dataset)
set fmri(alternative_example_func) ""

# Alternative (to BETting) mask image
set fmri(alternative_mask) ""

# Initial structural space registration initialisation transform
set fmri(init_initial_highres) ""

# Structural space registration initialisation transform
set fmri(init_highres) ""

# Standard space registration initialisation transform
set fmri(init_standard) ""

# For full FEAT analysis: overwrite existing .feat output dir?
set fmri(overwrite_yn) 1" >> ${OUTPUT_DIR}/FEAT/design.fsf

# Declare fsl path for FEAT (need fsl not fsl50)
FSLDIR=${Soft_dir}/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR
feat ${OUTPUT_DIR}/FEAT/design.fsf

# Loop until FEAT finished 
feat_task=`ls ${OUTPUT_DIR}/FEAT/.feat/reg/* 2> /dev/null | grep "example_func2standard" | wc -l`
while [ ! $feat_task = 5 ]
do

	if [ $feat_task -lt 5 ] && [ $feat_task -gt 0 ]; then

		>> ${OUTPUT_DIR}/FEAT/error_feat.log
		exit
	fi

	feat_task=` ls ${OUTPUT_DIR}/FEAT/.feat/reg/* 2> /dev/null | grep "example_func2standard" | wc -l`
done

# -------------------------------------------------------------------------
#                          FSL FIX CORRECTION
# -------------------------------------------------------------------------

if [ $useFix = 1 ]; then
# Declare fsl50 path for fix (need fsl50 not fsl)
	FSLDIR=/home/global/fsl50
	. ${FSLDIR}/etc/fslconf/fsl.sh
	PATH=${FSLDIR}/bin:${PATH}
	export FSLDIR


	echo "fix ${OUTPUT_DIR}/FEAT/.feat /home/global/fix1.06/training_files/Standard.RData 20"
	/home/global/fix1.06/fix ${OUTPUT_DIR}/FEAT/.feat /home/global/fix1.06/training_files/Standard.RData 20
fi

mv ${OUTPUT_DIR}/FEAT/.feat ${OUTPUT_DIR}/FEAT/feat_prepro

fi

# -------------------------------------------------------------------------
#                SPM White Matter and CSF Segmentation 
# -------------------------------------------------------------------------

if [ $SPMseg -eq 1 ]; then

	T1_vol=${FS_dir}/mri/T1.nii

	mri_convert ${FS_dir}/mri/T1.mgz $T1_vol --out_orientation LAS
	/usr/local/matlab11/bin/matlab -nodisplay <<EOF

    cd ${HOME}
    p = pathdef11;
    addpath(p);

    spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	matlabbatch{1}.spm.spatial.preproc.channel.vols = {'${T1_vol},1'};
	matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
	matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
	matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,1'};
	matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
	matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,2'};
	matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
	matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,3'};
	matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
	matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,4'};
	matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
	matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,5'};
	matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
	matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,6'};
	matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
	matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
	matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
	matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
	matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
	matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
	matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
	matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
	matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
	matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];



	spm_jobman('run',matlabbatch);

EOF

mkdir ${FS_dir}/mri/spm
mv ${FS_dir}/mri/c2T1.nii ${FS_dir}/mri/spm/SPM_WMmask.nii
mv ${FS_dir}/mri/c3T1.nii ${FS_dir}/mri/spm/SPM_CSFmask.nii

fi	

# -------------------------------------------------------------------------
#            Time Series extraction for seed-based analysis 
# -------------------------------------------------------------------------


if [ $PostStat -eq 1 ] || [ $full -eq 1 ]; then

WM_mask=${FS_dir}/mri/spm/SPM_WMmask.nii
CSF_mask=${FS_dir}/mri/spm/SPM_CSFmask.nii

mri_convert -i ${WM_mask} -o ${OUTPUT_DIR}/WM.nii -rl ${OUTPUT_DIR}/FEAT/feat_prepro/mean_func.nii.gz
mri_convert -i ${CSF_mask} -o ${OUTPUT_DIR}/CSF.nii -rl ${OUTPUT_DIR}/FEAT/feat_prepro/mean_func.nii.gz
mri_convert -i ${seed_mask} -o ${OUTPUT_DIR}/${seed_name}.nii -rl ${OUTPUT_DIR}/FEAT/feat_prepro/mean_func.nii.gz

fslmeants -i ${OUTPUT_DIR}/FEAT/feat_prepro/filtered_func_data_clean.nii.gz -o ${OUTPUT_DIR}/FEAT/WM_TS.txt -m ${OUTPUT_DIR}/WM.nii
fslmeants -i ${OUTPUT_DIR}/FEAT/feat_prepro/filtered_func_data_clean.nii.gz -o ${OUTPUT_DIR}/FEAT/CSF_TS.txt -m ${OUTPUT_DIR}/CSF.nii
fslmeants -i ${OUTPUT_DIR}/FEAT/feat_prepro/filtered_func_data_clean.nii.gz -o ${OUTPUT_DIR}/FEAT/${seed_name}_TS.txt -m ${OUTPUT_DIR}/${seed_name}.nii
fslmeants -i ${OUTPUT_DIR}/FEAT/feat_prepro/filtered_func_data_clean.nii.gz -o ${OUTPUT_DIR}/FEAT/global_TS.txt -m ${OUTPUT_DIR}/FEAT/feat_prepro/mask.nii.gz


EPI=${OUTPUT_DIR}/FEAT/feat_prepro/filtered_func_data_clean*

tmp=`mri_info ${EPI} | grep nframes:`
frm_nb=${tmp:16: (${#tmp})}
# -------------------------------------------------------------------------
#                      FSL FEAT PostStat 
# -------------------------------------------------------------------------

rm -rf ${OUTPUT_DIR}/FEAT/design.fsf

echo "
# FEAT version number
set fmri(version) 5.98

# Are we in MELODIC?
set fmri(inmelodic) 0

# Analysis level
# 1 : First-level analysis
# 2 : Higher-level analysis
set fmri(level) 1

# Which stages to run
# 0 : No first-level analysis (registration and/or group stats only)
# 7 : Full first-level analysis
# 1 : Pre-Stats
# 3 : Pre-Stats + Stats
# 2 :             Stats
# 6 :             Stats + Post-stats
# 4 :                     Post-stats
set fmri(analysis) 7

# Use relative filenames
set fmri(relative_yn) 0

# Balloon help
set fmri(help_yn) 1

# Run Featwatcher
set fmri(featwatcher_yn) 1

# Cleanup first-level standard-space images
set fmri(sscleanup_yn) 0

# Output directory
set fmri(outputdir) "\"${OUTPUT_DIR}/FEAT/.\""

# TR(s)
set fmri(tr) ${TR}

# Total volumes
set fmri(npts) ${frm_nb}

# Delete volumes
set fmri(ndelete) 0

# Perfusion tag/control order
set fmri(tagfirst) 1

# Number of first-level analyses
set fmri(multiple) 1

# Higher-level input type
# 1 : Inputs are lower-level FEAT directories
# 2 : Inputs are cope images from FEAT directories
set fmri(inputtype) 1

# Carry out pre-stats processing?
set fmri(filtering_yn) 1

# Brain/background threshold, %
set fmri(brain_thresh) 10

# Critical z for design efficiency calculation
set fmri(critical_z) 5.3

# Noise level
set fmri(noise) 0.66

# Noise AR(1)
set fmri(noisear) 0.34

# Post-stats-only directory copying
# 0 : Overwrite original post-stats results
# 1 : Copy original FEAT directory for new Contrasts, Thresholding, Rendering
set fmri(newdir_yn) 0

# Motion correction
# 0 : None
# 1 : MCFLIRT
set fmri(mc) 0

# Spin-history (currently obsolete)
set fmri(sh_yn) 0

# B0 fieldmap unwarping?
set fmri(regunwarp_yn) 0

# EPI dwell time (ms)
set fmri(dwell) 0.7

# EPI TE (ms)
set fmri(te) 35

# % Signal loss threshold
set fmri(signallossthresh) 10

# Unwarp direction
set fmri(unwarp_dir) y-

# Slice timing correction
# 0 : None
# 1 : Regular up (0, 1, 2, 3, ...)
# 2 : Regular down
# 3 : Use slice order file
# 4 : Use slice timings file
# 5 : Interleaved (0, 2, 4 ... 1, 3, 5 ... )
set fmri(st) 0

# Slice timings file
set fmri(st_file) ""

# BET brain extraction
set fmri(bet_yn) 0

# Spatial smoothing FWHM (mm)
set fmri(smooth) ${fwhm}

# Intensity normalization
set fmri(norm_yn) 0

# Perfusion subtraction
set fmri(perfsub_yn) 0

# Highpass temporal filtering
set fmri(temphp_yn) 0

# Lowpass temporal filtering
set fmri(templp_yn) 0

# MELODIC ICA data exploration
set fmri(melodic_yn) 0

# Carry out main stats?
set fmri(stats_yn) 1

# Carry out prewhitening?
set fmri(prewhiten_yn) 1

# Add motion parameters to model
# 0 : No
# 1 : Yes
set fmri(motionevs) 1

# Robust outlier detection in FLAME?
set fmri(robust_yn) 0

# Higher-level modelling
# 3 : Fixed effects
# 0 : Mixed Effects: Simple OLS
# 2 : Mixed Effects: FLAME 1
# 1 : Mixed Effects: FLAME 1+2
set fmri(mixed_yn) 2

# Number of EVs
set fmri(evs_orig) 4
set fmri(evs_real) 4
set fmri(evs_vox) 0

# Number of contrasts
set fmri(ncon_orig) 1
set fmri(ncon_real) 1

# Number of F-tests
set fmri(nftests_orig) 0
set fmri(nftests_real) 0

# Add constant column to design matrix? (obsolete)
set fmri(constcol) 0

# Carry out post-stats steps?
set fmri(poststats_yn) 1

# Pre-threshold masking?
set fmri(threshmask) ""

# Thresholding
# 0 : None
# 1 : Uncorrected
# 2 : Voxel
# 3 : Cluster
set fmri(thresh) 3

# P threshold
set fmri(prob_thresh) 0.05

# Z threshold
set fmri(z_thresh) 2.3

# Z min/max for colour rendering
# 0 : Use actual Z min/max
# 1 : Use preset Z min/max
set fmri(zdisplay) 0

# Z min in colour rendering
set fmri(zmin) 2

# Z max in colour rendering
set fmri(zmax) 8

# Colour rendering type
# 0 : Solid blobs
# 1 : Transparent blobs
set fmri(rendertype) 1

# Background image for higher-level stats overlays
# 1 : Mean highres
# 2 : First highres
# 3 : Mean functional
# 4 : First functional
# 5 : Standard space template
set fmri(bgimage) 1

# Create time series plots
set fmri(tsplot_yn) 1

# Registration?
set fmri(reg_yn) 1

# Registration to initial structural
set fmri(reginitial_highres_yn) 0

# Search space for registration to initial structural
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(reginitial_highres_search) 90

# Degrees of Freedom for registration to initial structural
set fmri(reginitial_highres_dof) 3

# Registration to main structural
set fmri(reghighres_yn) 0

# Search space for registration to main structural
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(reghighres_search) 90

# Degrees of Freedom for registration to main structural
set fmri(reghighres_dof) 6

# Registration to standard image?
set fmri(regstandard_yn) 1

# Standard image
set fmri(regstandard) "\"/home/global//fsl/data/standard/MNI152_T1_2mm_brain\""

# Search space for registration to standard space
# 0   : No search
# 90  : Normal search
# 180 : Full search
set fmri(regstandard_search) 90

# Degrees of Freedom for registration to standard space
set fmri(regstandard_dof) 12

# Do nonlinear registration from structural to standard space?
set fmri(regstandard_nonlinear_yn) 0

# Control nonlinear warp field resolution
set fmri(regstandard_nonlinear_warpres) 10 

# High pass filter cutoff
set fmri(paradigm_hp) 100

# Number of lower-level copes feeding into higher-level analysis
set fmri(ncopeinputs) 0

# 4D AVW data or FEAT directory (1)
set feat_files(1) "\"${EPI}\""

# Add confound EVs text file
set fmri(confoundevs) 0

# EV 1 title
set fmri(evtitle1) "\"${seed_name}\""

# Basic waveform shape (EV 1)
# 0 : Square
# 1 : Sinusoid
# 2 : Custom (1 entry per volume)
# 3 : Custom (3 column format)
# 4 : Interaction
# 10 : Empty (all zeros)
set fmri(shape1) 2

# Convolution (EV 1)
# 0 : None
# 1 : Gaussian
# 2 : Gamma
# 3 : Double-Gamma HRF
# 4 : Gamma basis functions
# 5 : Sine basis functions
# 6 : FIR basis functions
set fmri(convolve1) 0

# Convolve phase (EV 1)
set fmri(convolve_phase1) 0

# Apply temporal filtering (EV 1)
set fmri(tempfilt_yn1) 0

# Add temporal derivative (EV 1)
set fmri(deriv_yn1) 0

# Custom EV file (EV 1)
set fmri(custom1) "\"${OUTPUT_DIR}/FEAT/${seed_name}_TS.txt\""

# Orthogonalise EV 1 wrt EV 0
set fmri(ortho1.0) 0

# Orthogonalise EV 1 wrt EV 1
set fmri(ortho1.1) 0

# Orthogonalise EV 1 wrt EV 2
set fmri(ortho1.2) 0

# Orthogonalise EV 1 wrt EV 3
set fmri(ortho1.3) 0

# Orthogonalise EV 1 wrt EV 4
set fmri(ortho1.4) 0

# EV 2 title
set fmri(evtitle2) "\"WM\""

# Basic waveform shape (EV 2)
# 0 : Square
# 1 : Sinusoid
# 2 : Custom (1 entry per volume)
# 3 : Custom (3 column format)
# 4 : Interaction
# 10 : Empty (all zeros)
set fmri(shape2) 2

# Convolution (EV 2)
# 0 : None
# 1 : Gaussian
# 2 : Gamma
# 3 : Double-Gamma HRF
# 4 : Gamma basis functions
# 5 : Sine basis functions
# 6 : FIR basis functions
set fmri(convolve2) 0

# Convolve phase (EV 2)
set fmri(convolve_phase2) 0

# Apply temporal filtering (EV 2)
set fmri(tempfilt_yn2) 0

# Add temporal derivative (EV 2)
set fmri(deriv_yn2) 0

# Custom EV file (EV 2)
set fmri(custom2) "\"${OUTPUT_DIR}/FEAT/WM_TS.txt\""

# Orthogonalise EV 2 wrt EV 0
set fmri(ortho2.0) 0

# Orthogonalise EV 2 wrt EV 1
set fmri(ortho2.1) 0

# Orthogonalise EV 2 wrt EV 2
set fmri(ortho2.2) 0

# Orthogonalise EV 2 wrt EV 3
set fmri(ortho2.3) 0

# Orthogonalise EV 2 wrt EV 4
set fmri(ortho2.4) 0

# EV 3 title
set fmri(evtitle3) "\"CSF\""

# Basic waveform shape (EV 3)
# 0 : Square
# 1 : Sinusoid
# 2 : Custom (1 entry per volume)
# 3 : Custom (3 column format)
# 4 : Interaction
# 10 : Empty (all zeros)
set fmri(shape3) 2

# Convolution (EV 3)
# 0 : None
# 1 : Gaussian
# 2 : Gamma
# 3 : Double-Gamma HRF
# 4 : Gamma basis functions
# 5 : Sine basis functions
# 6 : FIR basis functions
set fmri(convolve3) 0

# Convolve phase (EV 3)
set fmri(convolve_phase3) 0

# Apply temporal filtering (EV 3)
set fmri(tempfilt_yn3) 0

# Add temporal derivative (EV 3)
set fmri(deriv_yn3) 0

# Custom EV file (EV 3)
set fmri(custom3) "\"${OUTPUT_DIR}/FEAT/CSF_TS.txt\""

# Orthogonalise EV 3 wrt EV 0
set fmri(ortho3.0) 0

# Orthogonalise EV 3 wrt EV 1
set fmri(ortho3.1) 0

# Orthogonalise EV 3 wrt EV 2
set fmri(ortho3.2) 0

# Orthogonalise EV 3 wrt EV 3
set fmri(ortho3.3) 0

# Orthogonalise EV 3 wrt EV 4
set fmri(ortho3.4) 0

# EV 4 title
set fmri(evtitle4) "\"GS\""

# Basic waveform shape (EV 4)
# 0 : Square
# 1 : Sinusoid
# 2 : Custom (1 entry per volume)
# 3 : Custom (3 column format)
# 4 : Interaction
# 10 : Empty (all zeros)
set fmri(shape4) 2

# Convolution (EV 4)
# 0 : None
# 1 : Gaussian
# 2 : Gamma
# 3 : Double-Gamma HRF
# 4 : Gamma basis functions
# 5 : Sine basis functions
# 6 : FIR basis functions
set fmri(convolve4) 0

# Convolve phase (EV 4)
set fmri(convolve_phase4) 0

# Apply temporal filtering (EV 4)
set fmri(tempfilt_yn4) 0

# Add temporal derivative (EV 4)
set fmri(deriv_yn4) 0

# Custom EV file (EV 4)
set fmri(custom4) "\"${OUTPUT_DIR}/FEAT/global_TS.txt\""

# Orthogonalise EV 4 wrt EV 0
set fmri(ortho4.0) 0

# Orthogonalise EV 4 wrt EV 1
set fmri(ortho4.1) 0

# Orthogonalise EV 4 wrt EV 2
set fmri(ortho4.2) 0

# Orthogonalise EV 4 wrt EV 3
set fmri(ortho4.3) 0

# Orthogonalise EV 4 wrt EV 4
set fmri(ortho4.4) 0

# Contrast & F-tests mode
# real : control real EVs
# orig : control original EVs
set fmri(con_mode_old) orig
set fmri(con_mode) orig

# Display images for contrast_real 1
set fmri(conpic_real.1) 1

# Title for contrast_real 1
set fmri(conname_real.1) "\"contrast\""

# Real contrast_real vector 1 element 1
set fmri(con_real1.1) 1

# Real contrast_real vector 1 element 2
set fmri(con_real1.2) 0

# Real contrast_real vector 1 element 3
set fmri(con_real1.3) 0

# Real contrast_real vector 1 element 4
set fmri(con_real1.4) 0

# Display images for contrast_orig 1
set fmri(conpic_orig.1) 1

# Title for contrast_orig 1
set fmri(conname_orig.1) "\"t\""

# Real contrast_orig vector 1 element 1
set fmri(con_orig1.1) 1

# Real contrast_orig vector 1 element 2
set fmri(con_orig1.2) 0

# Real contrast_orig vector 1 element 3
set fmri(con_orig1.3) 0

# Real contrast_orig vector 1 element 4
set fmri(con_orig1.4) 0

# Contrast masking - use >0 instead of thresholding?
set fmri(conmask_zerothresh_yn) 0

# Do contrast masking at all?
set fmri(conmask1_1) 0

##########################################################
# Now options that don't appear in the GUI

# Alternative example_func image (not derived from input 4D dataset)
set fmri(alternative_example_func) ""

# Alternative (to BETting) mask image
set fmri(alternative_mask) ""

# Initial structural space registration initialisation transform
set fmri(init_initial_highres) ""

# Structural space registration initialisation transform
set fmri(init_highres) ""

# Standard space registration initialisation transform
set fmri(init_standard) ""

# For full FEAT analysis: overwrite existing .feat output dir?
set fmri(overwrite_yn) 1" >> ${OUTPUT_DIR}/FEAT/design.fsf


# Declare fsl path for FEAT (need fsl not fsl50)
FSLDIR=${Soft_dir}/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR
#
feat ${OUTPUT_DIR}/FEAT/design.fsf
#mv ${OUTPUT_DIR}/FEAT/.feat/ ${OUTPUT_DIR}/FEAT/feat_${seed_name}
fi

