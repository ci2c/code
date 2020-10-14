#!/bin/bash

# WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsLANGvsVISUvsEXE
# WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsLANGvsVISUvsEXE/M0_M3/3Cov
# WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/3Cov
# WD=/NAS/tupac/matthieu/LME/PET_CAT/TYPvsATYP/MA
# WD=/NAS/tupac/matthieu/LME/PET_CAT/TYPvsLANGvsVISUvsEXE
# WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM1
# WD=/NAS/tupac/matthieu/LME/MRI_CAT/TYPvsLANGvsVISUvsEXE/SULC
# WD=/NAS/tupac/matthieu/LME/PET_FS/Corr_Beery_TYP
# WD=/NAS/tupac/matthieu/LME/PET_FS/TimeVaryingCov/Beery_M0_M2
# WD=/NAS/tupac/matthieu/LME/MRI_FS/TYPvsLANGvsVISUvsEXE
# WD=/NAS/tupac/matthieu/LME/PET_FS/Average_Corr/FluenceP_EXE_STM
WD=/NAS/tupac/matthieu/LME/PET_FS/Average_Corr/PortesA_TYP
modelType=0
NbGroups=0
# NbGroups=4
FWHM=10
# FWHM=15
qdec=qdec.table.pet.dat
# qdec=qdec.table.mri.dat
motif=PET.MGRousset.gn
# motif=CT

# ## Step1. Map PET data onto fsaverage, smooth and stack it into one .mgh file per hemisphere %% (Do it with ASL_GroupFiles.sh)
#
# matlab -nodisplay <<EOF
# 	%% Load Matlab Path: Matlab 14 and SPM12 needed
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
#
# 	%% Step 2. Load stacked and smoothed PET surface data into matlab
# 	[Y_lh,mri_lh] = fs_read_Y(fullfile('${WD}', 'lh.all.subjects.fwhm${FWHM}.${motif}.mgh'));
# 	[Y_rh,mri_rh] = fs_read_Y(fullfile('${WD}', 'rh.all.subjects.fwhm${FWHM}.${motif}.mgh'));
#
# 	%% Step4. Load FS's Qdec table ordered according to time for each individual and build design matrix (X) %%
#
# 	% Load QDec table
# 	Qdec = fReadQdec(fullfile('${WD}', '${qdec}'));
# 	Qdec = rmQdecCol(Qdec,1);
# 	sID = Qdec(2:end,1);
# 	Qdec = rmQdecCol(Qdec,1);
# 	M = Qdec2num(Qdec);
#
# 	% Sorts the data (according to sID then time over subject)
# 	[M_lh,Y_lh,ni_lh] = sortData(M,1,Y_lh,sID);
# 	[M_rh,Y_rh,ni_rh] = sortData(M,1,Y_rh,sID);
#
# 	% Define design matrix X
# 	intercept = ones(length(M_lh),1);
#
# 	if ${NbGroups}==0 && ${modelType}==0
# 		Score = M_lh(:,2);
# 		TimeXScore = M_lh(:,1).*Score;
#
# 		%X = [ intercept M_lh(:,1) Score ];
# 		X = [ intercept M_lh(:,1) Score TimeXScore ];
#
# 	elseif ${NbGroups}==2 && ${modelType}==0
# 		Grp2 = zeros(length(M_lh),1);
# 		idx_grp2 = find(M_lh(:,2)==2);
# 		Grp2(idx_grp2) = 1;
#
# 		TimeXGrp2 = M_lh(:,1).*Grp2;
#
# 		X = [ intercept M_lh(:,1) Grp2 TimeXGrp2 ];
#
# 	elseif ${NbGroups}==2 && ${modelType}==1
# 		Grp2 = zeros(length(M_lh),1);
# 		idx_grp2 = find(M_lh(:,2)==2);
# 		Grp2(idx_grp2) = 1;
#
# 		TimeXGrp2 = M_lh(:,1).*Grp2;
#
# 		X = [ intercept M_lh(:,1) Grp2 TimeXGrp2 M_lh(:,3:5) ];
#
# 	elseif ${NbGroups}==2 && ${modelType}==2
# 		Time2 = M_lh(:,1).*M_lh(:,1);
#
# 		Grp2 = zeros(length(M_lh),1);
# 		idx_grp2 = find(M_lh(:,2)==2);
# 		Grp2(idx_grp2) = 1;
#
# 		TimeXGrp2 = M_lh(:,1).*Grp2;
# 		Time2XGrp2 = Time2.*Grp2;
#
# 		X = [ intercept M_lh(:,1) Time2 Grp2 TimeXGrp2 Time2XGrp2 ];
#
# 	elseif ${NbGroups}==3 && ${modelType}==0
# 		Grp2 = zeros(length(M_lh),1);
# 		idx_grp2 = find(M_lh(:,2)==2);
# 		Grp2(idx_grp2) = 1;
#
# 		Grp3 = zeros(length(M_lh),1);
# 		idx_grp3 = find(M_lh(:,2)==3);
# 		Grp3(idx_grp3) = 1;
#
# 		TimeXGrp2 = M_lh(:,1).*Grp2;
# 		TimeXGrp3 = M_lh(:,1).*Grp3;
#
# 		X = [ intercept M_lh(:,1) Grp2 TimeXGrp2 Grp3 TimeXGrp3 ];
#
# 	elseif ${NbGroups}==4 && ${modelType}==0
# 		Grp2 = zeros(length(M_lh),1);
# 		idx_grp2 = find(M_lh(:,2)==2);
# 		Grp2(idx_grp2) = 1;
#
# 		Grp3 = zeros(length(M_lh),1);
# 		idx_grp3 = find(M_lh(:,2)==3);
# 		Grp3(idx_grp3) = 1;
#
# 		Grp4 = zeros(length(M_lh),1);
# 		idx_grp4 = find(M_lh(:,2)==4);
# 		Grp4(idx_grp4) = 1;
#
# 		TimeXGrp2 = M_lh(:,1).*Grp2;
# 		TimeXGrp3 = M_lh(:,1).*Grp3;
# 		TimeXGrp4 = M_lh(:,1).*Grp4;
#
# 		X = [ intercept M_lh(:,1) Grp2 TimeXGrp2 Grp3 TimeXGrp3 Grp4 TimeXGrp4 ];
#
# 	elseif ${NbGroups}==4 && ${modelType}==1
# 		Grp2 = zeros(length(M_lh),1);
# 		idx_grp2 = find(M_lh(:,2)==2);
# 		Grp2(idx_grp2) = 1;
#
# 		Grp3 = zeros(length(M_lh),1);
# 		idx_grp3 = find(M_lh(:,2)==3);
# 		Grp3(idx_grp3) = 1;
#
# 		Grp4 = zeros(length(M_lh),1);
# 		idx_grp4 = find(M_lh(:,2)==4);
# 		Grp4(idx_grp4) = 1;
#
# 		TimeXGrp2 = M_lh(:,1).*Grp2;
# 		TimeXGrp3 = M_lh(:,1).*Grp3;
# 		TimeXGrp4 = M_lh(:,1).*Grp4;
#
# 		X = [ intercept M_lh(:,1) Grp2 TimeXGrp2 Grp3 TimeXGrp3 Grp4 TimeXGrp4 M_lh(:,3:5) ];
#
# 	end
#
# 	%% Step5. Read lh/rh.sphere surface and lh/rh.cortex label %%
#
# 	lhsphere = fs_read_surf(fullfile('${FREESURFER_HOME}', 'subjects/fsaverage/surf/lh.sphere'));
# 	rhsphere = fs_read_surf(fullfile('${FREESURFER_HOME}', 'subjects/fsaverage/surf/rh.sphere'));
#
# 	lhcortex = fs_read_label(fullfile('${FREESURFER_HOME}', 'subjects/fsaverage/label/lh.cortex.label'));
# 	rhcortex = fs_read_label(fullfile('${FREESURFER_HOME}', 'subjects/fsaverage/label/rh.cortex.label'));
#
# 	save(fullfile('${WD}','PrepData.mat'),'X','M_lh','M_rh','Y_lh','Y_rh','ni_lh','ni_rh','lhcortex','rhcortex','lhsphere','rhsphere','mri_lh','mri_rh','-v7.3');
#
# EOF

