#!/bin/bash
set -e


if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: Tracula_Preprocessing.sh  -dtipos <path>  -dtineg <path>  -fs <folder>  -subj <name>  -o <path>  [-echospacing <value>  -denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -onlypos]"
	echo ""
	echo "NIFTI IMAGE WHITHOUT EXTENSION"
	echo "BE CAREFUL NEED FREESURFER 5.3"
	echo "  -dtipos                   : PA dti file (nifti image) + need bval and bvec with same name "
	echo "  -dtineg                   : AP dti file (nifti image) + need bval and bvec with same name "
	echo "  -fs                       : Freesurfer folder "
	echo "  -subj                     : Subject's Freesurfer folder "
	echo "  -o                        : output folder "
	echo " "
	echo "Options :"
	echo "  -echospacing              : echo spacing in ms (Default: 0.7005818)"
	echo "  -denoise                  : do dwi denoising (Default: NONE)"
	echo "  -pedir                    : phase encoding direction (Default: 2 for +=PA and -=AP)"
	echo "  -b0dist                   : minimum distance in volumes between b0s considered for preprocessing (Default: 3)"
	echo "  -b0max                    : Volumes with a bvalue smaller than this value will be considered as b0s (Default: 50)"
	echo "  -onlypos                  : Keep only gradient diffusions from PA file (Default: no)"
	echo ""
	echo "Usage: Tracula_Preprocessing.sh  -dtipos <path>  -dtineg <path>  -fs <folder>  -subj <name>  -o <path>  [-echospacing <value>  -denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -onlypos]"
	echo ""
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

ToDenoising="NONE"
Gdcoeffs="NONE"
PEdir="2"
echo_spacing=0.7005818
b0dist="3"               # Minimum distance in volumes between b0s considered for preprocessing
b0maxbval=50             # Volumes with a bvalue smaller than this value will be considered as b0s
OnlyPos=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Tracula_Preprocessing.sh  -dtipos <path>  -dtineg <path>  -fs <folder>  -subj <name>  -o <path>  [-echospacing <value>  -denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -onlypos]"
		echo ""
		echo "NIFTI IMAGE WHITHOUT EXTENSION"
		echo "BE CAREFUL NEED FREESURFER 5.3"
		echo "  -dtipos                   : PA dti file (nifti image) + need bval and bvec with same name "
		echo "  -dtineg                   : AP dti file (nifti image) + need bval and bvec with same name "
		echo "  -fs                       : Freesurfer folder "
		echo "  -subj                     : Subject's Freesurfer folder "
		echo "  -o                        : output folder "
		echo " "
		echo "Options :"
		echo "  -echospacing              : echo spacing in ms (Default: 0.7005818)"
		echo "  -denoise                  : do dwi denoising (Default: NONE)"
		echo "  -pedir                    : phase encoding direction (Default: 2 for +=PA and -=AP)"
		echo "  -b0dist                   : minimum distance in volumes between b0s considered for preprocessing (Default: 3)"
		echo "  -b0max                    : Volumes with a bvalue smaller than this value will be considered as b0s (Default: 50)"
		echo "  -onlypos                  : Keep only gradient diffusions from PA file (Default: no)"
		echo ""
		echo "Usage: Tracula_Preprocessing.sh  -dtipos <path>  -dtineg <path>  -fs <folder>  -subj <name>  -o <path>  [-echospacing <value>  -denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -onlypos]"
		echo ""
		exit 1
		;;
	-dtipos)
		PosInputImages=`expr $index + 1`
		eval PosInputImages=\${$PosInputImages}
		echo "  |-------> DTI pos file : $PosInputImages"
		index=$[$index+1]
		;;
	-dtineg)
		NegInputImages=`expr $index + 1`
		eval NegInputImages=\${$NegInputImages}
		echo "  |-------> DTI neg file : ${NegInputImages}"
		index=$[$index+1]
		;;
	-fs)
		FSDIR=`expr $index + 1`
		eval FSDIR=\${$FSDIR}
		echo "  |-------> FS folder : ${FSDIR}"
		index=$[$index+1]
		;;
	-subj)
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "  |-------> subject's FS folder : ${SUBJ}"
		index=$[$index+1]
		;;
	-o)
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo "  |-------> output folder : ${outdir}"
		index=$[$index+1]
		;;
	-echospacing)
		echo_spacing=`expr $index + 1`
		eval echo_spacing=\${$echo_spacing}
		echo "  |-------> echo spacing : ${echo_spacing}"
		index=$[$index+1]
		;;
	-denoise)
		ToDenoising=1
		echo "Do dwi denoising"
		;;	
	-pedir)
		PEdir=`expr $index + 1`
		eval PEdir=\${$PEdir}
		echo "  |-------> phase encoding direction : ${PEdir}"
		index=$[$index+1]
		;;
	-b0dist)
		b0dist=`expr $index + 1`
		eval b0dist=\${$b0dist}
		echo "  |-------> minimum distance between b0 : ${b0dist}"
		index=$[$index+1]
		;;
	-b0max)
		b0maxbval=`expr $index + 1`
		eval b0maxbval=\${$b0maxbval}
		echo "  |-------> b0 max value : ${b0maxbval}"
		index=$[$index+1]
		;;
	-onlypos)
		OnlyPos=1
		echo "Keep only PA gradient diffusions"
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


