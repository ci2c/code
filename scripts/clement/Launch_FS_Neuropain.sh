#!/bin/bash
SUBJECTS_DIR=/NAS/tupac/protocoles/neuropain/FS53
for f in /NAS/tupac/protocoles/neuropain/data/dcm/*
do
subjid=`basename $f`

RS_Im=$(ls ${SUBJECTS_DIR}/${subjid}/rsfmri/*BOLDRSAX*nii* 2> /dev/null)

if [ ! -e ${SUBJECTS_DIR}/${subjid}/rsfmri/run01/wcarepi_al.nii.gz ]; then

	echo `basename $RS_Im`

	qbatch -q three_job_q -oe /home/clement/log/neuropain -N Prepro${subjid} FMRI_PreprocessingVolumeAndSurface.sh -sd ${SUBJECTS_DIR} -subj ${subjid}  -epi ${RS_Im}   -o rsfmri  -fwhmsurf 6  -fwhmvol 6  -acquis interleavedAscending -rmframe 3  -doGMS  -tr 3 -toMNI  -doCompCor -doFilt 0.008 0.1 -doSPMNorm  -doANTSNorm  -v 5.3

	sleep 2
fi
done