# ## Step6. Parameter estimation according to classical mass-univariate models
#
# # for NbRF in 1 2
# for NbRF in 1
# do
#
# # 	for hemi in lh rh
# 	for hemi in lh
# 	do
# 		qbatch -q M32_q@qotsa -oe ${WD}/log -N MUm_${NbRF}RF_${hemi} LME_mass_fit_vw.sh ${NbRF} ${hemi} ${WD}
# # 		qbatch -q one_job_q -oe ${WD}/log -N MUm_${NbRF}RF_${hemi} LME_mass_fit_vw.sh ${NbRF} ${hemi} ${WD}
# 		sleep 1
# 	done
# done

# ## Step7. Parameter estimation according to spatiotemporal models
#
# for hemi in lh rh
# do
# 	qbatch -q M32_q -oe ${WD}/log -N SpatioTempM_${hemi} LME_SpatioTemporal.sh ${hemi} ${WD}
# 	sleep 1
# done

## Step8. Visualize corrected p-maps

# # Step8.1. Threshold corrected p-maps at 90 mm2 (PET spatial resolution)
# # WD=/NAS/tupac/protocoles/COMAJ/FS53/CSF_FS_Analysis/LONG/LME
# # WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/NoCov/MUmodel
# # WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsLANGvsVISUvsEXE/M0_M3/NoCov
# # WD=/NAS/tupac/matthieu/LME/MRI_CAT/TYPvsATYP/GYR/15mm
# # WD=/NAS/tupac/matthieu/LME/MRI_FS/TYPvsATYP
# # WD=/NAS/tupac/matthieu/LME/MRI_FS/TYPvsLANGvsVISUvsEXE
# # WD=/NAS/tupac/matthieu/LME/MRI_CAT/TYPvsLANGvsVISUvsEXE/SULC
# WD=/NAS/tupac/matthieu/LME/PET_FS/Average_Corr/FluenceP_ATYP
# # WD=/NAS/tupac/matthieu/LME/PET_FS/Average_Corr/PortesA_TYP
# thmin_lh=1.3
# thmin_rh=1.3
# sign=pos
# # for group in TYPconjPortesA
# for group in ATYPconjFluenceP
# do
# # 	mri_surfcluster --in ${WD}/lh.${group}.sig.${sign}.mgh --subject fsaverage --hemi lh --annot aparc.a2009s --thmin ${thmin_lh} --minarea 90 \
# # 	--sum ${WD}/lh.${group}.cluster.${sign}.summary --ocn ${WD}/lh.${group}.cluster_number.${sign}.nii.gz --o ${WD}/lh.${group}.sig.${sign}.cs90.mgh
# # 	mri_surfcluster --in ${WD}/rh.${group}.sig.${sign}.mgh --subject fsaverage --hemi rh --annot aparc.a2009s --thmin ${thmin_rh} --minarea 90 \
# # 	--sum ${WD}/rh.${group}.cluster.${sign}.summary --ocn ${WD}/rh.${group}.cluster_number.${sign}.nii.gz --o ${WD}/rh.${group}.sig.${sign}.cs90.mgh
#
# 	# conjunction maps
# 	mri_surfcluster --in ${WD}/lh.${group}.cs90.mgh --subject fsaverage --hemi lh --annot aparc.a2009s --thmin ${thmin_lh} --minarea 90 \
# 	--sum ${WD}/Conjunction/lh.${group}.cluster.summary --ocn ${WD}/Conjunction/lh.${group}.cluster_number.nii.gz --o ${WD}/Conjunction/lh.${group}.cs90.mgh
# 	mri_surfcluster --in ${WD}/rh.${group}.cs90.mgh --subject fsaverage --hemi rh --annot aparc.a2009s --thmin ${thmin_lh} --minarea 90 \
# 	--sum ${WD}/Conjunction/rh.${group}.cluster.summary --ocn ${WD}/Conjunction/rh.${group}.cluster_number.nii.gz --o ${WD}/Conjunction/rh.${group}.cs90.mgh
#
# done

