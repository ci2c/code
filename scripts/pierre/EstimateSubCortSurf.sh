#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: EstimateSubCortSurf.sh  -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  [-loi <LABELS_OF_INTEREST>]"
	echo ""
	echo "  -sd <SUBJECTS_DIR>                : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj <SUBJ_ID>                   : Subject ID"
	echo ""
	echo " Option :"
	echo "  -loi <LABELS_OF_INTEREST>         : Text file with subcortical structures informations"
	echo "                Default : ~/SVN/scripts/pierre/ListOfSCLabels.txt"
	echo ""
	echo "Usage: EstimateSubCortSurf.sh  -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -loi <LABELS_OF_INTEREST>"
	echo ""
	exit 1
fi


index=1
LOI="${HOME}/SVN/scripts/pierre/ListOfSCLabels.txt"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: EstimateSubCortSurf.sh  -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  [-loi <LABELS_OF_INTEREST>]"
		echo ""
		echo "  -sd <SUBJECTS_DIR>                : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj <SUBJ_ID>                   : Subject ID"
		echo ""
		echo " Option :"
		echo "  -loi <LABELS_OF_INTEREST>         : Text file with subcortical structures informations"
		echo "                Default : ~/SVN/scripts/pierre/ListOfSCLabels.txt"
		echo ""
		echo "Usage: EstimateSubCortSurf.sh  -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -loi <LABELS_OF_INTEREST>"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SD=\${$index}
		echo "SD : $SD"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subj : $SUBJ"
		;;
	-loi)
		index=$[$index+1]
		eval LOI=\${$index}
		echo "LOI : $LOI"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: EstimateSubCortSurf.sh  -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  [-loi <LABELS_OF_INTEREST>]"
		echo ""
		echo "  -sd <SUBJECTS_DIR>                : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj <SUBJ_ID>                   : Subject ID"
		echo ""
		echo " Option :"
		echo "  -loi <LABELS_OF_INTEREST>         : Text file with subcortical structures informations"
		echo "                Default : ~/SVN/scripts/pierre/ListOfSCLabels.txt"
		echo ""
		echo "Usage: EstimateSubCortSurf.sh  -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -loi <LABELS_OF_INTEREST>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

N_struc=`cat ${LOI} | wc -l`

i_struc=1
while [ ${i_struc} -le ${N_struc} ]
do
	TT=`sed -n "${i_struc}{p;q}" ${LOI}`
	echo ${TT}
	roi_id=`echo ${TT} | awk  '{print $1}'`
	roi_name=`echo ${TT} | awk  '{print $2}'`
	echo "ROI_ID   = ${roi_id}"
	echo "ROI_NAME = ${roi_name}"
	
	echo "mri_extract_label ${SD}/${SUBJ}/mri/aparc.a2009s+aseg.mgz ${roi_id} /tmp/${SUBJ}_${roi_name}.mgz"
	mri_extract_label ${SD}/${SUBJ}/mri/aparc.a2009s+aseg.mgz ${roi_id} /tmp/${SUBJ}_${roi_name}.mgz

	echo "mri_binarize --i /tmp/${SUBJ}_${roi_name}.mgz --o /tmp/${SUBJ}_${roi_name}_bin.mgz --min 0.1 --max inf"
	mri_binarize --i /tmp/${SUBJ}_${roi_name}.mgz --o /tmp/${SUBJ}_${roi_name}_bin.mgz --min 0.1 --max inf
	
	echo "mri_tessellate /tmp/${SUBJ}_${roi_name}_bin.mgz 1 /tmp/lh.${SUBJ}_${roi_name}.orig.nofix"
	mri_tessellate /tmp/${SUBJ}_${roi_name}_bin.mgz 1 /tmp/lh.${SUBJ}_${roi_name}.orig.nofix
	
	echo "mris_info /tmp/lh.${SUBJ}_${roi_name}.orig.nofix > /tmp/${SUBJ}_${roi_name}.stats"
	mris_info /tmp/lh.${SUBJ}_${roi_name}.orig.nofix > /tmp/${SUBJ}_${roi_name}.stats
	
	A=`cat /tmp/${SUBJ}_${roi_name}.stats | grep total_area`
	A=`echo $A | awk '{print $2}'`
	
	if [ ${i_struc} -eq 1 ]
	then
		echo "${roi_name} ${roi_id} $A" > ${SD}/${SUBJ}/stats/subcortical_areas.stats
	else
		echo "${roi_name} ${roi_id} $A" >> ${SD}/${SUBJ}/stats/subcortical_areas.stats
	fi
	
	i_struc=$[${i_struc}+1]
done
