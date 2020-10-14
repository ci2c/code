#!/bin/bash

## I/O management
Long=$1
InputDir=$2
Filename=$3
hemi=$4
Meas=$5
FWHM=$6
SUBJ_ID=$7


matlab -nodisplay <<EOF

	%% Load Matlab Path: Matlab 14 and SPM12 needed
	cd ${HOME}
	p = pathdef14_SPM12;
	addpath(p);
	
	%% Save gifti surface data to .mgh freesurfer files
	temp = gifti('${InputDir}/surf/${Filename}');
	% temp = gifti('${InputDir}/surf/s${FWHM}mm.${hemi}.${Meas}.resampled.orig.lia.${SUBJ_ID}.gii');
	temp.cdata(~isfinite(temp.cdata(:))) = 0;
	
	if ${Long}==1
		save_mgh(temp.cdata,'${InputDir}/surf/${hemi}.${Meas}.fsaverage.s${FWHM}mm.rorig.lia.${SUBJ_ID}.mgh',temp.mat);
	elseif ${Long}==0
		save_mgh(temp.cdata,'${InputDir}/surf/${hemi}.${Meas}.fsaverage.s${FWHM}mm.orig.lia.${SUBJ_ID}.mgh',temp.mat);
	end
EOF