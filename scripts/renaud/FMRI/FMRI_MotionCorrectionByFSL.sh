#! /bin/bash

if [ $# -lt 16 ]
then
	echo ""
	echo "Usage: FMRI_MotionCorrectionByFSL.sh -d <folder>  -i <fmri>  -r <scout>  -o <ofmri>  -or <name>  -ot <folder>  [-on <name>  -t <type>  -dvth <value>  -fdth <value>]"
	echo ""
	echo "  -d              : working directory"
	echo "  -i              : fMRI data "
	echo "  -r              : fMRI reference "
	echo "  -o              : output fMRI "
	echo "  -or             : output regressors "
	echo "  -ot             : output matrix transformation "
	echo " Options "
	echo "  -on             : output matrix name "
	echo "  -t              : registration name "
	echo "  -dvth           : threshold value for DVARS (Default: p75 + 1.5*Interquartile) "
	echo "  -fdth           : threshold value for FDRMS (Default: p75 + 1.5*Interquartile) "
	echo ""
	echo "Usage: FMRI_MotionCorrectionByFSL.sh -d <folder>  -i <fmri>  -r <scout>  -o <ofmri>  -or <name>  -ot <folder>  [-on <name>  -t <type>  -dvth <value>  -fdth <value>]"
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1

OutputMotionMatrixNamePrefix="MAT_"
MotionCorrectionType="MCFLIRT"
FDTH="-1"
DVTH="-1"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_MotionCorrectionByFSL.sh -d <folder>  -i <fmri>  -r <scout>  -o <ofmri>  -or <name>  -ot <folder>  [-on <name>  -t <type>  -dvth <value>  -fdth <value>]"
		echo ""
		echo "  -d              : working directory"
		echo "  -i              : fMRI data "
		echo "  -r              : fMRI reference "
		echo "  -o              : output fMRI "
		echo "  -or             : output regressors "
		echo "  -ot             : output matrix transformation "
		echo " Options "
		echo "  -on             : output matrix name "
		echo "  -t              : registration name "
		echo "  -dvth           : threshold value for DVARS (Default: p75 + 1.5*Interquartile) "
		echo "  -fdth           : threshold value for FDRMS (Default: p75 + 1.5*Interquartile) "
		echo ""
		echo "Usage: FMRI_MotionCorrectionByFSL.sh -d <folder>  -i <fmri>  -r <scout>  -o <ofmri>  -or <name>  -ot <folder>  [-on <name>  -t <type>  -dvth <value>  -fdth <value>]"
		echo ""
		exit 1
		;;
	-d)
		index=$[$index+1]
		eval WorkingDirectory=\${$index}
		echo "WorkingDirectory : $WorkingDirectory"
		;;
	-i)
		index=$[$index+1]
		eval InputfMRI=\${$index}
		echo "InputfMRI : $InputfMRI"
		;;
	-r)
		index=$[$index+1]
		eval Scout=\${$index}
		echo "Scout : $Scout"
		;;
	-o)
		index=$[$index+1]
		eval OutputfMRI=\${$index}
		echo "OutputfMRI : $OutputfMRI"
		;;
	-or)
		index=$[$index+1]
		eval OutputMotionRegressors=\${$index}
		echo "OutputMotionRegressors : $OutputMotionRegressors"
		;;
	-ot)
		index=$[$index+1]
		eval OutputMotionMatrixFolder=\${$index}
		echo "OutputMotionMatrixFolder : $OutputMotionMatrixFolder"
		;;
	-on)
		index=$[$index+1]
		eval OutputMotionMatrixNamePrefix=\${$index}
		echo "OutputMotionMatrixNamePrefix : $OutputMotionMatrixNamePrefix"
		;;
	-t)
		index=$[$index+1]
		eval MotionCorrectionType=\${$index}
		echo "MotionCorrectionType : $MotionCorrectionType"
		;;
	-dvth)
		index=$[$index+1]
		eval DVTH=\${$index}
		echo "DVTH : $DVTH"
		;;
	-fdth)
		index=$[$index+1]
		eval FDTH=\${$index}
		echo "FDTH : $FDTH"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_MotionCorrectionByFSL.sh -d <folder>  -i <fmri>  -r <scout>  -o <ofmri>  -or <name>  -ot <folder>  [-on <name>  -t <type>  -dvth <value>  -fdth <value>]"
		echo ""
		echo "  -d              : working directory"
		echo "  -i              : fMRI data "
		echo "  -r              : fMRI reference "
		echo "  -o              : output fMRI "
		echo "  -or             : output regressors "
		echo "  -ot             : output matrix transformation "
		echo " Options "
		echo "  -on             : output matrix name "
		echo "  -t              : registration name "
		echo "  -dvth           : threshold value for DVARS (Default: p75 + 1.5*Interquartile) "
		echo "  -fdth           : threshold value for FDRMS (Default: p75 + 1.5*Interquartile) "
		echo ""
		echo "Usage: FMRI_MotionCorrectionByFSL.sh -d <folder>  -i <fmri>  -r <scout>  -o <ofmri>  -or <name>  -ot <folder>  [-on <name>  -t <type>  -dvth <value>  -fdth <value>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# --------------------------------------------------------------------------------
