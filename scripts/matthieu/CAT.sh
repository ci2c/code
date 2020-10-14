#!/bin/bash

# SUBJDIR=$1
# InputDir=$2
# InputSubjectsFile=$3

# # # InputSubjectsFile=/NAS/tupac/matthieu/PALM_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/V2/subjects_AMN_LANG_VISU_EXE
# # # InputSubjectsFile=/NAS/tupac/matthieu/CAT_diffcases/subjects
# # InputSubjectsFile=/NAS/tupac/matthieu/CAT_A0/subjectsFiles/subjects_NC_Basel_bis
# InputSubjectsFile=/NAS/tupac/matthieu/CAT_A0/PALM/Description_files/V4_27NC_Park_82pat/TYPvsLANGvsVISUvsEXEvsNC/subjects_NC_Park.M0
# InputDir=/NAS/tupac/matthieu/CAT_A0
# # SUBJDIR=/NAS/tupac/protocoles/COMAJ/FS53
# SUBJDIR=/NAS/tupac/protocoles/healthy_volunteers/FS53
# # SUBJDIR=/NAS/tupac/matthieu/FS5.3
#
# while read subject
# # for subject in 207193_M0_2017-01-30 207194_M0_2017-01-31 207195_M0_2017-02-07
# # for subject in 207003_M0_2010-05-05 207065_M0_2011-07-25
# # for subject in 207196_M0_2017-02-23
# # for subject in 207077_M2_2014-02-04 207078_M1_2013-01-29 207118_M0_2014-01-29
# do
# # 	mri_convert ${SUBJDIR}/${subject}/mri/T1.mgz ${InputDir}/T1.LAS.${subject}.nii --out_orientation LAS
# 	mri_convert ${SUBJDIR}/${subject}/mri/orig.mgz ${InputDir}/orig.lia.${subject}.nii
# # 	rm -Rf ${SUBJDIR}/${subject}/pet*
#
# # done
# done < ${InputSubjectsFile}

#
# matlab -nodisplay <<EOF
#
# 	%% Load Matlab Path: Matlab 14 and SPM12 needed
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
#
# 	%% Open the text file containing subjects names
# 	fid = fopen('${InputSubjectsFile}', 'r');
# 	S = textscan(fid,'%s','delimiter','\n');
# 	fclose(fid);
#
# 	%% Creation of the cell of subjects T1 segmentation
# 	NbFiles = size(S{1},1);
# 	Cell_Sub_T1 = cell(NbFiles,1);
# 	for k= 1 : NbFiles
# 	    % Input cell for T1 segmentation
# 	    % Cell_Sub_T1{k,1} = fullfile('${InputDir}', [ 'T1.LAS.' S{1}{k} '.nii,1' ]);
# 	    % Cell_Sub_T1{k,1} = fullfile('${InputDir}', [ 'T1.LIA.' S{1}{k} '.nii,1' ]);
# 	    Cell_Sub_T1{k,1} = fullfile('${InputDir}', [ 'orig.lia.' S{1}{k} '.nii,1' ]);
# 	end
#
# 	cd ${InputDir}
#
# 	% Init of spm_jobman
# 	spm('defaults', 'PET');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
#
# 	%% Step1. Segment T1 images
# 	matlabbatch{end+1}.spm.tools.cat.estwrite.data =  Cell_Sub_T1 ;
# 	matlabbatch{end}.spm.tools.cat.estwrite.nproc = 5;
# 	matlabbatch{end}.spm.tools.cat.estwrite.opts.tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii'};
# 	matlabbatch{end}.spm.tools.cat.estwrite.opts.affreg = 'mni';
# 	matlabbatch{end}.spm.tools.cat.estwrite.extopts.APP = 1;
# 	matlabbatch{end}.spm.tools.cat.estwrite.extopts.LASstr = 0.5;
# 	matlabbatch{end}.spm.tools.cat.estwrite.extopts.gcutstr = 0.5;
# 	matlabbatch{end}.spm.tools.cat.estwrite.extopts.cleanupstr = 0.5;
# 	matlabbatch{end}.spm.tools.cat.estwrite.extopts.darteltpm = {'/home/global/matlab_toolbox/spm12/toolbox/cat12/templates_1.50mm/Template_1_IXI555_MNI152.nii'};
# 	matlabbatch{end}.spm.tools.cat.estwrite.extopts.vox = 1.5;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.ROI = 1;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.surface = 1;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.GM.native = 0;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.GM.mod = 1;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.GM.dartel = 0;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.WM.native = 0;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.WM.mod = 1;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.WM.dartel = 0;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.bias.warped = 1;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.jacobian.warped = 0;
# 	matlabbatch{end}.spm.tools.cat.estwrite.output.warps = [0 0];
#
# 	spm_jobman('run',matlabbatch);
#
# EOF

