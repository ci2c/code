#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: FMRI_ConcatRuns.sh -sd <SUBJECTS_DIR>  -prefix <prefix>  -scale <value> "
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -prefix                      : prefix "
	echo "  -scale                       : scale value "
	echo ""
	echo "Usage: FMRI_ConcatRuns.sh -sd <SUBJECTS_DIR>  -prefix <prefix>  -scale <value> "
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
		echo "Usage: FMRI_ConcatRuns.sh -sd <SUBJECTS_DIR>  -prefix <prefix>  -scale <value> "
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -prefix                      : prefix "
		echo "  -scale                       : scale value "
		echo ""
		echo "Usage: FMRI_ConcatRuns.sh -sd <SUBJECTS_DIR>  -prefix <prefix>  -scale <value> "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval DIR=\${$index}
		echo "subjects directory : $DIR"
		;;
	-prefix)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix : $prefix"
		;;
	-scale)
		index=$[$index+1]
		eval scale=\${$index}
		echo "scale value : $scale"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ConcatRuns.sh -sd <SUBJECTS_DIR>  -prefix <prefix>  -scale <value> "
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -prefix                      : prefix "
		echo "  -scale                       : scale value "
		echo ""
		echo "Usage: FMRI_ConcatRuns.sh -sd <SUBJECTS_DIR>  -prefix <prefix>  -scale <value> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${prefix} ]
then
	 echo "-prefix argument mandatory"
	 exit 1
fi

if [ -z ${scale} ]
then
	 echo "-scale argument mandatory"
	 exit 1
fi

for img in `ls -1 ${DIR}/${prefix}*`
do
 
	echo ${img} 
	
	echo "create mask"
	bet ${img} ${DIR}/epi -f 0.5 -m -n
	
	echo "convert in float"
	fslmaths ${img} ${DIR}/epi -odt float
	
	echo "read min and max"
	read min max <<< $(fslstats ${DIR}/epi.nii.gz -k ${DIR}/epi_mask.nii.gz -r)
	echo "min = $min"
	echo "max = $max"
	
	echo "intensity normalisation"
	base=$(basename ${img})
	fslmaths ${DIR}/epi.nii.gz -sub $min -thr 0 -mul $scale -div $(echo $max - $min | /usr/bin/bc ) ${DIR}/norm${base}
	
done

echo "concatenation ..."
3dTcat -prefix ${DIR}/concat_runs.nii ${DIR}/norm*

echo "removing temporary files"
rm -f ${DIR}/epi_mask.nii.gz ${DIR}/epi.nii.gz ${DIR}/norm*


