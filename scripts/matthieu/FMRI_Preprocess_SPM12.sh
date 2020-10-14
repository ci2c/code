#! /bin/bash

if [ $# -lt 16 ]
then
	echo ""
	echo "Usage:  FMRI_Preprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value> -voxsize <value>"
	echo ""
	echo "  -epi                         : Path to epi data "
	echo "  -anat                        : Path to structural data "
	echo "  -fwhm                        : smoothing value "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo " 	-rmframe                     : frame for removal "
	echo "  -voxsize                     : Interpolation voxel size "
	echo "  -o                           : Output directory "
	echo ""
	echo "Usage:  FMRI_Preprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value> -voxsize <value>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 22, 2013"
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
		echo "Usage:  FMRI_Preprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value> -voxsize <value>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo " 	-rmframe                     : frame for removal "
		echo "  -voxsize                     : Interpolation voxel size "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  FMRI_Preprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value> -voxsize <value>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 22, 2013"
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
	-refslice)
		index=$[$index+1]
		eval refslice=\${$index}
		echo "slice of reference : ${refslice}"
		;;
	-acquis)
		index=$[$index+1]
		eval acquis=\${$index}
		echo "acquisition : ${acquis}"
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
		echo "Usage:  FMRI_Preprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value> -voxsize <value>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo " 	-rmframe                     : frame for removal "
		echo "  -voxsize                     : Interpolation voxel size "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  FMRI_Preprocess_SPM12.sh  -epi <epi_path>  -anat <anat_path>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value> -voxsize <value>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 22, 2013"
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

if [ -z ${refslice} ]
then
	 echo "-refslice argument mandatory"
	 exit 1
fi

if [ -z ${acquis} ]
then
	 echo "-acquis argument mandatory"
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

## Calculate TR and N
TR=$(mri_info ${epi}/run1.nii | grep TR | awk '{print $2}')
TR=$(echo "$TR/1000" | bc -l)
N=$(mri_info ${epi}/run1.nii | grep dimensions | awk '{print $6}')

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
	mkdir ${outdir}/spm/RawEPI/run1
	mkdir ${outdir}/spm/RawEPI/run2
fi

if [ ! -d ${outdir}/spm/Structural ]
then
	mkdir ${outdir}/spm/Structural
fi

if [ ! -f ${outdir}/spm/RawEPI/run1/epi_0000.nii ]
then
	fslsplit ${epi}/run1.nii ${outdir}/spm/RawEPI/run1/epi_ -t
fi

if [ ! -f ${outdir}/spm/RawEPI/run2/epi_0000.nii ]
then
	fslsplit ${epi}/run2.nii ${outdir}/spm/RawEPI/run2/epi_ -t
fi

if [ ! -f ${outdir}/Structural/orig.nii ]
then
	mri_convert ${anat}/mri/orig.mgz ${outdir}/spm/Structural/orig.nii
fi

## Removal the first fMRI frames
for ((ind = 1; ind <= ${remframe}; ind += 1))
do
	filename1=`ls -1 ${outdir}/spm/RawEPI/run1 | sed -ne "1p"`
	filename2=`ls -1 ${outdir}/spm/RawEPI/run2 | sed -ne "1p"`
	rm -f ${outdir}/spm/RawEPI/run1/${filename1}
	rm -f ${outdir}/spm/RawEPI/run2/${filename2}
done
gunzip ${outdir}/spm/RawEPI/run1/epi_*
gunzip ${outdir}/spm/RawEPI/run2/epi_*


## Preprocessing with SPM
if [[ !( -f ${outdir}/spm/RawEPI/run1/swarepi_0005.nii || -f ${outdir}/spm/RawEPI/run1/swraepi_0005.nii) || !( -f ${outdir}/spm/RawEPI/run2/swarepi_0005.nii || -f ${outdir}/spm/RawEPI/run2/swraepi_0005.nii) ]]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

FMRI_Preprocess_SPM12('${outdir}',${TR},${N},${refslice},${fwhm},'${acquis}',${voxelsize});
 
EOF

else
echo "Already done"
fi


## Postprocessing
# if [[ ${acquis} == ascending && ${resamp} == 0 ]]
# then
# 	echo ""
# 	echo "fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/sarepi_*"
# 	fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/sarepi_*
# 
# 	echo ""
# 	echo "Make sure TR is correct"
# 	echo "3drefit -TR ${TR}s ${outdir}/epi_pre_al_${fwhm}.nii.gz"
# 	3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz
# 
# 	echo ""
# 	echo "Move data"
# 	echo "cp ${outdir}/RawEPI/meanepi_0000.nii ${outdir}/meanepi.nii "
# 	cp ${outdir}/RawEPI/meanepi_0000.nii ${outdir}/meanepi.nii
# 	echo "cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt "
# 	cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt
# 	echo "cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii"
# 	cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii
# elif [[ ${acquis} == interleaved && ${resamp} == 0 ]]
# then
# 	echo ""
# 	echo "fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/sraepi_*"
# 	fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/sraepi_*
# 
# 	echo ""
# 	cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii
# 	echo "Make sure TR is correct"
# 	echo "3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz"
# 	3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz
# 
# 	echo ""
# 	echo "Move data"
# 	echo "cp ${outdir}/RawEPI/meanaepi_0000.nii ${outdir}/meanepi.nii "
# 	cp ${outdir}/RawEPI/meanaepi_0000.nii ${outdir}/meanepi.nii
# 	echo "cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt "
# 	cp ${outdir}/RawEPI/rp_aepi_0000.txt ${outdir}/motion_values.txt
# 	echo "cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii"
# elif [[ ${acquis} == ascending && ${resamp} == 1 ]]
# then
# 	echo ""
# 	echo "fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/srarepi_*"
# 	fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/srarepi_*
# 
# 	echo ""
# 	echo "Make sure TR is correct"
# 	echo "3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz"
# 	3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz
# 
# 	echo ""
# 	echo "Move data"
# 	echo "cp ${outdir}/RawEPI/rmeanepi_0000.nii ${outdir}/meanepi.nii "
# 	cp ${outdir}/RawEPI/rmeanepi_0000.nii ${outdir}/meanepi.nii
# 	echo "cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt "
# 	cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt
# 	echo "cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii"
# 	cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii
# elif [[ ${acquis} == interleaved && ${resamp} == 1 ]]
# then
# 	echo ""
# 	echo "fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/srraepi_*"
# 	fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/srraepi_*
# 
# 	echo ""
# 	echo "Make sure TR is correct"
# 	echo "3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz"
# 	3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz
# 
# 	echo ""
# 	echo "Move data"
# 	echo "cp ${outdir}/RawEPI/rameanepi_0000.nii ${outdir}/meanepi.nii "
# 	cp ${outdir}/RawEPI/rameanepi_0000.nii ${outdir}/meanepi.nii
# 	echo "cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt "
# 	cp ${outdir}/RawEPI/rp_aepi_0000.txt ${outdir}/motion_values.txt
# 	echo "cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii"
# 	cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii
# fi
# 
# echo "gunzip ${outdir}/epi_pre_al.nii.gz"
# gunzip ${outdir}/epi_pre_al.nii.gz
