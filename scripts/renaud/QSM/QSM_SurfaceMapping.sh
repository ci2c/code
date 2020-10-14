#! /bin/bash
set -e

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: QSM_SurfaceMapping.sh  -sd <folder>  -subj <name>  -mag <nifti>  -map <nifti>  -o  <folder>  [-thr <value>  -fwhm <value>  -surf <name>  -method <value>]"
	echo ""
	echo "  -sd                       : subjects folder"
	echo "  -subj                     : subject's name"
	echo "  -mag                      : magnitude to project (nifti image)"
	echo "  -map                      : map to project (nifti image)"
	echo "  -o                        : output folder"
	echo " "
	echo "Options :"
	echo "  -thr                      : threshold value to applied (default : -1000)"
	echo "  -fwhm                     : smoothing value (default : 6mm)"
	echo "  -surf                     : surface name (default : midthickness)"
	echo "  -method                   : method for projection (default: 0) "
	echo "                                 0=ribbon constrained"
	echo "                                 1=enclosing"
	echo "                                 2=cubic"
	echo ""
	echo "Usage: QSM_SurfaceMapping.sh  -sd <folder>  -subj <name>  -mag <nifti>  -map <nifti>  -o  <folder>  [-thr <value>  -fwhm <value>  -surf <name>  -method <value>]"
	echo ""
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

THR="-1000"
SURF="midthickness"
METHOD="0"
SmoothingFWHM="6"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: QSM_SurfaceMapping.sh  -sd <folder>  -subj <name>  -mag <nifti>  -map <nifti>  -o  <folder>  [-thr <value>  -fwhm <value>  -surf <name>  -method <value>]"
		echo ""
		echo "  -sd                       : subjects folder"
		echo "  -subj                     : subject's name"
		echo "  -mag                      : magnitude to project (nifti image)"
		echo "  -map                      : map to project (nifti image)"
		echo "  -o                        : output folder"
		echo " "
		echo "Options :"
		echo "  -thr                      : threshold value to applied (default : -1000)"
		echo "  -fwhm                     : smoothing value (default : 6mm)"
		echo "  -surf                     : surface name (default : midthickness)"
		echo "  -method                   : method for projection (default: 0) "
		echo "                                 0=ribbon constrained"
		echo "                                 1=enclosing"
		echo "                                 2=cubic"
		echo ""
		echo "Usage: QSM_SurfaceMapping.sh  -sd <folder>  -subj <name>  -mag <nifti>  -map <nifti>  -o  <folder>  [-thr <value>  -fwhm <value>  -surf <name>  -method <value>]"
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
	-mag)
		MAGNITUDE=`expr $index + 1`
		eval MAGNITUDE=\${$MAGNITUDE}
		echo "  |-------> mag : $MAGNITUDE"
		index=$[$index+1]
		;;
	-map)
		MAP=`expr $index + 1`
		eval MAP=\${$MAP}
		echo "  |-------> map : $MAP"
		index=$[$index+1]
		;;
	-o)
		OUTDIR=`expr $index + 1`
		eval OUTDIR=\${$OUTDIR}
		echo "  |-------> o : $OUTDIR"
		index=$[$index+1]
		;;
	-thr)
		THR=`expr $index + 1`
		eval THR=\${$THR}
		echo "  |-------> thr : $THR"
		index=$[$index+1]
		;;
	-fwhm)
		SmoothingFWHM=`expr $index + 1`
		eval SmoothingFWHM=\${$SmoothingFWHM}
		echo "  |-------> fwhm : $SmoothingFWHM"
		index=$[$index+1]
		;;
	-surf)
		SURF=`expr $index + 1`
		eval SURF=\${$SURF}
		echo "  |-------> surf : $SURF"
		index=$[$index+1]
		;;
	-method)
		METHOD=`expr $index + 1`
		eval METHOD=\${$SURF}
		echo "  |-------> method : $METHOD"
		index=$[$index+1]
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


# --------------------------------------------------------------------------------
#                      Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions


echo ""
echo "START: QSM_SurfaceMapping.sh"
echo ""

echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                   CONFIG"
echo "# --------------------------------------------------------------------------------"
echo ""

MAGNITUDE=`$FSLDIR/bin/remove_ext $MAGNITUDE`
MAP=`$FSLDIR/bin/remove_ext $MAP`
echo "Magnitude: ${MAGNITUDE}"
echo "Map: ${MAP}"

T1wFolder=${DIR}/${SUBJ}/"T1w"
AtlasSpaceFolder=${DIR}/${SUBJ}/"MNINonLinear"
T1=${T1wFolder}/"T1w_acpc"
T1BRAIN=${T1wFolder}/"T1w_acpc_brain"
StructuralToStandard=${AtlasSpaceFolder}/"xfms"/"acpc_dc2standard"
SURFDIR=${T1wFolder}/"Native"
dof="6"
LowResMesh="32"

if [ ! -d ${OUTDIR} ]; then mkdir -p ${OUTDIR}; fi


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                              Map preprocessing"
echo "# --------------------------------------------------------------------------------"
echo ""

echo "fslmaths ${MAP} -nan ${OUTDIR}/Map"
fslmaths ${MAP} -nan ${OUTDIR}/Map

echo "fslmaths ${OUTDIR}/Map -thr ${THR} ${OUTDIR}/Map"
fslmaths ${OUTDIR}/Map -thr ${THR} ${OUTDIR}/Map


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                          Magnitude to T1 registration"
echo "# --------------------------------------------------------------------------------"
echo ""

if [ ! -f ${OUTDIR}/MAG2T1w.mat ]; then
	echo "flirt -in ${MAGNITUDE} -ref ${T1} -omat ${OUTDIR}/MAG2T1w.mat -o ${OUTDIR}/Magnitude_2T1 -interp spline -dof ${dof}"
	flirt -in ${MAGNITUDE} -ref ${T1} -omat ${OUTDIR}/MAG2T1w.mat -o ${OUTDIR}/Magnitude_2T1 -interp spline -dof ${dof}
fi
echo "flirt -in ${OUTDIR}/Map -ref ${T1} -applyxfm -init ${OUTDIR}/MAG2T1w_init_init.mat -interp spline -out ${OUTDIR}/Map_2T1"
${FSLDIR}/bin/flirt -in ${OUTDIR}/Map -ref ${T1} -applyxfm -init ${OUTDIR}/MAG2T1w.mat -interp spline -out ${OUTDIR}/Map_2T1


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                     One step resampling : MULTIGRE -> T1 -> MNI"
echo "# --------------------------------------------------------------------------------"
echo ""

# Create transformation
ResampRefIm=$FSLDIR/data/standard/MNI152_T1_1mm
echo "convertwarp --relout --rel --premat=${OUTDIR}/MAG2T1w_init_init.mat --warp2=${StructuralToStandard} --ref=${ResampRefIm} --out=${OUTDIR}/MAG2MNI"
${FSLDIR}/bin/convertwarp --relout --rel --premat=${OUTDIR}/MAG2T1w.mat --warp2=${StructuralToStandard} --ref=${ResampRefIm} --out=${OUTDIR}/MAG2MNI

# Apply transformation
echo "applywarp --rel --interp=spline -i ${MAGNITUDE} -r ${ResampRefIm} -w ${OUTDIR}/MAG2MNI -o ${OUTDIR}/Magnitude_2MNI"
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${MAGNITUDE} -r ${ResampRefIm} -w ${OUTDIR}/MAG2MNI -o ${OUTDIR}/Magnitude_2MNI
echo "applywarp --rel --interp=spline -i ${OUTDIR}/Map -r ${ResampRefIm} -w ${OUTDIR}/MAG2MNI -o ${OUTDIR}/Map_2MNI"
${FSLDIR}/bin/applywarp --rel --interp=spline -i ${OUTDIR}/Map -r ${ResampRefIm} -w ${OUTDIR}/MAG2MNI -o ${OUTDIR}/Map_2MNI


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                   Create Ribbon"
echo "# --------------------------------------------------------------------------------"
echo ""

