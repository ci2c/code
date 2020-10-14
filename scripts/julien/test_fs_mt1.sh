#!/bin/bash


fs_version=$1
subj=$2
data_source=$3
data_destination=$4
fichier=$5




export FREESURFER_HOME=/home/global/freesurfer${fs_version}/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

echo "recon-all -all -sd ${data_destination} -s ${subj}_${fichier%%.*} -i ${data_source}/${fichier} -nuintensitycor-3T -hippo-subfields
cp -Rf /tmp/${subj}_${fichier%%.*}  ${data_destination}
----------------------------------------------------------------------------------------------------------------"

recon-all -all -sd ${data_destination} -s ${subj}_${fichier%%.*} -i ${data_source}/${fichier} -nuintensitycor-3T -hippo-subfields
#cp -Rf /tmp/${subj}_${fichier%%.*}  ${data_destination}