# # matlab -nodesktop -nosplash <<EOF
# matlab -nodisplay <<EOF
#
# 	%% Load Matlab Path: Matlab 14 and SPM12 needed
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
#
# 	%% Open the text file containing subjects names
# 	fid = fopen('${InputSubjectsFile}', 'r');
# 	S = textscan(fid,'%s','delimiter','\n');
# 	fclose(fid);
#
# 	%% Creation of the cell of subjects for extraction of surface features
# 	NbFiles = size(S{1},1);
# 	Cell_Sub_SurfFeat_lh = cell(NbFiles,1);
# 	Cell_Sub_SurfFeat_rh = cell(NbFiles,1);
# 	for k= 1 : NbFiles
# 	    % Input cell for extract surface features
# 	    Cell_Sub_SurfFeat_lh{k,1} = fullfile('${InputDir}','surf',[ 'lh.central.T1.LAS.' S{1}{k} '.gii' ]);
# 	    Cell_Sub_SurfFeat_rh{k,1} = fullfile('${InputDir}','surf',[ 'rh.central.T1.LAS.' S{1}{k} '.gii' ]);
# 	end
#
# 	cd /NAS/tupac/matthieu/CAT
#
# 	% Init of spm_jobman
# 	spm('defaults', 'PET');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
#
# 	%% Step 2. Extract surface features
# 	matlabbatch{end+1}.spm.tools.cat.stools.surfextract.data_surf = [ Cell_Sub_SurfFeat_lh
# 									  Cell_Sub_SurfFeat_rh ];
# 	matlabbatch{end}.spm.tools.cat.stools.surfextract.GI = 1;
# 	matlabbatch{end}.spm.tools.cat.stools.surfextract.FD = 1;
# 	matlabbatch{end}.spm.tools.cat.stools.surfextract.SD = 1;
# 	matlabbatch{end}.spm.tools.cat.stools.surfextract.nproc = 4;
#
# 	spm_jobman('run',matlabbatch);
#
# EOF
#
# # matlab -nodesktop -nosplash <<EOF
# matlab -nodisplay <<EOF
#
# 	%% Load Matlab Path: Matlab 14 and SPM12 needed
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
#
# 	%% Open the text file containing subjects names
# 	fid = fopen('${InputSubjectsFile}', 'r');
# 	S = textscan(fid,'%s','delimiter','\n');
# 	fclose(fid);
#
# 	%% Creation of the cell of subjects for resample and smooth surface data
# 	NbFiles = size(S{1},1);
# 	Cell_Sub_ResSm_fd_lh = cell(NbFiles,1);
# 	Cell_Sub_ResSm_fd_rh = cell(NbFiles,1);
# 	Cell_Sub_ResSm_gy_lh = cell(NbFiles,1);
# 	Cell_Sub_ResSm_gy_rh = cell(NbFiles,1);
# 	Cell_Sub_ResSm_sulc_lh = cell(NbFiles,1);
# 	Cell_Sub_ResSm_sulc_rh = cell(NbFiles,1);
# 	Cell_Sub_ResSm_thick_lh = cell(NbFiles,1);
# 	Cell_Sub_ResSm_thick_rh = cell(NbFiles,1);
# 	for k= 1 : NbFiles
# 	    % Input cell for extract surface features
# 	    Cell_Sub_ResSm_fd_lh{k,1} = fullfile('${InputDir}','surf',[ 'lh.fractaldimension.T1.LAS.' S{1}{k} ]);
# 	    Cell_Sub_ResSm_gy_lh{k,1} = fullfile('${InputDir}','surf',[ 'lh.gyrification.T1.LAS.' S{1}{k} ]);
# 	    Cell_Sub_ResSm_sulc_lh{k,1} = fullfile('${InputDir}','surf',[ 'lh.sqrtsulc.T1.LAS.' S{1}{k} ]);
# 	    Cell_Sub_ResSm_thick_lh{k,1} = fullfile('${InputDir}','surf',[ 'lh.thickness.T1.LAS.' S{1}{k} ]);
# 	    Cell_Sub_ResSm_fd_rh{k,1} = fullfile('${InputDir}','surf',[ 'rh.fractaldimension.T1.LAS.' S{1}{k} ]);
# 	    Cell_Sub_ResSm_gy_rh{k,1} = fullfile('${InputDir}','surf',[ 'rh.gyrification.T1.LAS.' S{1}{k} ]);
# 	    Cell_Sub_ResSm_sulc_rh{k,1} = fullfile('${InputDir}','surf',[ 'rh.sqrtsulc.T1.LAS.' S{1}{k} ]);
# 	    Cell_Sub_ResSm_thick_rh{k,1} = fullfile('${InputDir}','surf',[ 'rh.thickness.T1.LAS.' S{1}{k} ]);
# 	end
#
# 	cd /NAS/tupac/matthieu/CAT
#
# 	%% Step 3. Resample and smooth surface data
# 	clear matlabbatch
# 	matlabbatch = {};
#
# 	matlabbatch{end+1}.spm.tools.cat.stools.surfresamp.data_surf = [  Cell_Sub_ResSm_fd_lh
# 									  Cell_Sub_ResSm_gy_lh
# 									  Cell_Sub_ResSm_sulc_lh
# 									  Cell_Sub_ResSm_thick_lh
# 									  Cell_Sub_ResSm_fd_rh
# 									  Cell_Sub_ResSm_gy_rh
# 									  Cell_Sub_ResSm_sulc_rh
# 									  Cell_Sub_ResSm_thick_rh ];
# 	%%
# 	matlabbatch{end}.spm.tools.cat.stools.surfresamp.fwhm = 15;
# 	matlabbatch{end}.spm.tools.cat.stools.surfresamp.nproc = 4;
#
# 	spm_jobman('run',matlabbatch);
#
# EOF

