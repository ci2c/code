#! /bin/bash
set -e

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: FMRI_MNIVolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -scout <file>  -o <folder>  [-mask <file>  -reg <name>  -lowres <value>  -fwhm <value>  -tr <value>] "
	echo ""
	echo "  -subj           : subject's name "
	echo "  -i              : input folder (path to MNINonLinear) "
	echo "  -fmri           : fmri input image "
	echo "  -scout          : Scout input image "
	echo "  -o              : output folder "
	echo " Options "
	echo "  -mask           : mask image ('goodvoxels') "
	echo "  -reg            : registration name (Default: FS) "
	echo "  -lowres         : low resolution of mesh (Default: 32) "
	echo "  -fwhm           : smoothing value (Default: 6) "
	echo ""
	echo "Usage: FMRI_MNIVolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -scout <file>  -o <folder>  [-mask <file>  -reg <name>  -lowres <value>  -fwhm <value>  -tr <value>] "
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1

RegName="FS"
LowResMesh="32"
GoodVoxels="NONE"
SmoothingFWHM="6"
TR="2.4"
GrayordinatesResolution="2"

# Example:
# -subj T01S01
# -i /NAS/tupac/protocoles/healthy_volunteers/process/T01S01/MNINonLinear
# -o /NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/surface
# -fmri /NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/fmri_rf_st_mni


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_MNIVolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -scout <file>  -o <folder>  [-mask <file>  -reg <name>  -lowres <value>  -fwhm <value>  -tr <value>] "
		echo ""
		echo "  -subj           : subject's name "
		echo "  -i              : input folder (path to MNINonLinear) "
		echo "  -fmri           : fmri input image "
		echo "  -scout          : Scout input image "
		echo "  -o              : output folder "
		echo " Options "
		echo "  -mask           : mask image ('goodvoxels') "
		echo "  -reg            : registration name (Default: FS) "
		echo "  -lowres         : low resolution of mesh (Default: 32) "
		echo "  -fwhm           : smoothing value (Default: 6) "
		echo ""
		echo "Usage: FMRI_MNIVolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -scout <file>  -o <folder>  [-mask <file>  -reg <name>  -lowres <value>  -fwhm <value>  -tr <value>] "
		echo ""
		exit 1
		;;
	-subj)
		index=$[$index+1]
		eval Subject=\${$index}
		echo "Subject : $Subject"
		;;
	-i)
		index=$[$index+1]
		eval InputFolder=\${$index}
		echo "InputFolder : $InputFolder"
		;;
	-fmri)
		index=$[$index+1]
		eval VolumefMRI=\${$index}
		echo "VolumefMRI : $VolumefMRI"
		;;
	-scout)
		index=$[$index+1]
		eval ScoutImage=\${$index}
		echo "ScoutImage : $ScoutImage"
		;;
	-mask)
		index=$[$index+1]
		eval GoodVoxels=\${$index}
		echo "GoodVoxels : $GoodVoxels"
		;;
	-o)
		index=$[$index+1]
		eval WorkingDirectory=\${$index}
		echo "WorkingDirectory : $WorkingDirectory"
		;;
	-reg)
		index=$[$index+1]
		eval RegName=\${$index}
		echo "RegName : $RegName"
		;;
	-lowres)
		index=$[$index+1]
		eval LowResMesh=\${$index}
		echo "LowResMesh : $LowResMesh"
		;;
	-fwhm)
		index=$[$index+1]
		eval SmoothingFWHM=\${$index}
		echo "SmoothingFWHM : $SmoothingFWHM"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR : $TR"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_MNIVolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -scout <file>  -o <folder>  [-mask <file>  -reg <name>  -lowres <value>  -fwhm <value>  -tr <value>] "
		echo ""
		echo "  -subj           : subject's name "
		echo "  -i              : input folder (path to MNINonLinear) "
		echo "  -fmri           : fmri input image "
		echo "  -scout          : Scout input image "
		echo "  -o              : output folder "
		echo " Options "
		echo "  -mask           : mask image ('goodvoxels') "
		echo "  -reg            : registration name (Default: FS) "
		echo "  -lowres         : low resolution of mesh (Default: 32) "
		echo "  -fwhm           : smoothing value (Default: 6) "
		echo ""
		echo "Usage: FMRI_MNIVolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -scout <file>  -o <folder>  [-mask <file>  -reg <name>  -lowres <value>  -fwhm <value>  -tr <value>] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# --------------------------------------------------------------------------------
