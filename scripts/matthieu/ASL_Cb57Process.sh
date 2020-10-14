#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:  ASL_Cb57Process.sh -subj <patientname>"
	echo ""
	echo "  -subj       : Subject name "
	echo ""
	echo "Usage:  ASL_Cb57Process.sh -subj <patientname>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Avril,24 2014"
	echo ""
	exit 1
fi

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
	echo ""
	echo "Usage:  ASL_Cb57Process.sh -subj <patientname>"
	echo ""
	echo "  -subj       : Subject name "
	echo ""
	echo "Usage:  ASL_Cb57Process.sh -subj <patientname>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Avril,24 2014"
	echo ""
	exit 1
		;;
	-subj)
		index=$[$index+1]
		eval subject=\${$index}
		echo "subject name : ${subject}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  ASL_Cb57Process.sh -subj <patientname>"
		echo ""
		echo "  -subj       : Subject name "
		echo ""
		echo "Usage:  ASL_Cb57Process.sh -subj <patientname>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Avril,24 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${subject} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

# INPUT_DIR=/NAS/dumbo/protocoles/PreClinique/ASL_MouseCb57/data
OUTPUT_DIR=/NAS/dumbo/matthieu/PreClinique/MotorCortex_Mouse

################################
## Step 1. Prepare ASL data directory
################################

# dcm2nii -o ${INPUT_DIR}/${subject} ${INPUT_DIR}/${subject}

# if [ ! -d ${OUTPUT_DIR}/${subject} ]
# then
# 	mkdir -p ${OUTPUT_DIR}/${subject}/{RawEpi,Structural}
# else
# 	rm -rf ${OUTPUT_DIR}/${subject}/*
# 	mkdir ${OUTPUT_DIR}/${subject}/{RawEpi,Structural}
# fi
# 
# cp ${INPUT_DIR}/${subject}/*TurboRARET2*.nii.gz ${OUTPUT_DIR}/${subject}/Structural
# mv ${OUTPUT_DIR}/${subject}/Structural/*TurboRARET2*.nii.gz ${OUTPUT_DIR}/${subject}/Structural/T2.nii.gz
# 
# cp ${INPUT_DIR}/${subject}/asl.nii.gz ${OUTPUT_DIR}/${subject}
# 
# for_asl=${OUTPUT_DIR}/${subject}/asl.nii.gz

################################
## Step 2. PreProcess asl nifti files
################################

# if [ -n "${for_asl}" ]
# then
# 	if [ ! -f ${OUTPUT_DIR}/${subject}/RawEpi/epi_0000.nii ]
# 	then
# 		fslsplit ${for_asl} ${OUTPUT_DIR}/${subject}/RawEpi/epi_ -z
# 		gunzip ${OUTPUT_DIR}/${subject}/RawEpi/epi_*.gz
# 	fi

# 	if [ ! -f ${OUTPUT_DIR}/${subject}/RawEpi/repi_0000.nii ]
# 	then
# 		gunzip ${OUTPUT_DIR}/${subject}/Structural/T2.nii.gz
# 		matlab -nodisplay <<EOF
# 
# 		prefix{1}  = '';
# 		prefix{2}  = 'r';
# 		prefix{3}  = 'mean';
# 		data_path = '${OUTPUT_DIR}/${subject}'
# 
# 		%% Initialise SPM defaults
# 		%--------------------------------------------------------------------------
# 		spm('defaults', 'FMRI');
# 
# 		spm_jobman('initcfg');
# 		jobs={};
# 
# 		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 		% SPATIAL PREPROCESSING
# 		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 
# 		%% Select functional and structural scans
# 		%--------------------------------------------------------------------------
# 		f = spm_select('FPList', fullfile(data_path,'RawEpi'), '^epi_.*\.nii$');
# 		a = spm_select('FPList', fullfile(data_path,'Structural'), '^T2.*\.nii$');
# 
# 		%% REALIGN
# 		%--------------------------------------------------------------------------
# 		jobs{end+1}.spm.spatial.realign.estwrite.data = { editfilenames(f,'prefix',prefix{1}) };
# 		jobs{end}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
# 		jobs{end}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
# 		jobs{end}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
# 		jobs{end}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
# 		jobs{end}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
# 		jobs{end}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
# 		jobs{end}.spm.spatial.realign.estwrite.eoptions.weight  = '';
# 		jobs{end}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
# 		jobs{end}.spm.spatial.realign.estwrite.roptions.interp  = 4;
# 		jobs{end}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
# 		jobs{end}.spm.spatial.realign.estwrite.roptions.mask    = 1;
# 		jobs{end}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';
# 
# 		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 		%% RUN
# 		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 		save(fullfile(data_path,'batch_preprocessing.mat'),'jobs');
# 		spm_jobman('run',jobs);
# EOF
# 		gunzip ${OUTPUT_DIR}/${subject}/RawEpi/repi_*.gz 
# 	fi
# 	gunzip ${OUTPUT_DIR}/${subject}/RawEpi/epi_*.gz
# fi	