# ## Step 4. Convert to .mgh files
# while read subject
# do
# 	for meas in fractaldimension gyrification sqrtsulc thickness
# # 	for meas in fractaldimension gyrification sqrtsulc
# 	do
# 		for hemi in lh rh
# 		do
# 			qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N ConvertMgh_${hemi}_${meas}_${subject} ConvertGiftiToMgh.sh ${InputDir} ${meas} ${hemi} ${subject} 25
# 			sleep 1
# 		done
# 	done
#
# done < ${InputSubjectsFile}

# ## Step 5a. Perform surface second level statistical analysis (PALM)
#
# # WD=/NAS/tupac/matthieu/CAT/analysis/PALM/TYPvsLANGvsVISUvsEXE_fwhm25_i10000
# WD=/NAS/tupac/matthieu/CAT_A0/PALM/V4_27NC_Park_82pat/TYPvsLANGvsVISUvsEXEvsNC_fwhm15_i10000
# # DescriptionDir=/NAS/tupac/matthieu/CAT/analysis/PALM/Description_files/TYPvsLANGvsVISUvsEXE
# DescriptionDir=/NAS/tupac/matthieu/CAT_A0/PALM/Description_files/V4_27NC_Park_82pat/TYPvsLANGvsVISUvsEXEvsNC
# Design=Design_palm_TYPvsLANGvsVISUvsEXEvsNC.csv
# # Design=Design_palm_TYPvsLANGvsVISUvsEXEvsNC.csv
# # index=1
# # -accel tail -n 500 -nouncorrected
# FWHM=15
#
# # for meas in fractaldimension gyrification sqrtsulc thickness
# # # for meas in gyrification
# # do
# # 	## TYPvsLANGvsVISUvsEXE(vsNC) + TFCE : default parameters for pmethod & F-contrast ##
# # 	qbatch -q M32_q -oe /NAS/tupac/matthieu/CAT_A0/PALM/Logdir -N palm_${meas}_sm${FWHM}_tfce_lh_F_4grps palm -i ${DescriptionDir}/lh.all.subjects.${meas}.fsaverage.sm${FWHM}.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 15000 \
# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 	-d ${WD}/${meas}/${Design} \
# # 	-t ${WD}/${meas}/Contrasts_palm_t_groups.csv \
# # 	-f ${WD}/${meas}/Contrasts_palm_F_groups.csv \
# # 	-fonly -twotail \
# # 	-logp -o ${WD}/${meas}/palm.F.lh
# # 	sleep 1
# #
# # 	qbatch -q M32_q -oe /NAS/tupac/matthieu/CAT_A0/PALM/Logdir -N palm_${meas}_sm${FWHM}_tfce_rh_F_4grps palm -i ${DescriptionDir}/rh.all.subjects.${meas}.fsaverage.sm${FWHM}.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 15000 \
# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 	-d ${WD}/${meas}/${Design} \
# # 	-t ${WD}/${meas}/Contrasts_palm_t_groups.csv \
# # 	-f ${WD}/${meas}/Contrasts_palm_F_groups.csv \
# # 	-fonly -twotail \
# # 	-logp -o ${WD}/${meas}/palm.F.rh
# # 	sleep 1
# # done
#
# # for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# # for group in NCvsTYP NCvsATYP NCvsLANG NCvsVISU NCvsEXE TYPvsNC ATYPvsNC LANGvsNC VISUvsNC EXEvsNC
# # for group in TYPvsNC ATYPvsNC LANGvsNC VISUvsNC EXEvsNC
# for group in EXEvsNC
# do
# # 	for meas in fractaldimension gyrification sqrtsulc thickness
# # 	for meas in fractaldimension gyrification
# 	for meas in sqrtsulc
# 	do
# 		## TYPvsLANGvsVISUvsEXE(vsNC) + TFCE : default parameters for pmethod ##
# 		qbatch -q M32_q -oe /NAS/tupac/matthieu/CAT_A0/PALM/Logdir -N palm_${meas}_sm${FWHM}_tfce_lh_${group} palm -i ${DescriptionDir}/lh.all.subjects.${meas}.fsaverage.sm${FWHM}.mgh \
# 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# 		-d ${WD}/${meas}/${Design} \
# 		-t ${WD}/${meas}/Contrasts_palm_${group}.csv \
# 		-logp -o ${WD}/${meas}/palm.${group}.lh
# 		sleep 1
#
# # 		qbatch -q M32_q -oe /NAS/tupac/matthieu/CAT_A0/PALM/Logdir -N palm_${meas}_sm${FWHM}_tfce_rh_${group} palm -i ${DescriptionDir}/rh.all.subjects.${meas}.fsaverage.sm${FWHM}.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${meas}/${Design} \
# # 		-t ${WD}/${meas}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${meas}/palm.${group}.rh
# # 		sleep 1
# 	done
# done

