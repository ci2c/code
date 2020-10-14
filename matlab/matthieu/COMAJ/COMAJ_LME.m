% function COMAJ_LME(output_dir, FS_HOME, model_type)
%
% This function compute LME models on longitudinals data
%
% 
% model_type = 0 --> classical univariate model
% model_type = 1 --> novel mass-univariate tools (spatiotemporal models)
%
% Matthieu Vanhoutte 20/02/17

clear all; close all;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%
% %% Preparing the data  %%
% %%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % output_dir='/NAS/tupac/protocoles/COMAJ/FS53/CSF_FS_Analysis/LONG/LME';
% output_dir='/NAS/tupac/matthieu/LME/PET_FS/TYPvsLANGvsVISUvsEXE';
% output_dir='/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/3Cov';
% output_dir='/NAS/tupac/matthieu/LME/PET_FS/TYPvsLANGvsVISUvsEXE/M0_M3/3Cov';
% output_dir='/NAS/tupac/matthieu/LME/PET_FS/Corr_Beery_TYP';
% output_dir='/NAS/tupac/matthieu/LME/PET_CAT/TYPvsATYP/MA';
% output_dir='/NAS/tupac/matthieu/LME/PET_CAT/TYPvsLANGvsVISUvsEXE';
%  output_dir='/NAS/tupac/matthieu/LME/MRI_CAT/TYPvsATYP/FD/25mm';
% output_dir='/NAS/tupac/matthieu/LME/MRI_CAT/TYPvsLANGvsVISUvsEXE/SULC';
% output_dir='/NAS/tupac/matthieu/LME/PET_FS/TYPvsATYP/M0toM3/NoCov/MUmodel';
% output_dir='/NAS/tupac/matthieu/LME/PET_FS/TimeVaryingCov/FluenceA_EXE';
% output_dir='/NAS/tupac/matthieu/LME/PET_FS/Average_Corr/Praxie_EXE';
output_dir='/NAS/tupac/matthieu/LME/PET_FS/Average_Corr/PortesA_TYP';
% 
% %% Step1. Map PET data onto fsaverage and stack it into one .mgh file per hemisphere %%
% 
% %% Step2. Smooth stacked PET data %%
% 
% %% Step3. Load stacked and smoothed PET surface data into matlab %%
% 
% [y_lh,mri_lh] = fs_read_Y(fullfile(output_dir, 'lh.all.subjects.fwhm10.PET.MGRousset.gn.mgh'));
% [y_rh,mri_rh] = fs_read_Y(fullfile(output_dir, 'rh.all.subjects.fwhm10.PET.MGRousset.gn.mgh'));
% 
% %% Step4. Load FS's Qdec table ordered according to time for each individual and build design matrix (X) %%
% 
% % Load QDec table
% Qdec = fReadQdec(fullfile(output_dir, 'qdec.table.pet.dat'));
% Qdec = rmQdecCol(Qdec,1); 
% sID = Qdec(2:end,1);
% Qdec = rmQdecCol(Qdec,1);  
% M = Qdec2num(Qdec);
% 
% % % Define ni (Vector whose entries are the number of repeated measures for each
% % % subject (ordered according to X).
% % id = find(M(:,1)==0);
% % id = [id;size(M,1)+1];
% % ni = diff(id);
% 
% % Sorts the data (according to sID then time over subject)
% [M_lh,Y_lh,ni_lh] = sortData(M,1,Y_lh,sID);
% [M_rh,Y_rh,ni_rh] = sortData(M,1,Y_rh,sID);
% 
% % Define design matrix X
% intercept = ones(length(M),1);
% 
% % Grp2 = zeros(length(M),1);
% % idx_grp2 = find(M(:,2)==2);
% % Grp2(idx_grp2) = 1;
% % 
% % Grp3 = zeros(length(M),1);
% % idx_grp3 = find(M(:,2)==3);
% % Grp3(idx_grp3) = 1;
% % 
% % TimeXGrp2 = M(:,1).*Grp2;
% % TimeXGrp3 = M(:,1).*Grp3;
% % 
% % X = [ intercept M(:,1) Grp2 TimeXGrp2 Grp3 TimeXGrp3 ];
% 
% Grp2 = zeros(length(M_lhs),1);
% idx_grp2 = find(M_lhs(:,2)==2);
% Grp2(idx_grp2) = 1;
% 
% TimeXGrp2 = M_lhs(:,1).*Grp2;
% 
% X = [ intercept M_lhs(:,1) Grp2 TimeXGrp2 ];
% 
% %% Step5. Read lh/rh.sphere surface and lh/rh.cortex label %%
% 
% FS_HOME='/home/global/freesurfer5.3'
% 
% lhsphere = fs_read_surf(fullfile(FS_HOME, 'subjects/fsaverage/surf/lh.sphere'));
% rhsphere = fs_read_surf(fullfile(FS_HOME, 'subjects/fsaverage/surf/rh.sphere'));
% 
% lhcortex = fs_read_label(fullfile(FS_HOME, 'subjects/fsaverage/label/lh.cortex.label'));
% rhcortex = fs_read_label(fullfile(FS_HOME, 'subjects/fsaverage/label/rh.cortex.label'));
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%
% % %% Model specification  %%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% % %% Step7. Depict longitudinal variation in case of univariate data (linear, quadratic, ...)
% % lme_lowessPlot(M(:,1),Y(:,1)+Y(:,2),0.7,M(:,2));
% % 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Parameter Estimation  %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %% Step8. Parameter estimation according to classical mass-univariate/spatiotemporal models %%
% 
% model_type = 0;
% 
% if model_type == 0
%     % Estimate models with 1 and 2 RF
%     lhstats_1RF = lme_mass_fit_vw(X,[1],Y_lh,ni,lhcortex);
%     rhstats_1RF = lme_mass_fit_vw(X,[1],Y_rh,ni,rhcortex);
% 
%     lhstats_2RF = lme_mass_fit_vw(X,[1 2],Y_lh,ni,lhcortex);
%     rhstats_2RF = lme_mass_fit_vw(X,[1 2],Y_rh,ni,rhcortex);
%     
%     save(fullfile(output_dir,'MUmodel.mat'),'lhstats_1RF','rhstats_1RF','lhstats_2RF','rhstats_2RF','-v7.3');
%     
% elseif model_type == 1
%     % Compute initial vertex-wise temporal covariance estimates
%     [lhTh0,lhRe] = lme_mass_fit_EMinit(X,[1 2],Y_lh,ni,lhcortex,3);
%     [rhTh0,rhRe] = lme_mass_fit_EMinit(X,[1 2],Y_rh,ni,rhcortex,3);
%     
%     % Covariance estimates segmentations into homogeneous regions
%     [lhRgs,lhRgMeans] = lme_mass_RgGrow(lhsphere,lhRe,lhTh0,lhcortex,2,95);
%     [rhRgs,rhRgMeans] = lme_mass_RgGrow(rhsphere,rhRe,rhTh0,rhcortex,2,95);
%     
%     % Visually compare similarities of lhTh0 and lhRgMeans maps overlaid onto lhsphere
%     surf.faces =  lhsphere.tri;
%     surf.vertices =  lhsphere.coord';
% 
%     figure; p1 = patch(surf);
%     set(p1,'facecolor','interp','edgecolor','none','facevertexcdata',lhTh0(1,:)');
% 
%     figure; p2 = patch(surf); set(p2,'facecolor','interp','edgecolor','none','facevertexcdata',lhRgMeans(1,:)');
%     
%     surf.faces =  rhsphere.tri;
%     surf.vertices =  rhsphere.coord';
% 
%     figure; p3 = patch(surf);
%     set(p3,'facecolor','interp','edgecolor','none','facevertexcdata',rhTh0(1,:)');
% 
%     figure; p4 = patch(surf); set(p4,'facecolor','interp','edgecolor','none','facevertexcdata',rhRgMeans(1,:)');
%     
%     % Fit the spatiotemporal LME model
%     lhstats_2RF = lme_mass_fit_Rgw(X,[1 2],Y_lh,ni,lhTh0,lhRgs,lhsphere);
%     rhstats_2RF = lme_mass_fit_Rgw(X,[1 2],Y_rh,ni,rhTh0,rhRgs,rhsphere);
%     
%     % Fit the model with one random effect using the segmentation obtained from the previous model
%     lhTh0_1RF = lme_mass_fit_EMinit(X,[1],Y_lh,ni,lhcortex,3);
%     rhTh0_1RF = lme_mass_fit_EMinit(X,[1],Y_rh,ni,rhcortex,3);
%     
%     lhstats_1RF = lme_mass_fit_Rgw(X,[1],Y_lh,ni,lhTh0_1RF,lhRgs,lhsphere);
%     rhstats_1RF = lme_mass_fit_Rgw(X,[1],Y_rh,ni,rhTh0_1RF,rhRgs,rhsphere);
% end

%%%%%%%%%%%%%%%%%%%%%%
%% Model selection  %%
%%%%%%%%%%%%%%%%%%%%%%

%% Step9. Compare models with 1 and 2 RF with Likelihood ratio %%

% Use the likelihood ratio
LR_pval_lh = lme_mass_LR(lhstats_2RF,lhstats_1RF,1);
LR_pval_rh = lme_mass_LR(rhstats_2RF,rhstats_1RF,1);

% Correct for multiple comparisons
dvtx_lh = lme_mass_FDR2(LR_pval_lh,ones(1,length(LR_pval_lh)),lhcortex,0.05,0);
dvtx_rh = lme_mass_FDR2(LR_pval_rh,ones(1,length(LR_pval_rh)),rhcortex,0.05,0);

%%%%%%%%%%%%%%%%
%% Inference  %%
%%%%%%%%%%%%%%%%

%% Step10. Define contrast and realize inference based on best model %%

% Define contrasts: 3 groups and linear effect
% CM.C = [zeros(2,3) [1 0 0 ; -1 0 1]]; %% F-contrast
% CM.C = [0 1 0 0 0 0]; %% Grp1 slope of change  <> 0 ?
% CM.C = [0 1 0 1 0 0]; %% Grp2 slope of change  <> 0 ?
% CM.C = [0 1 0 0 0 1]; %% Grp3 slope of change  <> 0 ?
% CM.C = [0 0 0 1 0 0]; %% Grp2-Grp1 slope of change <> 0 ?
% CM.C = [0 0 0 0 0 1]; %% Grp3-Grp1 slope of change <> 0 ?
% CM.C = [0 0 0 -1 0 1]; %% Grp3-Grp2 slope of change <> 0 ?

% Define contrasts: 2 groups and linear effect
% CM.C = [0 0 0 1]; %% F-contrast
% CM.C = [0 1 0 0]; %% Grp1 slope of change  <> 0 ?
% CM.C = [0 1 0 1]; %% Grp2 slope of change  <> 0 ?
% CM.C = [0 0 0 1]; %% Grp2-Grp1 slope of change <> 0 ?

% Define contrasts: 2 groups and linear effect, with 3 covariates
% CM.C = [0 0 0 1 0 0 0]; %% F-contrast
% CM.C = [0 1 0 0 0 0 0]; %% Grp1 slope of change  <> 0 ?
% CM.C = [0 1 0 1 0 0 0]; %% Grp2 slope of change  <> 0 ?
% CM.C = [0 0 0 1 0 0 0]; %% Grp2-Grp1 slope of change <> 0 ?

% Define contrasts: 2 groups and quadratic effect
% CM.C = [0 0 0 0 0 1]; %% F-contrast
% CM.C = [0 0 1 0 0 0]; %% Grp1 slope^2 of change  <> 0 ?
% CM.C = [0 0 1 0 0 1]; %% Grp2 slope^2 of change  <> 0 ?
% CM.C = [0 0 0 0 0 1]; %% Grp2-Grp1 slope of change <> 0 ?

% Define contrasts: 4 groups
% CM.C = [zeros(3,3) [1 0 0 0 0; -1 0 1 0 0; 0 0 -1 0 1]]; %% F-contrast
% CM.C = [0 1 0 0 0 0 0 0]; %% Grp1 slope of change  <> 0 ?
% CM.C = [0 1 0 1 0 0 0 0]; %% Grp2 slope of change  <> 0 ?
% CM.C = [0 1 0 0 0 1 0 0]; %% Grp3 slope of change  <> 0 ?
% CM.C = [0 1 0 0 0 0 0 1]; %% Grp4 slope of change  <> 0 ?
% CM.C = [0 0 0 1 0 0 0 0]; %% Grp2-Grp1 slope of change <> 0 ?
% CM.C = [0 0 0 0 0 1 0 0]; %% Grp3-Grp1 slope of change <> 0 ?
% CM.C = [0 0 0 0 0 0 0 1]; %% Grp4-Grp1 slope of change <> 0 ?
% CM.C = [0 0 0 -1 0 1 0 0]; %% Grp3-Grp2 slope of change <> 0 ?
% CM.C = [0 0 0 -1 0 0 0 1]; %% Grp4-Grp2 slope of change <> 0 ?
% CM.C = [0 0 0 0 0 -1 0 1]; %% Grp4-Grp3 slope of change <> 0 ?

% Define contrasts: 4 groups and 3 Cov
% CM.C = [zeros(3,3) [1 0 0 0 0 0 0 0; -1 0 1 0 0 0 0 0; 0 0 -1 0 1 0 0 0]]; %% F-contrast
% CM.C = [0 1 0 0 0 0 0 0 0 0 0]; %% Grp1 slope of change  <> 0 ?
% CM.C = [0 1 0 1 0 0 0 0 0 0 0]; %% Grp2 slope of change  <> 0 ?
% CM.C = [0 1 0 0 0 1 0 0 0 0 0]; %% Grp3 slope of change  <> 0 ?
% CM.C = [0 1 0 0 0 0 0 1 0 0 0]; %% Grp4 slope of change  <> 0 ?
% CM.C = [0 0 0 1 0 0 0 0 0 0 0]; %% Grp2-Grp1 slope of change <> 0 ?
% CM.C = [0 0 0 0 0 1 0 0 0 0 0]; %% Grp3-Grp1 slope of change <> 0 ?
% CM.C = [0 0 0 0 0 0 0 1 0 0 0]; %% Grp4-Grp1 slope of change <> 0 ?
% CM.C = [0 0 0 -1 0 1 0 0 0 0 0]; %% Grp3-Grp2 slope of change <> 0 ?
% CM.C = [0 0 0 -1 0 0 0 1 0 0 0]; %% Grp4-Grp2 slope of change <> 0 ?
% CM.C = [0 0 0 0 0 -1 0 1 0 0 0]; %% Grp4-Grp3 slope of change <> 0 ?

% Define contrasts: 1 group and correlations
% CM.C = [0 0 1 0]; %% score correlation
CM.C = [0 0 0 1]; %% scoreXtime correlation


% % Define contrasts: 1 group and correlation time-varying score
% CM.C = [0 0 1]; %% TV score correlation


% Infer with the best model between 1 and 2 random effects
if (length(dvtx_lh) >= length(lhcortex)/2) && (length(dvtx_rh) >= length(rhcortex)/2)
    F_lhstats = lme_mass_F(lhstats_2RF,CM);
    F_rhstats = lme_mass_F(rhstats_2RF,CM);
elseif (length(dvtx_lh) < length(lhcortex)/2) && (length(dvtx_rh) < length(rhcortex)/2)
    F_lhstats = lme_mass_F(lhstats_1RF,CM);
    F_rhstats = lme_mass_F(rhstats_1RF,CM);
end

% Correct for multiple comparisons

% % Separate hemisphere
% % [detvtx_lh,sided_pval_lh,pth_lh] = lme_mass_FDR2(F_lhstats.pval,F_lhstats.sgn,lhcortex,0.05,0);
% % [detvtx_rh,sided_pval_rh,pth_rh] = lme_mass_FDR2(F_rhstats.pval,F_rhstats.sgn,rhcortex,0.05,0);

% Both hemispheres on whole surface with FDR correction only on cortex
P = [ F_lhstats.pval F_rhstats.pval ];
G = [ F_lhstats.sgn F_rhstats.sgn ];
cortex=[ lhcortex rhcortex+size(Y_lh,2) ];

% [detvtx,sided_pval,pth] = lme_mass_FDR2(P,G,cortex,0.05,0);  % two-sided
% pcor = -log10(pth);

[detvtx_pos,sided_pval_pos,pth_pos] = lme_mass_FDR2(P,G,cortex,0.05,1);  % right-sided (>0)
[detvtx_neg,sided_pval_neg,pth_neg] = lme_mass_FDR2(P,G,cortex,0.05,-1);  % left-sided (<0)
pcor_pos = -log10(pth_pos);
pcor_neg = -log10(pth_neg);

%%%%%%%%%%%%%%%%%%%%%%%
%% Save output data  %%
%%%%%%%%%%%%%%%%%%%%%%%

%% Step11. Save uncorrected and corrected -log10(p) maps %%

% % % Save Beta2 coefficient
% % nv=length(lhstats);
% % Beta2 = zeros(1,nv);
% % for i=1:nv
% %    if ~isempty(lhstats(i).Bhat)
% %       Beta2(i) = lhstats(i).Bhat(2);
% %    end;
% % end;
% 
% Set mri1.volsz(4) = 1 for saving corrected p-maps
mri1_lh = mri_lh;
mri1_rh = mri_rh;
mri1_lh.volsz(4) = 1;
mri1_rh.volsz(4) = 1;
% % fs_write_Y(Beta2,mri1,'Beta2.mgh');

% Save uncorrected p-maps
% fs_write_fstats(F_lhstats,mri_lh,fullfile(output_dir, 'lh.sig.mgh'),'sig');
% fs_write_fstats(F_rhstats,mri_rh,fullfile(output_dir, 'rh.sig.mgh'),'sig');
% 
fs_write_fstats(F_lhstats,mri_lh,fullfile(output_dir, 'lh.sig.grp2vsgrp1.mgh'),'sig');
fs_write_fstats(F_rhstats,mri_rh,fullfile(output_dir, 'rh.sig.grp2vsgrp1.mgh'),'sig');

fs_write_fstats(F_lhstats,mri_lh,fullfile(output_dir, 'lh.sig.corrPortesA.mgh'),'sig');
fs_write_fstats(F_rhstats,mri_rh,fullfile(output_dir, 'rh.sig.corrPortesA.mgh'),'sig');

% Save multiple comparisons corrected p-maps
% if length(detvtx_lh) > 0
%     fs_write_Y(sided_pval_lh,mri1_lh,fullfile(output_dir, 'lh.spval.sep.mgh'));
% end
% if length(detvtx_rh) > 0
%     fs_write_Y(sided_pval_rh,mri1_lh,fullfile(output_dir, 'rh.spval.sep.mgh'));
% end

% if length(detvtx) > 0
% % %     fs_write_Y(sided_pval(1:size(Y_lh,2)),mri1_lh,fullfile(output_dir, 'lh.spval.mgh'));
% % %     fs_write_Y(sided_pval(size(Y_lh,2)+1:end),mri1_rh,fullfile(output_dir, 'rh.spval.mgh'));
% %     
    fs_write_Y(-log10(sided_pval(1:size(Y_lh,2))),mri1_lh,fullfile(output_dir, 'lh.spval.sig.mgh'));
    fs_write_Y(-log10(sided_pval(size(Y_lh,2)+1:end)),mri1_rh,fullfile(output_dir, 'rh.spval.sig.mgh'));
% end

if length(detvtx_pos) > 0
    fs_write_Y(-log10(sided_pval_pos(1:size(Y_lh,2))),mri1_lh,fullfile(output_dir, 'lh.grp2vsgrp1.sig.pos.mgh'));
    fs_write_Y(-log10(sided_pval_pos(size(Y_lh,2)+1:end)),mri1_rh,fullfile(output_dir, 'rh.grp2vsgrp1.sig.pos.mgh')); 
    
    fs_write_Y(-log10(sided_pval_pos(1:size(Y_lh,2))),mri1_lh,fullfile(output_dir, 'lh.corrPortesA.sig.pos.mgh'));
    fs_write_Y(-log10(sided_pval_pos(size(Y_lh,2)+1:end)),mri1_rh,fullfile(output_dir, 'rh.corrPortesA.sig.pos.mgh'));
end
if length(detvtx_neg) > 0
    fs_write_Y(-log10(sided_pval_neg(1:size(Y_lh,2))),mri1_lh,fullfile(output_dir, 'lh.grp4vsgrp1.sig.neg.mgh'));
    fs_write_Y(-log10(sided_pval_neg(size(Y_lh,2)+1:end)),mri1_rh,fullfile(output_dir, 'rh.grp4vsgrp1.sig.neg.mgh'));    
    
    fs_write_Y(-log10(sided_pval_neg(1:size(Y_lh,2))),mri1_lh,fullfile(output_dir, 'lh.corrPortesA.sig.neg.mgh'));
    fs_write_Y(-log10(sided_pval_neg(size(Y_lh,2)+1:end)),mri1_rh,fullfile(output_dir, 'rh.corrPortesA.sig.neg.mgh'));
end