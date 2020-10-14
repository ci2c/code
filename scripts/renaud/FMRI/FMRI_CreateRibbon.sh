#! /bin/bash
set -e

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_CreateRibbon.sh  -subj <name>  -i <folder>  -scout <GE epi>  -o <folder>  "
	echo ""
	echo "  -subj           : subject's name "
	echo "  -i              : input folder (path to MNINonLinear or T1w) "
	echo "  -scout          : scout input image "
	echo "  -o              : output folder "
	echo ""
	echo "Usage: FMRI_CreateRibbon.sh  -subj <name>  -i <folder>  -scout <GE epi>  -o <folder> "
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1

LeftGreyRibbonValue="1"
RightGreyRibbonValue="1"


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_CreateRibbon.sh  -subj <name>  -i <folder>  -scout <GE epi>  -o <folder>  "
		echo ""
		echo "  -subj           : subject's name "
		echo "  -i              : input folder (path to MNINonLinear or T1w) "
		echo "  -scout          : scout input image "
		echo "  -o              : output folder "
		echo ""
		echo "Usage: FMRI_CreateRibbon.sh  -subj <name>  -i <folder>  -scout <GE epi>  -o <folder> "
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
	-scout)
		index=$[$index+1]
		eval ScoutInput=\${$index}
		echo "ScoutInput : $ScoutInput"
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
		echo "Usage: FMRI_CreateRibbon.sh  -subj <name>  -i <folder>  -scout <GE epi>  -o <folder>  "
		echo ""
		echo "  -subj           : subject's name "
		echo "  -i              : input folder (path to MNINonLinear or T1w) "
		echo "  -scout          : scout input image "
		echo "  -o              : output folder "
		echo ""
		echo "Usage: FMRI_CreateRibbon.sh  -subj <name>  -i <folder>  -scout <GE epi>  -o <folder> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# --------------------------------------------------------------------------------
#                           Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions


# --------------------------------------------------------------------------------
#                                   Process
# --------------------------------------------------------------------------------

echo " "
echo "START: FMRI_CreateRibbon.sh"
echo " START: `date`"
echo ""

AtlasSpaceNativeFolder=${InputFolder}/Native

if [ ! -d ${AtlasSpaceNativeFolder} ]; then 
	echo "no ${AtlasSpaceNativeFolder} folder"
	exit 1
fi


if [ ! -d $WorkingDirectory ]; then mkdir -p $WorkingDirectory; fi


echo "====================="
echo "   Create ribbon"
echo "====================="

for Hemisphere in L R ; do

	echo "Hemisphere : ${Hemisphere}H"

	if [ $Hemisphere = "L" ] ; then
		GreyRibbonValue="$LeftGreyRibbonValue"
	elif [ $Hemisphere = "R" ] ; then
		GreyRibbonValue="$RightGreyRibbonValue"
	fi    
	${CARET7DIR}/wb_command -create-signed-distance-volume "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".white.native.surf.gii ${ScoutInput}.nii.gz "$WorkingDirectory"/"$Subject"."$Hemisphere".white.native.nii.gz
	${CARET7DIR}/wb_command -create-signed-distance-volume "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".pial.native.surf.gii ${ScoutInput}.nii.gz "$WorkingDirectory"/"$Subject"."$Hemisphere".pial.native.nii.gz
	fslmaths "$WorkingDirectory"/"$Subject"."$Hemisphere".white.native.nii.gz -thr 0 -bin -mul 255 "$WorkingDirectory"/"$Subject"."$Hemisphere".white_thr0.native.nii.gz
	fslmaths "$WorkingDirectory"/"$Subject"."$Hemisphere".white_thr0.native.nii.gz -bin "$WorkingDirectory"/"$Subject"."$Hemisphere".white_thr0.native.nii.gz
	fslmaths "$WorkingDirectory"/"$Subject"."$Hemisphere".pial.native.nii.gz -uthr 0 -abs -bin -mul 255 "$WorkingDirectory"/"$Subject"."$Hemisphere".pial_uthr0.native.nii.gz
	fslmaths "$WorkingDirectory"/"$Subject"."$Hemisphere".pial_uthr0.native.nii.gz -bin "$WorkingDirectory"/"$Subject"."$Hemisphere".pial_uthr0.native.nii.gz
	fslmaths "$WorkingDirectory"/"$Subject"."$Hemisphere".pial_uthr0.native.nii.gz -mas "$WorkingDirectory"/"$Subject"."$Hemisphere".white_thr0.native.nii.gz -mul 255 "$WorkingDirectory"/"$Subject"."$Hemisphere".ribbon.nii.gz
	fslmaths "$WorkingDirectory"/"$Subject"."$Hemisphere".ribbon.nii.gz -bin -mul $GreyRibbonValue "$WorkingDirectory"/"$Subject"."$Hemisphere".ribbon.nii.gz
	rm "$WorkingDirectory"/"$Subject"."$Hemisphere".white.native.nii.gz "$WorkingDirectory"/"$Subject"."$Hemisphere".white_thr0.native.nii.gz "$WorkingDirectory"/"$Subject"."$Hemisphere".pial.native.nii.gz "$WorkingDirectory"/"$Subject"."$Hemisphere".pial_uthr0.native.nii.gz

done

fslmaths "$WorkingDirectory"/"$Subject".L.ribbon.nii.gz -add "$WorkingDirectory"/"$Subject".R.ribbon.nii.gz "$WorkingDirectory"/ribbon_only.nii.gz
rm "$WorkingDirectory"/"$Subject".L.ribbon.nii.gz "$WorkingDirectory"/"$Subject".R.ribbon.nii.gz

echo ""


echo " "
echo "END: FMRI_CreateRibbon.sh"
echo " END: `date`"
echo ""