## Step 6. Visualize stats results and make montages

# SUBJECTS_DIR=/NAS/tupac/matthieu/FS5.3
# rBPM_dir=/NAS/tupac/matthieu/rBPM_analysis
# FWHM=8
#
# index=11
# clus_thresh=30
# for results in Mixed-Model_Analysis_CT/FWHM10_4Cov
# do
# 	for group in EXE
# 	do
# 		Make_montage.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${rBPM_dir}/${results}/Clusterwise_correction_0.05/C${index}/lh_pos_noadjust_fwhm${FWHM}/cache.th${clus_thresh}.pos.sig.cluster.mgh  \
# 		-rhoverlay ${rBPM_dir}/${results}/Clusterwise_correction_0.05/C${index}/rh_pos_noadjust_fwhm${FWHM}/cache.th${clus_thresh}.pos.sig.cluster.mgh  -fminmax 1.3 3.7 -fmid 2.5  -output ${rBPM_dir}/${results}/Clusterwise_correction_0.05/${group}_${clus_thresh}.tiff -template -axial
# # 		index=$[$index+1]
# # 		clus_thresh=20
# 	done
# done

# ## Convert .mgz files into .nii.gz and compute min/max stats
# PALM_dir=/NAS/tupac/matthieu/CAT_A0/PALM/V4_27NC_Park_82pat/TYPvsLANGvsVISUvsEXEvsNC_fwhm15_i10000
# # for meas in fractaldimension gyrification sqrtsulc thickness
# # for meas in sqrtsulc
# for meas in sqrtsulc
# do
# # 	for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# # 	for group in NCvsATYP NCvsTYP NCvsLANG NCvsVISU NCvsEXE TYPvsNC ATYPvsNC LANGvsNC VISUvsNC EXEvsNC
# 	for group in EXEvsNC
# # 	for group in F
# 	do
# 		cd ${PALM_dir}/${meas}
# 		for i in palm.${group}.?h_tfce_tstat_fwep.mgz ; do
# # 		for i in palm.F.?h_tfce_fstat_fwep.mgz ; do
# 			base=${i%.mgz}
# 			mri_convert $i ${base}.nii.gz
# 		done
# 	done
# done

