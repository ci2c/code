#! /bin/bash

if [ $# -lt 18 ]
then
	echo ""
	echo "Usage:  NRJ_PreprocessingSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -acquis <name>  -coreg <name>  -resampling <value>  -Nses <value>"
	echo ""
	echo "  -epi                         : Path to epi data "
	echo "  -anat                        : Path to structural file "
	echo "  -TR                          : TR value "
	echo "  -N                           : Number of slices "
	echo "  -fwhm                        : smoothing value "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo "  -coreg                       : 'epi2anat' = registration epi to anat ; 'anat2epi' = registration anat to epi "
	echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
	echo "  -Nses                        : Number of sessions "
	echo ""
	echo "Usage:  NRJ_PreprocessingSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -acquis <name>  -coreg <name>  -resampling <value>  -Nses <value>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Jan 23, 2012"
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
		echo "Usage:  NRJ_PreprocessingSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -acquis <name>  -coreg <name>  -resampling <value>  -Nses <value>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural file "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -fwhm                        : smoothing value "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -coreg                       : 'epi2anat' = registration epi to anat ; 'anat2epi' = registration anat to epi "
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo "  -Nses                        : Number of sessions "
		echo ""
		echo "Usage:  NRJ_PreprocessingSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -acquis <name>  -coreg <name>  -resampling <value>  -Nses <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 23, 2012"
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
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-N)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of slices : ${N}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "fwhm : ${fwhm}"
		;;
	-acquis)
		index=$[$index+1]
		eval acquis=\${$index}
		echo "acquisition : ${acquis}"
		;;
	-coreg)
		index=$[$index+1]
		eval coreg=\${$index}
		echo "coreg : ${coreg}"
		;;
	-resampling)
		index=$[$index+1]
		eval resamp=\${$index}
		echo "resampling : ${resamp}"
		;;
	-Nses)
		index=$[$index+1]
		eval nses=\${$index}
		echo "number of sessions : ${nses}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  NRJ_PreprocessingSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -acquis <name>  -coreg <name>  -resampling <value>  -Nses <value>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural file "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -fwhm                        : smoothing value "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -coreg                       : 'epi2anat' = registration epi to anat ; 'anat2epi' = registration anat to epi "
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo "  -Nses                        : Number of sessions "
		echo ""
		echo "Usage:  NRJ_PreprocessingSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -acquis <name>  -coreg <name>  -resampling <value>  -Nses <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 23, 2012"
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

if [ -z ${TR} ]
then
	 echo "-TR argument mandatory"
	 exit 1
fi

if [ -z ${N} ]
then
	 echo "-N argument mandatory"
	 exit 1
fi

if [ -z ${fwhm} ]
then
	 echo "-fwhm argument mandatory"
	 exit 1
fi

if [ -z ${acquis} ]
then
	 echo "-acquis argument mandatory"
	 exit 1
fi

if [ -z ${coreg} ]
then
	 echo "-coreg argument mandatory"
	 exit 1
fi

if [ -z ${resamp} ]
then
	 echo "-resampling argument mandatory"
	 exit 1
fi

if [ -z ${nses} ]
then
	 echo "-Nses argument mandatory"
	 exit 1
fi

echo "cp ${anat} ${epi}/t1.nii"
cp ${anat} ${epi}/t1.nii

echo "NRJ_PreprocessSPM8('${epi}','${epi}/t1.nii',${nses},${TR},${N},${fwhm},'${coreg}','${acquis}',${resamp})"

## Preprocessing with SPM

matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

NRJ_PreprocessSPM8('${epi}','${epi}/t1.nii',${nses},${TR},${N},${fwhm},'${coreg}','${acquis}',${resamp});
 
EOF
