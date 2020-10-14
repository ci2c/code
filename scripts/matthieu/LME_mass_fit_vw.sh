#!/bin/bash

NbRF=$1
hemi=$2
WD=$3

matlab -nodisplay <<EOF
	%% Load Matlab Path: Matlab 14 and SPM12 needed
	cd ${HOME}
	p = pathdef14_SPM12;
	addpath(p);

	load(fullfile('${WD}','PrepData.mat'));
	
	if ${NbRF}==1 && strcmp('${hemi}','lh')==1
		lhstats_1RF = lme_mass_fit_vw(X,[1],Y_lh,ni_lh,lhcortex);
		save(fullfile('${WD}','MUmodel_1RF_lh.mat'),'lhstats_1RF','-v7.3');
	elseif ${NbRF}==1 && strcmp('${hemi}','rh')==1
		rhstats_1RF = lme_mass_fit_vw(X,[1],Y_rh,ni_lh,rhcortex);
		save(fullfile('${WD}','MUmodel_1RF_rh.mat'),'rhstats_1RF','-v7.3');
	elseif ${NbRF}==2 && strcmp('${hemi}','lh')==1
		lhstats_2RF = lme_mass_fit_vw(X,[1 2],Y_lh,ni_lh,lhcortex);
		save(fullfile('${WD}','MUmodel_2RF_lh.mat'),'lhstats_2RF','-v7.3');
	elseif ${NbRF}==2 && strcmp('${hemi}','rh')==1
		rhstats_2RF = lme_mass_fit_vw(X,[1 2],Y_rh,ni_lh,rhcortex);
		save(fullfile('${WD}','MUmodel_2RF_rh.mat'),'rhstats_2RF','-v7.3');
	end
EOF