#!/bin/bash

FILE_PATH=$1
NUMBER=$2

echo "NormalizeFMRI_est_write('${FILE_PATH}',${NUMBER})"
matlab -nodisplay <<EOF
NormalizeFMRI_est_write('${FILE_PATH}',${NUMBER});
EOF