#                      Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions


# --------------------------------------------------------------------------------
#                                     CONFIG
# --------------------------------------------------------------------------------


AtlasSpaceNativeFolder=${InputFolder}/MNINonLinear/Native
echo "AtlasSpaceNativeFolder = $AtlasSpaceNativeFolder"
if [ ! -d ${AtlasSpaceNativeFolder} ]; then 
	echo "no ${AtlasSpaceNativeFolder} folder"
	exit 1
fi

DownsampleFolder=${InputFolder}/MNINonLinear/fsaverage_LR${LowResMesh}k
echo "DownsampleFolder = $DownsampleFolder"
if [ ! -d ${DownsampleFolder} ]; then 
	echo "no ${DownsampleFolder} folder"
	exit 1
fi

ROIFolder=${InputFolder}/MNINonLinear/ROIs
echo "ROIFolder = $ROIFolder"
if [ ! -d ${ROIFolder} ]; then 
	echo "no ${DownsampleFolder} folder"
	exit 1
fi

if [ ! -d ${WorkingDirectory} ]; then mkdir -p ${WorkingDirectory}; fi

if [ ${RegName} = "FS" ]; then
	RegName="reg.reg_LR"
fi

echo " "
echo "START: FMRI_MNIVolumeToSurfaceMapping.sh"
echo " START: `date`"
echo ""

# --------------------------------------------------------------------------------
#                                    PROCESS
# --------------------------------------------------------------------------------


VolumefMRIName=`basename ${VolumefMRI}`


echo ""
echo "====================="
echo "  Good voxels image  "
echo "====================="
echo ""

if [ ${GoodVoxels} = "NONE" ]; then 

	RibbonImage=${WorkingDirectory}/ribbon_only

	if [ ! -f ${RibbonImage}.nii.gz ]; then

		echo "Create Ribbon image"
	
		echo "FMRI_CreateRibbon.sh \
			-subj ${Subject} \
			-i ${InputFolder}/MNINonLinear \
			-scout ${ScoutImage} \
			-o ${WorkingDirectory}"
		FMRI_CreateRibbon.sh \
			-subj ${Subject} \
			-i ${InputFolder}/MNINonLinear \
			-scout ${ScoutImage} \
			-o ${WorkingDirectory}
	fi

	echo "Create good voxels image"
	echo "FMRI_FindGoodVoxels.sh  \
		-fmri ${VolumefMRI} \
		-ribbon ${RibbonImage} \
		-o ${WorkingDirectory}"
	FMRI_FindGoodVoxels.sh  \
		-fmri ${VolumefMRI} \
		-ribbon ${RibbonImage} \
		-o ${WorkingDirectory}

	GoodVoxels=${WorkingDirectory}/goodvoxels

fi

echo ""
echo "====================="
echo "   Surface mapping   "
echo "====================="
echo ""