# # Step8.2. Convert .mgz files into .nii.gz and compute min/max stats
# # PALM_dir=/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/NoCov
# # PALM_dir=/NAS/tupac/matthieu/LME/PET_FS/TYPvsLANGvsVISUvsEXE/M0_M3
# # PALM_dir=/NAS/tupac/matthieu/LME/MRI_CAT/TYPvsATYP/GYR
# # PALM_dir=/NAS/tupac/matthieu/LME/MRI_FS
# # PALM_dir=/NAS/tupac/matthieu/LME/MRI_CAT/TYPvsATYP
# PALM_dir=/NAS/tupac/matthieu/LME/PET_FS/Average_Corr
#
# # cd ${PALM_dir}/CorrAll_Tau_fwhm10_gn_MGRousset_i10000_TFCE_defaults_CT_Cov
# # for i in palm.*.?h_tfce_tstat_fwep.mgz ; do
# # # for i in palm.F.?h_tfce_fstat_fwep.mgz ; do
# # # for i in palm.*.?h_tfce_rstat_fwep.mgz ; do
# # 	base=${i%.mgz}
# # 	mri_convert $i ${base}.nii.gz
# # done

# # Step8.3. Create .tiff images of surface representations
# PALM_dir=/NAS/tupac/matthieu/LME/PET_FS/Average_Corr/PortesA_TYP
# FS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
# sign=pos
# # for results in FluenceP_ATYP
# # for results in PortesA_TYP
# for results in Conjunction
# do
# # 	for group in corrFluenceP
# # 	for group in corrPortesA
# 	for group in TYPconjPortesA
# 	do
# # 		## No-scaling
# 		# T_tests
# # 		Make_montage.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/palm.${group}.lh_tfce_tstat_fwep.mgz  \
# # 		-rhoverlay ${PALM_dir}/${results}/palm.${group}.rh_tfce_tstat_fwep.mgz  -fminmax 1.3 3.7 -fmid 2.5  -output ${PALM_dir}/${results}/${group}.tiff -template -axial
# # 		# F_tests
# # 		Make_montage.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/palm.${group}.lh_tfce_fstat_fwep.mgz  \
# # 		-rhoverlay ${PALM_dir}/${results}/palm.${group}.rh_tfce_fstat_fwep.mgz  -fminmax 1.3 3.7 -fmid 2.5  -output ${PALM_dir}/${results}/${group}.tiff -template -axial
# 	done
# done

## Step9. Extract significant clusters and compute mean PET on A0...A3 subjects in fsaverage space

SUBJECTS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
FILE_PATH=/NAS/tupac/matthieu/LME
DDP=/NAS/tupac/matthieu/LME/ROIs/PET

# 9.1 Extract binary masks from significant cortical clusters

# ## Lateral orbitofrontal + temporal sup ##
# WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/NoCov/MUmodel
# mri_binarize --i ${WD}/lh.grp2vsgrp1.sig.neg.cs90.mgh --min 0.1 --o ${DD}/lh.grp2vsgrp1.sig.neg.cs90.bin.mgh
# mri_binarize --i ${WD}/rh.grp2vsgrp1.sig.neg.cs90.mgh --min 0.1 --o ${DD}/rh.grp2vsgrp1.sig.neg.cs90.bin.mgh
#
# ## Posterior cortex: temporo-parietal & precuneus ##
# WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/NoCov/MUmodel
# mri_surfcluster --in ${WD}/lh.grp1.sig.neg.mgh --subject fsaverage --hemi lh --annot aparc.a2009s --thmin 7.3 --minarea 90 \
# --sum ${DD}/lh.grp1.cluster.neg.summary --ocn ${DD}/lh.grp1.cluster.number.neg.mgh --o ${DD}/lh.grp1.sig.neg.cs90.mgh
# mri_surfcluster --in ${WD}/rh.grp1.sig.neg.mgh --subject fsaverage --hemi rh --annot aparc.a2009s --thmin 6.2 --minarea 90 \
# --sum ${DD}/rh.grp1.cluster.neg.summary --ocn ${DD}/rh.grp1.cluster.number.neg.mgh --o ${DD}/rh.grp1.sig.neg.cs90.mgh
#
# mri_extract_label ${DD}/lh.grp1.cluster.number.neg.mgh 1 ${DD}/lh.grp1.sig.neg.cs90.bin.mgh
# mri_extract_label ${DD}/rh.grp1.cluster.number.neg.mgh 1 ${DD}/rh.grp1.sig.neg.cs90.bin.mgh

# ## Temporal cortex: lateral inf-mid, pole, median, fusiform & lingual  ##
# mri_annotation2label --annotation aparc.a2009s --subject fsaverage --hemi lh --sd ${SUBJECTS_DIR} --outdir ${DD}/Destrieux/labels
# mri_annotation2label --annotation aparc.a2009s --subject fsaverage --hemi rh --sd ${SUBJECTS_DIR} --outdir ${DD}/Destrieux/labels
#
# mri_mergelabels -i ${DD}/Destrieux/labels/lh.G_temporal_middle.label \
# -i ${DD}/Destrieux/labels/lh.S_temporal_inf.label \
# -i ${DD}/Destrieux/labels/lh.G_temporal_inf.label \
# -i ${DD}/Destrieux/labels/lh.Pole_temporal.label \
# -i ${DD}/Destrieux/labels/lh.G_temp_sup-Plan_polar.label \
# -i ${DD}/Destrieux/labels/lh.G_oc-temp_med-Parahip.label \
# -i ${DD}/Destrieux/labels/lh.S_oc-temp_med_and_Lingual.label \
# -i ${DD}/Destrieux/labels/lh.S_collat_transv_ant.label \
# -i ${DD}/Destrieux/labels/lh.G_oc-temp_lat-fusifor.label \
# -i ${DD}/Destrieux/labels/lh.S_oc-temp_lat.label \
# -o ${DD}/Destrieux/labels/lh.temporal.sign.label
#
# mri_mergelabels -i ${DD}/Destrieux/labels/rh.G_temporal_middle.label \
# -i ${DD}/Destrieux/labels/rh.S_temporal_inf.label \
# -i ${DD}/Destrieux/labels/rh.G_temporal_inf.label \
# -i ${DD}/Destrieux/labels/rh.Pole_temporal.label \
# -i ${DD}/Destrieux/labels/rh.G_temp_sup-Plan_polar.label \
# -i ${DD}/Destrieux/labels/rh.G_oc-temp_med-Parahip.label \
# -i ${DD}/Destrieux/labels/rh.S_oc-temp_med_and_Lingual.label \
# -i ${DD}/Destrieux/labels/rh.S_collat_transv_ant.label \
# -i ${DD}/Destrieux/labels/rh.G_oc-temp_lat-fusifor.label \
# -i ${DD}/Destrieux/labels/rh.S_oc-temp_lat.label \
# -o ${DD}/Destrieux/labels/rh.temporal.sign.label
#
# mri_label2label --srclabel ${DD}/Destrieux/labels/lh.temporal.sign.label --s fsaverage --trglabel ${DD}/lh.temporal.sig.bin.mgh --outmask ${DD}/lh.temporal.sig.bin.mgh --hemi lh --regmethod surface
# mri_label2label --srclabel ${DD}/Destrieux/labels/rh.temporal.sign.label --s fsaverage --trglabel ${DD}/rh.temporal.sig.bin.mgh --outmask ${DD}/rh.temporal.sig.bin.mgh --hemi rh --regmethod surface