# ## Threshold corrected p-maps at 90 mm2 (PET spatial resolution)
# SUBJECTS_DIR=/NAS/tupac/matthieu/FS5.3
# PALM_dir=/NAS/tupac/matthieu/CAT_A0/PALM/V4_27NC_Park_82pat
# thmin_lh=1.3
# thmin_rh=1.3
# for results in TYPvsLANGvsVISUvsEXEvsNC_fwhm15_i10000
# do
# # 	for meas in fractaldimension gyrification sqrtsulc thickness
# 	for meas in sqrtsulc
# 	do
# # 		for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# # 		for group in NCvsATYP NCvsTYP NCvsLANG NCvsVISU NCvsEXE TYPvsNC ATYPvsNC LANGvsNC VISUvsNC EXEvsNC
# 		for group in EXEvsNC
# 		do
# 			thresh_lh=`fslstats ${PALM_dir}/${results}/${meas}/palm.${group}.lh_tfce_tstat_fwep.nii.gz -R | awk '{print $2}'`
# 			thresh_bin_lh=`echo "${thresh_lh}>=1.3" | bc`
# 			thresh_rh=`fslstats ${PALM_dir}/${results}/${meas}/palm.${group}.rh_tfce_tstat_fwep.nii.gz -R | awk '{print $2}'`
# 			thresh_bin_rh=`echo "${thresh_rh}>=1.3" | bc`
# 			if [ ${thresh_bin_lh} -eq 1 -o ${thresh_bin_rh} -eq 1 ]
# 			then
# 				mri_surfcluster --in ${PALM_dir}/${results}/${meas}/palm.${group}.lh_tfce_tstat_fwep.mgz --subject fsaverage --hemi lh --annot aparc.a2009s --thmin ${thmin_lh} --minarea 90 \
# 				--sum ${PALM_dir}/${results}/${meas}/palm.${group}.lh.cluster.cs90.summary --ocn ${PALM_dir}/${results}/${meas}/palm.${group}.lh.cluster_number.cs90.nii.gz --o ${PALM_dir}/${results}/${meas}/lh.${group}_tfce_tstat_fwep.cs90.mgh
# 				mri_surfcluster --in ${PALM_dir}/${results}/${meas}/palm.${group}.rh_tfce_tstat_fwep.mgz --subject fsaverage --hemi rh --annot aparc.a2009s --thmin ${thmin_rh} --minarea 90 \
# 				--sum ${PALM_dir}/${results}/${meas}/palm.${group}.rh.cluster.cs90.summary --ocn ${PALM_dir}/${results}/${meas}/palm.${group}.rh.cluster_number.cs90.nii.gz --o ${PALM_dir}/${results}/${meas}/rh.${group}_tfce_tstat_fwep.cs90.mgh
# 			fi
# 		done
# 	done
# done

