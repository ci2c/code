#! /bin/bash

SUBJECTS_DIR=$1
SUBJ=$2

export FREESURFER_HOME=/home/global/freesurfer5.1/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

recon-all -qcache -sd ${SUBJECTS_DIR} -s ${SUBJ} -nuintensitycor-3T -no-isrunning