################################
## Step 3. Merge, calcul mean of each type of ASL files and ASL_map
################################

# echo "fslmerge -t ${OUTPUT_DIR}/${subject}/control ${OUTPUT_DIR}/${subject}/RawEpi/epi_00{01..29..2}.nii.gz"
# fslmerge -z ${OUTPUT_DIR}/${subject}/control ${OUTPUT_DIR}/${subject}/RawEpi/epi_00{01..29..2}.nii.gz
# 
# echo "fslmerge -t ${OUTPUT_DIR}/${subject}/tag ${OUTPUT_DIR}/${subject}/RawEpi/epi_00{00..28..2}.nii.gz"
# fslmerge -z ${OUTPUT_DIR}/${subject}/tag ${OUTPUT_DIR}/${subject}/RawEpi/epi_00{00..28..2}.nii.gz
# 
# echo "fslmaths ${OUTPUT_DIR}/${subject}/control -Zmean ${OUTPUT_DIR}/${subject}/control_mean"
# fslmaths ${OUTPUT_DIR}/${subject}/control -Zmean ${OUTPUT_DIR}/${subject}/control_mean
# 
# # Remove NaNs
# echo "fslmaths ${OUTPUT_DIR}/${subject}/control_mean -nan ${OUTPUT_DIR}/${subject}/control_mean"
# fslmaths ${OUTPUT_DIR}/${subject}/control_mean -nan ${OUTPUT_DIR}/${subject}/control_mean
# # gunzip ${OUTPUT_DIR}/${subject}/asl/control_mean.nii.gz
# 
# echo "fslmaths ${OUTPUT_DIR}/${subject}/tag -Zmean  ${OUTPUT_DIR}/${subject}/tag_mean"
# fslmaths ${OUTPUT_DIR}/${subject}/tag -Zmean  ${OUTPUT_DIR}/${subject}/tag_mean
# 
# # Remove NaNs
# echo "fslmaths ${OUTPUT_DIR}/${subject}/tag_mean -nan ${OUTPUT_DIR}/${subject}/tag_mean"
# fslmaths ${OUTPUT_DIR}/${subject}/tag_mean -nan ${OUTPUT_DIR}/${subject}/tag_mean
# # gunzip ${OUTPUT_DIR}/${subject}/asl/tag_mean.nii.gz
# 
# echo "fslmaths ${OUTPUT_DIR}/${subject}/control_mean  -sub ${OUTPUT_DIR}/${subject}/tag_mean ${OUTPUT_DIR}/${subject}/asl_map"
# fslmaths ${OUTPUT_DIR}/${subject}/control_mean -sub ${OUTPUT_DIR}/${subject}/tag_mean ${OUTPUT_DIR}/${subject}/asl_map
# 
# # gunzip ${FS_DIR}/${subject}/asl/*.gz 
# # 
# # echo "mri_binarize --i ${FS_DIR}/${subject}/asl/control_mean.nii --min 150 --o ${FS_DIR}/${subject}/asl/brain_mask.nii"
# # mri_binarize --i ${FS_DIR}/${subject}/asl/control_mean.nii --min 150 --o ${FS_DIR}/${subject}/asl/brain_mask.nii
# # 
# # echo "mri_morphology ${FS_DIR}/${subject}/asl/brain_mask.nii dilate 1 ${FS_DIR}/${subject}/asl/brain_mask_dil.nii" 
# # mri_morphology ${FS_DIR}/${subject}/asl/brain_mask.nii dilate 1 ${FS_DIR}/${subject}/asl/brain_mask_dil.nii
# 
# ################################
# ## Step 4. N4BiasFieldCorrection on ASL control mean image
# ################################
# 
# ${ANTSPATH}/N4BiasFieldCorrection -d 2 -i ${OUTPUT_DIR}/${subject}/control_mean.nii.gz -o ${OUTPUT_DIR}/${subject}/N4_control_mean.nii.gz -b [200] -s 3 -c [50x50x30x20,1e-6]
# 
# ################################
# ## Step 5. Quick SyN registration of control_mean ASL onto T2 anatomical 
# ################################
# 
# antsRegistrationSyNQuick.sh -d 3 -f ${OUTPUT_DIR}/${subject}/Structural/T2.nii.gz -m ${OUTPUT_DIR}/${subject}/N4_control_mean.nii.gz -o ${OUTPUT_DIR}/${subject}/T2toAsl
# 
# ################################
# ## Step 6. Reorient source images onto T2 template
# ################################
# 
# if [ ! -f ${OUTPUT_DIR}/${subject}/fT2.nii.gz ]
# then
# 	gunzip ${OUTPUT_DIR}/${subject}/Structural/T2.nii.gz ${OUTPUT_DIR}/${subject}/T2toAslWarped.nii.gz
# 	
# 	matlab -nodisplay <<EOF
# 	
# 	%% Initialise SPM defaults
# 	%-----------------------------
# 	spm('defaults', 'FMRI');
# 
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 
# 	matlabbatch{end+1}.spm.util.reorient.srcfiles = {
# 							'${OUTPUT_DIR}/${subject}/Structural/T2.nii,1'
# 							'${OUTPUT_DIR}/${subject}/T2toAslWarped.nii,1'
# 							 };
# 	matlabbatch{end}.spm.util.reorient.transform.transprm = [0 0 0 1.57 0 3.14 1 1 1 0 0 0];
# 	matlabbatch{end}.spm.util.reorient.prefix = 'f';
# 
# 	spm_jobman('run',matlabbatch);
# EOF
# 
# gzip ${OUTPUT_DIR}/${subject}/Structural/*.nii ${OUTPUT_DIR}/${subject}/*.nii
# fi
# 
# ################################
# ## Step 7. N4BiasFieldCorrection on fT2 image
# ################################
# 
# ${ANTSPATH}/N4BiasFieldCorrection -d 3 -i ${OUTPUT_DIR}/${subject}/Structural/fT2.nii.gz -o ${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz -b [200] -s 3 -c [50x50x30x20,1e-6]
# 
# ################################
# ## Step 8. Resampling T2 template to a lower resolution
# ################################
# 
# ${ANTSPATH}/ResampleImageBySpacing 3 ${OUTPUT_DIR}/../Atlas/Dorr_2008_average.nii.gz ${OUTPUT_DIR}/../Atlas/DorrSmall.nii.gz .1 .1 .1 0
# 
# ################################
# ## Step 9.  Perform diffeomorphic registration of T2 template lower resolution onto N4_fT2.nii.gz
# ################################
# 
USEHISTOGRAMMATCHING=1
OUTPUTNAME="T2toTemplate"
DIM=3
# 
# RIGIDCONVERGENCE="[1000x500x250x0,1e-6,10]"
# RIGIDSHRINKFACTORS="8x4x2x1"
# RIGIDSMOOTHINGSIGMAS="0.3x0.2x0.1x0mm"
# 
# SYNCONVERGENCE="[70x50x0,1e-6,10]"
# SYNSHRINKFACTORS="2x2x1"
# SYNSMOOTHINGSIGMAS="0.2x0.1x0mm"
# 
# RIGIDSTAGE="--initial-moving-transform [${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz,${OUTPUT_DIR}/../Atlas/DorrSmall.nii.gz,1] \
#             --transform Rigid[0.1] \
#             --metric MI[${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz,${OUTPUT_DIR}/../Atlas/DorrSmall.nii.gz,1,32,Regular,0.25] \
#             --convergence $RIGIDCONVERGENCE \
#             --shrink-factors $RIGIDSHRINKFACTORS \
#             --smoothing-sigmas $RIGIDSMOOTHINGSIGMAS"
# 
# SYNSTAGE="--transform SyN[0.1,3,0] \
# 	  --metric cc[${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz,${OUTPUT_DIR}/../Atlas/DorrSmall.nii.gz,1,2]
#           --convergence $SYNCONVERGENCE \
#           --shrink-factors $SYNSHRINKFACTORS \
#           --smoothing-sigmas $SYNSMOOTHINGSIGMAS"
# 
# STAGES="${RIGIDSTAGE} ${SYNSTAGE}"
# 
# COMMAND="${ANTSPATH}/antsRegistration --dimensionality ${DIM} \
# 		--output [${OUTPUT_DIR}/${subject}/${OUTPUTNAME},${OUTPUT_DIR}/${subject}/${OUTPUTNAME}Warped.nii.gz,${OUTPUT_DIR}/${subject}/${OUTPUTNAME}InverseWarped.nii.gz] \
# 		--interpolation Linear \
# 		--use-histogram-matching ${USEHISTOGRAMMATCHING} \
# 		--winsorize-image-intensities [0.005,0.995] \
#                  ${STAGES}"
# 
# echo " antsRegistration call:"
# echo "--------------------------------------------------------------------------------------"
# echo ${COMMAND}
# echo "--------------------------------------------------------------------------------------"
# ${COMMAND}
# 
# ################################
# ## Step 10.  Apply diffeomorphic inverse registration of N4_fT2.nii.gz and fT2toAslWarped.nii.gz onto T2 template
# ################################
# 
# COMMAND="${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-r ${OUTPUT_DIR}/../Atlas/Dorr_2008_average.nii.gz \
# 	-t [${OUTPUT_DIR}/${subject}/${OUTPUTNAME}0GenericAffine.mat,1] \
# 	-t ${OUTPUT_DIR}/${subject}/${OUTPUTNAME}1InverseWarp.nii.gz \
# 	-o ${OUTPUT_DIR}/${subject}/N4_fT2Warped.nii.gz \
# 	-i ${OUTPUT_DIR}/${subject}/Structural/N4_fT2.nii.gz"
# 
# echo " antsApplyTransforms call:"
# echo "--------------------------------------------------------------------------------------"
# echo ${COMMAND}
# echo "--------------------------------------------------------------------------------------"
# ${COMMAND}	

