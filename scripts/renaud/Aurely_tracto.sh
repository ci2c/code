#!/bin/bash


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Aurely_tracto.sh -sd <Subject DIR> -subj <Subject> "
	echo ""
	echo "	-sd 					: Subject directory"
	echo ""
	echo "	-subj 					: Subject"
	echo "Usage: Aurely_tracto.sh -sd <Subject DIR> -subj <Subject> "
	echo ""
	exit 1
	exit 1
fi



index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Aurely_tracto.sh -sd <Subject DIR> -subj <Subject> "
		echo ""
		echo "	-sd 					: Subject directory"
		echo ""
		echo "	-subj 					: Subject"
		echo "Usage: Aurely_tracto.sh -sd <Subject DIR> -subj <Subject> "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval sd=\${$index}
		echo "Subject directory : $sd"
		;;

	
	-subj)
		index=$[$index+1]
		eval subj=\${$index}
		echo "subj : $subj"
		;;
	esac
	index=$[$index+1]
done


echo "labels=/home/tanguy/dumbo/protocoles/ictus/Connectome/aparc2009LOI_ictus.txt"
labels=/home/tanguy/dumbo/protocoles/ictus/Connectome/aparc2009LOI_ictus.txt

if [ ! -d $sd/$subj/dti_connectome ]
then
    mkdir $sd/$subj/dti_connectome
fi

if [ ! -f $sd/$subj/dti_connectome/data_corr.nii ]
then

    echo "cp -f $sd/$subj/dti/data_corr.nii.gz $sd/$subj/dti_connectome"
    cp -f $sd/$subj/dti/data_corr.nii.gz $sd/$subj/dti_connectome

    echo "gunzip $sd/$subj/dti_connectome/data_corr.nii.gz"
    gunzip $sd/$subj/dti_connectome/data_corr.nii.gz

fi

echo "CMatrixVolume_mrtrix.sh -fs $sd -subj $subj -parcname aparc.a2009s+aseg.mgz -labels $labels -dti $sd/$subj/dti_connectome/data_corr.nii -bvecs $sd/$subj/dti/data.bvec -bvals $sd/$subj/dti/data.bval -outdir $sd/$subj/dti_connectome -N 300000 -no_CM"
CMatrixVolume_mrtrix.sh -fs $sd -subj $subj -parcname aparc.a2009s+aseg.mgz -labels $labels -dti $sd/$subj/dti_connectome/data_corr.nii -bvecs $sd/$subj/dti/data.bvec -bvals $sd/$subj/dti/data.bval -outdir $sd/$subj/dti_connectome -N 300000
