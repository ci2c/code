#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage:  FMRI_EmotionsPreprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value> -o <output_directory> -rmframe <value> -voxsize <value>"
	echo ""
	echo "  -epi                         : Path to epi data "
	echo "  -anat                        : Path to structural data "
	echo "  -fwhm                        : smoothing value "
	echo " 	-rmframe                     : frame for removal "
	echo "  -voxsize                     : Interpolation voxel size "
	echo "  -o                           : Output directory "
	echo ""
	echo "Usage:  FMRI_EmotionsPreprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value> -o <output_directory> -rmframe <value> -voxsize <value>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Jan 24, 2014"
	echo ""
	exit 1
fi

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  FMRI_EmotionsPreprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value> -o <output_directory> -rmframe <value> -voxsize <value>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -fwhm                        : smoothing value "
		echo " 	-rmframe                     : frame for removal "
		echo "  -voxsize                     : Interpolation voxel size "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  FMRI_EmotionsPreprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value> -o <output_directory> -rmframe <value> -voxsize <value>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Jan 24, 2014"
		echo ""
		exit 1
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "epi data : ${epi}"
		;;
	-anat)
		index=$[$index+1]
		eval anat=\${$index}
		echo "anat data : ${anat}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "fwhm : ${fwhm}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-voxsize)
		index=$[$index+1]
		eval voxelsize=\${$index}
		echo "interpolation voxel size : ${voxelsize}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_EmotionsPreprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value> -o <output_directory> -rmframe <value> -voxsize <value>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -fwhm                        : smoothing value "
		echo " 	-rmframe                     : frame for removal "
		echo "  -voxsize                     : Interpolation voxel size "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  FMRI_EmotionsPreprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value> -o <output_directory> -rmframe <value> -voxsize <value>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Jan 24, 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${epi} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${anat} ]
then
	 echo "-anat argument mandatory"
	 exit 1
fi

if [ -z ${fwhm} ]
then
	 echo "-fwhm argument mandatory"
	 exit 1
fi

if [ -z ${voxelsize} ]
then
	 echo "-voxsize argument mandatory"
	 exit 1
fi

if [ -z ${remframe} ]
then
	 echo "-rmframe argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

## Rename input fMRI
mv  ${epi}/IMA/*.nii ${epi}/IMA/run1.nii

## Calculate TR and N
# TR=$(mri_info ${epi}/IMA/run1.nii | grep TR | awk '{print $2}')
# TR=$(echo "$TR/1000" | bc -l)
# N=$(mri_info ${epi}/IMA/run1.nii | grep dimensions | awk '{print $6}')

## Create output directories and copy source files
if [ ! -d ${outdir}/spm ]
then
	mkdir -p ${outdir}/spm
else
	rm -rf ${outdir}/spm/*
fi

if [ ! -d ${outdir}/spm/RawEPI ]
then
	mkdir ${outdir}/spm/RawEPI
fi

if [ ! -d ${outdir}/spm/Structural ]
then
	mkdir ${outdir}/spm/Structural
fi

if [ ! -f ${outdir}/spm/RawEPI/epi_0000.nii ]
then
	fslsplit ${epi}/IMA/run1.nii ${outdir}/spm/RawEPI/epi_ -t
fi

if [ ! -f ${outdir}/Structural/orig.nii ]
then
	cp ${anat}/3DT1/*3DT1*.nii ${outdir}/spm/Structural/orig.nii
fi

## Removal the first fMRI frames
for ((ind = 1; ind <= ${remframe}; ind += 1))
do
	filename=`ls -1 ${outdir}/spm/RawEPI | sed -ne "1p"`
	rm -f ${outdir}/spm/RawEPI/${filename}
done
gunzip ${outdir}/spm/RawEPI/epi_*

## Preprocessing with SPM
if [[ !( -f ${outdir}/spm/RawEPI/swrepi_0002.nii) ]]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	FMRI_EmotionsPreprocess_SPM12('${outdir}',${fwhm},${voxelsize});
 
EOF

else
	echo "Already done"
fi