#!/bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: getJacobianStats.sh -grid <displacement_grid_0.mnc> -fwhm <FWHM>  -md <mask_directory> -outdir <outdir>"
	echo ""
	echo "  -grid <displacement_grid_0.mnc>  : displacement grid as provided by minctracc"
	echo "  -fwhm <FWHM>                     : FWHM used for blurring"
	echo "  -outdir <outdir>                 : output directory"
	echo "  -md <mask_directory>             : mask directory"
	echo ""
	echo "Usage: getJacobianStats.sh -grid <displacement_grid_0.mnc> -fwhm <FWHM>  -md <mask_directory> -outdir <outdir>"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: getJacobianStats.sh -grid <displacement_grid_0.mnc> -fwhm <FWHM>  -md <mask_directory> -outdir <outdir>"
		echo ""
		echo "  -grid <displacement_grid_0.mnc>  : displacement grid as provided by minctracc"
		echo "  -fwhm <FWHM>                     : FWHM used for blurring"
		echo "  -outdir <outdir>                 : output directory"
		echo "  -md <mask_directory>             : mask directory"
		echo ""
		echo "Usage: getJacobianStats.sh -grid <displacement_grid_0.mnc> -fwhm <FWHM>  -md <mask_directory> -outdir <outdir>"
		exit 1
		;;
	-grid)
		grid=`expr $index + 1`
		eval grid=\${$grid}
		echo "  |-------> Grid : $grid"
		index=$[$index+1]
		;;
	-fwhm)
		fwhm=`expr $index + 1`
		eval fwhm=\${$fwhm}
		echo "  |-------> FWHM : ${fwhm}"
		index=$[$index+1]
		;;
	-md)
		md=`expr $index + 1`
		eval md=\${$md}
		echo "  |-------> Mask directory : ${md}"
		index=$[$index+1]
		;;
	-outdir)
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo "  |-------> Output directory : ${outdir}"
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


# Creates output dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

# Get determinant
echo " "
echo "-------------------------------------------------------------------------"
echo "mincblob -determinant ${grid} ${outdir}/determinant.mnc -clobber"
mincblob -determinant ${grid} ${outdir}/determinant.mnc -clobber

echo "mincblur -fwhm ${fwhm} ${outdir}/determinant.mnc ${outdir}/determinant_${fwhm} -clobber"
mincblur -fwhm ${fwhm} ${outdir}/determinant.mnc ${outdir}/determinant_${fwhm} -clobber

echo "mincmath ${outdir}/determinant_${fwhm}_blur.mnc -mult -const -1 ${outdir}/determinant_${fwhm}_blur_minus.mnc"
mincmath ${outdir}/determinant_${fwhm}_blur.mnc -mult -const -1 ${outdir}/determinant_${fwhm}_blur_minus.mnc

# Close the masks
for Mask in `ls ${md}`
do
	echo "------------------------------------"
	echo "Closing ${md}/${Mask}"
	nii2mnc ${md}/${Mask}
	
	mincmask=${md}/${Mask%.nii}.mnc
	
	echo "mincmorph -successive DD ${mincmask} ${outdir}/${Mask%.nii}_dilated.mnc -clobber"
	mincmorph -successive DD ${mincmask} ${outdir}/${Mask%.nii}_dilated.mnc -clobber
	
	echo "mincmorph -successive EE ${mincmask} ${outdir}/${Mask%.nii}_eroded.mnc -clobber"
	mincmorph -successive EE ${mincmask} ${outdir}/${Mask%.nii}_eroded.mnc -clobber
	
	echo "mincmath ${outdir}/${Mask%.nii}_dilated.mnc -sub ${outdir}/${Mask%.nii}_eroded.mnc ${outdir}/${Mask%.nii}_border.mnc -clobber"
	mincmath ${outdir}/${Mask%.nii}_dilated.mnc -sub ${outdir}/${Mask%.nii}_eroded.mnc ${outdir}/${Mask%.nii}_border.mnc -clobber
	
	echo "mincresample -like ${outdir}/determinant_${fwhm}_blur.mnc ${outdir}/${Mask%.nii}_border.mnc ${outdir}/${Mask%.nii}_border_to_grid.mnc -clobber"
	mincresample -like ${outdir}/determinant_${fwhm}_blur.mnc ${outdir}/${Mask%.nii}_border.mnc ${outdir}/${Mask%.nii}_border_to_grid.mnc -clobber
	
	echo "mincmorph -successive DDEE ${mincmask} ${outdir}/${Mask%.nii}_close.mnc -clobber"
	mincmorph -successive DDEE ${mincmask} ${outdir}/${Mask%.nii}_close.mnc -clobber
	
	echo "mincresample -like ${outdir}/determinant_${fwhm}_blur.mnc ${outdir}/${Mask%.nii}_close.mnc ${outdir}/${Mask%.nii}_close_to_grid.mnc -clobber"
	mincresample -like ${outdir}/determinant_${fwhm}_blur.mnc ${outdir}/${Mask%.nii}_close.mnc ${outdir}/${Mask%.nii}_close_to_grid.mnc -clobber
	
	echo "mincstats ${outdir}/determinant_${fwhm}_blur.mnc -mask ${outdir}/${Mask%.nii}_close_to_grid.mnc -histogram ${outdir}/${Mask%.nii}_histogram.txt"
	mincstats ${outdir}/determinant_${fwhm}_blur.mnc -mask ${outdir}/${Mask%.nii}_close_to_grid.mnc -histogram ${outdir}/${Mask%.nii}_histogram.txt
	
	echo "mincstats ${outdir}/determinant_${fwhm}_blur.mnc -mask ${outdir}/${Mask%.nii}_border_to_grid.mnc -histogram ${outdir}/${Mask%.nii}_histogram_border.txt"
	mincstats ${outdir}/determinant_${fwhm}_blur.mnc -mask ${outdir}/${Mask%.nii}_border_to_grid.mnc -histogram ${outdir}/${Mask%.nii}_histogram_border.txt
done







