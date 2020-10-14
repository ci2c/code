#!/bin/bash

OUTPUT_DIR=/home/fatmike/renaud/alexis/data_ju/
SUBJ_ID=CD15

matlab -nodisplay <<EOF

% normalize probability lesion map
fprintf('normalize probability lesion map ... ')
images = {fullfile('${OUTPUT_DIR}/${SUBJ_ID}/LST', 'b_010_lesion_lbm0_030_rmT2FLAIR.nii')};
field1 = {fullfile('${OUTPUT_DIR}/${SUBJ_ID}/LST', 'y_3DT1.nii')};
jobDeform = struct('interp', 5, 'modulate', 0);
jobDeform.field1 = field1;
jobDeform.images = images;
cg_vbm8_defs(jobDeform)

EOF