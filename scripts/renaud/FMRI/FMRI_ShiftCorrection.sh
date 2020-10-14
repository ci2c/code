#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: FMRI_ShiftCorrection.sh -epi <path> "
	echo ""
	echo "  -epi              : path to nifti file "
	echo ""
	echo "Usage: FMRI_ShiftCorrection.sh -epi <path> "
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ShiftCorrection.sh -epi <path> "
		echo ""
		echo "  -epi              : path to nifti file "
		echo ""
		echo "Usage: FMRI_ShiftCorrection.sh -epi <path> "
		echo ""
		exit 1
		;;
	-epi)
		index=$[$index+1]
		eval FMRI=\${$index}
		echo "FMRI : $FMRI"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ShiftCorrection.sh -epi <path> "
		echo ""
		echo "  -epi              : path to nifti file "
		echo ""
		echo "Usage: FMRI_ShiftCorrection.sh -epi <path> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

echo ""
echo "==============================="
echo "START: FMRI_ShiftCorrection.sh "
echo "==============================="
echo ""

DIR=`dirname ${FMRI}`
gunzip -f ${FMRI}
IMA=`$FSLDIR/bin/remove_ext $FMRI`
PhaseName=`basename ${IMA}`
PhaseName=${PhaseName}.nii

curdir=`pwd`
cd ${DIR}

matlab -nodisplay <<EOF

	FMRI_EPIshift_and_flip('${PhaseName}', 's${PhaseName}');

EOF

gzip ${DIR}/s${PhaseName} 

cd ${curdir}

rm -f ${DIR}/${PhaseName}
mv ${DIR}/s${PhaseName}.gz ${FMRI}


