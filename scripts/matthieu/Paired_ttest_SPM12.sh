#!/bin/bash

InputDir=$1
InputSubjectsFile=$2
PVC=$3
Recon=$4
fwhmvol=$5

matlab -nodisplay <<EOF

%% Load Matlab Path: Matlab 14 and SPM12 version
cd ${HOME}
p = pathdef14_SPM12;
addpath(p);

Paired_ttest_SPM12_job('${InputDir}', '${InputSubjectsFile}', '${PVC}', '${Recon}', '${fwhmvol}');

EOF