#  Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR_Global/log.shlib # Logging related functions


# --------------------------------------------------------------------------------
#  Establish tool name for logging
# --------------------------------------------------------------------------------

echo "MotionCorrection.sh"
echo "START"

if [ ! -d ${WorkingDirectory} ]; then mkdir -p ${WorkingDirectory}; fi

OutputfMRIBasename=`basename ${OutputfMRI}`

# Do motion correction
echo "Do motion correction"
${HCPPIPEDIR_Global}/mcflirt.sh ${InputfMRI} ${WorkingDirectory}/${OutputfMRIBasename} ${Scout}

# Move output files about
mv -f ${WorkingDirectory}/${OutputfMRIBasename}/mc.par ${WorkingDirectory}/${OutputfMRIBasename}.par
if [ -e $OutputMotionMatrixFolder ] ; then
  rm -r $OutputMotionMatrixFolder
fi
mkdir $OutputMotionMatrixFolder

mv -f ${WorkingDirectory}/${OutputfMRIBasename}/* ${OutputMotionMatrixFolder}
mv -f ${WorkingDirectory}/${OutputfMRIBasename}.nii.gz ${OutputfMRI}.nii.gz

# Change names of all matrices in OutputMotionMatrixFolder
echo "Change names of all matrices in OutputMotionMatrixFolder"
DIR=`pwd`
if [ -e $OutputMotionMatrixFolder ] ; then
  cd $OutputMotionMatrixFolder
  Matrices=`ls`
  for Matrix in $Matrices ; do
    MatrixNumber=`basename ${Matrix} | cut -d "_" -f 2`
    mv $Matrix `echo ${OutputMotionMatrixNamePrefix}${MatrixNumber} | cut -d "." -f 1`
  done
  cd $DIR
fi

# Make 4dfp style motion parameter and derivative regressors for timeseries
# Take the backwards temporal derivative in column $1 of input $2 and output it as $3
# Vectorized Matlab: d=[zeros(1,size(a,2));(a(2:end,:)-a(1:end-1,:))];
# Bash version of above algorithm
function DeriveBackwards {
  i="$1"
  in="$2"
  out="$3"
  # Var becomes a string of values from column $i in $in. Single space separated
  Var=`cat "$in" | sed s/"  "/" "/g | cut -d " " -f $i`
  Length=`echo $Var | wc -w`
  # TCS becomes an array of the values from column $i in $in (derived from Var)
  TCS=($Var)
  # random is a random file name for temporary output
  random=$RANDOM

  # Cycle through our array of values from column $i
  j=0
  while [ $j -lt $Length ] ; do
    if [ $j -eq 0 ] ; then
      # Backward derivative of first volume is set to 0
      Answer=`echo "0"`
    else
      # Compute the backward derivative of non-first volumes

      # Format numeric value (convert scientific notation to decimal) jth row of ith column
      # in $in (mcpar)
      Forward=`echo ${TCS[$j]} | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}'`
    
      # Similarly format numeric value for previous row (j-1)
      Back=`echo ${TCS[$(($j-1))]} | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}'`

      # Compute backward derivative as current minus previous
      Answer=`echo "scale=10; $Forward - $Back" | bc -l`
    fi
    # 0 prefix the resulting number
    Answer=`echo $Answer | sed s/"^\."/"0."/g | sed s/"^-\."/"-0."/g`
    echo `printf "%10.6f" $Answer` >> $random
    j=$(($j + 1))
  done
  paste -d " " $out $random > ${out}_
  mv ${out}_ ${out}
  rm $random
}

# Run the Derive function to generate appropriate regressors from the par file
echo "Run the Derive function to generate appropriate regressors from the par file"
in=${WorkingDirectory}/${OutputfMRIBasename}.par
out=${OutputMotionRegressors}.txt
cat $in | sed s/"  "/" "/g > $out
i=1
while [ $i -le 6 ] ; do
  DeriveBackwards $i $in $out
  i=`echo "$i + 1" | bc`
done

cat ${out} | awk '{for(i=1;i<=NF;i++)printf("%10.6f ",$i);printf("\n")}' > ${out}_
mv ${out}_ $out

awk -f ${HCPPIPEDIR_Global}/mtrendout.awk $out > ${OutputMotionRegressors}_dt.txt



echo ""
echo "#############################################"
echo "                     QC                      "
echo "#############################################"
echo ""

echo "FMRI_QCMotion.sh -d ${WorkingDirectory} -i ${InputfMRI} -mc ${OutputfMRI} -o ${WorkingDirectory}/QCmotion -dvth ${DVTH} -fdth ${FDTH}"
FMRI_QCMotion.sh -d ${WorkingDirectory} -i ${InputfMRI} -mc ${OutputfMRI} -o ${WorkingDirectory}/QCmotion -dvth ${DVTH} -fdth ${FDTH}



echo ""
echo "END: FMRI_MotionCorrectionByFSL.sh"
echo ""