# ## ATYPvsTYP A0 ##
# mri_mergelabels -i ${DD}/Destrieux/labels/lh.Pole_temporal.label \
# -i ${DD}/Destrieux/labels/lh.G_temp_sup-Plan_polar.label \
# -i ${DD}/Destrieux/labels/lh.G_oc-temp_med-Parahip.label \
# -o ${DD}/Destrieux/labels/lh.ATYPvsTYP.A0.sign.label
#
# mri_mergelabels -i ${DD}/Destrieux/labels/rh.Pole_temporal.label \
# -i ${DD}/Destrieux/labels/rh.G_temp_sup-Plan_polar.label \
# -i ${DD}/Destrieux/labels/rh.G_oc-temp_med-Parahip.label \
# -o ${DD}/Destrieux/labels/rh.ATYPvsTYP.A0.sign.label
#
# mri_label2label --srclabel ${DD}/Destrieux/labels/lh.ATYPvsTYP.A0.sign.label --s fsaverage --trglabel ${DD}/lh.ATYPvsTYP.A0.sig.bin.mgh --outmask ${DD}/lh.ATYPvsTYP.A0.sig.bin.mgh --hemi lh --regmethod surface
# mri_label2label --srclabel ${DD}/Destrieux/labels/rh.ATYPvsTYP.A0.sign.label --s fsaverage --trglabel ${DD}/rh.ATYPvsTYP.A0.sig.bin.mgh --outmask ${DD}/rh.ATYPvsTYP.A0.sig.bin.mgh --hemi rh --regmethod surface

# ## Frontal: grp2.neg ##
# # WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/NoCov/MUmodel
# # mri_surfcluster --in ${WD}/lh.grp2.sig.neg.mgh --subject fsaverage --hemi lh --annot aparc.a2009s --thmin 3.5 --minarea 90 \
# # --sum ${DDP}/lh.grp2.cluster.neg.frontal.summary --ocn ${DDP}/lh.grp2.cluster.number.neg.frontal.mgh --o ${DDP}/lh.grp2.sig.neg.cs90.frontal.mgh
# # mri_surfcluster --in ${WD}/rh.grp2.sig.neg.mgh --subject fsaverage --hemi rh --annot aparc.a2009s --thmin 2 --minarea 90 \
# # --sum ${DDP}/rh.grp2.cluster.neg.frontal.summary --ocn ${DDP}/rh.grp2.cluster.number.neg.frontal.mgh --o ${DDP}/rh.grp2.sig.neg.cs90.frontal.mgh
#
# mri_extract_label ${DDP}/lh.grp2.cluster.number.neg.frontal.mgh 2 ${DDP}/lh.grp2.sig.neg.cs90.frontal.bin.mgh
# mri_extract_label ${DDP}/rh.grp2.cluster.number.neg.frontal.mgh 2 ${DDP}/rh.grp2.sig.neg.cs90.frontal.bin.mgh

# ## Precuneus + posterior cingulate ##
# mri_mergelabels -i ${DDP}/Destrieux/labels/lh.G_precuneus.label \
# -i ${DDP}/Destrieux/labels/lh.S_subparietal.label \
# -i ${DDP}/Destrieux/labels/lh.G_cingul-Post-dorsal.label \
# -o ${DDP}/Destrieux/labels/lh.Prec.PCC.sign.label
#
# mri_mergelabels -i ${DDP}/Destrieux/labels/rh.G_precuneus.label \
# -i ${DDP}/Destrieux/labels/rh.S_subparietal.label \
# -i ${DDP}/Destrieux/labels/rh.G_cingul-Post-dorsal.label \
# -o ${DDP}/Destrieux/labels/rh.Prec.PCC.sign.label
#
# mri_label2label --srclabel ${DDP}/Destrieux/labels/lh.Prec.PCC.sign.label --s fsaverage --trglabel ${DDP}/lh.Prec.PCC.sig.bin.mgh --outmask ${DDP}/lh.Prec.PCC.sig.bin.mgh --hemi lh --regmethod surface
# mri_label2label --srclabel ${DDP}/Destrieux/labels/rh.Prec.PCC.sign.label --s fsaverage --trglabel ${DDP}/rh.Prec.PCC.sig.bin.mgh --outmask ${DDP}/rh.Prec.PCC.sig.bin.mgh --hemi rh --regmethod surface

