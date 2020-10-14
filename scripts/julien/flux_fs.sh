#!/bin/bash

#  flux.sh
#  
#
#  Created by Julien Dumont on 6/6/14.
#


echo "
********************************************************************
**            CONVERT AND RENAME 3DT1                             **
********************************************************************
"

base_path= ${PWD}
echo ${base_path}

for session in $(ls $base_path)
do

echo "*** >> Run on  ${session}
"
#dcm2nii -g n -o ${PWD}/${session} ${PWD}/${session}/*.par
#rm -rf  ${PWD}/${session}/co*
#rm -rf  ${PWD}/${session}/o*
#mv ${PWD}/${session}/*.nii ${PWD}/${session}/t1.nii
#echo ${PWD}/${session}

#/usr/local/matlab11/bin/matlab -nodisplay -nosplash -nojvm<<EOF
#par2bval('${PAR_FILE}');
#EOF

#export FREESURFER_HOME=/home/global/freesurfer5.1/
#. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

#recon-all -all -sd /tmp -s ${session} -i /NAS/dumbo/protocoles/flux/data/${subject}/t1.nii -nuintensitycor-3T -hippo-#subfields -bigventricules
#cp -Rf /tmp/${session} /NAS/dumbo/protocoles/flux/fs51

qbatch -q fs_q -oe /home/julien/log/ -N fs_${session} flux_fs51.sh ${session}

sleep 10


done
