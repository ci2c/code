#!/bin/bash
set -e


if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_CreateMask.sh  -aparc <file>  -brainmask <file>  -scout <file>  -o <file>  [-reg <transf>  -erode]  "
	echo ""
	echo "  -aparc            : aparc file "
	echo "  -brainmask        : brain mask file "
	echo "  -scout            : Scout fMRI file "
	echo "  -o                : output folder "
	echo "  OPTIONS "
	echo "  -reg              : transformation T1->EPI file  "
	echo "  -erode            : create erode masks "
	echo ""
	echo "Usage: FMRI_CreateMask.sh  -aparc <file>  -brainmask <file>  -scout <file>  -o <file>  [-reg <transf>  -erode] "
	echo ""
	exit 1
fi


#### Inputs ####
user=`whoami`
HOME=/home/${user}
index=1
echo "------------------------"

ERODE=0
RegTransf="NONE"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_CreateMask.sh  -aparc <file>  -brainmask <file>  -scout <file>  -o <file>  [-reg <transf>  -erode]  "
		echo ""
		echo "  -aparc            : aparc file  "
		echo "  -brainmask        : brain mask file "
		echo "  -scout            : Scout fMRI file "
		echo "  -o                : output folder "
		echo "  OPTIONS "
		echo "  -reg              : transformation T1->EPI file "
		echo "  -erode            : create erode masks "
		echo ""
		echo "Usage: FMRI_CreateMask.sh  -aparc <file>  -brainmask <file>  -scout <file>  -o <file>  [-reg <transf>  -erode] "
		echo ""
		exit 1
		;;
	-aparc)
		index=$[$index+1]
		eval AparcFile=\${$index}
		echo "AparcFile : $AparcFile"
		;;
	-brainmask)
		index=$[$index+1]
		eval BrainMask=\${$index}
		echo "BrainMask : $BrainMask"
		;;
	-scout)
		index=$[$index+1]
		eval ScoutInput=\${$index}
		echo "ScoutInput : $ScoutInput"
		;;
	-o)
		index=$[$index+1]
		eval WD=\${$index}
		echo "WorkingDirectory : $WD"
		;;
	-reg)
		index=$[$index+1]
		eval RegTransf=\${$index}
		echo "RegTransf : $RegTransf"
		;;
	-erode)
		ERODE=1
		echo "do erosion"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_CreateMask.sh  -aparc <file>  -brainmask <file>  -scout <file>  -o <file>  [-reg <transf>  -erode]  "
		echo ""
		echo "  -aparc            : aparc file "
		echo "  -brainmask        : brain mask file "
		echo "  -scout            : Scout fMRI file "
		echo "  -o                : output folder "
		echo "  OPTIONS "
		echo "  -reg              : transformation T1->EPI file "
		echo "  -erode            : create erode masks "
		echo ""
		echo "Usage: FMRI_CreateMask.sh  -aparc <file>  -brainmask <file>  -scout <file>  -o <file>  [-reg <transf>  -erode] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# --------------------------------------------------------------------------------
#                      Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions


echo " "
echo "START: FMRI_CreateMask.sh"
echo " START: `date`"
echo ""


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                    CONFIG "
echo "# --------------------------------------------------------------------------------"

# Create output folder
if [ ! -d ${WD} ]; then mkdir -p ${WD}; fi

# Aparc and brainmask in fMRI space
if [ ${RegTransf} = "NONE" ]; then

	echo "applywarp --rel --interp=nn -i ${AparcFile} -r ${ScoutInput} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/Aparc"
	applywarp --rel --interp=nn -i ${AparcFile} -r ${ScoutInput} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/Aparc
	echo "applywarp --rel --interp=nn -i ${BrainMask} -r ${ScoutInput} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/BrainMask"
	applywarp --rel --interp=nn -i ${BrainMask} -r ${ScoutInput} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/BrainMask

else

	echo "applywarp --rel --interp=nn -i ${AparcFile} -r ${ScoutInput} -w ${RegTransf} -o ${WD}/Aparc"
	applywarp --rel --interp=nn -i ${AparcFile} -r ${ScoutInput} -w ${RegTransf} -o ${WD}/Aparc
	echo "applywarp --rel --interp=nn -i ${BrainMask} -r ${ScoutInput} -w ${RegTransf} -o ${WD}/BrainMask"
	applywarp --rel --interp=nn -i ${BrainMask} -r ${ScoutInput} -w ${RegTransf} -o ${WD}/BrainMask

fi

