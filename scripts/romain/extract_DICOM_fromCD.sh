#!/bin/bash

SUBJ=$1

mkdir /NAS/tupac/protocoles/alexcis/data/mri/t_${SUBJ}
mkdir /NAS/tupac/protocoles/alexcis/data/nifti/t_${SUBJ}

cd '/media/romain/SCAN+'
`dcmdump --search 0004,1500 DICOMDIR | sed -e 's/.*\[\(.*\)\].*/\1/' | sed -e 's/\\/\//' | xargs cp -t /NAS/tupac/protocoles/alexcis/data/mri/t_${SUBJ}`

`dcm2nii /NAS/tupac/protocoles/alexcis/data/mri/t_${SUBJ}/* -o /NAS/tupac/protocoles/alexcis/data/nifti/t_${SUBJ}`
