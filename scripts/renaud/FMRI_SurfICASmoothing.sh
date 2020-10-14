#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: FMRI_SurfICASmoothing.sh -sd <subjdir>  -subj <name>  -i <datapath>  -N <value>  -pref <prefix>  -surffwhm <value> "
	echo ""
	echo "  -sd                          : Path to subject "
	echo "  -subj                        : subject "
	echo "  -i                           : Path to data "
	echo "  -N                           : Number of components "
	echo "  -pref                        : prefix "
	echo "  -surffwhm                    : smoothing value "
	echo ""
	echo "Usage: FMRI_SurfICASmoothing.sh -sd <subjdir>  -subj <name>  -i <datapath>  -N <value>  -pref <prefix>  -surffwhm <value> "
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
		echo "Usage: FMRI_SurfICASmoothing.sh -sd <subjdir>  -subj <name>  -i <datapath>  -N <value>  -pref <prefix>  -surffwhm <value> "
		echo ""
		echo "  -sd                          : Path to subject "
		echo "  -subj                        : subject "
		echo "  -i                           : Path to data "
		echo "  -N                           : Number of components "
		echo "  -pref                        : prefix "
		echo "  -surffwhm                    : smoothing value "
		echo ""
		echo "Usage: FMRI_SurfICASmoothing.sh -sd <subjdir>  -subj <name>  -i <datapath>  -N <value>  -pref <prefix>  -surffwhm <value> "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SUBJECTSDIR=\${$index}
		echo "subject path : ${SUBJECTSDIR}"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "subject name : ${SUBJ}"
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data path : ${input}"
		;;
	-N)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of components : ${N}"
		;;
	-pref)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix : ${prefix}"
		;;
	-surffwhm)
		index=$[$index+1]
		eval surffwhm=\${$index}
		echo "smoothing : ${surffwhm}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_SurfICASmoothing.sh -sd <subjdir>  -subj <name>  -i <datapath>  -N <value>  -pref <prefix>  -surffwhm <value> "
		echo ""
		echo "  -sd                          : Path to subject "
		echo "  -subj                        : subject "
		echo "  -i                           : Path to data "
		echo "  -N                           : Number of components "
		echo "  -pref                        : prefix "
		echo "  -surffwhm                    : smoothing value "
		echo ""
		echo "Usage: FMRI_SurfICASmoothing.sh -sd <subjdir>  -subj <name>  -i <datapath>  -N <value>  -pref <prefix>  -surffwhm <value> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SUBJECTSDIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

if [ -z ${input} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${N} ]
then
	 echo "-N argument mandatory"
	 exit 1
fi

if [ -z ${prefix} ]
then
	 echo "-prefix argument mandatory"
	 exit 1
fi

if [ -z ${surffwhm} ]
then
	 echo "-surffwhm argument mandatory"
	 exit 1
fi

# Resampling to fsaverage and smoothing
for ((ind = 1; ind <= ${N}; ind += 1))
do
	# Left hemisphere
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${input}/lh.${prefix}_${ind}.mgh --fwhm ${surffwhm} --o ${input}/lh.sm${surffwhm}_${prefix}_${ind}.mgh
	
	# Right hemisphere
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${input}/rh.${prefix}_${ind}.mgh --fwhm ${surffwhm} --o ${input}/rh.sm${surffwhm}_${prefix}_${ind}.mgh	
done
