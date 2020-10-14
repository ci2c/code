#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_ApplyAntsWarp.sh  -epi <path>  -temp <path>  -pref <name>  -o <name>  "
	echo ""
	echo "  -epi                          : EPI file "
	echo "  -temp                         : template file "
	echo "  -pref                         : prefix name of Warp and Affine files "
	echo "  -o                            : output name "
	echo ""
	echo "Usage: FMRI_ApplyAntsWarp.sh  -epi <path>  -temp <path>  -pref <name>  -o <name> "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ApplyAntsWarp.sh  -epi <path>  -temp <path>  -pref <name>  -o <name>  "
		echo ""
		echo "  -epi                          : EPI file "
		echo "  -temp                         : template file "
		echo "  -pref                         : prefix name of Warp and Affine files "
		echo "  -o                            : output name "
		echo ""
		echo "Usage: FMRI_ApplyAntsWarp.sh  -epi <path>  -temp <path>  -pref <name>  -o <name> "
		echo ""
		exit 1
		;;
	-epi)
		index=$[$index+1]
		eval EPIFILE=\${$index}
		echo "EPI file : ${EPIFILE}"
		;;
	-temp)
		index=$[$index+1]
		eval TEMPLATE=\${$index}
		echo "template file : ${TEMPLATE}"
		;;
	-pref)
		index=$[$index+1]
		eval FILE_NAME=\${$index}
		echo "prefix name of Warp and Affine files : ${FILE_NAME}"
		;;
	-o)
		index=$[$index+1]
		eval OUTPUTNAME=\${$index}
		echo "output name : ${OUTPUTNAME}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ApplyAntsWarp.sh  -epi <path>  -temp <path>  -pref <name>  -o <name>  "
		echo ""
		echo "  -epi                          : EPI file "
		echo "  -temp                         : template file "
		echo "  -pref                         : prefix name of Warp and Affine files "
		echo "  -o                            : output name "
		echo ""
		echo "Usage: FMRI_ApplyAntsWarp.sh  -epi <path>  -temp <path>  -pref <name>  -o <name> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments

if [ -z ${EPIFILE} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${TEMPLATE} ]
then
	 echo "-temp argument mandatory"
	 exit 1
fi

if [ -z ${FILE_NAME} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

if [ -z ${OUTPUTNAME} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

EPI_NAME=${EPIFILE%%.*}

OUTDIR=$(dirname ${EPIFILE})
SPLITDIR=`mktemp -d --tmpdir=${OUTDIR}`

fslsplit ${EPIFILE} ${SPLITDIR}/epi_ -t

for IMG in `ls -1 ${SPLITDIR}/`
do
    WarpImageMultiTransform 3 ${SPLITDIR}/${IMG} ${SPLITDIR}/warp${IMG} ${FILE_NAME}Warp.nii.gz ${FILE_NAME}Affine.txt ${FILE_NAME}_rigidAffine.txt -R ${TEMPLATE} --use-BSpline
done

fslmerge -t ${OUTDIR}/${OUTPUTNAME} ${SPLITDIR}/warp*
rm -rf ${SPLITDIR}
