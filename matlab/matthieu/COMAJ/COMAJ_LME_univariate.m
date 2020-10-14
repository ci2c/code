% function COMAJ_LME(output_dir, FS_HOME, model_type)
%
% This function compute LME models on longitudinals data
%
% Matthieu Vanhoutte 05/09/17

clear all; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Preparing the data  %%
%%%%%%%%%%%%%%%%%%%%%%%%%

% output_dir='/NAS/tupac/matthieu/LME/SubcortVol/Pallidum_FS/TYPvsATYP';
% output_dir='/NAS/tupac/matthieu/LME/Hippo_FS/TYPvsLANGvsVISUvsEXE';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/PortesA/TYPvsATYP';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/PortesA/All';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/FluenceP_EXE';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/All_values/PortesA/All';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/All_values/FluenceP_EXE';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/All_values/PortesA/TYPvsATYP';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/All_values/FluenceP/TYPvsATYP';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/All_values/MMSE/TYPvsATYP';
% output_dir='/NAS/tupac/matthieu/LME/Neuropsy/All_values/VAT/TYPvsATYP';
output_dir='/NAS/tupac/matthieu/LME/Neuropsy/All_values/FluenceA/TYPvsATYP';

%% Step1. Load aseg.long.table data into matlab %%
[aseg, asegrows,asegcols] =  fast_ldtable(fullfile(output_dir,'aseg.long.table'));
asegcols=cellstr(asegcols); % convert column names into cell string
% select structures of interest: lh/rh hippo. volumes and total intracranial volume (ICV)
strLH = 'Left-Pallidum';
strRH = 'Right-Pallidum';
strICV = 'EstimatedTotalIntraCranialVol';
idLH=find(strcmp(strLH,asegcols)==1);
idRH=find(strcmp(strRH,asegcols)==1);
idICV=find(strcmp(strICV,asegcols)==1);
Y_LH = aseg(:,idLH);
Y_RH = aseg(:,idRH);
Y_ICV = aseg(:,idICV);
Y = [Y_LH Y_RH Y_ICV];

%% Step2. Load FS's Qdec table ordered according to time for each individual and build design matrix (X) %%

% Load QDec table
Qdec = fReadQdec(fullfile(output_dir, 'qdec.table.dat'));
Qdec = rmQdecCol(Qdec,1); 
sID = Qdec(2:end,1);
Qdec = rmQdecCol(Qdec,1);  
M = Qdec2num(Qdec);
% % if Neuropsy with NbGroups==1
% Y = M(:,2);
% M = M(:,1);
% if Neuropsy with NbGroups==2
Y = M(:,3);
M = M(:,1:2);

% Sorts the data (according to sID then time over subject)
[M,Y,ni] = sortData(M,1,Y,sID);

% Mean response trends over time
% lme_lowessPlot(M(:,1),Y(:,1)+Y(:,2),0.70,M(:,2));
% if Neuropsy with NbGroups==2
lme_lowessPlot(M(:,1),Y,0.70,M(:,2));

%% Step3. Define design matrix X %%
NbGroups=2;
intercept = ones(length(M),1);
	
if NbGroups==1
    X = [ intercept M(:,1) ];

elseif NbGroups==2
    Grp2 = zeros(length(M),1);
	idx_grp2 = find(M(:,2)==2);
	Grp2(idx_grp2) = 1;

    TimeXGrp2 = M(:,1).*Grp2;
    
% 	X = [ intercept M(:,1) Grp2 TimeXGrp2 Y(:,3) ];
    % if Neuropsy with NbGroups==2
    X = [ intercept M(:,1) Grp2 TimeXGrp2 ];

elseif NbGroups==4
	Grp2 = zeros(length(M),1);
	idx_grp2 = find(M(:,2)==2);
	Grp2(idx_grp2) = 1;

	Grp3 = zeros(length(M),1);
	idx_grp3 = find(M(:,2)==3);
	Grp3(idx_grp3) = 1;
	
	Grp4 = zeros(length(M),1);
	idx_grp4 = find(M(:,2)==4);
	Grp4(idx_grp4) = 1;

    TimeXGrp2 = M(:,1).*Grp2;
	TimeXGrp3 = M(:,1).*Grp3;
	TimeXGrp4 = M(:,1).*Grp4;

