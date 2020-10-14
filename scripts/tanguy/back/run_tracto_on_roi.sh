#! /bin/bash

if [ $# -lt 3 ]
then
		echo ""
		echo "Usage: run_tracto_on_roi -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "  -sd                             : Subjects Dir : directory containing the patient records to control"
		echo ""
		echo "	-subj				: Subj ID"
		echo ""
		echo "Usage: run_tracto_on_roi -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
fi


index=1


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo ""
		echo "Usage: run_tracto_on_roi -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "  -sd                             : Subjects Dir : directory containing the patient records to control"
		echo ""
		echo "	-subj				: Subj ID"
		echo ""
		echo "Usage: run_tracto_on_roi -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
		;;
	-sd)
		
		SD=`expr $index + 1`
		eval SD=\${$SD}
		echo "SUBJ_DIR : $SD"
		;;

	-subj)
		
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "SUBJ : $SUBJ"
		;;


	
	esac
	index=$[$index+1]
done



#
DIR=$SD/$SUBJ/dti
rm -Rf ${DIR}/mrtrix/tracto
mkdir ${DIR}/mrtrix/tracto
ROIDIR=$DIR/ROI

## lance Matlab
## pour extraire les fibres des ROI



for ROI in `ls $ROIDIR/*.nii`
do
ROINAME=${ROI%.*}

matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${DIR}


tractoonroi('$SD','$SUBJ','$ROINAME')


EOF




done