# ## Temporoparietal: Destrieux ##
# mri_mergelabels -i ${DDP}/Destrieux/labels/lh.G_pariet_inf-Supramar.label \
# -i ${DDP}/Destrieux/labels/lh.G_temp_sup-Plan_tempo.label \
# -i ${DDP}/Destrieux/labels/lh.Lat_Fis-post.label \
# -i ${DDP}/Destrieux/labels/lh.S_intrapariet_and_P_trans.label \
# -i ${DDP}/Destrieux/labels/lh.G_pariet_inf-Angular.label \
# -i ${DDP}/Destrieux/labels/lh.S_interm_prim-Jensen.label \
# -i ${DDP}/Destrieux/labels/lh.G_parietal_sup.label \
# -o ${DDP}/Destrieux/labels/lh.Temporoparietal.sign.label
#
# mri_mergelabels -i ${DDP}/Destrieux/labels/rh.G_pariet_inf-Supramar.label \
# -i ${DDP}/Destrieux/labels/rh.G_temp_sup-Plan_tempo.label \
# -i ${DDP}/Destrieux/labels/rh.S_intrapariet_and_P_trans.label \
# -i ${DDP}/Destrieux/labels/rh.G_pariet_inf-Angular.label \
# -i ${DDP}/Destrieux/labels/rh.S_interm_prim-Jensen.label \
# -i ${DDP}/Destrieux/labels/rh.G_parietal_sup.label \
# -o ${DDP}/Destrieux/labels/rh.Temporoparietal.sign.label
#
# mri_label2label --srclabel ${DDP}/Destrieux/labels/lh.Temporoparietal.sign.label --s fsaverage --trglabel ${DDP}/lh.Temporoparietal.sig.bin.mgh --outmask ${DDP}/lh.Temporoparietal.sig.bin.mgh --hemi lh --regmethod surface
# mri_label2label --srclabel ${DDP}/Destrieux/labels/rh.Temporoparietal.sign.label --s fsaverage --trglabel ${DDP}/rh.Temporoparietal.sig.bin.mgh --outmask ${DDP}/rh.Temporoparietal.sig.bin.mgh --hemi rh --regmethod surface

# ## Frontal: grp1.neg ##
# # WD=/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/NoCov/MUmodel
# # mri_surfcluster --in ${WD}/lh.grp1.sig.neg.mgh --subject fsaverage --hemi lh --annot aparc.a2009s --thmin 4.4 --minarea 90 \
# # --sum ${DDP}/lh.grp1.cluster.neg.frontal.summary --ocn ${DDP}/lh.grp1.cluster.number.neg.frontal.mgh --o ${DDP}/lh.grp1.sig.neg.cs90.frontal.mgh
# # mri_surfcluster --in ${WD}/rh.grp1.sig.neg.mgh --subject fsaverage --hemi rh --annot aparc.a2009s --thmin 4 --minarea 90 \
# # --sum ${DDP}/rh.grp1.cluster.neg.frontal.summary --ocn ${DDP}/rh.grp1.cluster.number.neg.frontal.mgh --o ${DDP}/rh.grp1.sig.neg.cs90.frontal.mgh
#
# mri_extract_label ${DDP}/lh.grp1.cluster.number.neg.frontal.mgh 2 ${DDP}/lh.grp1.sig.neg.cs90.frontal.bin.mgh
# mri_extract_label ${DDP}/rh.grp1.cluster.number.neg.frontal.mgh 2 ${DDP}/rh.grp1.sig.neg.cs90.frontal.bin.mgh

# # 9.2 Verify existence of processed files in long FS directory
# while read LINE
# do
# 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# 	NbTP=$(echo ${LINE} | awk '{print $2}')
#
# 	for i in `seq 1 ${NbTP}`;
# 	do
# 		j=$[$i+2]
# 		TP=$(echo ${LINE} | cut -d" " -f$j)
# 		SUBJECT_ID=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -E "long.${SUBJ_ID}$")
#
# 		if [ -s ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh ] && [ -s ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh ]
# 		then
# 			echo "${SUBJECT_ID} : OK"
# 		else
# 			echo "${SUBJECT_ID} : NOK"
# 		fi
# 	done
# done < ${FILE_PATH}/Long_COMAJ_MRI