echo " "
echo "START: Tracula_Preprocessing.sh"
echo " START: `date`"
echo ""


echo ""
echo "################################################################################################"
echo "##                                     CONFIGURATIONS "
echo "################################################################################################"
echo ""

# Establish output directory paths
if [ ${outdir} ]; then rm -rf ${outdir}; fi

# Make sure output directories exist
mkdir -p ${outdir}

T1wFolder=${FSDIR}/${SUBJ}/T1w
DTIDir=`dirname ${PosInputImages}`
echo "DTIDir=${DTIDir}"
DTIName=`basename ${PosInputImages}`
echo "DTIName=${DTIName}"



echo ""
echo "################################################################################################"
echo "##                                     PRE-PROCESSING "
echo "################################################################################################"
echo ""

export FREESURFER_HOME=${Soft_dir}/freesurfer5_3HCP/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

if [ $OnlyPos -eq 1 ] && [ $ToDenoising -eq 1 ]; then

	echo "DTI_CorrectionForTracula.sh  \
		-dtipos ${PosInputImages} \
		-dtineg ${NegInputImages} \
		-subj ${SUBJ} \
		-o ${outdir} \
		-echospacing ${echo_spacing} \
		-denoise \
		-pedir ${PEdir} \
		-b0dist ${b0dist} \
		-b0max ${b0maxbval} \
		-onlypos"
	DTI_CorrectionForTracula.sh  \
		-dtipos ${PosInputImages} \
		-dtineg ${NegInputImages} \
		-subj ${SUBJ} \
		-o ${outdir} \
		-echospacing ${echo_spacing} \
		-denoise \
		-pedir ${PEdir} \
		-b0dist ${b0dist} \
		-b0max ${b0maxbval} \
		-onlypos

elif [ $OnlyPos -eq 1 ] && [ $ToDenoising -eq 0 ]; then

	echo "DTI_CorrectionForTracula.sh  \
		-dtipos ${PosInputImages} \
		-dtineg ${NegInputImages} \
		-subj ${SUBJ} \
		-o ${outdir} \
		-echospacing ${echo_spacing} \
		-pedir ${PEdir} \
		-b0dist ${b0dist} \
		-b0max ${b0maxbval} \
		-onlypos"
	DTI_CorrectionForTracula.sh  \
		-dtipos ${PosInputImages} \
		-dtineg ${NegInputImages} \
		-subj ${SUBJ} \
		-o ${outdir} \
		-echospacing ${echo_spacing} \
		-pedir ${PEdir} \
		-b0dist ${b0dist} \
		-b0max ${b0maxbval} \
		-onlypos

