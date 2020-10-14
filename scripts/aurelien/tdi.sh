#!/bin/bash

dir=$1

dcm2nii -o . *

mri_convert *DTI* dti.nii -vs 1 1 1 -rt cubic --out_orientation RAS

mrconvert dti.nii dti.mif

mrconvert dwi.mif -coord 3 0 - | threshold -percent 2 - - | median3D - - | median3D - mask.mif
dwi2tensor dwi.mif -grad encoding.b dt.mif
tensor2FA dt.mif - | mrmult - mask.mif fa.mif
tensor2vector dt.mif - | mrmult - fa.mif ev.mif
erode mask.mif - | erode - - | mrmult fa.mif - - | threshold - -abs 0.6 sf.mif
estimate_response dwi.mif sf.mif -lmax 6 response.txt -grad grad.d
csdeconv dwi.mif response.txt -lmax 10 -mask mask.mif CSD10.mif -grad grad.b

gen_WM_mask dwi.mif mask.mif wm.mif
streamtrack SD_PROB CSD10.mif -seed wm.mif -mask mask.mif whole_brain.tck -num 5000