## Create .tiff images of surface representations
SUBJECTS_DIR=/NAS/tupac/matthieu/FS5.3
PALM_dir=/NAS/tupac/matthieu/CAT_A0/PALM/V2_12NC_82pat
# PALM_dir=/NAS/tupac/matthieu/CAT_A0/PALM/V4_27NC_Park_82pat
# # # for results in TYPvsLANGvsVISUvsEXEvsNC_fwhm15_i15000 TYPvsLANGvsVISUvsEXEvsNC_3Cov_fwhm15_i15000
for results in TYPvsLANGvsVISUvsEXE_fwhm15_i15000
# for results in TYPvsLANGvsVISUvsEXEvsNC_fwhm15_i10000
do
# 	for meas in fractaldimension gyrification sqrtsulc thickness
	for meas in sqrtsulc
	do
# 		for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# 		for group in NCvsATYP NCvsTYP NCvsLANG NCvsVISU NCvsEXE TYPvsNC ATYPvsNC LANGvsNC VISUvsNC EXEvsNC
		for group in TYPvsVISU
		do
			thresh_lh=`fslstats ${PALM_dir}/${results}/${meas}/palm.${group}.lh_tfce_tstat_fwep.nii.gz -R | awk '{print $2}'`
			thresh_bin_lh=`echo "${thresh_lh}>=1.3" | bc`
			thresh_rh=`fslstats ${PALM_dir}/${results}/${meas}/palm.${group}.rh_tfce_tstat_fwep.nii.gz -R | awk '{print $2}'`
			thresh_bin_rh=`echo "${thresh_rh}>=1.3" | bc`
			if [ ${thresh_bin_lh} -eq 1 -o ${thresh_bin_rh} -eq 1 ]
			then
# 				# Not scaled
# 				# F-stat
# 				Make_montage.sh  -fs  ${SUBJECTS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/${meas}/palm.${group}.lh_tfce_fstat_fwep.mgz  \
# 				-rhoverlay ${PALM_dir}/${results}/${meas}/palm.${group}.rh_tfce_fstat_fwep.mgz  -fminmax 1.3 1.7 -fmid 1.5 -output ${PALM_dir}/${results}/${meas}/${group}.tiff -template -axial
# 				# T-stat
# 				Make_montage.sh  -fs  ${SUBJECTS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/${meas}/lh.${group}_tfce_tstat_fwep.cs90.mgh  \
# 				-rhoverlay ${PALM_dir}/${results}/${meas}/rh.${group}_tfce_tstat_fwep.cs90.mgh  -fminmax 1.3 4 -fmid 2.65  -output ${PALM_dir}/${results}/${meas}/${group}.cs90.tiff -template -axial

				# Scaled
# # 				# No Tresholding
# 				Make_montage_scales.sh  -fs ${SUBJECTS_DIR} -subj  fsaverage  -surf white -lhoverlay ${PALM_dir}/${results}/${meas}/palm.${group}.lh_tfce_tstat_fwep.nii.gz  \
# 				-rhoverlay ${PALM_dir}/${results}/${meas}/palm.${group}.rh_tfce_tstat_fwep.nii.gz  -fminmaxl 1.3 4 -fmidl 2.65 -fminmaxr 1.3 4 -fmidr 2.65 -output ${PALM_dir}/${results}/${meas}/${group}.white.tiff -template -axial

				# Tresholding
				Make_montage_scales.sh  -fs ${SUBJECTS_DIR} -subj  fsaverage  -surf inflated_pre -lhoverlay ${PALM_dir}/${results}/${meas}/lh.${group}_tfce_tstat_fwep.cs90.mgh  \
				-rhoverlay ${PALM_dir}/${results}/${meas}/rh.${group}_tfce_tstat_fwep.cs90.mgh  -fminmaxl 1.3 1.42 -fmidl 1.36 -fminmaxr 1.3 1.42 -fmidr 1.36 -output ${PALM_dir}/${results}/${meas}/${group}.inflated_pre.cs90.tiff -template -axial
			fi
		done
	done
done