elif [ $OnlyPos -eq 0 ] && [ $ToDenoising -eq 1 ]; then

	echo "DTI_CorrectionForTracula.sh  \
		-dtipos ${PosInputImages} \
		-dtineg ${NegInputImages} \
		-subj ${SUBJ} \
		-o ${outdir} \
		-echospacing ${echo_spacing} \
		-denoise \
		-pedir ${PEdir} \
		-b0dist ${b0dist} \
		-b0max ${b0maxbval}"
	DTI_CorrectionForTracula.sh  \
		-dtipos ${PosInputImages} \
		-dtineg ${NegInputImages} \
		-subj ${SUBJ} \
		-o ${outdir} \
		-echospacing ${echo_spacing} \
		-denoise \
		-pedir ${PEdir} \
		-b0dist ${b0dist} \
		-b0max ${b0maxbval}

else

	echo "DTI_CorrectionForTracula.sh  \
		-dtipos ${PosInputImages} \
		-dtineg ${NegInputImages} \
		-subj ${SUBJ} \
		-o ${outdir} \
		-echospacing ${echo_spacing} \
		-pedir ${PEdir} \
		-b0dist ${b0dist} \
		-b0max ${b0maxbval}"
	DTI_CorrectionForTracula.sh  \
		-dtipos ${PosInputImages} \
		-dtineg ${NegInputImages} \
		-subj ${SUBJ} \
		-o ${outdir} \
		-echospacing ${echo_spacing} \
		-pedir ${PEdir} \
		-b0dist ${b0dist} \
		-b0max ${b0maxbval}

fi


echo ""
echo "################################################################################################"
echo "##                                 CREATE CONFIGURATION FILE "
echo "################################################################################################"
echo ""

export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# copy configuration file
echo "copy configuration file"
echo "cp /NAS/tupac/renaud/scripts/dmrirc.tracula ${outdir}/"
cp /NAS/tupac/renaud/scripts/dmrirc.tracula ${outdir}/

# change path
echo ""
echo "change path"
old_run="^setenv SUBJECTS_DIR.*"
new_run="setenv SUBJECTS_DIR ${T1wFolder}"
sed -i "s#${old_run}#${new_run}#g" ${outdir}/dmrirc.tracula

old_run="^set dtroot.*"
new_run="set dtroot = ${outdir}/tracula"
sed -i "s#${old_run}#${new_run}#g" ${outdir}/dmrirc.tracula

old_run="^set subjlist.*"
new_run="set subjlist = ( ${SUBJ} )"
sed -i "s#${old_run}#${new_run}#g" ${outdir}/dmrirc.tracula

old_run="^set dcmroot.*"
new_run="set dcmroot = ${DTIDir}/"
sed -i "s#${old_run}#${new_run}#g" ${outdir}/dmrirc.tracula

old_run="^set dcmlist.*"
new_run="set dcmlist = ( ${DTIName} )"
sed -i "s#${old_run}#${new_run}#g" ${outdir}/dmrirc.tracula

old_run="^set bvecfile.*"
new_run="set bvecfile = ( ${outdir}/rawdata/backup.bvecs )"
sed -i "s#${old_run}#${new_run}#g" ${outdir}/dmrirc.tracula

old_run="^set bvalfile.*"
new_run="set bvalfile = ( ${outdir}/rawdata/backup.bvals )"
sed -i "s#${old_run}#${new_run}#g" ${outdir}/dmrirc.tracula



echo ""
echo "################################################################################################"
echo "##                                 TRACULA PREPROCESSING "
echo "################################################################################################"
echo ""

echo "trac-all -prep -c ${outdir}/dmrirc.tracula"
trac-all -prep -c ${outdir}/dmrirc.tracula

ln -sf ${outdir}/tracula/${SUBJ}/dmri/dwi.nii.gz ${outdir}/tracula/${SUBJ}/dmri/data.nii.gz

