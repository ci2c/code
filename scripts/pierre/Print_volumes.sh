#! /bin/bash

if [ $# -lt 3 ]
then
	echo ""
	echo "Usage: Print_volumes.sh <Freesurfer_dir> <regular_expression> <output_name>"
	echo ""
	echo "  Freesurfer_dir                   : path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  regular_expression               : regular expression to search in aseg.stats"
	echo "  output_name                      : output suffix name"
	exit 1
fi

SD=$1

SUBJECTS_DIR=${SD}
EXPR=$2
out_suffix=$3

for subject in `ls ${SD} --hide fsaverage --hide lh.EC_average --hide rh.EC_average --hide *.touch`
do
	A=`cat ${SD}/${subject}/stats/aseg.stats | grep ${EXPR} | awk  '{print $4}'`
	echo ${A} > ${subject}_${out_suffix}.stat
done
