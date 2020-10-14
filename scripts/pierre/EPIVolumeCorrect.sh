#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: EPIVolumeCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
	echo ""
	echo "  -f                           : Path to forward image (displacement toward +y)"
	echo "  -b                           : Path to forward image (displacement toward -y)"
	echo "  -o                           : Output directory"
	echo "  -pref                        : Output files prefix" 
	echo ""
	echo "Usage: EPIVolumeCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
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
		echo "Usage: EPIVolumeCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -f                           : Path to forward image (displacement toward +y)"
		echo "  -b                           : Path to forward image (displacement toward -y)"
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage: EPIVolumeCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		exit 1
		;;
	-f)
		index=$[$index+1]
		eval forw=\${$index}
		echo "Forward image : ${forw}"
		;;
	-b)
		index=$[$index+1]
		eval back=\${$index}
		echo "Backward image : ${back}"
		;;
	-o)
		index=$[$index+1]
		eval obase=\${$index}
		echo "Output directory : ${obase}"
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
		echo "Usage: EPIVolumeCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -f                           : Path to forward image (displacement toward +y)"
		echo "  -b                           : Path to forward image (displacement toward -y)"
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage: EPIVolumeCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${forw} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi

if [ -z ${back} ]
then
	 echo "-b argument mandatory"
	 exit 1
fi

if [ -z ${obase} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${pref} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi


outdir=${obase}

## Creates out dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

## Create log dir
if [ ! -d ${outdir}/logs ]
then
	mkdir ${outdir}/logs
fi

## Split input volumes
fslsplit ${forw} ${outdir}/forw_slice -z
fslsplit ${back} ${outdir}/back_slice -z

gunzip -f ${outdir}/*gz

## Loop on the slices
FORW=(`ls ${outdir}/forw_slice*nii`)
BACK=(`ls ${outdir}/back_slice*nii`)
nslice=`ls ${outdir}/back_slice*nii | wc -l`

i=0
while [ ${i} -lt ${nslice} ]
do
	A=$(printf "%.4d" ${i})
	qbatch -N ${pref}${A} -q fs_q -oe ${outdir}/logs EPISliceCorrect.sh  -f ${FORW[i]}  -b ${BACK[i]}  -o ${outdir}  -pref ${pref}${A}
	sleep 18
	i=$[$i+1]
done

WaitForJobs.sh ${pref}