# ## 9.3 Extract mean PET activity based on binary significant clusters (.mgh): gives only number of vertices
# while read LINE
# do
# 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# 	NbTP=$(echo ${LINE} | awk '{print $2}')
# 	for i in `seq 1 ${NbTP}`;
# 	do
# 		j=$[$i+2]
# 		TP=$(echo ${LINE} | cut -d" " -f$j)
# 		SUBJECT_ID=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -E "long.${SUBJ_ID}$")
#
# # 		## Grp2vsGrp1.neg: Lateral orbitofrontal + temporal sup ##
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DD}/lh.grp2vsgrp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 		--sum ${DD}/Grp2vsGrp1/lh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DD}/Grp2vsGrp1/lh.pet.wav.${SUBJECT_ID}.bin.txt
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DD}/rh.grp2vsgrp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 		--sum ${DD}/Grp2vsGrp1/rh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DD}/Grp2vsGrp1/rh.pet.wav.${SUBJECT_ID}.bin.txt
#
# # 		## Grp1.neg poserior cortex: temporo-parietal + precuneus ##
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DD}/lh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 		--sum ${DD}/PosteriorCortex/lh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DD}/PosteriorCortex/lh.pet.wav.${SUBJECT_ID}.bin.txt
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DD}/rh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 		--sum ${DD}/PosteriorCortex/rh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DD}/PosteriorCortex/rh.pet.wav.${SUBJECT_ID}.bin.txt
#
# # 		## Temporal cortex: lateral inf-mid, pole, median, fusiform & lingual ##
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DD}/lh.temporal.sig.bin.mgh --excludeid 0 \
# # 		--sum ${DD}/Temporal/lh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DD}/Temporal/lh.pet.wav.${SUBJECT_ID}.bin.txt
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DD}/rh.temporal.sig.bin.mgh --excludeid 0 \
# # 		--sum ${DD}/Temporal/rh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DD}/Temporal/rh.pet.wav.${SUBJECT_ID}.bin.txt
#
# # 		## ATYPvsTYP A0 ##
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DD}/lh.ATYPvsTYP.A0.sig.bin.mgh --excludeid 0 \
# # 		--sum ${DD}/ATYPvsTYP_A0/lh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DD}/ATYPvsTYP_A0/lh.pet.wav.${SUBJECT_ID}.bin.txt
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DD}/rh.ATYPvsTYP.A0.sig.bin.mgh --excludeid 0 \
# # 		--sum ${DD}/ATYPvsTYP_A0/rh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DD}/ATYPvsTYP_A0/rh.pet.wav.${SUBJECT_ID}.bin.txt
#
# # 		## Frontal grp2.neg ##
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DDP}/lh.grp2.sig.neg.cs90.frontal.bin.mgh --excludeid 0 \
# # 		--sum ${DDP}/Frontal/lh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DDP}/Frontal/lh.pet.wav.${SUBJECT_ID}.bin.txt
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DDP}/rh.grp2.sig.neg.cs90.frontal.bin.mgh --excludeid 0 \
# # 		--sum ${DDP}/Frontal/rh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DDP}/Frontal/rh.pet.wav.${SUBJECT_ID}.bin.txt
#
# # 		## Precuneus + PCC: Destrieux ##
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DDP}/lh.Prec.PCC.sig.bin.mgh --excludeid 0 \
# # 		--sum ${DDP}/Precuneus_PCC/lh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DDP}/Precuneus_PCC/lh.pet.wav.${SUBJECT_ID}.bin.txt
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DDP}/rh.Prec.PCC.sig.bin.mgh --excludeid 0 \
# # 		--sum ${DDP}/Precuneus_PCC/rh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DDP}/Precuneus_PCC/rh.pet.wav.${SUBJECT_ID}.bin.txt
#
# # 		## Temporoparietal: Destrieux ##
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DDP}/lh.Temporoparietal.sig.bin.mgh --excludeid 0 \
# # 		--sum ${DDP}/Temporoparietal/lh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DDP}/Temporoparietal/lh.pet.wav.${SUBJECT_ID}.bin.txt
# # 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DDP}/rh.Temporoparietal.sig.bin.mgh --excludeid 0 \
# # 		--sum ${DDP}/Temporoparietal/rh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DDP}/Temporoparietal/rh.pet.wav.${SUBJECT_ID}.bin.txt
#
# 		## Frontal grp1.neg ##
# 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DDP}/lh.grp1.sig.neg.cs90.frontal.bin.mgh --excludeid 0 \
# 		--sum ${DDP}/Frontal_Grp1/lh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DDP}/Frontal_Grp1/lh.pet.wav.${SUBJECT_ID}.bin.txt
# 		mri_segstats --i ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm10.mgh --seg ${DDP}/rh.grp1.sig.neg.cs90.frontal.bin.mgh --excludeid 0 \
# 		--sum ${DDP}/Frontal_Grp1/rh.pet.${SUBJECT_ID}.bin.sum --avgwf ${DDP}/Frontal_Grp1/rh.pet.wav.${SUBJECT_ID}.bin.txt
# 	done
# done < ${FILE_PATH}/Long_COMAJ_MRI

while read LINE
do
	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# 	for ROI in Grp2vsGrp1 PosteriorCortex Temporal ATYPvsTYP_A0 Frontal Precuneus_PCC Temporoparietal Frontal_Grp1
	for ROI in Frontal_Grp1
	do
		for TP in M0 M1 M2 M3
		do
			MeanPet_lh=$(ls ${DDP}/${ROI} | grep -E "^lh.pet.wav.${SUBJ_ID}_${TP}" | grep -E "long.${SUBJ_ID}.bin.txt$")
			MeanPet_rh=$(ls ${DDP}/${ROI} | grep -E "^rh.pet.wav.${SUBJ_ID}_${TP}" | grep -E "long.${SUBJ_ID}.bin.txt$")

			if [ -f ${DDP}/${ROI}/${MeanPet_lh} ] && [ -f ${DDP}/${ROI}/${MeanPet_rh} ]
			then
				for WORD in `cat ${DDP}/${ROI}/${MeanPet_lh}`
				do
					echo ${WORD} >> ${DDP}/${ROI}/lh.mean.pet.roi.bin.${TP}.txt
				done

				for WORD in `cat ${DDP}/${ROI}/${MeanPet_rh}`
				do
					echo ${WORD} >> ${DDP}/${ROI}/rh.mean.pet.roi.bin.${TP}.txt
				done
			elif [ ! -f ${DDP}/${ROI}/${MeanPet_lh} ] && [ ! -f ${DDP}/${ROI}/${MeanPet_rh} ]
			then
				echo "NA" >> ${DDP}/${ROI}/lh.mean.pet.roi.bin.${TP}.txt
				echo "NA" >> ${DDP}/${ROI}/rh.mean.pet.roi.bin.${TP}.txt
			fi
		done
	done
done < ${FILE_PATH}/Long_COMAJ_MRI

# ## Step10. Extract significant clusters and compute mean MRI CT on A0...A3 subjects in fsaverage space
#
# SUBJECTS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
# FILE_PATH=/NAS/tupac/matthieu/LME
# DD=/NAS/tupac/matthieu/LME/ROIs/MRI

# 10.1 Extract binary masks from significant cortical clusters

## Temporal + insula ##
# WD=/NAS/tupac/matthieu/LME/MRI_CAT/TYPvsATYP/CT
# mri_surfcluster --in ${WD}/lh.grp1.sig.neg.mgh --subject fsaverage --hemi lh --annot aparc.a2009s --thmin 6.5 --minarea 90 \
# --sum ${DD}/lh.grp1.cluster.neg.summary --ocn ${DD}/lh.grp1.cluster.number.neg.mgh --o ${DD}/lh.grp1.sig.neg.cs90.mgh
# mri_surfcluster --in ${WD}/rh.grp1.sig.neg.mgh --subject fsaverage --hemi rh --annot aparc.a2009s --thmin 8 --minarea 90 \
# --sum ${DD}/rh.grp1.cluster.neg.summary --ocn ${DD}/rh.grp1.cluster.number.neg.mgh --o ${DD}/rh.grp1.sig.neg.cs90.mgh
#
# mri_extract_label ${DD}/lh.grp1.cluster.number.neg.mgh 2 ${DD}/lh.grp1.sig.neg.cs90.bin.mgh
# mri_extract_label ${DD}/rh.grp1.cluster.number.neg.mgh 1 3 ${DD}/rh.grp1.sig.neg.cs90.bin.mgh

