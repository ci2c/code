#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: mgz2FSLnii.sh Input.mgz Reference.nii Output.nii Transform.mat"
	echo ""
	echo "  Input.mgz            : File in .mgz format"
	echo "  Reference.nii        : Images .nii in FSL space, usually a 3D DTI"
	echo "  Output.nii           : Name of the output file (i.e. example.nii.gz)"
	echo "  Transform.mat        : Transformation matrix from T1 to DTI."
	echo "                 Will be used if already created, otherwise will be outputed"
	echo ""
	echo "Usage: mgz2FSLnii.sh Input.mgz Reference.nii Output.nii Transform.mat"
	echo ""
	exit 1
fi

# I/O management
infile=$1
ref=$2
outfile=$3
outmat=$4
outpath=`dirname $3`

###
# Step 1. Check if DTI volume if 3D or 4D
###
N_vol=`fslnvols ${ref}`
if [ ! ${N_vol} -eq 1 ]
then
	echo "fslsplit ${ref} ${outpath}/vol"
	fslsplit ${ref} ${outpath}/vol
	mv ${outpath}/vol0000.nii.gz ${outpath}/dti_b0.nii.gz
	gunzip -f ${outpath}/dti_b0.nii.gz
	ref=${outpath}/dti_b0.nii
	rm -f ${outpath}/vol00*
fi

###
# Step 2. Place T1 to FSL-DTI space
###
#echo "nii2mnc ${ref} ${outpath}/ref_$$.mnc"
#nii2mnc ${ref} ${outpath}/ref_$$.mnc

#echo "mnc2nii ${outpath}/ref_$$.mnc ${outpath}/ref_2_$$.nii"
#mnc2nii ${outpath}/ref_$$.mnc ${outpath}/ref_2_$$.nii

echo "mri_convert ${infile} ${outpath}/ref_3_$$.nii --out_orientation RAS"
mri_convert ${infile} ${outpath}/ref_3_$$.nii --out_orientation RAS

echo "fslswapdim ${outpath}/ref_3_$$ -x y z ${outpath}/ref_4_$$"
fslswapdim ${outpath}/ref_3_$$ -x y z ${outpath}/ref_4_$$
# cp ${outpath}/ref_3_$$.nii ${outpath}/ref_4_$$.nii
# echo "fslorient -swaporient ${outpath}/ref_4_$$"
# fslorient -swaporient ${outpath}/ref_4_$$

# echo "fslcpgeom ${ref} ${outpath}/ref_4_$$"
# fslcpgeom ${ref} ${outpath}/ref_4_$$

###
# Step 3. Align FSL-T1 on 3D FSL-DTI
###
if [ ! -f ${outmat} ]
then
	#echo "flirt -usesqform -in ${outpath}/ref_4_$$ -ref ${ref} -out ${outfile} -omat ${outmat}"
	#flirt -usesqform -in ${outpath}/ref_4_$$ -ref ${ref} -out ${outfile} -omat ${outmat}
	echo "flirt -in ${outpath}/ref_4_$$ -ref ${ref} -out ${outfile} -omat ${outmat}"
	flirt -in ${outpath}/ref_4_$$ -ref ${ref} -out ${outfile} -omat ${outmat}
else
	echo "flirt -in ${outpath}/ref_4_$$ -applyxfm -init ${outmat} -out ${outfile} -paddingsize 0.0 -interp trilinear -ref ${ref}"
	flirt -in ${outpath}/ref_4_$$ -applyxfm -init ${outmat} -out ${outfile} -paddingsize 0.0 -interp trilinear -ref ${ref}
fi

rm -f ${outpath}/ref_$$* ${outpath}/ref_2_$$* ${outpath}/ref_3_$$* ${outpath}/ref_3_$$* ${outpath}/ref_4_$$*
