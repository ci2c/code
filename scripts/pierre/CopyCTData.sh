#!/bin/bash

if [ $# -lt 3 ]
then
	echo "Usage: CopyCTData.sh FSdir outdir outprefix"
	echo ""
	echo "  FSDir       : FreeSurfer directory"
	echo "  outdir      : output directory"
	echo "  outprefix   : output prefix"
	echo " "
	echo "For all CASE in FSdir copy"
	echo "FSdir/CASE/surf/?h.thickness.fwhm20.fsaverage.mgh -> outdir/outprefix.CASE.?h.thickness.fwhm20.fsaverage.mgh"
	exit 1
fi

fsdir=$1
outdir=$2
prefix=$3

for I in `ls ${fsdir}`
do
	if [ -f ${fsdir}/${I}/surf/lh.thickness.fwhm20.fsaverage.mgh ]
	then
		cp ${fsdir}/${I}/surf/lh.thickness.fwhm20.fsaverage.mgh ${outdir}/${prefix}.${I}.lh.thickness.fwhm20.fsaverage.mgh
		cp ${fsdir}/${I}/surf/rh.thickness.fwhm20.fsaverage.mgh ${outdir}/${prefix}.${I}.rh.thickness.fwhm20.fsaverage.mgh
	fi
done
