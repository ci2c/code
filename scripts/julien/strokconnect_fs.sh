#!/bin/bash



subj=$1




export FREESURFER_HOME=/home/global/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh



recon-all -all -sd /NAS/dumbo/protocoles/strokconnect/FS53 -s ${subj} -i /NAS/dumbo/protocoles/strokconnect/data/${subj}/t1.nii.gz -nuintensitycor-3T

