#!/bin/bash

if [ $# -lt 5 ]
then
	echo ""
	echo "Usage: DTI_Tracto_ROI.sh -roi <NameRoi> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -roi		: Name of the ROI used for tractography"
	echo "  -subjid		: Subject ID"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage: DTI_Tracto_ROI.sh -roi <NameRoi> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
ROI=$1
SUBJ_ID=$2
DTI=$3
lmax=$4
Nfiber=$5
CutOff=$6
# Exclusion_ROI=$7

if [ ! -e ${DTI}/LFN_VIII_${lmax}_${Nfiber}_th${CutOff}.tck ]
then
	# Stream locally to avoid RAM filling
	rm -f /tmp/${SUBJ_ID}_LFN_VIII_${lmax}_${Nfiber}_th${CutOff}.tck
#	streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/r${ROI}_dti_ras.mif -mask ${DTI}/rwm_mask_dti.mif /tmp/${SUBJ_ID}_${ROI}_${lmax}_${Nfiber}_th${CutOff}.tck -exclude ${Exclusion_ROI} -num ${Nfiber} -cutoff ${CutOff}
	streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${ROI} -mask ${DTI}/brain_mask.mif /tmp/${SUBJ_ID}_LFN_VIII_${lmax}_${Nfiber}_th${CutOff}.tck -num ${Nfiber} -cutoff ${CutOff}
	
# 	# LEMP
# 	streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/labels_dti_${ROI}_ras.mif -mask ${DTI}/mask.mif /tmp/${SUBJ_ID}_${ROI}_${lmax}_${Nfiber}_th${CutOff}.tck -exclude ${DTI}/labels_dti_${Exclusion_ROI}_ras.mif -num ${Nfiber} -cutoff ${CutOff}	
	
#	cp -f /tmp/${SUBJ_ID}_${ROI}_${lmax}_${Nfiber}_th${CutOff}.tck ${DTI}/ROI_${ROI}_${lmax}_${Nfiber}_th${CutOff}_ex.wm.tck
#	rm -f /tmp/${SUBJ_ID}_${ROI}_${lmax}_${Nfiber}_th${CutOff}.tck

	cp -f /tmp/${SUBJ_ID}_LFN_VIII_${lmax}_${Nfiber}_th${CutOff}.tck ${DTI}/LFN_VIII_${lmax}_${Nfiber}_th${CutOff}.tck
	rm -f /tmp/${SUBJ_ID}_LFN_VIII_${lmax}_${Nfiber}_th${CutOff}.tck
fi

# if [ ! -e ${DTI}/${ROI}_${lmax}_${Nfiber}_part000001.tck ]
# then
# 	# Cut the fiber file into small matlab files
# 	matlab -nodisplay <<EOF
# 	split_fibers('${DTI}/${ROI}_${lmax}_${Nfiber}.tck', '${DTI}', '${ROI}_${lmax}_${Nfiber}');
# EOF
# fi

# if [ ! -e ${DTI}/${ROI}_${lmax}_${Nfiber}.vtk ]
# then
# 	matlab -nodisplay <<EOF
# 	tracts = f_readFiber_tck('${DTI}/${ROI}_${lmax}_${Nfiber}.tck');
# 	tract_out = color_tracts(tracts);
# 	save_tract_vtk(tract_out,'${DTI}/${ROI}_${lmax}_${Nfiber}.vtk');
# EOF
# fi
