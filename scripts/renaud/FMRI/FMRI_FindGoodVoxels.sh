#! /bin/bash
set -e

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: FMRI_FindGoodVoxels.sh  -fmri <file>  -ribbon <file>  -o <folder>  [-fwhm <value>  -factor <value>] "
	echo ""
	echo "  -fmri           : fmri input image "
	echo "  -ribbon         : ribbon image "
	echo "  -o              : output folder "
	echo " Options "
	echo "  -fwhm           : neighborhood smoothing value (Default: 5) "
	echo "  -factor         : low resolution of mesh (Default: 32) "
	echo ""
	echo "Usage: FMRI_FindGoodVoxels.sh  -fmri <file>  -ribbon <file>  -o <folder>  [-fwhm <value>  -factor <value>] "
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1

NeighborhoodSmoothing="5"
Factor="0.5"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_FindGoodVoxels.sh  -fmri <file>  -ribbon <file>  -o <folder>  [-fwhm <value>  -factor <value>] "
		echo ""
		echo "  -fmri           : fmri input image "
		echo "  -ribbon         : ribbon image "
		echo "  -o              : output folder "
		echo " Options "
		echo "  -fwhm           : neighborhood smoothing value (Default: 5) "
		echo "  -factor         : low resolution of mesh (Default: 32) "
		echo ""
		echo "Usage: FMRI_FindGoodVoxels.sh  -fmri <file>  -ribbon <file>  -o <folder>  [-fwhm <value>  -factor <value>] "
		echo ""
		exit 1
		;;
	-ribbon)
		index=$[$index+1]
		eval RibbonInput=\${$index}
		echo "RibbonInput : $RibbonInput"
		;;
	-fmri)
		index=$[$index+1]
		eval VolumefMRI=\${$index}
		echo "VolumefMRI : $VolumefMRI"
		;;
	-o)
		index=$[$index+1]
		eval WorkingDirectory=\${$index}
		echo "WorkingDirectory : $WorkingDirectory"
		;;
	-fwhm)
		index=$[$index+1]
		eval NeighborhoodSmoothing=\${$index}
		echo "NeighborhoodSmoothing : $NeighborhoodSmoothing"
		;;
	-factor)
		index=$[$index+1]
		eval Factor=\${$index}
		echo "Factor : $Factor"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_FindGoodVoxels.sh  -fmri <file>  -ribbon <file>  -o <folder>  [-fwhm <value>  -factor <value>] "
		echo ""
		echo "  -fmri           : fmri input image "
		echo "  -ribbon         : ribbon image "
		echo "  -o              : output folder "
		echo " Options "
		echo "  -fwhm           : neighborhood smoothing value (Default: 5) "
		echo "  -factor         : low resolution of mesh (Default: 32) "
		echo ""
		echo "Usage: FMRI_FindGoodVoxels.sh  -fmri <file>  -ribbon <file>  -o <folder>  [-fwhm <value>  -factor <value>] "
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
echo "START: FMRI_FindGoodVoxels.sh"
echo " START: `date`"
echo ""

if [ ! -d $WorkingDirectory ]; then mkdir -p $WorkingDirectory; fi


echo "====================="
echo "  Find good voxels"
echo "====================="

fslmaths "$VolumefMRI" -Tmean "$WorkingDirectory"/mean -odt float
fslmaths "$VolumefMRI" -Tstd "$WorkingDirectory"/std -odt float
fslmaths "$WorkingDirectory"/std -div "$WorkingDirectory"/mean "$WorkingDirectory"/cov

fslmaths "$WorkingDirectory"/cov -mas $RibbonInput "$WorkingDirectory"/cov_ribbon

fslmaths "$WorkingDirectory"/cov_ribbon -div `fslstats "$WorkingDirectory"/cov_ribbon -M` "$WorkingDirectory"/cov_ribbon_norm
fslmaths "$WorkingDirectory"/cov_ribbon_norm -bin -s $NeighborhoodSmoothing "$WorkingDirectory"/SmoothNorm
fslmaths "$WorkingDirectory"/cov_ribbon_norm -s $NeighborhoodSmoothing -div "$WorkingDirectory"/SmoothNorm -dilD "$WorkingDirectory"/cov_ribbon_norm_s$NeighborhoodSmoothing
fslmaths "$WorkingDirectory"/cov -div `fslstats "$WorkingDirectory"/cov_ribbon -M` -div "$WorkingDirectory"/cov_ribbon_norm_s$NeighborhoodSmoothing "$WorkingDirectory"/cov_norm_modulate
fslmaths "$WorkingDirectory"/cov_norm_modulate -mas $RibbonInput "$WorkingDirectory"/cov_norm_modulate_ribbon

STD=`fslstats "$WorkingDirectory"/cov_norm_modulate_ribbon -S`
echo $STD
MEAN=`fslstats "$WorkingDirectory"/cov_norm_modulate_ribbon -M`
echo $MEAN
Lower=`echo "$MEAN - ($STD * $Factor)" | bc -l`
echo $Lower
Upper=`echo "$MEAN + ($STD * $Factor)" | bc -l`
echo $Upper

#fslmaths "$WorkingDirectory"/mean -bin "$WorkingDirectory"/mask
bet "$WorkingDirectory"/mean "$WorkingDirectory"/mean -m -n -f 0.2
mv "$WorkingDirectory"/mean_mask.nii.gz "$WorkingDirectory"/mask.nii.gz
fslmaths "$WorkingDirectory"/cov_norm_modulate -thr $Upper -bin -sub "$WorkingDirectory"/mask -mul -1 "$WorkingDirectory"/goodvoxels


echo " "
echo "END: FMRI_FindGoodVoxels.sh"
echo " END: `date`"
echo ""

