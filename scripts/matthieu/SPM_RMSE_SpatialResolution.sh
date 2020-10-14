#!/bin/bash

DIR=$1
RECON=$2
SUBJECT_ID=$3

matlab -nodisplay <<EOF
%% Load Matlab Path: Matlab 14 and SPM12 needed
cd ${HOME}
p = pathdef14_SPM12;
addpath(p);
			
%% Compute RMSE files for each reconstruction
FileRef = '${DIR}/pet_std/OT_i2s21_g2/SpatialResolution.txt';
FileSource = '${DIR}/pet_std/${RECON}/SpatialResolution.txt';
FileWrite = '/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD/SpatialResolution/SR_${SUBJECT_ID}_${RECON}.txt';

RootMeanSquareError(FileRef,FileSource,FileWrite)
EOF