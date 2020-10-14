#!/bin/bash

bids_dir=/NAS/tupac/matthieu/BIDS/Nifti
output_dir=/NAS/tupac/matthieu/BIDS/fmriPrep
WD=/NAS/tupac/matthieu/BIDS/work_dir

## First run of heudiconv
docker run --rm -it -v /NAS/tupac/matthieu/BIDS/DICOM:/data:ro \
-v /NAS/tupac/matthieu/BIDS/Nifti:/output nipy/heudiconv:latest \
-d /data/{subject}/*/* -s 207103_M0_2013-02-19 \
-f convertall -c none -o /output

## Conversion od DICOMs into BIDS format with heudiconv
docker run --rm -it -v /NAS/tupac/matthieu/BIDS/DICOM:/data:ro \
-v /NAS/tupac/matthieu/BIDS/Nifti:/output nipy/heudiconv:latest \
-d /data/{subject}/*/* -s 207103_M0_2013-02-19 \
-f /data/COMAJ-bids.py -b -o /output

## Run anatomical fmriprep pipeline only without
fmriprep-docker ${bids_dir} ${output_dir} participant \
                --participant_label 207103M020130219 \
                -vvv \
                --anat-only \
                --output-space T1w template fsnative fsaverage \
                --write-graph \
                --stop-on-first-crash \
                -w ${WD} \
                --fs-license-file /NAS/tupac/matthieu/BIDS/license.txt

## Whole fmriprep pipeline for RS-fMRI data
fmriprep-docker ${bids_dir} ${output_dir} participant \
                --participant_label 207103M020130219 \
                -vvv \
                --ignore slicetiming \
                --output-space T1w template fsnative fsaverage \
                --medial-surface-nan \
                --use-aroma \
                --use-syn-sdc \
                --cifti-output \
                --write-graph \
                --stop-on-first-crash \
                -w ${WD} \
                --fs-license-file /NAS/tupac/matthieu/BIDS/license.txt