COMMAND="${ANTSPATH}/antsApplyTransforms -d 3 \
	-r ${OUTPUT_DIR}/../Atlas/Dorr_2008_average.nii.gz \
	-t [${OUTPUT_DIR}/${subject}/${OUTPUTNAME}0GenericAffine.mat,1] \
	-t ${OUTPUT_DIR}/${subject}/${OUTPUTNAME}1InverseWarp.nii.gz \
	-o ${OUTPUT_DIR}/${subject}/TempToAslWarped.nii.gz \
	-i ${OUTPUT_DIR}/${subject}/fT2toAslWarped.nii.gz"

echo " antsApplyTransforms call:"
echo "--------------------------------------------------------------------------------------"
echo ${COMMAND}
echo "--------------------------------------------------------------------------------------"
${COMMAND}	

################################
## Step 5. Calcul CBF map
################################

# if [ ! -f ${FS_DIR}/${subject}/asl/CBF.nii ]
# then
# 	matlab -nodisplay <<EOF
# 	
# 	disp('calcul carto CBF');
# 	V1=spm_vol('${FS_DIR}/${subject}/asl/control_mean.nii');
# 	V2=spm_vol('${FS_DIR}/${subject}/asl/asl_map.nii');
# 	V3=spm_vol('${FS_DIR}/${subject}/asl/brain_mask_dil.nii');
# 
# 	data1=spm_read_vols(V1);
# 	data2=spm_read_vols(V2);
# 	data3=spm_read_vols(V3);
# 
# 	data2(~isfinite(data2(:))) = 0;
# 	data3(~isfinite(data3(:))) = 0;
# 	%CBFtemp=6000.*data2.*exp(1.525./1.68)./(2.*0.85.*0.76.*1.68.*data1);
# 	CBFtemp=6000/2*0.76*0.85*0.83*1.68.*data2./data1*exp((1.525+0.03646)/1.68)*exp(14/50).*data3;
# 
# 	V1.fname='${FS_DIR}/${subject}/asl/CBF.nii';
# 	spm_write_vol(V1,CBFtemp);
# EOF
# 
# # Remove NaNs
# echo "fslmaths ${FS_DIR}/${subject}/asl/CBF -nan ${FS_DIR}/${subject}/asl/CBF"
# fslmaths ${FS_DIR}/${subject}/asl/CBF -nan ${FS_DIR}/${subject}/asl/CBF
# rm -f ${FS_DIR}/${subject}/asl/CBF.nii
# gunzip ${FS_DIR}/${subject}/asl/CBF.nii.gz
# 
# fi

