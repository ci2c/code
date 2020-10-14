#!/bin/bash 
set -e

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: FMRI_IntensityNormalization.sh  -fmri <file>  -ofmri <file>  [-scout <file>  -oscout <file>  -mask <file>  -biasfield <file>  -jacobian <file>]  "
	echo ""
	echo "Usage: "
	echo "  -fmri              : input fmri"
	echo "  -ofmri             : output fmri"
	echo " OPTIONS "
	echo "  -scout             : input scout image"
	echo "  -oscout            : output scout image"
	echo "  -mask              : brain mask"
	echo "  -jacobian          : jacobian"
	echo "  -biasfield         : bias field"
	echo ""
	echo "Usage: FMRI_IntensityNormalization.sh  -fmri <file>  -ofmri <file>  [-scout <file>  -oscout <file>  -mask <file>  -biasfield <file>  -jacobian <file>]  "
	echo ""
	exit 1
fi

# --------------------------------------------------------------------------------
#                         Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR_Global/log.shlib # Logging related functions


# --------------------------------------------------------------------------------
#                                  INIT
# --------------------------------------------------------------------------------
user=`whoami`

HOME=/home/${user}
index=1

ScoutInput="NONE"
ScoutOutput="NONE"
BrainMask="NONE"
Jacobian="NONE"
BiasField="NONE"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_IntensityNormalization.sh  -fmri <file>  -ofmri <file>  [-scout <file>  -oscout <file>  -mask <file>  -biasfield <file>  -jacobian <file>]  "
		echo ""
		echo "Usage: "
		echo "  -fmri              : input fmri"
		echo "  -ofmri             : output fmri"
		echo " OPTIONS "
		echo "  -scout             : input scout image"
		echo "  -oscout            : output scout image"
		echo "  -mask              : brain mask"
		echo "  -jacobian          : jacobian"
		echo "  -biasfield         : bias field"
		echo ""
		echo "Usage: FMRI_IntensityNormalization.sh  -fmri <file>  -ofmri <file>  [-scout <file>  -oscout <file>  -mask <file>  -biasfield <file>  -jacobian <file>]  "
		echo ""
		exit 1
		;;
	-fmri)
		index=$[$index+1]
		eval InputfMRI=\${$index}
		echo "input fmri : $InputfMRI"
		;;
	-ofmri)
		index=$[$index+1]
		eval OutputfMRI=\${$index}
		echo "output fmri : $OutputfMRI"
		;;
	-scout)
		index=$[$index+1]
		eval ScoutInput=\${$index}
		echo "input scout : $ScoutInput"
		;;
	-mask)
		index=$[$index+1]
		eval BrainMask=\${$index}
		echo "Brain mask : $BrainMask"
		;;
	-oscout)
		index=$[$index+1]
		eval ScoutOutput=\${$index}
		echo "output scout : $ScoutOutput"
		;;
	-biasfield)
		index=$[$index+1]
		eval BiasField=\${$index}
		echo "bias field : $BiasField"
		;;
	-jacobian)
		index=$[$index+1]
		eval Jacobian=\${$index}
		echo "Jacobian : $Jacobian"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_IntensityNormalization.sh  -fmri <file>  -ofmri <file>  [-scout <file>  -oscout <file>  -mask <file>  -biasfield <file>  -jacobian <file>]  "
		echo ""
		echo "Usage: "
		echo "  -fmri              : input fmri"
		echo "  -ofmri             : output fmri"
		echo " OPTIONS "
		echo "  -scout             : input scout image"
		echo "  -oscout            : output scout image"
		echo "  -mask              : brain mask"
		echo "  -jacobian          : jacobian"
		echo "  -biasfield         : bias field"
		echo ""
		echo "Usage: FMRI_IntensityNormalization.sh  -fmri <file>  -ofmri <file>  [-scout <file>  -oscout <file>  -mask <file>  -biasfield <file>  -jacobian <file>]  "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done



# --------------------------------------------------------------------------------
#                                  INIT
# --------------------------------------------------------------------------------

echo " "
echo "START: FMRI_IntensityNormalization.sh"
echo " START: `date`"
echo ""


# default parameters
OutputfMRI=`$FSLDIR/bin/remove_ext $OutputfMRI`
WD=`dirname ${OutputfMRI}`

# sanity check the jacobian option
if [[ "$ScoutInput" != "NONE" && "$ScoutOutput" = "NONE" ]]
then
	echo "Error: if scout exist, then it needs scout output."
	exit 1
fi

if [ $Jacobian = "NONE" ] ; then
	echo "do not use Jacobian"
	jacobiancom=""
else
	echo "use Jacobian"
  	jacobiancom="-mul $Jacobian"
fi

if [ $BiasField = "NONE" ] ; then
	echo "do not use bias field"
	biascom=""
else
	echo "use bias field"
  	biascom="-div $BiasField"
fi

if [ ! -d $WD ]; then mkdir -p $WD; fi

if [ "$ScoutOutput" != "NONE" ]; then

	ScoutFolder=`dirname ${ScoutOutput}`
	if [ ! -d $ScoutFolder ]; then mkdir -p $ScoutFolder; fi

fi

########################################## DO WORK ########################################## 

# Run intensity normalisation, with bias field correction and optional jacobian modulation, for the main fmri timeseries and the scout images (pre-saturation images)
echo $biascom
echo "fslmaths ${InputfMRI} $biascom $jacobiancom -mas ${BrainMask} -thr 0 -ing 10000 ${OutputfMRI} -odt float"
fslmaths ${InputfMRI} $biascom $jacobiancom -mas ${BrainMask} -thr 0 -ing 10000 ${OutputfMRI} -odt float
if [ ${ScoutInput} != "NONE" ] ; then
	${FSLDIR}/bin/fslmaths ${ScoutInput} $biascom $jacobiancom -mas ${BrainMask} -thr 0 -ing 10000 ${ScoutOutput} -odt float
fi

echo " "
echo "END: FMRI_IntensityNormalization"
echo " END: `date`"
echo ""

########################################## QA STUFF ########################################## 

if [ -e $WD/qa_norm.txt ] ; then rm -f $WD/qa_norm.txt ; fi
echo "cd `pwd`" >> $WD/qa.txt
echo "# Check that the fMRI and Scout images look OK and that the mean intensity across the timeseries is about 10000" >> $WD/qa_norm.txt
if [ "$ScoutOutput" != "NONE" ]; then
	echo "freeview ${ScoutOutput}.nii.gz ${OutputfMRI}.nii.gz" >> $WD/qa_norm.txt
else
	echo "freeview ${OutputfMRI}.nii.gz" >> $WD/qa_norm.txt
fi

##############################################################################################

