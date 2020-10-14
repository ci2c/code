#!/bin/bash
set -e

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: QSM_CreateScalarFile.sh  -sd <folder>  -subj <name>  -map <nifti>  -lhmap <file>  -rhmap <file>  -o <folder>  [-oname <name>  -hcp] "
	echo ""
	echo "  -sd                       : subjects folder"
	echo "  -subj                     : subject's name"
	echo "  -map                      : map in mni space (nifti image)"
	echo "  -lhmap                    : map in surface - left hemisphere (gii file)"
	echo "  -rhmap                    : map in surface - right hemisphere (gii file)"
	echo "  -o                        : output folder "
	echo "Options :"
	echo "  -oname                    : output name (Default: Map.32k_fs_LR.dscalar.nii) "
	echo "  -hcp                      : values inside HCP parcellation (Default: No) "
	echo ""
	echo "Usage: QSM_CreateScalarFile.sh  -sd <folder>  -subj <name>  -map <nifti>  -lhmap <file>  -rhmap <file>  -o <folder>  [-oname <name>  -hcp] "
	echo ""
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

OUTNAME="Map.32k_fs_LR.dscalar.nii"
HCP="NONE"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: QSM_CreateScalarFile.sh  -sd <folder>  -subj <name>  -map <nifti>  -lhmap <file>  -rhmap <file>  -o <folder>  [-oname <name>  -hcp] "
		echo ""
		echo "  -sd                       : subjects folder"
		echo "  -subj                     : subject's name"
		echo "  -map                      : map in mni space (nifti image)"
		echo "  -lhmap                    : map in surface - left hemisphere (gii file)"
		echo "  -rhmap                    : map in surface - right hemisphere (gii file)"
		echo "  -o                        : output folder"
		echo "Options :"
		echo "  -oname                    : output name (Default: Map.32k_fs_LR.dscalar.nii) "
		echo "  -hcp                      : values inside HCP parcellation (Default: No) "
		echo ""
		echo "Usage: QSM_CreateScalarFile.sh  -sd <folder>  -subj <name>  -map <nifti>  -lhmap <file>  -rhmap <file>  -o <folder>  [-oname <name>  -hcp] "
		echo ""
		exit 1
		;;
	-sd)
		DIR=`expr $index + 1`
		eval DIR=\${$DIR}
		echo "  |-------> sd : $DIR"
		index=$[$index+1]
		;;
	-subj)
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "  |-------> subj : $SUBJ"
		index=$[$index+1]
		;;
	-map)
		MAP=`expr $index + 1`
		eval MAP=\${$MAP}
		echo "  |-------> map : $MAP"
		index=$[$index+1]
		;;
	-lhmap)
		LHMAP=`expr $index + 1`
		eval LHMAP=\${$LHMAP}
		echo "  |-------> lh map : $LHMAP"
		index=$[$index+1]
		;;
	-rhmap)
		RHMAP=`expr $index + 1`
		eval RHMAP=\${$RHMAP}
		echo "  |-------> rh map : $RHMAP"
		index=$[$index+1]
		;;
	-o)
		OUTDIR=`expr $index + 1`
		eval OUTDIR=\${$OUTDIR}
		echo "  |-------> o : $OUTDIR"
		index=$[$index+1]
		;;
	-oname)
		OUTNAME=`expr $index + 1`
		eval OUTNAME=\${$OUTNAME}
		echo "  |-------> oname : $OUTNAME"
		index=$[$index+1]
		;;
	-hcp)
		HCP="TRUE"
		echo "use of HCP parcellation"
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


echo ""
echo "START: QSM_CreateScalarFile.sh"
echo ""

# ------------------------------------------------------------------------------
#  Load Function Libraries
# ------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions

echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                               Initialization..."
echo "# --------------------------------------------------------------------------------"
echo ""

echo "Create output folder"
if [ ! -d ${OUTDIR} ]; then mkdir -p ${OUTDIR}; fi


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                  Process..."
echo "# --------------------------------------------------------------------------------"
echo ""

if [ ! -f ${OUTDIR}/Map_2MNI.2.nii.gz ]; then
	echo "applywarp --interp=spline -i ${MAP} -r ${DIR}/${SUBJ}/MNINonLinear/T1w_acpc.2.nii.gz -o ${OUTDIR}/Map_2MNI.2.nii.gz"
	applywarp --interp=spline -i ${MAP} -r ${DIR}/${SUBJ}/MNINonLinear/T1w_acpc.2.nii.gz -o ${OUTDIR}/Map_2MNI.2.nii.gz
fi

echo ""
echo "wb_command -cifti-create-dense-scalar ${OUTDIR}/${OUTNAME} -volume ${OUTDIR}/Map_2MNI.2.nii.gz ${DIR}/${SUBJ}/MNINonLinear/ROIs/Atlas_ROIs.2.nii.gz -left-metric ${LHMAP} -roi-left ${DIR}/${SUBJ}/MNINonLinear/fsaverage_LR32k/${SUBJ}.L.atlasroi.32k_fs_LR.shape.gii -right-metric ${RHMAP} -roi-right ${DIR}/${SUBJ}/MNINonLinear/fsaverage_LR32k/${SUBJ}.R.atlasroi.32k_fs_LR.shape.gii"
wb_command -cifti-create-dense-scalar ${OUTDIR}/${OUTNAME} -volume ${OUTDIR}/Map_2MNI.2.nii.gz ${DIR}/${SUBJ}/MNINonLinear/ROIs/Atlas_ROIs.2.nii.gz -left-metric ${LHMAP} -roi-left ${DIR}/${SUBJ}/MNINonLinear/fsaverage_LR32k/${SUBJ}.L.atlasroi.32k_fs_LR.shape.gii -right-metric ${RHMAP} -roi-right ${DIR}/${SUBJ}/MNINonLinear/fsaverage_LR32k/${SUBJ}.R.atlasroi.32k_fs_LR.shape.gii



echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                Parcellation..."
echo "# --------------------------------------------------------------------------------"
echo ""

if [ ${HCP} = "NONE" ]; then

	echo "don't use HCP parcellation"

else

	echo "extract values from HCP parcellation"

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd /home/renaud
	p = pathdef;
	addpath(p);

	[roi,labels] = QSM_GetValueFromHCPParcellation(fullfile('${OUTDIR}','${OUTNAME}'),fullfile('${OUTDIR}','HCP_parcels.mat'));

EOF

fi


echo ""
echo "END: QSM_CreateScalarFile.sh"
echo ""

