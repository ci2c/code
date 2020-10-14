#! /bin/bash
set -e

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: FMRI_T1VolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -mask <file>  -o <folder>  "
	echo ""
	echo "  -subj           : subject's name "
	echo "  -i              : input folder (path to T1w) "
	echo "  -fmri           : fmri input image "
	echo "  -mask           : mask image ('goodvoxels') "
	echo "  -o              : output folder "
	echo ""
	echo "Usage: FMRI_T1VolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -mask <file>  -o <folder>  "
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1

RegName="FS"
LowResMesh="32"

# Example:
# -subj T01S01
# -i /NAS/tupac/protocoles/healthy_volunteers/process/T01S01/T1w
# -o /NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/surface
# -fmri /NAS/tupac/protocoles/healthy_volunteers/process/T01S01/fmri/fmri_rf_st_T1


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_T1VolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -mask <file>  -o <folder>  "
		echo ""
		echo "  -subj           : subject's name "
		echo "  -i              : input folder (path to T1w) "
		echo "  -fmri           : fmri input image "
		echo "  -mask           : mask image ('goodvoxels') "
		echo "  -o              : output folder "
		echo ""
		echo "Usage: FMRI_T1VolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -mask <file>  -o <folder>  "
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
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_T1VolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -mask <file>  -o <folder>  "
		echo ""
		echo "  -subj           : subject's name "
		echo "  -i              : input folder (path to T1w) "
		echo "  -fmri           : fmri input image "
		echo "  -mask           : mask image ('goodvoxels') "
		echo "  -o              : output folder "
		echo ""
		echo "Usage: FMRI_T1VolumeToSurfaceMapping.sh  -subj <name>  -i <folder>  -fmri <file>  -mask <file>  -o <folder>  "
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


AtlasSpaceNativeFolder=${InputFolder}/Native

if [ ! -d ${AtlasSpaceNativeFolder} ]; then 
	echo "no ${AtlasSpaceNativeFolder} folder"
	exit 1
fi

if [ ! -d ${WorkingDirectory} ]; then mkdir -p ${WorkingDirectory}; fi

echo " "
echo "START: FMRI_T1VolumeToSurfaceMapping.sh"
echo " START: `date`"
echo ""

# --------------------------------------------------------------------------------
#                                    PROCESS
# --------------------------------------------------------------------------------


VolumefMRIName=`basename ${VolumefMRI}`

echo "====================="
echo "   Surface mapping"
echo "====================="

for Hemisphere in L R ; do

	echo "Hemisphere : ${Hemisphere}H"
 
	if [ -f "$WorkingDirectory"/mean.nii.gz ]; then
		echo "mapping mean and cov"
		for Map in mean cov ; do
			${CARET7DIR}/wb_command -volume-to-surface-mapping "$WorkingDirectory"/"$Map".nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii -ribbon-constrained "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii -volume-roi ${GoodVoxels}.nii.gz
			${CARET7DIR}/wb_command -metric-dilate "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii 10 "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii -nearest
#			${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii
			${CARET7DIR}/wb_command -volume-to-surface-mapping "$WorkingDirectory"/"$Map".nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$WorkingDirectory"/"$Hemisphere"."$Map"_all.native.func.gii -ribbon-constrained "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii
#			${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere"."$Map"_all.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii "$WorkingDirectory"/"$Hemisphere"."$Map"_all.native.func.gii
		done
	fi

	echo "mapping goodvoxels"
	${CARET7DIR}/wb_command -volume-to-surface-mapping ${GoodVoxels}.nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$WorkingDirectory"/"$Hemisphere".goodvoxels.native.func.gii -ribbon-constrained "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii
#	${CARET7DIR}/wb_command -metric-mask "$WorkingDirectory"/"$Hemisphere".goodvoxels.native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii "$WorkingDirectory"/"$Hemisphere".goodvoxels.native.func.gii

	echo "mapping fMRI"
	${CARET7DIR}/wb_command -volume-to-surface-mapping "$VolumefMRI".nii.gz "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii -ribbon-constrained "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii -volume-roi ${GoodVoxels}.nii.gz
	${CARET7DIR}/wb_command -metric-dilate "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".midthickness.native.surf.gii 10 "$VolumefMRI"."$Hemisphere".native.func.gii -nearest
#	${CARET7DIR}/wb_command -metric-mask  "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii  "$WorkingDirectory"/"$VolumefMRIName"."$Hemisphere".native.func.gii

done


echo " "
echo "END: FMRI_T1VolumeToSurfaceMapping.sh"
echo " END: `date`"
echo ""

