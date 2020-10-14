#! /bin/bash

if [ $# -lt 20 ]
then
	echo ""
	echo "Usage:  FMRI_PreprocessSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
	echo ""
	echo "  -epi                         : Path to epi data "
	echo "  -anat                        : Path to structural data "
	echo "  -TR                          : TR value "
	echo "  -N                           : Number of slices "
	echo "  -fwhm                        : smoothing value "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo "  -coreg                       : 'epi2anat' = registration epi to anat ; 'anat2epi' = registration anat to epi "
	echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
	echo "  -o                           : Output directory "
	echo ""
	echo "Usage:  FMRI_PreprocessSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
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
		echo "Usage:  FMRI_PreprocessSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -coreg                       : 'epi2anat' = registration epi to anat ; 'anat2epi' = registration anat to epi "
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  FMRI_PreprocessSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
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
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_PreprocessSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -coreg                       : 'epi2anat' = registration epi to anat ; 'anat2epi' = registration anat to epi "
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  FMRI_PreprocessSPM8.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
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

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

## Creates out dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

if [ ! -d "${outdir}"/RawEPI ]
then
	mkdir "${outdir}"/RawEPI
fi

if [ ! -d "${outdir}"/Structural ]
then
	mkdir "${outdir}"/Structural
fi

if [ ! -f "${outdir}"/RawEPI/epi_0000.nii ]
then
	fslsplit ${epi} "${outdir}"/RawEPI/epi_ -t
	gunzip "${outdir}"/RawEPI/epi_*
fi

if [ ! -f "${outdir}"/Structural/brain.nii ]
then
	cp ${anat} "${outdir}"/Structural/brain.nii
fi

echo "FMRIPreprocessSPM('${outdir}',${TR},${N},${refslice},${fwhm},'${coreg}','${acquis}')"
echo "${coreg} / ${acquis}"

## Preprocessing with SPM
echo "FMRI_PreprocessSPM8('${outdir}',${TR},${N},${refslice},${fwhm},'${coreg}','${acquis}',${resamp});"
if [[ !( -f "${outdir}"/RawEPI/sarepi_0000.nii || -f "${outdir}"/RawEPI/sraepi_0000.nii) ]]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

FMRI_PreprocessSPM8('${outdir}',${TR},${N},${refslice},${fwhm},'${coreg}','${acquis}',${resamp});
 
EOF
else
echo "Already done"
fi


## Postprocessing
if [[ ${acquis} == ascending && ${resamp} == 0 ]]
then
	echo ""
	echo "fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/sarepi_*"
	fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/sarepi_*

	echo ""
	echo "Make sure TR is correct"
	echo "3drefit -TR ${TR}s ${outdir}/epi_pre_al_${fwhm}.nii.gz"
	3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz

	echo ""
	echo "Move data"
	echo "cp ${outdir}/RawEPI/meanepi_0000.nii ${outdir}/meanepi.nii "
	cp ${outdir}/RawEPI/meanepi_0000.nii ${outdir}/meanepi.nii
	echo "cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt "
	cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt
	echo "cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii"
	cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii
elif [[ ${acquis} == interleaved && ${resamp} == 0 ]]
then
	echo ""
	echo "fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/sraepi_*"
	fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/sraepi_*

	echo ""
	cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii
	echo "Make sure TR is correct"
	echo "3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz"
	3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz

	echo ""
	echo "Move data"
	echo "cp ${outdir}/RawEPI/meanaepi_0000.nii ${outdir}/meanepi.nii "
	cp ${outdir}/RawEPI/meanaepi_0000.nii ${outdir}/meanepi.nii
	echo "cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt "
	cp ${outdir}/RawEPI/rp_aepi_0000.txt ${outdir}/motion_values.txt
	echo "cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii"
elif [[ ${acquis} == ascending && ${resamp} == 1 ]]
then
	echo ""
	echo "fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/srarepi_*"
	fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/srarepi_*

	echo ""
	echo "Make sure TR is correct"
	echo "3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz"
	3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz

	echo ""
	echo "Move data"
	echo "cp ${outdir}/RawEPI/rmeanepi_0000.nii ${outdir}/meanepi.nii "
	cp ${outdir}/RawEPI/rmeanepi_0000.nii ${outdir}/meanepi.nii
	echo "cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt "
	cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt
	echo "cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii"
	cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii
elif [[ ${acquis} == interleaved && ${resamp} == 1 ]]
then
	echo ""
	echo "fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/srraepi_*"
	fslmerge -t ${outdir}/epi_pre_al.nii ${outdir}/RawEPI/srraepi_*

	echo ""
	echo "Make sure TR is correct"
	echo "3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz"
	3drefit -TR ${TR}s ${outdir}/epi_pre_al.nii.gz

	echo ""
	echo "Move data"
	echo "cp ${outdir}/RawEPI/rameanepi_0000.nii ${outdir}/meanepi.nii "
	cp ${outdir}/RawEPI/rameanepi_0000.nii ${outdir}/meanepi.nii
	echo "cp ${outdir}/RawEPI/rp_epi_0000.txt ${outdir}/motion_values.txt "
	cp ${outdir}/RawEPI/rp_aepi_0000.txt ${outdir}/motion_values.txt
	echo "cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii"
	cp ${outdir}/Structural/brain.nii ${outdir}/brain.nii
fi

echo "gunzip ${outdir}/epi_pre_al.nii.gz"
gunzip ${outdir}/epi_pre_al.nii.gz
