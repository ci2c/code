#!/bin/bash


if [ $# -lt 2 ]
then
	echo "Usage: DTI_mean_B0.sh -dti <dti_file> [ -bval <bval file> -bvec <bvec file>"
	echo ""
	echo "	-dti 					: dti file"	
	echo "	-bval 					: [fac] bval file (if the basename is different)"
	echo "	-bvec 					: [fac] bvec file (if the basename is different)"
	echo "Usage: DTI_mean_B0.sh -dti <dti_file>[ -bval <bval file> -bvec <bvec file>"
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
		echo ""
		echo "Usage: DTI_mean_B0.sh -dti <dti_file> [ -bval <bval file> -bvec <bvec file>"
		echo ""
		echo "	-dti 					: dti file"	
		echo "	-bval 					: [fac] bval file (if the basename is different)"
		echo "	-bvec 					: [fac] bvec file (if the basename is different)"
		echo "Usage: DTI_mean_B0.sh -dti <dti_file>[ -bval <bval file> -bvec <bvec file>"
		echo ""
		exit 1
		;;
	-dti)
		index=$[$index+1]
		eval dti=\${$index}
		echo "dti file  : $dti"
		;;

	
	-bval)
		index=$[$index+1]
		eval bval=\${$index}
		echo "bval file  : $bval"
		;;


	-bvec)
		index=$[$index+1]
		eval bvec=\${$index}
		echo "bvec file  : $bvec"
		;;

	esac
	index=$[$index+1]
done


dti_name=`basename $dti`
dti_name=${dti_name%%.*}
echo "dti basename : $dti_name"
dti_path=`dirname $dti`
echo "dti path : $dti_path/"

dti_info=$(sed 's/ /\n/g' $dti_path/${dti_name}.bval | sort | uniq -c)
nb0=$( echo $dti_info | awk '{print $((NF-3))}')

echo "nombre de volume B0 : $nb0"

if [ $nb0 -gt 1 ]
	then

	echo "mkdir $dti_path/tmp_dti"
	mkdir $dti_path/tmp_dti
	echo "fslsplit $dti_path/${dti_name}.nii.gz $dti_path/tmp_dti/$dti_name -t"
	fslsplit $dti_path/${dti_name}.nii.gz $dti_path/tmp_dti/$dti_name -t

	mkdir $dti_path/tmp_dti/B0
	for ((ind = 0; ind < ${nb0}; ind += 1))
	do
		filename=`ls -1 ${dti_path}/tmp_dti/${dti_name}* | sed -ne "1p"`
		filename=`basename $filename`
		echo "mv ${dti_path}/tmp_dti/${filename} $dti_path/tmp_dti/B0"
		mv ${dti_path}/tmp_dti/${filename} $dti_path/tmp_dti/B0
	done
	echo "fslmerge -t $dti_path/tmp_dti/B0/dti_B0 $dti_path/tmp_dti/B0/${dti_name}*"
	fslmerge -t $dti_path/tmp_dti/B0/dti_B0 $dti_path/tmp_dti/B0/${dti_name}*
	echo "fslmerge -t $dti_path/tmp_dti/dti_dir $dti_path/tmp_dti/${dti_name}*"
	fslmerge -t $dti_path/tmp_dti/dti_dir $dti_path/tmp_dti/${dti_name}*
	echo "fslmaths $dti_path/tmp_dti/B0/dti_B0* -Tmean $dti_path/tmp_dti/B0/dti_B0_mean"
	fslmaths $dti_path/tmp_dti/B0/dti_B0* -Tmean $dti_path/tmp_dti/B0/dti_B0_mean

	echo "fslmerge -t $dti_path/tmp_dti/dti_corr $dti_path/tmp_dti/B0/dti_B0_mean* $dti_path/tmp_dti/dti_dir*"
	fslmerge -t $dti_path/tmp_dti/dti_corr $dti_path/tmp_dti/B0/dti_B0_mean* $dti_path/tmp_dti/dti_dir*

	# correction du fichier bval
	
	bval=`cat $dti_path/${dti_name}.bval`
	echo "echo ${bval:$(($nb0*2+1-$nb0)):$((${#bval}))} > $dti_path/tmp_dti/dti_corr.bval"
	echo ${bval:$(($nb0*2+1-$nb0)):$((${#bval}))} > $dti_path/tmp_dti/dti_corr.bval

	# correction du fichier bvec
	echo "cat $dti_path/${dti_name}.bvec | cut -d' ' -f $nb0- > $dti_path/tmp_dti/dti_corr.bvec"
	cat $dti_path/${dti_name}.bvec | cut -d' ' -f $nb0- > $dti_path/tmp_dti/dti_corr.bvec

	mkdir $dti_path/dti_${nb0}_B0
	mv $dti_path/${dti_name}* $dti_path/dti_${nb0}_B0
	mv $dti_path/tmp_dti/dti_corr.bvec $dti_path/${dti_name}.bvec
	mv $dti_path/tmp_dti/dti_corr.bval $dti_path/${dti_name}.bval
	mv $dti_path/tmp_dti/dti_corr.nii.gz $dti_path/${dti_name}.nii.gz

	rm -Rf $dti_path/tmp_dti/ 

else
	echo "un seul volume B0 : pas de correction à faire."
fi