echo "FMRI_CreateRibbon.sh -subj ${SUBJ} -i ${T1wFolder} -scout ${OUTDIR}/Magnitude_2T1 -o ${OUTDIR}"
FMRI_CreateRibbon.sh -subj ${SUBJ} -i ${T1wFolder} -scout ${OUTDIR}/Magnitude_2T1 -o ${OUTDIR}


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                    Good voxels"
echo "# --------------------------------------------------------------------------------"
echo ""

GoodVoxels=${T1wFolder}/ribbon
echo "Good voxels: ${GoodVoxels}"


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                   Surface mapping"
echo "# --------------------------------------------------------------------------------"
echo ""

for Hemi in L R ; do

	echo "Hemisphere: ${Hemi}"

	if [ ${METHOD} = "0" ]; then

		echo "Projection's method: ribbon constrained"
		echo "Magnitude"
		${CARET7DIR}/wb_command -volume-to-surface-mapping \
			${OUTDIR}/Magnitude_2T1.nii.gz \
			"$SURFDIR"/"$SUBJ"."$Hemi".${SURF}.native.surf.gii \
			"$OUTDIR"/Magnitude."$Hemi".native.shape.gii \
			-ribbon-constrained "$SURFDIR"/"$SUBJ"."$Hemi".white.native.surf.gii "$SURFDIR"/"$SUBJ"."$Hemi".pial.native.surf.gii \
			-volume-roi ${GoodVoxels}.nii.gz

		echo "Map"
		${CARET7DIR}/wb_command -volume-to-surface-mapping \
			${OUTDIR}/Map_2T1.nii.gz \
			"$SURFDIR"/"$SUBJ"."$Hemi".${SURF}.native.surf.gii \
			"$OUTDIR"/Map."$Hemi".native.shape.gii \
			-ribbon-constrained "$SURFDIR"/"$SUBJ"."$Hemi".white.native.surf.gii "$SURFDIR"/"$SUBJ"."$Hemi".pial.native.surf.gii \
			-volume-roi ${GoodVoxels}.nii.gz

	elif [ ${METHOD} = "1" ]; then

		echo "Projection's method: enclosing"
		echo "Magnitude"
		${CARET7DIR}/wb_command -volume-to-surface-mapping \
			${OUTDIR}/Magnitude_2T1.nii.gz \
			"$SURFDIR"/"$SUBJ"."$Hemi".${SURF}.native.surf.gii \
			"$OUTDIR"/Magnitude."$Hemi".native.shape.gii \
			-enclosing

		echo "Map"
		${CARET7DIR}/wb_command -volume-to-surface-mapping \
			${OUTDIR}/Map_2T1.nii.gz \
			"$SURFDIR"/"$SUBJ"."$Hemi".${SURF}.native.surf.gii \
			"$OUTDIR"/Map."$Hemi".native.shape.gii \
			-enclosing

	else

		echo "Projection's method: cubic"
		echo "Magnitude"
		${CARET7DIR}/wb_command -volume-to-surface-mapping \
			${OUTDIR}/Magnitude_2T1.nii.gz \
			"$SURFDIR"/"$SUBJ"."$Hemi".${SURF}.native.surf.gii \
			"$OUTDIR"/Magnitude."$Hemi".native.shape.gii \
			-cubic

		echo "Map"
		${CARET7DIR}/wb_command -volume-to-surface-mapping \
			${OUTDIR}/Map_2T1.nii.gz \
			"$SURFDIR"/"$SUBJ"."$Hemi".${SURF}.native.surf.gii \
			"$OUTDIR"/Map."$Hemi".native.shape.gii \
			-cubic

	fi

done



echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                          Resampling to fsaverage 32k"
echo "# --------------------------------------------------------------------------------"
echo ""