################################
## Step 6. Reslice CBF map
################################

# if [ ! -f ${FS_DIR}/${subject}/asl/rCBF.nii ]
# then
# 	matlab -nodisplay <<EOF
# 	
# 	disp('reslice CBF.nii');
# 	prefix{1}  = '';
# 	data_path = '${FS_DIR}/${subject}/asl'
# 
# 	%% Initialise SPM defaults
# 	%--------------------------------------------------------------------------
# 	spm('defaults', 'FMRI');
# 
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 
# 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 	% SPATIAL PREPROCESSING
# 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 
# 	%% Select functional and structural scans
# 	%--------------------------------------------------------------------------
# 	a = spm_select('FPList', fullfile(data_path,'Structural'), '^brain.*\.nii$');
# 	f = spm_select('FPList', data_path, '^CBF.*\.nii$');
# 
# 	%% Reslice Coregistration on T1 map
# 	%-----------------------------------------------------------------------
# 	matlabbatch{end+1}.spm.spatial.coreg.write.ref = editfilenames(a,'prefix',prefix{1});
# 	matlabbatch{end}.spm.spatial.coreg.write.source = editfilenames(f,'prefix',prefix{1}) ;
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 1;
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
# 	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
# 
# 	save(fullfile(data_path,'batch_reslice.mat'),'matlabbatch');
# 	spm_jobman('run',matlabbatch);
# EOF
# 	# Remove NaNs
# 	echo "fslmaths ${FS_DIR}/${subject}/asl/rCBF -nan ${FS_DIR}/${subject}/asl/rCBF"
# 	fslmaths ${FS_DIR}/${subject}/asl/rCBF -nan ${FS_DIR}/${subject}/asl/rCBF
# 	rm -f ${FS_DIR}/${subject}/asl/rCBF.nii
# fi