# ## Lateral orbitofrontal ##
# mri_mergelabels -i ${DDP}/Destrieux/labels/lh.S_orbital-H_Shaped.label \
# -i ${DDP}/Destrieux/labels/lh.G_orbital.label \
# -i ${DDP}/Destrieux/labels/lh.S_orbital_med-olfact.label \
# -i ${DDP}/Destrieux/labels/lh.G_and_S_frontomargin.label \
# -o ${DD}/Destrieux/labels/lh.orbitofrontal.sign.label
#
# mri_mergelabels -i ${DDP}/Destrieux/labels/rh.S_orbital-H_Shaped.label \
# -i ${DDP}/Destrieux/labels/rh.G_orbital.label \
# -i ${DDP}/Destrieux/labels/rh.S_orbital_med-olfact.label \
# -i ${DDP}/Destrieux/labels/rh.G_and_S_frontomargin.label \
# -o ${DD}/Destrieux/labels/rh.orbitofrontal.sign.label
#
# mri_label2label --srclabel ${DD}/Destrieux/labels/lh.orbitofrontal.sign.label --s fsaverage --trglabel ${DD}/lh.orbitofrontal.sig.bin.mgh --outmask ${DD}/lh.orbitofrontal.sig.bin.mgh --hemi lh --regmethod surface
# mri_label2label --srclabel ${DD}/Destrieux/labels/rh.orbitofrontal.sign.label --s fsaverage --trglabel ${DD}/rh.orbitofrontal.sig.bin.mgh --outmask ${DD}/rh.orbitofrontal.sig.bin.mgh --hemi rh --regmethod surface

# # 10.2 Verify existence of processed files in CAT_A0/CAT_LONG directories
# while read LINE
# do
# 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# 	NbTP=$(echo ${LINE} | awk '{print $2}')
# 	if [ ${NbTP} -eq 1 ]
# 	then
# 		TP=$(echo ${LINE} | cut -d" " -f3)
# 		id=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -v -E "long.${SUBJ_ID}$")
# 		if [ ${TP} != M0 ]
# 		then
# 			for motif in thickness
# 			do
# 				if [ -s /NAS/tupac/matthieu/CAT_LONG/surf/lh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh ] && [ -s /NAS/tupac/matthieu/CAT_LONG/surf/rh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh ]
# 				then
# 					echo "${id} : OK"
# 				else
# 					echo "${id} : NOK"
# 				fi
# 			done
#
# 		else
# 			for motif in thickness
# 			do
# 				if [ -s /NAS/tupac/matthieu/CAT_A0/surf/lh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh ] && [ -s /NAS/tupac/matthieu/CAT_A0/surf/rh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh ]
# 				then
# 					echo "${id} : OK"
# 				else
# 					echo "${id} : NOK"
# 				fi
# 			done
# 		fi
# 	elif [ ${NbTP} -gt 1 ]
# 	then
# 		for i in `seq 1 ${NbTP}`;
# 		do
# 			j=$[$i+2]
# 			TP=$(echo ${LINE} | cut -d" " -f$j)
# 			id=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -v -E "long.${SUBJ_ID}$")
#
# 			for motif in thickness
# 			do
# 				if [ -s /NAS/tupac/matthieu/CAT_LONG/surf/lh.${motif}.fsaverage.s15mm.rorig.lia.${id}.mgh ] && [ -s /NAS/tupac/matthieu/CAT_LONG/surf/rh.${motif}.fsaverage.s15mm.rorig.lia.${id}.mgh ]
# 				then
# 					echo "${id} : OK"
# 				else
# 					echo "${id} : NOK"
# 				fi
# 			done
# 		done
# 	fi
# done < ${FILE_PATH}/Long_COMAJ_MRI

