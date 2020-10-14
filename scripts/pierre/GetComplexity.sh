#!/bin/bash

if [ $# -lt 3 ]
then
	echo ""
	echo "Usage: GetComplexity.sh  fs_dir  subj  radius"
	echo ""
	echo "  fs_dir                         : freesurfer output path (i.e. SUBJECTS_DIR)"
	echo "  subj                           : subject ID"
	echo "  radius                         : sphere radius"
	echo ""
	echo "Usage: GetComplexity.sh  fs_dir  subj  radius"
	echo ""
	exit 1
fi

SUBJECTS_DIR=$1
FS=$1
R=$3

for subj in `ls | grep $2`
do

matlab -nodisplay <<EOF
Surf = SurfStatReadSurf('${FS}/${subj}/surf/lh.white');
C = getSurfaceComplexity(Surf, ${R});
write_curv_properly(C, '${FS}/${subj}/surf/lh.complexity.${R}', '${FS}', '${subj}');
EOF

done


