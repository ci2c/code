#!/bin/bash

SUBJECTS_DIR=$1
SUBJECT_ID=$2

index=1
FS_VERSION=5.3
oldSeg=1
DoPVC=1
DoMeanRoi=1
DoIN=1
DoSBA=1

## Set up FSL (if not already done so in the running environment) ##
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

## Set up FreeSurfer (if not already done so in the running environment) ##
if [ "${FS_VERSION}" == "5.3" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	export FSFAST_HOME=${Soft_dir}/freesurfer5.3/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer5.3/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
elif [ "${FS_VERSION}" == "6b" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer6_b/
	export FSFAST_HOME=${Soft_dir}/freesurfer6_b/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer6_b/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
fi

DIR=${SUBJECTS_DIR}/${SUBJECT_ID}

if [ ${oldSeg} -eq 1 ]
then
	pvedir=pvelab_Seg8_l0
elif [ ${oldSeg} -eq 0 ]
then
	pvedir=pvelab_Seg12_l0
fi

# ========================================================================================================================================
#                                   Compute partial volume correction with Muller-Gartner/Rousset based method
# ========================================================================================================================================

if [ $DoPVC -eq 1 ]
then
	if [ -d ${DIR}/pet/${pvedir} ]
	then
	    rm -rf ${DIR}/pet/${pvedir}/*
	else
	    mkdir ${DIR}/pet/${pvedir}
	fi

# 	# Register T1_LIA into upsampled PET space without resample
# 	mri_vol2vol --mov ${DIR}/pet/BS7_PET.lps.nii.gz --targ ${DIR}/pet/T1.lia.nii.gz --o ${DIR}/pet/T1.npet.nii.gz --inv --reg ${DIR}/pet/Pet2T1.BS7.register.dof6.dat --no-save-reg --no-resample
#
# 	# Register brainmask.mgz into upsampled PET space without nearest interpolation
# 	mri_binarize --i ${DIR}/mri/brainmask.mgz --min 0.001 --o ${DIR}/pet/brainmask.nii.gz
# 	mri_vol2vol --mov ${DIR}/pet/BS7_PET.lps.nii.gz --targ ${DIR}/pet/brainmask.nii.gz --o ${DIR}/pet/rbrainmask.npet.nii.gz --inv --reg ${DIR}/pet/Pet2T1.BS7.register.dof6.dat --no-save-reg --nearest

	gunzip ${DIR}/pet/BS7_PET.lps.nii.gz ${DIR}/pet/T1.npet.nii.gz ${DIR}/pet/rbrainmask.npet.nii.gz

	# Reslice T1 in upsampled PET space, remove NaN and negative values, then convert to analyze format
	matlab -nodisplay <<EOF

	%% Load Matlab Path: Matlab 14 and SPM8 version
	cd ${HOME}
	p = pathdef14_SPM8;
	addpath(p);

	%% Init of spm_jobman
	spm('defaults', 'PET');
	spm_jobman('initcfg');
	matlabbatch={};

	%% Step 1. Reslice T1.lia.npet.nii with B-spline 7th interpolation %%
	matlabbatch{end+1}.spm.spatial.realign.write.data = {
							    '${DIR}/pet/BS7_PET.lps.nii,1'
							    '${DIR}/pet/T1.npet.nii,1'
							};
	matlabbatch{end}.spm.spatial.realign.write.roptions.which = [1 0];
	matlabbatch{end}.spm.spatial.realign.write.roptions.interp = 7;
	matlabbatch{end}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.realign.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.realign.write.roptions.prefix = 'BS7_';

	spm_jobman('run',matlabbatch);

	%% Step 2. Remove NaN and negative values in BS7_T1.npet.nii %%

	V = spm_vol('${DIR}/pet/BS7_T1.npet.nii');
	[Y, XYZ] = spm_read_vols(V);
	Y(~isfinite(Y(:))) = 0;
	Y(Y(:) < 0) = 0;
	spm_write_vol(V, Y);

	%% Step 3. Convert nifti format to analyze %%

	V = spm_vol('${DIR}/pet/BS7_T1.npet.nii');
	[Y, XYZ] = spm_read_vols(V);
	V.fname = '${DIR}/pet/${pvedir}/rt1.BS7.lps.img';
	spm_write_vol(V, Y);

	V = spm_vol('${DIR}/pet/BS7_PET.lps.nii');
	[Y, XYZ] = spm_read_vols(V);
	V.fname = '${DIR}/pet/${pvedir}/PET.BS7.lps.img';
	spm_write_vol(V, Y);
EOF

	# Apply old Segmentation (SPM8) or new Segmentation (SPM12 + imported files for DARTEL)
	if [ ${oldSeg} -eq 1 ]
	then
		matlab -nodisplay <<EOF

		%% Load Matlab Path: Matlab 14 and SPM8 version for old Segmentation
		cd ${HOME}
		p = pathdef14_SPM8;
		addpath(p);

		rt1_path = '${DIR}/pet/${pvedir}/rt1.BS7.lps.img';

		%% Step 4. Segment rt1.BS7.lps.img using SPM8 new segment function %%

		% Init of spm_jobman
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};

		matlabbatch{end+1}.spm.tools.preproc8.channel.vols = {[rt1_path ',1']};
		matlabbatch{end}.spm.tools.preproc8.channel.biasreg = 0.0001;
		matlabbatch{end}.spm.tools.preproc8.channel.biasfwhm = 60;
		matlabbatch{end}.spm.tools.preproc8.channel.write = [0 1];
		matlabbatch{end}.spm.tools.preproc8.tissue(1).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,1'};
		matlabbatch{end}.spm.tools.preproc8.tissue(1).ngaus = 2;
		matlabbatch{end}.spm.tools.preproc8.tissue(1).native = [1 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(1).warped = [0 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(2).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,2'};
		matlabbatch{end}.spm.tools.preproc8.tissue(2).ngaus = 2;
		matlabbatch{end}.spm.tools.preproc8.tissue(2).native = [1 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(2).warped = [0 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(3).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,3'};
		matlabbatch{end}.spm.tools.preproc8.tissue(3).ngaus = 2;
		matlabbatch{end}.spm.tools.preproc8.tissue(3).native = [1 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(3).warped = [0 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(4).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,4'};
		matlabbatch{end}.spm.tools.preproc8.tissue(4).ngaus = 3;
		matlabbatch{end}.spm.tools.preproc8.tissue(4).native = [1 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(4).warped = [0 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(5).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,5'};
		matlabbatch{end}.spm.tools.preproc8.tissue(5).ngaus = 4;
		matlabbatch{end}.spm.tools.preproc8.tissue(5).native = [1 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(5).warped = [0 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(6).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,6'};
		matlabbatch{end}.spm.tools.preproc8.tissue(6).ngaus = 2;
		matlabbatch{end}.spm.tools.preproc8.tissue(6).native = [0 0];
		matlabbatch{end}.spm.tools.preproc8.tissue(6).warped = [0 0];
		matlabbatch{end}.spm.tools.preproc8.warp.mrf = 0;
		matlabbatch{end}.spm.tools.preproc8.warp.reg = 4;
		matlabbatch{end}.spm.tools.preproc8.warp.affreg = 'mni';
		matlabbatch{end}.spm.tools.preproc8.warp.samp = 3;
		matlabbatch{end}.spm.tools.preproc8.warp.write = [0 0];

		spm_jobman('run',matlabbatch);
EOF
	elif [ ${oldSeg} -eq 0 ]
	then
		matlab -nodisplay <<EOF
		%% Load Matlab Path: Matlab 14 and SPM12 needed
		cd ${HOME}
		p = pathdef14_SPM12;
		addpath(p);

		rt1_path = '${DIR}/pet/${pvedir}/rt1.BS7.lps.img';

		%% Step 4. Segment rt1.BS7.lps.img using SPM12 segment function + imported DARTEL %%

		% Init of spm_jobman
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};

		matlabbatch{end+1}.spm.spatial.preproc.channel.vols = {[rt1_path ',1']};
		matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
		matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
		matlabbatch{end}.spm.spatial.preproc.channel.write = [0 1];
		matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,1'};
		matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 1;
		matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 1];
		matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,2'};
		matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 1;
		matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 1];
		matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,3'};
		matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
		matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,4'};
		matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
		matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [1 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,5'};
		matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
		matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [1 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,6'};
		matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus = 2;
		matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
		matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];
		matlabbatch{end}.spm.spatial.preproc.warp.mrf = 1;
		matlabbatch{end}.spm.spatial.preproc.warp.cleanup = 1;
		matlabbatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
		matlabbatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
		matlabbatch{end}.spm.spatial.preproc.warp.fwhm = 0;
		matlabbatch{end}.spm.spatial.preproc.warp.samp = 3;
		matlabbatch{end}.spm.spatial.preproc.warp.write = [0 0];

		spm_jobman('run',matlabbatch);
EOF
	fi

	matlab -nodisplay <<EOF

	%% Load Matlab Path: Matlab 14 and SPM8 version for pvelab2012
	cd ${HOME}
	p = pathdef14_SPM8;
	addpath(p);

	rt1_path = '${DIR}/pet/${pvedir}/rt1.BS7.lps.img';
	pet_path = '${DIR}/pet/${pvedir}/PET.BS7.lps.img';

	%% Step 5. Rescale prob maps to [0 255], rename them to rt1.BS7.lps_segN.img and create rt1.BS7.lps_GMROI.img %%

	Vt1   = spm_vol(rt1_path);
	Vseg1 = spm_vol('${DIR}/pet/${pvedir}/c1rt1.BS7.lps.nii');
	Vseg2 = spm_vol('${DIR}/pet/${pvedir}/c2rt1.BS7.lps.nii');
	Vseg3 = spm_vol('${DIR}/pet/${pvedir}/c3rt1.BS7.lps.nii');
	delete('${DIR}/pet/${pvedir}/c4rt1.BS7.lps.nii');
	delete('${DIR}/pet/${pvedir}/c5rt1.BS7.lps.nii');

	[Y1, XYZ] = spm_read_vols(Vseg1);
	[Y2, XYZ] = spm_read_vols(Vseg2);
	[Y3, XYZ] = spm_read_vols(Vseg3);

	Vseg1.fname = '${DIR}/pet/${pvedir}/rt1.BS7.lps_seg1.img';
	spm_write_vol(Vseg1, Y1);
	Vseg2.fname = '${DIR}/pet/${pvedir}/rt1.BS7.lps_seg2.img';
	spm_write_vol(Vseg2, Y2);
	Vseg3.fname = '${DIR}/pet/${pvedir}/rt1.BS7.lps_seg3.img';
	spm_write_vol(Vseg3, Y3);

	[seg1,hseg]=ReadAnalyzeImg('${DIR}/pet/${pvedir}/rt1.BS7.lps_seg1.img');
	seg1=double(seg1);
	[seg2,hseg]=ReadAnalyzeImg('${DIR}/pet/${pvedir}/rt1.BS7.lps_seg2.img');
	seg2=double(seg2);
	[seg3,hseg]=ReadAnalyzeImg('${DIR}/pet/${pvedir}/rt1.BS7.lps_seg3.img');
	seg3=double(seg3);

	seg4=255-(seg1+seg2+seg3);
	[dummy,index]=max([seg1 seg2 seg3 seg4]');
	gmroi=zeros(size(seg1));
	gmroi(index==1)=51;
	gmroi(index==2)=2;
	gmroi(index==3)=3;

	GMROI = reshape(gmroi,Vt1.dim(1),Vt1.dim(2),Vt1.dim(3));
	Vt1.fname = '${DIR}/pet/${pvedir}/rt1.BS7.lps_GMROI.img';
	Vt1.dt = [2 0];
	spm_write_vol(Vt1, GMROI);

	%% Step 6. Remove misclassified GM and WM located in dura mater from rt1.BS7.lps_GMROI.img %%

	V = spm_vol('${DIR}/pet/${pvedir}/rt1.BS7.lps_GMROI.img');
	[GMROI, XYZ] = spm_read_vols(V);

	W = spm_vol('${DIR}/pet/rbrainmask.npet.nii');
	[brainmask, XYZ] = spm_read_vols(W);

	GMROI(((GMROI==51)&(brainmask==0))|((GMROI==2)&(brainmask==0)))=0;
	V.dt = [2 0];
	spm_write_vol(V, GMROI);
EOF

	matlab -nodisplay <<EOF

	%% Load Matlab Path: Matlab 14 and SPM8 version for pvelab2012
	cd ${HOME}
	p = pathdef14_SPM8;
	addpath(p);

	rt1_path = '${DIR}/pet/${pvedir}/rt1.BS7.lps.img';
	pet_path = '${DIR}/pet/${pvedir}/PET.BS7.lps.img';

	%% Step 5. Rescale prob maps to [0 255], rename them to rt1.BS7.lps_segN.img and create rt1.BS7.lps_GMROI.img %%

	Vt1   = spm_vol(rt1_path);

	%% Step 7. Launch pve correction %%

	% Load configuration file for pve correction
	configfile = '${HOME}/SVN/matlab/matthieu/pve/config_pvec';

	mni = round(Vt1.dim(3) / 3);
	%mni = 85;
	gmROI_path = '${DIR}/pet/${pvedir}/rt1.BS7.lps_GMROI.img';
	cmdline = ['/home/global/matlab_toolbox/pvelab2012/IBB_wrapper/pve/pve64 -cse 2 -w -s -cs ', num2str(mni), ' ', gmROI_path, ' ', pet_path, ' ', configfile];
	fid = fopen('${DIR}/pet/${pvedir}/cmdline.txt', 'w');
	fprintf(fid, '%s', cmdline);
	fclose(fid);
	disp('Performing PVC. Please wait...');
	[status, result] = unix(cmdline);

	%% Step 8. Remove NaN and negative values in rt1.BS7.lps_MGRousset.img & rt1.BS7.lps_MGCS.img %%

	V = spm_vol('${DIR}/pet/${pvedir}/rt1.BS7.lps_MGRousset.img');
	[Y, XYZ] = spm_read_vols(V);
	Y(~isfinite(Y(:))) = 0;
	Y(Y(:) < 0) = 0;
	spm_write_vol(V, Y);

	V = spm_vol('${DIR}/pet/${pvedir}/rt1.BS7.lps_MGCS.img');
	[Y, XYZ] = spm_read_vols(V);
	Y(~isfinite(Y(:))) = 0;
	Y(Y(:) < 0) = 0;
	spm_write_vol(V, Y);

	%% Step 9. Modify transformation matrix of corrected output misaligned : overwrite with PET.BS7.lps.img %%

	Vref = spm_vol(pet_path);

	Vsrc = spm_vol('${DIR}/pet/${pvedir}/rt1.BS7.lps_MGRousset.img');
	Y = spm_read_vols(Vsrc);
	Vsrc.mat = Vref.mat;
	spm_write_vol(Vsrc, Y);

	Vsrc = spm_vol('${DIR}/pet/${pvedir}/rt1.BS7.lps_MGCS.img');
	Y = spm_read_vols(Vsrc);
	Vsrc.mat = Vref.mat;
	spm_write_vol(Vsrc, Y);
EOF

	gzip ${DIR}/pet/BS7_PET.lps.nii ${DIR}/pet/T1.npet.nii ${DIR}/pet/rbrainmask.npet.nii ${DIR}/pet/BS7_T1.npet.nii
	mri_convert ${DIR}/pet/${pvedir}/rt1.BS7.lps_MGRousset.img ${DIR}/pet/${pvedir}/PET.BS7.lps.MGRousset.nii.gz
	mri_convert ${DIR}/pet/${pvedir}/rt1.BS7.lps_MGCS.img ${DIR}/pet/${pvedir}/PET.BS7.lps.MGCS.nii.gz
fi

# ========================================================================================================================================
#                                               Compute mean values in PET ROIs (with PVC)
# ========================================================================================================================================

for type_pvc in MGRousset MGCS
do
	if [ $DoMeanRoi -eq 1 ] && [ ! -f ${DIR}/pet/${pvedir}/mean.cerebellar.pet.BS7.${type_pvc}.dat ]
	then
		mri_segstats --seg ${DIR}/pet/rGMcerebellum.BS7.mask.nii.gz --id 1 --i ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.nii.gz --sum ${DIR}/pet/${pvedir}/mean.cerebellar.pet.BS7.${type_pvc}.dat
		mean_cerebellar_pet_pvc[${type_pvc}]=$(fslstats ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.nii.gz -k ${DIR}/pet/rGMcerebellum.BS7.mask.nii.gz -m)
	fi
done

# ========================================================================================================================================
#                                         Apply intensity normalization (with PVC)
# ========================================================================================================================================

for type_pvc in MGRousset MGCS
do
	if [ $DoIN -eq 1 ] && [ ! -f ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.gn.nii.gz ]
	then
		# Based on anatomical reference ROI
# 		fslmaths ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.nii.gz -div ${mean_pons_pet_pvc[${type_pvc}]} ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.npons.nii.gz
		fslmaths ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.nii.gz -div ${mean_cerebellar_pet_pvc[${type_pvc}]} ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.ncereb.nii.gz

		# Global normalization based on SPM
		gunzip ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.nii.gz
		matlab -nodisplay <<EOF
			% Load Matlab Path: Matlab 14 and SPM12 needed
			cd ${HOME}
			p = pathdef14_SPM12;
			addpath(p);

			% Compute global mean
			V = spm_data_hdr_read('${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.nii');
			Gmean = spm_global(V);
			PET = spm_data_read(V);

			% Value of Grand Mean scaling (50 per default for O2)
			GM = 6.5;

			% Scaling: compute global scaling factors gSF required to implement proportional scaling global normalisation (PropSca)
			gSF = GM/Gmean;

			% Apply gSF to memory-mapped scalefactors to implement scaling
			% V.pinfo(1:2,:) = V.pinfo(1:2,:)*gSF;

			% Compute & save global normalized PET image
			% PET_gnorm = PET.*V.pinfo(1,1) + V.pinfo(2,1);
			PET_gnorm = PET.*gSF;
			V.fname = '${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.gn.nii';
			spm_write_vol(V,PET_gnorm);
EOF
		gzip ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.nii ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.gn.nii
	fi
done

# ========================================================================================================================================
#                                  Resample PET data onto native and common surfaces
# ========================================================================================================================================


if [ $DoSBA -eq 1 ] && [ ! -f ${DIR}/pet/${pvedir}/surf/rh.PET.BS7.lps.MGCS.gn.fsaverage.sm18.mgh ]
then
	if [ -d ${DIR}/pet/${pvedir}/surf ]
	then
	    rm -rf ${DIR}/pet/${pvedir}/surf/*
	else
	    mkdir ${DIR}/pet/${pvedir}/surf
	fi

	# Modify "${SUBJECT_ID}_copy" by "${SUBJECT_ID}" in "Pet2T1.BS7.register.dof6.dat" file
	sed "s/${SUBJECT_ID}_copy/${SUBJECT_ID}/" ${DIR}/pet/Pet2T1.BS7.register.dof6.dat > ${DIR}/pet/Pet2T1.BS7.register.dof6.bis.dat
	rm -f ${DIR}/pet/Pet2T1.BS7.register.dof6.dat
	mv ${DIR}/pet/Pet2T1.BS7.register.dof6.bis.dat ${DIR}/pet/Pet2T1.BS7.register.dof6.dat

	for type_norm in ncereb gn
	do
		for type_pvc in MGRousset MGCS
		do
			## Resample onto native surface

			# lh
			mri_vol2surf --mov ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg

			# rh
			mri_vol2surf --mov ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg

			# smooth
			for fwhmsurf in 0 3 6 8 9 10 12 15 18
			do
				mris_fwhm --s ${SUBJECT_ID} --hemi lh --smooth-only --i ${DIR}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet/surf/lh.PET.lps.BS7.brain_mask.nii
				mris_fwhm --s ${SUBJECT_ID} --hemi rh --smooth-only --i ${DIR}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet/surf/rh.PET.lps.BS7.brain_mask.nii
			done

			## Resample onto fsaverage

			# lh
			mri_vol2surf --mov ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

			# rh
			mri_vol2surf --mov ${DIR}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

			# smooth
			for fwhmsurf in 0 3 6 8 9 10 12 15 18
# 			for fwhmsurf in 8
			do
				mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii
				mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii
			done
		done
	done
fi
