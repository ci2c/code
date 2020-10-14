#!/bin/bash

OUTPUT_DIR=$1
subject=$2
# var=$3
Recon=$3
FWHM=$4
# TLE=$5
PVC=$5

# if [ "${TLE}" == "LTLE" ]
# then
# 	matlab -nodisplay <<EOF
# 		% Load Matlab Path: Matlab 14 and SPM12 needed
# 		cd ${HOME}
# 		p = pathdef14_SPM12;
# 		addpath(p);
# 		
# 		% ConvertAslToZscoreVol('${OUTPUT_DIR}/${subject}/asl/Volumetric_Analyses','s${FWHM}_${var}.nii');
# 		ConvertAslToZscore('${OUTPUT_DIR}/${subject}/asl/bbr/Surface_Analyses','lh.fwhm${FWHM}.fsaverage_sym.${var}.mgh','rh.fwhm${FWHM}.fsaverage_sym.${var}.mgh',1);
# 		ConvertAslToZscore('${OUTPUT_DIR}/${subject}/asl/bbr/Surface_Analyses','lh.fwhm${FWHM}.fsaverage_sym.thickness.mgh','rh.fwhm${FWHM}.fsaverage_sym.thickness.mgh',1);
# 		% ConvertAslToZscore('${OUTPUT_DIR}/${subject}/asl/Surface_Analyses','lh.fwhm${FWHM}.fsaverage.${var}.mgh','rh.fwhm${FWHM}.fsaverage.${var}.mgh',1);
# 		% ConvertAslToZscore('${OUTPUT_DIR}/${subject}/surf','lh.thickness.fwhm${FWHM}.fsaverage.mgh','rh.thickness.fwhm${FWHM}.fsaverage.mgh',1);
# 		% ConvertAslToZscore('${OUTPUT_DIR}/${subject}/asl/bbr/Surface_Analyses','lh.fwhm${FWHM}.fsaverage.${var}.mgh','rh.fwhm${FWHM}.fsaverage.${var}.mgh',1);
# EOF
# elif [ "${TLE}" == "RTLE" ]
# then
# 	matlab -nodisplay <<EOF
# 		% Load Matlab Path: Matlab 14 and SPM12 needed
# 		cd ${HOME}
# 		p = pathdef14_SPM12;
# 		addpath(p);
# 		
# 		% ConvertAslToZscoreVol('${OUTPUT_DIR}/${subject}/asl/Volumetric_Analyses','s${FWHM}_${var}.nii');
# 		% ConvertAslToZscore('${OUTPUT_DIR}/${subject}/xhemi/surf','lh.fwhm${FWHM}.fsaverage_sym.${var}.mgh','rh.fwhm${FWHM}.fsaverage_sym.${var}.mgh',1);
# 		% ConvertAslToZscore('${OUTPUT_DIR}/${subject}/xhemi/surf','lh.fwhm${FWHM}.fsaverage_sym.thickness.mgh','rh.fwhm${FWHM}.fsaverage_sym.thickness.mgh',1);
# 		ConvertAslToZscore('${OUTPUT_DIR}/${subject}/asl/bbr/Surface_Analyses','lh.fwhm${FWHM}.fsaverage_sym.${var}.mgh','rh.fwhm${FWHM}.fsaverage_sym.${var}.mgh',1);
# 		ConvertAslToZscore('${OUTPUT_DIR}/${subject}/asl/bbr/Surface_Analyses','lh.fwhm${FWHM}.fsaverage_sym.thickness.mgh','rh.fwhm${FWHM}.fsaverage_sym.thickness.mgh',1);	
# 		% ConvertAslToZscore('${OUTPUT_DIR}/${subject}/asl/Surface_Analyses','lh.fwhm${FWHM}.fsaverage.${var}.mgh','rh.fwhm${FWHM}.fsaverage.${var}.mgh',1);
# 		% ConvertAslToZscore('${OUTPUT_DIR}/${subject}/surf','lh.thickness.fwhm${FWHM}.fsaverage.mgh','rh.thickness.fwhm${FWHM}.fsaverage.mgh',1);
# EOF
# fi

matlab -nodisplay <<EOF
	% Load Matlab Path: Matlab 14 and SPM12 needed
	cd ${HOME}
	p = pathdef14_SPM12;
	addpath(p);
	
	if strcmp('${PVC}','noPVC')==1
		ConvertAslToZscore('${OUTPUT_DIR}/${subject}/pet_std/${Recon}/surf','lh.PET.lps.BS7.gn.fsaverage.sm${FWHM}.mgh','rh.PET.lps.BS7.gn.fsaverage.sm${FWHM}.mgh',1);
	elseif strcmp('${PVC}','PVC')==1
		ConvertAslToZscore('${OUTPUT_DIR}/${subject}/pet_std/${Recon}/pvelab_Seg8_l0/surf','lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm${FWHM}.mgh','rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm${FWHM}.mgh',1);
	end
EOF