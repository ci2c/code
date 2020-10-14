#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: Repair_DTI.sh  <DTI1>  [<DTI2>]  <OutputDTI>"
	echo ""
	echo "  DTI1            : DTI to be repaired if needed (.nii or .nii.gz)"
	echo "  DTI2            : DTI used for repairing DTI1 if needed (.nii or .nii.gz) [Optional]"
	echo "  OutputDTI       : Name of the output repaired DTI (NO extension)"
	echo ""
	echo "Usage: Repair_DTI.sh  <DTI1>  [<DTI2>]  <OutputDTI>"
	echo ""
	exit 1
fi

# Inputs
if [ $# -eq 3 ]
then
	dti1=$1
	bvec1=${dti1%.gz}
	bvec1=${bvec1%.nii}.bvec
	dti2=$2
	bvec2=${dti2%.gz}
	bvec2=${bvec2%.nii}.bvec
	outdti=$3
else
	dti1=$1
	bvec1=${dti1%.gz}
	bvec1=${bvec1%.nii}.bvec
	outdti=$2
	dti2=[]
	bvec2=[]
fi

indir=`dirname ${dti1}`
outdir=`dirname ${outdti}`
cd ${outdir}

# Extract brain mask temp_brain_mask.nii.gz
echo "bet ${dti1} temp_brain  -f 0.3 -g 0 -n -m"
brain_mask="temp_brain_mask.nii.gz"
bet ${dti1} temp_brain  -f 0.3 -g 0 -n -m

echo "repairBlackSlices(${dti1}, ${bvec1}, ${brain_mask}, ${dti2}, ${bvec2});"

# Find abnormal slices [matlab]
matlab -nodisplay <<EOF
cd ${HOME}
p = pathdef;
addpath(p);
cd ${indir}
repairBlackSlices('${dti1}', '${bvec1}', '${brain_mask}', '${dti2}', '${bvec2}');
EOF

if [ -f volumes_to_repair.txt ]
then
	echo "Fixing DTI"
	echo "fslsplit ${DTI1} temp1 -t"
	fslsplit ${DTI1} temp1 -t
	ls temp1* > TEMP1.txt
	
	echo "fslsplit ${DTI2} temp2 -t"
	fslsplit ${DTI2} temp2 -t
	ls temp2* > TEMP2.txt
	
	for LINE in `cat volumes_to_repair.txt`
	do
		TO_REMOVE=`sed -n "${LINE}{p;q}" TEMP1.txt`
		rm -f ${TO_REMOVE}
		TO_RENAME=`sed -n "${LINE}{p;q}" TEMP2.txt`
		mv ${TO_RENAME} ${TO_REMOVE}
	done
	
	rm -f temp2*.nii.gz TEMP1.txt TEMP2.txt
	
	echo "fslmerge -t ${outdti} temp1*.nii.gz"
	fslmerge -t ${outdti} temp1*.nii.gz
	
	mv temp.bvec ${outdti}.bvec
else
	cp ${dti1} ${outdti}.nii.gz
	cp ${bvec1} ${outdti}.bvec
fi

rm -f ${brain_mask}