# 10.3 Extract mean CT based on binary significant clusters (.mgh): gives only number of vertices
# while read LINE
# do
# 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# 	NbTP=$(echo ${LINE} | awk '{print $2}')
# 	if [ ${NbTP} -eq 1 ]
# 	then
# 		TP=$(echo ${LINE} | cut -d" " -f3)
# 		id=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -v -E "long.${SUBJ_ID}$")
# 		if [ ${TP} != M0 ]
# 		then
# 			for motif in thickness
# 			do
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/lh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DD}/lh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/Temporal_Insula/lh.ct.${id}.bin.sum --avgwf ${DD}/Temporal_Insula/lh.ct.wav.${id}.bin.txt
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/rh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DD}/rh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/Temporal_Insula/rh.ct.${id}.bin.sum --avgwf ${DD}/Temporal_Insula/rh.ct.wav.${id}.bin.txt
#
# # 				## Grp1.neg PET poserior cortex: temporo-parietal + precuneus ##
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/lh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DDP}/lh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/PosteriorCortex/lh.ct.${id}.bin.sum --avgwf ${DD}/PosteriorCortex/lh.ct.wav.${id}.bin.txt
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/rh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DDP}/rh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/PosteriorCortex/rh.ct.${id}.bin.sum --avgwf ${DD}/PosteriorCortex/rh.ct.wav.${id}.bin.txt
#
# 				## Lateral orbitofrontal ##
# 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/lh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DD}/lh.orbitofrontal.sig.bin.mgh --excludeid 0 \
# 				--sum ${DD}/Orbitofrontal/lh.ct.${id}.bin.sum --avgwf ${DD}/Orbitofrontal/lh.ct.wav.${id}.bin.txt
# 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/rh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DD}/rh.orbitofrontal.sig.bin.mgh --excludeid 0 \
# 				--sum ${DD}/Orbitofrontal/rh.ct.${id}.bin.sum --avgwf ${DD}/Orbitofrontal/rh.ct.wav.${id}.bin.txt
# 			done
#
# 		else
# 			for motif in thickness
# 			do
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_A0/surf/lh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DD}/lh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/Temporal_Insula/lh.ct.${id}.bin.sum --avgwf ${DD}/Temporal_Insula/lh.ct.wav.${id}.bin.txt
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_A0/surf/rh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DD}/rh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/Temporal_Insula/rh.ct.${id}.bin.sum --avgwf ${DD}/Temporal_Insula/rh.ct.wav.${id}.bin.txt
#
# # 				## Grp1.neg PET poserior cortex: temporo-parietal + precuneus ##
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_A0/surf/lh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DDP}/lh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/PosteriorCortex/lh.ct.${id}.bin.sum --avgwf ${DD}/PosteriorCortex/lh.ct.wav.${id}.bin.txt
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_A0/surf/rh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DDP}/rh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/PosteriorCortex/rh.ct.${id}.bin.sum --avgwf ${DD}/PosteriorCortex/rh.ct.wav.${id}.bin.txt
#
# 				## Lateral orbitofrontal ##
# 				mri_segstats --i /NAS/tupac/matthieu/CAT_A0/surf/lh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DD}/lh.orbitofrontal.sig.bin.mgh --excludeid 0 \
# 				--sum ${DD}/Orbitofrontal/lh.ct.${id}.bin.sum --avgwf ${DD}/Orbitofrontal/lh.ct.wav.${id}.bin.txt
# 				mri_segstats --i /NAS/tupac/matthieu/CAT_A0/surf/rh.${motif}.fsaverage.s15mm.orig.lia.${id}.mgh --seg ${DD}/rh.orbitofrontal.sig.bin.mgh --excludeid 0 \
# 				--sum ${DD}/Orbitofrontal/rh.ct.${id}.bin.sum --avgwf ${DD}/Orbitofrontal/rh.ct.wav.${id}.bin.txt
# 			done
# 		fi
# 	elif [ ${NbTP} -gt 1 ]
# 	then
# 		for i in `seq 1 ${NbTP}`;
# 		do
# 			j=$[$i+2]
# 			TP=$(echo ${LINE} | cut -d" " -f$j)
# 			id=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -v -E "long.${SUBJ_ID}$")
#
# 			for motif in thickness
# 			do
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/lh.${motif}.fsaverage.s15mm.rorig.lia.${id}.mgh --seg ${DD}/lh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/Temporal_Insula/lh.ct.${id}.bin.sum --avgwf ${DD}/Temporal_Insula/lh.ct.wav.${id}.bin.txt
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/rh.${motif}.fsaverage.s15mm.rorig.lia.${id}.mgh --seg ${DD}/rh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/Temporal_Insula/rh.ct.${id}.bin.sum --avgwf ${DD}/Temporal_Insula/rh.ct.wav.${id}.bin.txt
#
# # 				## Grp1.neg PET poserior cortex: temporo-parietal + precuneus ##
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/lh.${motif}.fsaverage.s15mm.rorig.lia.${id}.mgh --seg ${DDP}/lh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/PosteriorCortex/lh.ct.${id}.bin.sum --avgwf ${DD}/PosteriorCortex/lh.ct.wav.${id}.bin.txt
# # 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/rh.${motif}.fsaverage.s15mm.rorig.lia.${id}.mgh --seg ${DDP}/rh.grp1.sig.neg.cs90.bin.mgh --excludeid 0 \
# # 				--sum ${DD}/PosteriorCortex/rh.ct.${id}.bin.sum --avgwf ${DD}/PosteriorCortex/rh.ct.wav.${id}.bin.txt
#
# 				## Lateral orbitofrontal ##
# 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/lh.${motif}.fsaverage.s15mm.rorig.lia.${id}.mgh --seg ${DD}/lh.orbitofrontal.sig.bin.mgh --excludeid 0 \
# 				--sum ${DD}/Orbitofrontal/lh.ct.${id}.bin.sum --avgwf ${DD}/Orbitofrontal/lh.ct.wav.${id}.bin.txt
# 				mri_segstats --i /NAS/tupac/matthieu/CAT_LONG/surf/rh.${motif}.fsaverage.s15mm.rorig.lia.${id}.mgh --seg ${DD}/rh.orbitofrontal.sig.bin.mgh --excludeid 0 \
# 				--sum ${DD}/Orbitofrontal/rh.ct.${id}.bin.sum --avgwf ${DD}/Orbitofrontal/rh.ct.wav.${id}.bin.txt
# 			done
# 		done
# 	fi
# done < ${FILE_PATH}/Long_COMAJ_MRI

# while read LINE
# do
# 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# # 	for ROI in Temporal_Insula PosteriorCortex Orbitofrontal
# 	for ROI in Orbitofrontal
# 	do
# 		for TP in M0 M1 M2 M3
# 		do
# 			MeanCT_lh=$(ls ${DD}/${ROI} | grep -E "^lh.ct.wav.${SUBJ_ID}_${TP}" | grep -E "bin.txt$")
# 			MeanCT_rh=$(ls ${DD}/${ROI} | grep -E "^rh.ct.wav.${SUBJ_ID}_${TP}" | grep -E "bin.txt$")
#
# 			if [ -f ${DD}/${ROI}/${MeanCT_lh} ] && [ -f ${DD}/${ROI}/${MeanCT_rh} ]
# 			then
# 				for WORD in `cat ${DD}/${ROI}/${MeanCT_lh}`
# 				do
# 					echo ${WORD} >> ${DD}/${ROI}/lh.mean.ct.roi.bin.${TP}.txt
# 				done
#
# 				for WORD in `cat ${DD}/${ROI}/${MeanCT_rh}`
# 				do
# 					echo ${WORD} >> ${DD}/${ROI}/rh.mean.ct.roi.bin.${TP}.txt
# 				done
# 			elif [ ! -f ${DD}/${ROI}/${MeanCT_lh} ] && [ ! -f ${DD}/${ROI}/${MeanCT_rh} ]
# 			then
# 				echo "NA" >> ${DD}/${ROI}/lh.mean.ct.roi.bin.${TP}.txt
# 				echo "NA" >> ${DD}/${ROI}/rh.mean.ct.roi.bin.${TP}.txt
# 			fi
# 		done
# 	done
# done < ${FILE_PATH}/Long_COMAJ_MRI