for Hemisphere in L R ; do

	echo "Hemisphere : ${Hemisphere}H"
 
	if [ -f "$WorkingDirectory"/mean.nii.gz ]; then
		echo "mapping mean and cov"
		for Map in mean cov ; do
			${CARET7DIR}/wb_command -volume-to-surface-mapping "$WorkingDirectory"/"$Map".nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii -ribbon-constrained "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii -volume-roi ${GoodVoxels}.nii.gz
			${CARET7DIR}/wb_command -metric-dilate "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii 10 "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii -nearest
			${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii
			${CARET7DIR}/wb_command -volume-to-surface-mapping "$WorkingDirectory"/"$Map".nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$WorkingDirectory"/"$Hemisphere"."$Map"_all.native.func.gii -ribbon-constrained "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii
			${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere"."$Map"_all.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii "$WorkingDirectory"/"$Hemisphere"."$Map"_all.native.func.gii
			${CARET7DIR}/wb_command -metric-resample "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".sphere.${RegName}.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".sphere."$LowResMesh"k_fs_LR.surf.gii ADAP_BARY_AREA "$WorkingDirectory"/"$Hemisphere"."$Map"."$LowResMesh"k_fs_LR.func.gii -area-surfs "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii -current-roi "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii
			${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere"."$Map"."$LowResMesh"k_fs_LR.func.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii "$WorkingDirectory"/"$Hemisphere"."$Map"."$LowResMesh"k_fs_LR.func.gii
			${CARET7DIR}/wb_command -metric-resample "$WorkingDirectory"/"$Hemisphere"."$Map"_all.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".sphere.${RegName}.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".sphere."$LowResMesh"k_fs_LR.surf.gii ADAP_BARY_AREA "$WorkingDirectory"/"$Hemisphere"."$Map"_all."$LowResMesh"k_fs_LR.func.gii -area-surfs "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii -current-roi "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii
			${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere"."$Map"_all."$LowResMesh"k_fs_LR.func.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii "$WorkingDirectory"/"$Hemisphere"."$Map"_all."$LowResMesh"k_fs_LR.func.gii
		done
	fi

	echo "mapping goodvoxels"
	${CARET7DIR}/wb_command -volume-to-surface-mapping ${GoodVoxels}.nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$WorkingDirectory"/"$Hemisphere".goodvoxels.native.func.gii -ribbon-constrained "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii
	${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere".goodvoxels.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii "$WorkingDirectory"/"$Hemisphere".goodvoxels.native.func.gii
	${CARET7DIR}/wb_command -metric-resample "$WorkingDirectory"/"$Hemisphere".goodvoxels.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".sphere.${RegName}.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".sphere."$LowResMesh"k_fs_LR.surf.gii ADAP_BARY_AREA "$WorkingDirectory"/"$Hemisphere".goodvoxels."$LowResMesh"k_fs_LR.func.gii -area-surfs "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii -current-roi "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii
	${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere".goodvoxels."$LowResMesh"k_fs_LR.func.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii "$WorkingDirectory"/"$Hemisphere".goodvoxels."$LowResMesh"k_fs_LR.func.gii

	echo "mapping fMRI"
	${CARET7DIR}/wb_command -volume-to-surface-mapping "$VolumefMRI".nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii -ribbon-constrained "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii -volume-roi ${GoodVoxels}.nii.gz
	${CARET7DIR}/wb_command -metric-dilate "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii 10 "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii -nearest
	${CARET7DIR}/wb_command -metric-mask  "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii  "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii
	${CARET7DIR}/wb_command -metric-resample "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".sphere.${RegName}.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".sphere."$LowResMesh"k_fs_LR.surf.gii ADAP_BARY_AREA "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii -area-surfs "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii -current-roi "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii
	${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii "$DownsampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii

	rm -f "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii
done


echo ""
echo "====================="
echo "  Surface smoothing  "
echo "====================="
echo ""

if [ ${SmoothingFWHM} != "0" ]; then 
	Sigma=`echo "$SmoothingFWHM / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
	echo "Sigma = $Sigma"
fi

for Hemisphere in L R ; do

	mv "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii "$WorkingDirectory"/"$VolumefMRIName"_s0."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii

	if [ ${SmoothingFWHM} != "0" ]; then

		echo "wb_command -metric-smoothing \
			"$DownsampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii \
			"$WorkingDirectory"/"$VolumefMRIName"_s0."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii \
			"$Sigma" \
			"$WorkingDirectory"/"$VolumefMRIName"_s${SmoothingFWHM}."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii \
			-roi "$DownsampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii"

		${CARET7DIR}/wb_command -metric-smoothing \
			"$DownsampleFolder"/"$Subject"."$Hemisphere".midthickness."$LowResMesh"k_fs_LR.surf.gii \
			"$WorkingDirectory"/"$VolumefMRIName"_s0."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii \
			"$Sigma" \
			"$WorkingDirectory"/"$VolumefMRIName"_s${SmoothingFWHM}."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.func.gii \
			-roi "$DownsampleFolder"/"$Subject"."$Hemisphere".atlasroi."$LowResMesh"k_fs_LR.shape.gii

	fi

done


echo ""
echo "==========================="
echo "   Subcortical Processing  "
echo "==========================="
echo ""

echo "FMRI_SubcorticalProcessing.sh \
	-sd ${InputFolder} \
	-fmri $VolumefMRI \
	-o $WorkingDirectory \
	-fwhm $SmoothingFWHM \
	-res 2 \
	-finalres 2"
FMRI_SubcorticalProcessing.sh \
	-sd ${InputFolder} \
	-fmri $VolumefMRI \
	-o $WorkingDirectory \
	-fwhm $SmoothingFWHM \
	-res "$GrayordinatesResolution" \
	-finalres "2"



echo ""
echo "============================="
echo "   Create dense time series  "
echo "============================="
echo ""

echo "wb_command -cifti-create-dense-timeseries \
	"$WorkingDirectory"/"$VolumefMRIName"_s0.atlasroi."$LowResMesh"k_fs_LR.dtseries.nii \
	-volume ${WorkingDirectory}/"$VolumefMRIName"_AtlasSubcortical_s0.nii.gz \
	"$ROIFolder"/Atlas_ROIs."$GrayordinatesResolution".nii.gz \
	-left-metric ${WorkingDirectory}/"$VolumefMRIName"_s0.L.atlasroi."$LowResMesh"k_fs_LR.func.gii \
	-roi-left "$DownsampleFolder"/"$Subject".L.atlasroi."$LowResMesh"k_fs_LR.shape.gii \
	-right-metric ${WorkingDirectory}/"$VolumefMRIName"_s0.R.atlasroi."$LowResMesh"k_fs_LR.func.gii \
	-roi-right "$DownsampleFolder"/"$Subject".R.atlasroi."$LowResMesh"k_fs_LR.shape.gii \
	-timestep "$TR""

${CARET7DIR}/wb_command -cifti-create-dense-timeseries \
	"$WorkingDirectory"/"$VolumefMRIName"_s0.atlasroi."$LowResMesh"k_fs_LR.dtseries.nii \
	-volume ${WorkingDirectory}/"$VolumefMRIName"_AtlasSubcortical_s0.nii.gz \
	"$ROIFolder"/Atlas_ROIs."$GrayordinatesResolution".nii.gz \
	-left-metric ${WorkingDirectory}/"$VolumefMRIName"_s0.L.atlasroi."$LowResMesh"k_fs_LR.func.gii \
	-roi-left "$DownsampleFolder"/"$Subject".L.atlasroi."$LowResMesh"k_fs_LR.shape.gii \
	-right-metric ${WorkingDirectory}/"$VolumefMRIName"_s0.R.atlasroi."$LowResMesh"k_fs_LR.func.gii \
	-roi-right "$DownsampleFolder"/"$Subject".R.atlasroi."$LowResMesh"k_fs_LR.shape.gii \
	-timestep "$TR"

if [ ${SmoothingFWHM} != "0" ]; then

	echo "wb_command -cifti-create-dense-timeseries \
		"$WorkingDirectory"/"$VolumefMRIName"_s"$SmoothingFWHM".atlasroi."$LowResMesh"k_fs_LR.dtseries.nii \
		-volume ${WorkingDirectory}/"$VolumefMRIName"_AtlasSubcortical_s"$SmoothingFWHM".nii.gz \
		"$ROIFolder"/Atlas_ROIs."$GrayordinatesResolution".nii.gz \
		-left-metric ${WorkingDirectory}/"$VolumefMRIName"_s"$SmoothingFWHM".L.atlasroi."$LowResMesh"k_fs_LR.func.gii \
		-roi-left "$DownsampleFolder"/"$Subject".L.atlasroi."$LowResMesh"k_fs_LR.shape.gii \
		-right-metric ${WorkingDirectory}/"$VolumefMRIName"_s"$SmoothingFWHM".R.atlasroi."$LowResMesh"k_fs_LR.func.gii \
		-roi-right "$DownsampleFolder"/"$Subject".R.atlasroi."$LowResMesh"k_fs_LR.shape.gii \
		-timestep "$TR""

	${CARET7DIR}/wb_command -cifti-create-dense-timeseries \
		"$WorkingDirectory"/"$VolumefMRIName"_s"$SmoothingFWHM".atlasroi."$LowResMesh"k_fs_LR.dtseries.nii \
		-volume ${WorkingDirectory}/"$VolumefMRIName"_AtlasSubcortical_s"$SmoothingFWHM".nii.gz \
		"$ROIFolder"/Atlas_ROIs."$GrayordinatesResolution".nii.gz \
		-left-metric ${WorkingDirectory}/"$VolumefMRIName"_s"$SmoothingFWHM".L.atlasroi."$LowResMesh"k_fs_LR.func.gii \
		-roi-left "$DownsampleFolder"/"$Subject".L.atlasroi."$LowResMesh"k_fs_LR.shape.gii \
		-right-metric ${WorkingDirectory}/"$VolumefMRIName"_s"$SmoothingFWHM".R.atlasroi."$LowResMesh"k_fs_LR.func.gii \
		-roi-right "$DownsampleFolder"/"$Subject".R.atlasroi."$LowResMesh"k_fs_LR.shape.gii \
		-timestep "$TR"

fi


# Create dense time series
#${CARET7DIR}/wb_command -cifti-create-dense-timeseries "$OutputAtlasDenseTimeseries".dtseries.nii -volume "$NameOffMRI"_AtlasSubcortical_s"$SmoothingFWHM".nii.gz "$ROIFolder"/Atlas_ROIs."$GrayordinatesResolution".nii.gz -left-metric "$NameOffMRI"_s"$SmoothingFWHM".atlasroi.L."$LowResMesh"k_fs_LR.func.gii -roi-left "$DownsampleFolder"/"$Subject".L.atlasroi."$LowResMesh"k_fs_LR.shape.gii -right-metric "$NameOffMRI"_s"$SmoothingFWHM".atlasroi.R."$LowResMesh"k_fs_LR.func.gii -roi-right "$DownsampleFolder"/"$Subject".R.atlasroi."$LowResMesh"k_fs_LR.shape.gii -timestep "$TR_vol"

## Smoothing dense time series
#SmoothingFWHM="6"
#Sigma=`echo "$SmoothingFWHM / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
#${CARET7DIR}/wb_command -cifti-smoothing \
#	"$OutputAtlasDenseTimeseries".dtseries.nii \
#	${Sigma} ${Sigma} \
#	COLUMN \
#	"$OutputAtlasDenseTimeseries"_s${SmoothingFWHM}.dtseries.nii \
#	-left-surface "$DownsampleFolder"/"$Subject".L.midthickness."$LowResMesh"k_fs_LR.surf.gii \
#	-right-surface "$DownsampleFolder"/"$Subject".R.midthickness."$LowResMesh"k_fs_LR.surf.gii

echo " "
echo "END: FMRI_MNIVolumeToSurfaceMapping.sh"
echo " END: `date`"
echo " "

