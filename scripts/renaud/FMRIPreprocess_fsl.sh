#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage:  FMRIPreprocess_afni.sh  -epi <data_path>  -anat <anat_path>  -tr <value>  -o <output_directory>  -pref <output_prefix>"
	echo ""
	echo "  -epi                         : Path to epi data "
	echo "  -anat                        : Path to anatomical data "
	echo "  -tr                          : TR value "
	echo "  -o                           : Output directory"
	echo "  -pref                        : Output files prefix" 
	echo ""
	echo "Usage:  FMRIPreprocess_afni.sh  -epi <data_path>  -anat <anat_path>  -tr <value>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
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
		echo "Usage:  FMRIPreprocess_afni.sh  -epi <data_path>  -anat <anat_path>  -tr <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to anatomical data "
		echo "  -tr                          : TR value "
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage:  FMRIPreprocess_afni.sh  -epi <data_path>  -anat <anat_path>  -tr <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
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
		echo "anatomical data : ${anat}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR : ${TR}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-pref)
		index=$[$index+1]
		eval pref=\${$index}
		echo "Output prefix : ${pref}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRIPreprocess_afni.sh  -epi <data_path>  -anat <anat_path>  -tr <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to anatomical data "
		echo "  -tr                          : TR value "
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage:  FMRIPreprocess_afni.sh  -epi <data_path>  -anat <anat_path>  -tr <value>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
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
	 echo "-tr argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${pref} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

####
# Creates out dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

####
# Save out 1st volume of run as reference volume for motion correction and anatomical co-registration.
echo ""
echo "Reference volume"
if [ ! -f "${outdir}"/temp_mcref.nii.gz ] 
then
	echo "3dcalc -a "$2"'[4]' -expr 'a' -prefix "${outdir}"/temp_mcref.nii.gz"
	3dcalc -a "${epi}"'[0]' -expr 'a' -prefix "${outdir}"/temp_mcref.nii.gz
else
	echo "3dcalc: Already done"
fi

####
# fMRI preprocessing
echo ""
echo "fMRI preprocessing"

# Make sure TR is correct.
echo ""
echo "3drefit -TR "$TR"s "$epi""
3drefit -TR "$TR"s "$epi"

# Slice-time correction using 3dTshift
echo ""
if [ ! -f "${outdir}"/st_"$pref".nii.gz ]
then
	echo "3dTshift -tpattern alt+z -TR "$TR"s -Fourier -prefix "${outdir}"/st_"$pref".nii.gz "$epi""
	3dTshift -tpattern alt+z -TR "$TR"s -Fourier -prefix "${outdir}"/st_"$pref".nii.gz "$epi"
else
	echo "3dTshift: Already done"
fi

# Calculate motion correction using FSL mcflirt.
echo ""
if [ ! -f "${outdir}"/mcf_"$pref".nii.gz ]
then
	echo "mcflirt -in "${outdir}"/st_"$pref".nii.gz -out "$woutdir"/mcf_"$pref" -cost normcorr -dof 6 -reffile "${outdir}"/temp_mcref.nii.gz -mats -plots -report"
	mcflirt -in "${outdir}"/st_"$pref".nii.gz -out "${outdir}"/mcf_"$pref" -cost normcorr -dof 6 -reffile "${outdir}"/temp_mcref.nii.gz -mats -plots -report
else
	echo "mcflirt: Already done"
fi

# Calculate time-series mean.
echo ""
echo "Calculate time-series mean"
if [ ! -f "${outdir}"/mcref.nii.gz ]
then
	pathcur=pwd
	cd ${outdir}
	echo "3dTstat -prefix mcref.nii.gz "${outdir}"/mcf_"$pref".nii.gz"
	3dTstat -prefix	mcref.nii.gz "${outdir}"/mcf_"$pref".nii.gz
	cd ${pathcur}
else
	echo "time-series mean: Already done"
fi

# Calculate co-registration matrix from EPI reference to anatomical.
echo ""
echo "Calculate co-registration matrix from EPI reference to anatomical"
if [ ! -f "${outdir}"/rmcref.nii.gz ]
then
	echo "flirt -in "${outdir}"/mcref.nii.gz -ref "${anat}" -omat "${outdir}"/mcref-brain.mat -cost normmi -dof 12 -out "${outdir}"/rmcref"
	flirt -in "${outdir}"/mcref.nii.gz -ref "${anat}" -omat "${outdir}"/mcref-brain.mat -cost normmi -dof 12 -out "${outdir}"/rmcref
else
	echo "flirt: Already done"
fi

echo ""
if [ ! -f "${outdir}"/rmcf_"$pref".nii.gz ]
then
	# Clean up first-pass motion correction.
	echo "rm -r "${outdir}"/mcf_"$pref".*"
	rm -r "${outdir}"/mcf_"$pref".*
	
	# Re-calculate motion correction to mean epi image.
	echo "mcflirt -in "${outdir}"/st_"$pref".nii.gz -out "${outdir}"/mcf_"$pref" -cost normcorr -dof 6 -reffile "${outdir}"/mcref.nii.gz -mats -plots -report"
	mcflirt -in "${outdir}"/st_"$pref".nii.gz -out "${outdir}"/mcf_"$pref" -cost normcorr -dof 6 -reffile "${outdir}"/mcref.nii.gz -mats -plots -report
	
	# Split EPI time-series into separate volumes.
	pathcur=pwd
	cd ${outdir}
	echo "fslsplit "${outdir}"/st_"$pref".nii.gz temp -t"
	fslsplit "${outdir}"/st_"$pref".nii.gz temp -t
	cd ${pathcur}
	
	# Concatenate motion correction and anatomical co-registration transforms for each EPI volume.
	echo "Concatenating and applying spatial transforms..."
	for m in "${outdir}"/mcf_"$pref".mat/*; do 

		ind="${m##*_}"
		echo "$ind"
		convert_xfm -omat "${m/MAT/rMAT}" -concat "${outdir}"/mcref-brain.mat "$m"
		flirt -in "${outdir}"/temp"$ind".nii.gz -ref "${anat}" -applyisoxfm 2 -init "${m/MAT/rMAT}" -out "${outdir}"/rtemp"$ind"

	done
	
	# Recombine EPI volumes into time-series. Delete temp files.
	fslmerge -t "${outdir}"/rmcf_"$pref" "${outdir}"/rtemp*.nii.gz
	rm "${outdir}"/temp*nii.gz "${outdir}"/rtemp*nii.gz
	
else
	echo "Already done"
fi
	
	


