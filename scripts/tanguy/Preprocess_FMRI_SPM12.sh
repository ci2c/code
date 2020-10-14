#! /bin/bash

if [ $# -lt 14 ]
then
	echo ""
	echo "Usage:  Preprocess_FMRI_SPM12.sh  -epi <file>  -anat <file>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value>"
	echo ""
	echo "  -epi                         : epi file "
	echo "  -anat                        : T1-weighted file "
	echo "  -fwhm                        : smoothing value "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo "	-rmframe                     : frame for removal "
	echo "  -o                           : Output directory "
	echo ""
	echo "Usage:  Preprocess_FMRI_SPM12.sh  -epi <file>  -anat <file>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value>"
	echo ""
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
		echo "Usage:  Preprocess_FMRI_SPM12.sh  -epi <file>  -anat <file>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value>"
		echo ""
		echo "  -epi                         : epi file "
		echo "  -anat                        : T1-weighted file "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo " 	-rmframe                     : frame for removal "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  Preprocess_FMRI_SPM12.sh  -epi <file>  -anat <file>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value>"
		echo ""
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
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  Preprocess_FMRI_SPM12.sh  -epi <file>  -anat <file>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value>"
		echo ""
		echo "  -epi                         : epi file "
		echo "  -anat                        : T1-weighted file "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo " 	-rmframe                     : frame for removal "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  Preprocess_FMRI_SPM12.sh  -epi <file>  -anat <file>  -fwhm <value>  -refslice <value>  -acquis <name>  -o <output_directory> -rmframe <value>"
		echo ""
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

# Calculating TR

echo ""
echo ""
echo "Calculating TR"
TR=$(mri_info ${epi} | grep TR | awk '{print $2}')
TR=$(echo "$TR/1000" | bc -l)
echo "TR = $TR s"


# Calculating N

echo ""
echo ""
echo "Calculating N"
N=$(mri_info ${epi} | grep dimensions | awk '{print $6}')
echo "N = $N slices"





# Create output directories 

echo ""
echo ""
echo "creating output directories"
if [ ! -d ${outdir}/spm ]
then
	mkdir ${outdir}/spm
else
	rm -Rf ${outdir}/spm/*
fi


# Separating images in time

echo ""
echo ""
echo "separating images in time"
echo "fslsplit ${epi} ${outdir}/spm/epi_ -t"
fslsplit ${epi} ${outdir}/spm/epi_ -t
gunzip ${outdir}/spm/*.gz





# Removal the first fMRI frames

echo ""
echo ""
echo "Removal the first fMRI frames"
for ((ind = 0; ind < ${remframe}; ind += 1))
do
	filename=`ls -1 ${outdir}/spm/ | sed -ne "1p"`
	rm -f ${outdir}/spm/${filename}
done



## Preprocessing with SPM

echo ""
echo ""
echo "Preprocessing with SPM"
echo ""
echo ""
echo "Matlab : "
echo ""
echo "FMRI_PreprocessingBySPM12('${epi}','epi_','${anat}',${TR},${N},${refslice},${fwhm},7,'epi2anat','${acquis}')"


/usr/local/matlab11/bin/matlab -nodisplay <<EOF
	
addpath('/home/global/matlab_toolbox/spm12b');


FMRI_PreprocessingBySPM8('${outdir}/spm','epi_','${anat}',${TR},${N},${refslice},${fwhm},4,'epi2anat','${acquis}')
 
EOF