for Hemi in L R ; do

	echo "Hemisphere: ${Hemi}"

	RegSphere="${AtlasSpaceFolder}/Native/${SUBJ}.${Hemi}.sphere.reg.reg_LR.native.surf.gii"

	echo "Magnitude"
	${CARET7DIR}/wb_command -metric-resample \
		"$OUTDIR"/Magnitude."$Hemi".native.shape.gii \
		${RegSphere} \
		"$AtlasSpaceFolder"/fsaverage_LR"$LowResMesh"k/"$SUBJ"."$Hemi".sphere."$LowResMesh"k_fs_LR.surf.gii \
		ADAP_BARY_AREA \
		"$OUTDIR"/Magnitude."$Hemi"."$LowResMesh"k_fs_LR.shape.gii \
		-area-surfs "$T1wFolder"/Native/"$SUBJ"."$Hemi".${SURF}.native.surf.gii \
		"$AtlasSpaceFolder"/fsaverage_LR"$LowResMesh"k/"$SUBJ"."$Hemi".${SURF}."$LowResMesh"k_fs_LR.surf.gii \
		-current-roi "$AtlasSpaceFolder"/Native/"$SUBJ"."$Hemi".roi.native.shape.gii

	${CARET7DIR}/wb_command -metric-mask \
		"$OUTDIR"/Magnitude."$Hemi"."$LowResMesh"k_fs_LR.shape.gii \
		"$AtlasSpaceFolder"/fsaverage_LR"$LowResMesh"k/"$SUBJ"."$Hemi".atlasroi."$LowResMesh"k_fs_LR.shape.gii \
		"$OUTDIR"/Magnitude."$Hemi"."$LowResMesh"k_fs_LR.shape.gii

	echo "Map"
	${CARET7DIR}/wb_command -metric-resample \
		"$OUTDIR"/Map."$Hemi".native.shape.gii \
		${RegSphere} \
		"$AtlasSpaceFolder"/fsaverage_LR"$LowResMesh"k/"$SUBJ"."$Hemi".sphere."$LowResMesh"k_fs_LR.surf.gii \
		ADAP_BARY_AREA \
		"$OUTDIR"/Map."$Hemi"."$LowResMesh"k_fs_LR.shape.gii \
		-area-surfs "$T1wFolder"/Native/"$SUBJ"."$Hemi".${SURF}.native.surf.gii \
		"$AtlasSpaceFolder"/fsaverage_LR"$LowResMesh"k/"$SUBJ"."$Hemi".${SURF}."$LowResMesh"k_fs_LR.surf.gii \
		-current-roi "$AtlasSpaceFolder"/Native/"$SUBJ"."$Hemi".roi.native.shape.gii

	${CARET7DIR}/wb_command -metric-mask \
		"$OUTDIR"/Map."$Hemi"."$LowResMesh"k_fs_LR.shape.gii \
		"$AtlasSpaceFolder"/fsaverage_LR"$LowResMesh"k/"$SUBJ"."$Hemi".atlasroi."$LowResMesh"k_fs_LR.shape.gii \
		"$OUTDIR"/Map."$Hemi"."$LowResMesh"k_fs_LR.shape.gii

done



echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                 Smoothing"
echo "# --------------------------------------------------------------------------------"
echo ""

Sigma=`echo "$SmoothingFWHM / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`

for Hemi in L R ; do

	echo "Hemisphere: ${Hemi}"

	${CARET7DIR}/wb_command -metric-smoothing \
		"$AtlasSpaceFolder"/fsaverage_LR"$LowResMesh"k/"$SUBJ"."$Hemi".${SURF}."$LowResMesh"k_fs_LR.surf.gii \
		"$OUTDIR"/Map."$Hemi"."$LowResMesh"k_fs_LR.shape.gii \
		"$Sigma" \
		"$OUTDIR"/Map_s${SmoothingFWHM}."$Hemi"."$LowResMesh"k_fs_LR.shape.gii \
		-roi "$AtlasSpaceFolder"/fsaverage_LR"$LowResMesh"k/"$SUBJ"."$Hemi".atlasroi."$LowResMesh"k_fs_LR.shape.gii

done


echo ""
echo "END: QSM_SurfaceMapping.sh"
echo ""

