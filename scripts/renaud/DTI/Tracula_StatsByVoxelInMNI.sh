#!/bin/bash
set -e


if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: Tracula_StatsByVoxelInMNI.sh  -subjlist <file>  -fs <folder>  -trac <path>  -o <path> "
	echo ""
	echo "  -subjlist                 : list of subjects (.txt) "
	echo "  -fs                       : Freesurfer folder "
	echo "  -trac                     : path to tracula folder "
	echo "  -o                        : output folder "
	echo ""
	echo "Usage: Tracula_StatsByVoxelInMNI.sh  -subjlist <file>  -fs <folder>  -trac <path>  -o <path> "
	echo ""
	exit 1
fi


#### Inputs ####
user=`whoami`

HOME=/home/${user}
index=1

echo "---------------------"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Tracula_StatsByVoxelInMNI.sh  -subjlist <file>  -fs <folder>  -trac <path>  -o <path> "
		echo ""
		echo "  -subjlist                 : list of subjects (.txt) "
		echo "  -fs                       : Freesurfer folder "
		echo "  -trac                     : path to tracula folder "
		echo "  -o                        : output folder "
		echo ""
		echo "Usage: Tracula_StatsByVoxelInMNI.sh  -subjlist <file>  -fs <folder>  -trac <path>  -o <path> "
		echo ""
		exit 1
		;;
	-subjlist)
		SUBJLIST=`expr $index + 1`
		eval SUBJLIST=\${$SUBJLIST}
		echo "  |-------> subjects' list : $SUBJLIST"
		index=$[$index+1]
		;;
	-fs)
		FSDIR=`expr $index + 1`
		eval FSDIR=\${$FSDIR}
		echo "  |-------> FS folder : ${FSDIR}"
		index=$[$index+1]
		;;
	-trac)
		TRAC=`expr $index + 1`
		eval TRAC=\${$TRAC}
		echo "  |-------> tracula path : ${TRAC}"
		index=$[$index+1]
		;;
	-o)
		OUTDIR=`expr $index + 1`
		eval OUTDIR=\${$OUTDIR}
		echo "  |-------> output folder : ${OUTDIR}"
		index=$[$index+1]
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
echo "START: Tracula_StatsByVoxelInMNI.sh"
echo " START: `date`"
echo ""


echo ""
echo "################################################################################################"
echo "##                                     CONFIGURATIONS "
echo "################################################################################################"
echo ""

export FREESURFER_HOME=${Soft_dir}/freesurfer6_0/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# Establish output directory paths
if [ ${OUTDIR} ]; then rm -rf ${OUTDIR}; fi

# Make sure output directories exist
echo "mkdir -p ${OUTDIR}"
mkdir -p ${OUTDIR}

# List of tracts
declare -a tracts=( "fmajor_PP" "fminor_PP" "lh.atr_PP" "lh.cab_PP" "lh.ccg_PP" "lh.cst_AS" "lh.ilf_AS" "lh.slfp_PP" "lh.slft_PP" "lh.unc_AS" \
		    "rh.atr_PP" "rh.cab_PP" "rh.ccg_PP" "rh.cst_AS" "rh.ilf_AS" "rh.slfp_PP" "rh.slft_PP" "rh.unc_AS" )

echo ""
echo "Display all tracts"
echo ${tracts[@]}

echo ""
N=${#tracts[@]}
echo "number of tracts: ${N}"

TEMPLATE=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz
echo ""
echo "Template : ${TEMPLATE}"


echo ""
echo "################################################################################################"
echo "##                                        PROCESS "
echo "################################################################################################"
echo ""


for ((k = 0; k < ${N}; k += 1)); do

	tract=${tracts[${k}]}
	echo "tract: ${tract}"


	for SUBJ in `cat ${SUBJLIST}`; do

		if [ ! -f ${SUBJECTS_DIR}/${SUBJ}/${TRAC}/${SUBJ}/dpath/${tract}_avg33_mni_bbr/pathstats.overall.txt ]; then
			echo "${SUBJ} no tract file"
		else
			echo "${SUBJECTS_DIR}/${SUBJ}/${TRAC}/${SUBJ}/dpath/${tract}_avg33_mni_bbr ${SUBJECTS_DIR}/${SUBJ}/${TRAC}/${SUBJ}/dlabel/diff/aparc+aseg_mask.bbr.nii.gz ${SUBJECTS_DIR}/${SUBJ}/${TRAC}/${SUBJ}/dmri/xfms/diff2mni.bbr.mat" >> ${OUTDIR}/${tract}.avg33_mni_bbr.inputs.txt
		fi

	done

	echo "dmri_group --list ${OUTDIR}/${tract}.avg33_mni_bbr.inputs.txt --ref ${TEMPLATE} --out ${OUTDIR}/${tract}.avg33_mni_bbr"
	dmri_group --list ${OUTDIR}/${tract}.avg33_mni_bbr.inputs.txt --ref ${TEMPLATE} --out ${OUTDIR}/${tract}.avg33_mni_bbr |& tee -a ${OUTDIR}/${tract}.avg33_mni_bbr.log

done