# ################################
# ## Step 7. Correct partial volume
# ################################
# 
# 
# 	if [ ! -d ${FS_DIR}/${subject}/asl/pve_out ]
# 	then
# 		mkdir ${FS_DIR}/${subject}/asl/pve_out
# 	else
# 		rm -rf ${FS_DIR}/${subject}/asl/pve_out/*
# 	fi
# 	
# 	cp ${FS_DIR}/${subject}/asl/Structural/brain.nii ${FS_DIR}/${subject}/asl/pve_out
# 	gunzip ${FS_DIR}/${subject}/asl/rCBF.nii.gz
# 	cp ${FS_DIR}/${subject}/asl/rCBF.nii ${FS_DIR}/${subject}/asl/pve_out
# 	mri_convert ${FS_DIR}/${subject}/asl/pve_out/rCBF.nii ${FS_DIR}/${subject}/asl/pve_out/rCBF.img
# 	
# 	matlab -nodisplay <<EOF
# 	
# 	disp('correction volume partiel');
# 	t1_path='${FS_DIR}/${subject}/asl/pve_out/brain.nii';
# 	CBF_path='${FS_DIR}/${subject}/asl/pve_out/rCBF.img';
# 	outdir='${FS_DIR}/${subject}/asl/pve_out';
# 	
# 	HOME = getenv('HOME');
# 	configfile = [HOME, '/SVN/matlab/pierre/pve/config_pvec'];
# 
# 	%% Step 1. Segment T1 using spm12 segment function
# 	%--------------------------------------------------------------------------
# 	
# 	%% Initialise SPM defaults
# 	
# 	spm('defaults', 'FMRI');
# 
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
# 	matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [1 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
# 	matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,5'};
# 	matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
# 	matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [1 0];
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
# 	%% Step 2. Rescale prob maps to [0 255]
# 	%% Rename them to _segN.img
# 	%% Create _GMROI.img
# 	%--------------------------------------------------------------------------
# 
# 	Vt1   = spm_vol(t1_path);
# 	Vseg1 = spm_vol([outdir, '/c1brain.nii']);
# 	Vseg2 = spm_vol([outdir, '/c2brain.nii']);
# 	Vseg3 = spm_vol([outdir, '/c3brain.nii']);
# 	delete([outdir, '/c4brain.nii']);
# 	delete([outdir, '/c5brain.nii']);
# 
# 	[Y1, XYZ] = spm_read_vols(Vseg1);
# 	[Y2, XYZ] = spm_read_vols(Vseg2);
# 	[Y3, XYZ] = spm_read_vols(Vseg3);
# 
# 	Y1 = Y1 * 255;
# 	Y2 = Y2 * 255;
# 	Y3 = Y3 * 255;
# 
# 	Y_roi = 51 * double(Y1 > 127.5) + 2 * double(Y2 > 127.5) + 3 * double(Y3 > 127.5);
# 	Vt1.dt = [2 0];
# 
# 	Vt1.fname = [outdir, '/t1_seg1.img'];
# 	spm_write_vol(Vt1, Y1);
# 	Vt1.fname = [outdir, '/t1_seg2.img'];
# 	spm_write_vol(Vt1, Y2);
# 	Vt1.fname = [outdir, '/t1_seg3.img'];
# 	spm_write_vol(Vt1, Y3);
# 
# 	Vt1.fname = [outdir, '/t1_GMROI.img'];
# 	spm_write_vol(Vt1, Y_roi);
# 	
# 	%% Step 4. Launch pve
# 	%--------------------------------------------------------------------------
# 	
# 	mni = round(Vt1.dim(3) / 3);
# 	gmROI_path = [outdir, '/t1_GMROI.img'];
# 	cmdline = ['/home/gregory/matlab/pvelab-20100419/IBB_wrapper/pve/pve -w -s -cs ', num2str(mni), ' ', gmROI_path, ' ', CBF_path, ' ', configfile];
# 	fid = fopen([outdir '/cmdline.txt'], 'w');
# 	fprintf(fid, '%s', cmdline);
# 	fclose(fid);
# 	disp('Performing PVEc. Please wait...');
# 	result = system(cmdline);
# 	
# 	%% Step 5. Modify header to correct for misalignment
# 	%--------------------------------------------------------------------------	
# 	
# 	Vref = spm_vol([outdir '/rCBF.img']);
# 	Vsrc = spm_vol([outdir '/t1_MGRousset.img']);
# 	Y = spm_read_vols(Vsrc);
# 	Vsrc.mat = Vref.mat;
# 	spm_write_vol(Vsrc, Y);
# EOF
# 
# gzip ${FS_DIR}/${subject}/asl/*.nii ${FS_DIR}/${subject}/asl/pve_out/*.nii

# if [ -z "${AslCorr}" ]
# then
# 	if [ ! -f ${FS_DIR}/${subject}/asl/RawEpi/epi_corr_0000.nii ]
# 	then
# 		fslsplit ${AslNii} ${FS_DIR}/${subject}/asl/RawEpi/epi_corr_ -t
# 	fi
# fi
# 
# 
# # # ASL map
# # /usr/local/matlab11/bin/matlab -nodisplay <<EOF
# # % Load Matlab Path
# # %p = pathdef;
# # %addpath(p);
# # 
# # process_asl(fullfile('${FS_DIR}','${subject}'));
# #  
# # EOF
# # 
# # # Map on surface
# # Project_ASL.sh -sd ${FS_DIR} -subj ${subject} -fwhm 20
# 