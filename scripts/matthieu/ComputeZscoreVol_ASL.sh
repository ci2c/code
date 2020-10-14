#!/bin/bash

OUTPUT_DIR=$1
subject=$2
var=$3

matlab -nodisplay <<EOF
	% ConvertAslToZscoreVol('${OUTPUT_DIR}/${subject}/asl/Volumetric_Analyses','${var}.nii');
	ConvertAslToZscore('${OUTPUT_DIR}/${subject}/asl/Surface_Analyses','lh.fsaverage.${var}.mgh','rh.fsaverage.${var}.mgh',1);
EOF