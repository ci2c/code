#! /bin/bash

if [ $# -lt 1 ]
then
	echo ""
	echo "Usage: Run_qcache_dir.sh Freesurfer_dir"
	echo ""
	echo "  Freesurfer_dir                   : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	exit 1
fi

SD=$1

SUBJECTS_DIR=${SD}

for subject in `ls ${SD} --hide fsaverage --hide lh.EC_average --hide rh.EC_average --hide *.touch`
do
	do_cmd 10 ${SD}/${subject}_qcache.touch recon-all -qcache -sd ${SD} -subjid ${subject} -nuintensitycor-3T -no-isrunning &
	sleep 20
done