rm -f ${WD}/Mask_num_vox.txt
echo "Nmber of voxels in each mask" > ${WD}/Mask_num_vox.txt
echo "" >> ${WD}/Mask_num_vox.txt


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                WHOLE BRAIN MASK "
echo "# --------------------------------------------------------------------------------"

# whole brain mask
num_v=`fslstats ${WD}/BrainMask -V`
num_v=`echo $num_v | awk '{print $1}'`
echo "Brain mask: ${num_v}" >> ${WD}/Mask_num_vox.txt

# loose whole brain mask
echo "mri_binarize --i ${WD}/BrainMask.nii.gz --o ${WD}/LooseBrainMask.nii.gz --dilate 2 --min .0001"
mri_binarize --i ${WD}/BrainMask.nii.gz --o ${WD}/LooseBrainMask.nii.gz --dilate 2 --min .0001
num_v=`fslstats ${WD}/LooseBrainMask -V`
num_v=`echo $num_v | awk '{print $1}'`
echo "Loose Brain mask: ${num_v}" >> ${WD}/Mask_num_vox.txt


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                    WM MASK "
echo "# --------------------------------------------------------------------------------"

echo "mri_binarize --i ${WD}/Aparc.nii.gz --wm --erode 0 --o ${WD}/WM_erode0.nii.gz"
mri_binarize --i ${WD}/Aparc.nii.gz --wm --erode 0 --o ${WD}/WM_erode0.nii.gz
num_v=`fslstats ${WD}/WM_erode0 -V`
num_v=`echo $num_v | awk '{print $1}'`
echo "WM erode 0: ${num_v}" >> ${WD}/Mask_num_vox.txt

if [ ${ERODE} -gt 0 ]; then
	echo "mri_binarize --i ${WD}/Aparc.nii.gz --wm --erode 1 --o ${WD}/WM_erode1.nii.gz"
	mri_binarize --i ${WD}/Aparc.nii.gz --wm --erode 1 --o ${WD}/WM_erode1.nii.gz
	num_v=`fslstats ${WD}/WM_erode1 -V`
	num_v=`echo $num_v | awk '{print $1}'`
	echo "WM erode 1: ${num_v}" >> ${WD}/Mask_num_vox.txt
fi


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                  CSF MASK "
echo "# --------------------------------------------------------------------------------"


echo "mri_binarize --i ${WD}/Aparc.nii.gz --ventricles --erode 0 --o ${WD}/CSF_erode0.nii.gz"
mri_binarize --i ${WD}/Aparc.nii.gz --ventricles --erode 0 --o ${WD}/CSF_erode0.nii.gz
num_v=`fslstats ${WD}/CSF_erode0 -V`
num_v=`echo $num_v | awk '{print $1}'`
echo "CSF erode 0: ${num_v}" >> ${WD}/Mask_num_vox.txt

if [ ${ERODE} -gt 0 ]; then
	echo "mri_binarize --i ${AparcFile}.nii.gz --ventricles --erode 1 --o ${WD}/CSF_erode1_T1.nii.gz"
	mri_binarize --i ${AparcFile}.nii.gz --ventricles --erode 1 --o ${WD}/CSF_erode1_T1.nii.gz
	echo "applywarp --rel --interp=nn -i ${WD}/CSF_erode1_T1 -r ${ScoutInput} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/CSF_erode1"
	applywarp --rel --interp=nn -i ${WD}/CSF_erode1_T1 -r ${ScoutInput} --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${WD}/CSF_erode1
	num_v=`fslstats ${WD}/CSF_erode1 -V`
	num_v=`echo $num_v | awk '{print $1}'`
	echo "CSF erode 1: ${num_v}" >> ${WD}/Mask_num_vox.txt
fi


echo ""
echo "# --------------------------------------------------------------------------------"
echo "#                                 WM + CSF MASK "
echo "# --------------------------------------------------------------------------------"

echo "fslmaths ${WD}/WM_erode0 -max ${WD}/CSF_erode0 ${WD}/WM_CSF_erode0"
fslmaths ${WD}/WM_erode0 -max ${WD}/CSF_erode0 ${WD}/WM_CSF_erode0

if [ ${ERODE} -gt 0 ]; then
	echo "fslmaths ${WD}/WM_erode1 -max ${WD}/CSF_erode1 ${WD}/WM_CSF_erode1"
	fslmaths ${WD}/WM_erode1 -max ${WD}/CSF_erode1 ${WD}/WM_CSF_erode1
fi


echo " "
echo "END: FMRI_CreateMask.sh"
echo " END: `date`"
echo ""

