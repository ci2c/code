#!/bin/bash

InputDir=$1
InputSubjectsFile=$2
PVC=$3
Recon=$4

matlab -nodisplay <<EOF

%% Load Matlab Path: Matlab 14 and SPM12 version
cd ${HOME}
p = pathdef14_SPM12;
addpath(p);

DARTEL_NormalizeMNI_noMask('${InputDir}', '${InputSubjectsFile}', '${PVC}', '${Recon}');

EOF