% 	X = [ intercept M(:,1) Grp2 TimeXGrp2 Grp3 TimeXGrp3 Grp4 TimeXGrp4 Y(:,3) ];
    % if Neuropsy with NbGroups==4
    X = [ intercept M(:,1) Grp2 TimeXGrp2 Grp3 TimeXGrp3 Grp4 TimeXGrp4 ];
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameter Estimation  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Step4. Parameter estimation according to classical mass-univariate/spatiotemporal models %%

% Estimate models with 1 and 2 RF
total_hipp_vol_stats_1RF = lme_fit_FS(X,[1],Y(:,1)+Y(:,2),ni);
total_hipp_vol_stats_2RF = lme_fit_FS(X,[1 2],Y(:,1)+Y(:,2),ni); %% Input to EIG must not contain NaN or Inf.

% if Neuropsy
total_hipp_vol_stats_1RF = lme_fit_FS(X,[1],Y,ni);
total_hipp_vol_stats_2RF = lme_fit_FS(X,[1 2],Y,ni);
    
%%%%%%%%%%%%%%%%%%%%%%
%% Model selection  %%
%%%%%%%%%%%%%%%%%%%%%%

%% Step5. Compare models with 1 and 2 RF with Likelihood ratio %%

% Use the likelihood ratio
lr = lme_LR(total_hipp_vol_stats_2RF.lreml,total_hipp_vol_stats_1RF.lreml,1);
if (lr.pval <= 0.05)
    save(fullfile(output_dir,'PrepData.mat'),'X','M','Y','ni','total_hipp_vol_stats_2RF','-v7.3');
else
    save(fullfile(output_dir,'PrepData.mat'),'X','M','Y','ni','total_hipp_vol_stats_1RF','-v7.3');
end

%%%%%%%%%%%%%%%%
%% Inference  %%
%%%%%%%%%%%%%%%%

%% Step10. Define contrast and realize inference based on best model %%

% % Define contrasts: 1 group and linear effect (no covariate)
% C = [0 1]; %% Grp1 slope of change  <> 0 ?

% Define contrasts: 2 groups and linear effect (eTIV as covariate)
% C = [0 1 0 0 0]; %% Grp1 slope of change  <> 0 ?
% C = [0 1 0 1 0]; %% Grp2 slope of change  <> 0 ?
% C = [0 0 0 1 0]; %% Grp2-Grp1 slope of change <> 0 ?

% Define contrasts: 2 groups and linear effect (no covariate)
% C = [0 1 0 0]; %% Grp1 slope of change  <> 0 ?
% C = [0 1 0 1]; %% Grp2 slope of change  <> 0 ?
C = [0 0 0 1]; %% Grp2-Grp1 slope of change <> 0 ?

% Define contrasts: 4 groups
% C = [zeros(3,3) [1 0 0 0 0; -1 0 1 0 0; 0 0 -1 0 1] zeros(3,1)]; %% F-contrast
% C = [0 1 0 0 0 0 0 0 0]; %% Grp1 slope of change  <> 0 ?
% C = [0 1 0 1 0 0 0 0 0]; %% Grp2 slope of change  <> 0 ?
% C = [0 1 0 0 0 1 0 0 0]; %% Grp3 slope of change  <> 0 ?
% C = [0 1 0 0 0 0 0 1 0]; %% Grp4 slope of change  <> 0 ?
% C = [0 0 0 1 0 0 0 0 0]; %% Grp2-Grp1 slope of change <> 0 ?
% C = [0 0 0 0 0 1 0 0 0]; %% Grp3-Grp1 slope of change <> 0 ?
% C = [0 0 0 0 0 0 0 1 0]; %% Grp4-Grp1 slope of change <> 0 ?
% C = [0 0 0 -1 0 1 0 0 0]; %% Grp3-Grp2 slope of change <> 0 ?
% C = [0 0 0 -1 0 0 0 1 0]; %% Grp4-Grp2 slope of change <> 0 ?
% C = [0 0 0 0 0 -1 0 1 0]; %% Grp4-Grp3 slope of change <> 0 ?

% Define contrasts: 1 group and correlations
% C = [0 0 1 0]; %% score correlation
% C = [0 0 0 1]; %% scoreXtime correlation

% Infer with the best model between 1 and 2 random effects
if (lr.pval <= 0.05)
    F_C = lme_F(total_hipp_vol_stats_2RF,C);
else
    F_C = lme_F(total_hipp_vol_stats_1RF,C);
end
% 
% %%%%%%%%%%%%%%%%%%%%%%%
% %% Save output data  %%
% %%%%%%%%%%%%%%%%%%%%%%%
% 
% %% Step11. Save uncorrected and corrected -log10(p) maps %%