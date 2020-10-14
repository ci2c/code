#!/bin/bash


if [ $# -lt 6 ]
then
	echo "Usage: DTI_reduce_dir.sh -dti <dti_file> -b <bvec ref> -n <dir_number>"
	echo ""
	echo "	-dti 					: dti file"	
	echo "	-b 						: bvec ref"
	echo "	-n 						: number of new dir"
	echo "Usage: DTI_reduce_dir.sh -dti <dti_file> -b <bvec ref> -n <dir_number>"
	echo ""
	exit 1
fi



index=1
echo ""
echo ""
echo ""
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo "Usage: DTI_reduce_dir.sh -dti <dti_file> -b <bvec ref> -n <dir_number>"
		echo ""
		echo "	-dti 					: dti file"	
		echo "	-b 						: bvec ref"
		echo "	-n 						: number of new dir"
		echo "Usage: DTI_reduce_dir.sh -dti <dti_file> -b <bvec ref> -n <dir_number>"
		echo ""
		exit 1
		;;
	-dti)
		index=$[$index+1]
		eval dti=\${$index}
		echo "dti file  : $dti"
		;;
	-b)
		index=$[$index+1]
		eval bvec_ref=\${$index}
		echo "bvec ref : $bvec_ref"
		;;
	-n)
		index=$[$index+1]
		eval ndir=\${$index}
		echo "number of new dir : $ndir"
		;;
	esac
	index=$[$index+1]
done




dti_path=`dirname $dti`
dti_name=`basename $dti`
dti_name=${dti_name%%.*}

bvec_pat=$dti_path/${dti_name}.bvec

echo "bvec patient : $bvec_pat"
echo "bvec reference : $bvec_ref"


# Organisation des nouveaux fichiers

echo "mkdir -p $dti_path/DTI_${ndir}dir/split"
mkdir -p $dti_path/DTI_${ndir}dir/split

echo "fslsplit $dti_path/${dti_name}.nii* $dti_path/DTI_${ndir}dir/split/$dti_name"
fslsplit $dti_path/${dti_name}.nii* $dti_path/DTI_${ndir}dir/split/$dti_name

echo "DTI_reduce_dir('$bvec_ref','$dti_path','$dti_name','$dti_path/DTI_${ndir}dir')"
# Matlab

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

addpath('/home/tanguy/matlab')

DTI_reduce_dir('$bvec_ref','$dti_path','$dti_name','$dti_path/DTI_${ndir}dir')

EOF

cat $dti_path/DTI_${ndir}dir/DTI_${ndir}_dir_vol_sup.txt
`cat $dti_path/DTI_${ndir}dir/DTI_${ndir}_dir_vol_sup.txt`

echo "fslmerge -t $dti_path/DTI_${ndir}dir/DTI_${n}_dir_${dti_name} $dti_path/DTI_${ndir}dir/split/$dti_name*"
fslmerge -t $dti_path/DTI_${ndir}dir/DTI_${ndir}_dir_${dti_name} $dti_path/DTI_${ndir}dir/split/$dti_name*

echo "rm -Rf $dti_path/DTI_${ndir}dir/split"
rm -Rf $dti_path/DTI_${ndir}dir/split
echo "rm -f $dti_path/DTI_${ndir}dir/DTI_${ndir}_dir_vol_sup.txt "
rm -f $dti_path/DTI_${ndir}dir/DTI_${ndir}_dir_vol_sup.txt 


echo ""
echo ""
echo "end of DTI_reduce_dir.sh script"