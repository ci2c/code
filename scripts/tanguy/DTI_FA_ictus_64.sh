#!/bin/bash


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_FA_ictus_64.sh -sd <Subject DIR> -subj <Subject> "
	echo ""
	echo "	-sd 					: Subject directory"
	echo ""
	echo "	-subj 					: Subject"
	echo "Usage: DTI_FA_ictus_64.sh -sd <Subject DIR> -subj <Subject> "
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
		echo "Usage: DTI_FA_ictus_64.sh -sd <Subject DIR> -subj <Subject> "
		echo ""
		echo "	-sd 					: Subject directory"
		echo ""
		echo "	-subj 					: Subject"
		echo "Usage: DTI_FA_ictus_64.sh -sd <Subject DIR> -subj <Subject> "
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


#init


echo "DIR=${sd}/${subj}"
DIR=${sd}/${subj}

dti=`ls $DIR/orig/*bval`
dti=`basename $dti`
dti=${dti%%.*}

if [ -f $DIR/orig/${dti}.nii ]
then
	gzip $DIR/orig/${dti}.nii
fi


echo "dti basename : $dti"

dti_info=$(sed 's/ /\n/g' $DIR/orig/${dti}.bval | sort | uniq -c)
ndir=$( echo $dti_info | awk '{print $((NF-1))}')
nb0=$( echo $dti_info | awk '{print $((NF-3))}')



# si besoin : moyenne des cartes B0

if [ $nb0 -gt 1 ]
	then
	echo "DTI_mean_B0.sh -dti $DIR/orig/${dti}.nii.gz"
	DTI_mean_B0.sh -dti $DIR/orig/${dti}.nii.gz
fi



echo "mkdir -p $DIR/dti/orig"
mkdir -p $DIR/dti/orig



echo "cp -f $DIR/orig/${dti}.nii.gz $DIR/dti/orig/dti1.nii.gz"
cp -f $DIR/orig/${dti}.nii.gz $DIR/dti/orig/dti1.nii.gz
echo "cp -f $DIR/orig/${dti}.bval $DIR/dti/orig/dti1.bval"
cp -f $DIR/orig/${dti}.bval $DIR/dti/orig/dti1.bval
echo "cp -f $DIR/orig/${dti}.bvec $DIR/dti/orig/dti1.bvec"
cp -f $DIR/orig/${dti}.bvec $DIR/dti/orig/dti1.bvec



if [ ! -d ${DIR}/dti/steps ]
then
	echo "mkdir ${DIR}/dti/steps"
	mkdir ${DIR}/dti/steps
fi

if [ ! -f ${DIR}/dti/steps/eddy-correct.touch ]
then
	cp ${DIR}/dti/orig/dti1.nii.gz ${DIR}/dti/temp.nii.gz
	cp ${DIR}/dti/orig/dti1.bvec ${DIR}/dti/data.bvec
	cp ${DIR}/dti/orig/dti1.bval ${DIR}/dti/data.bval
	echo "eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data_corr 0"
	eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data_corr 0
	rm -f ${DIR}/dti/temp.nii.gz
	echo "touch ${DIR}/dti/steps/eddy-correct.touch"
	touch ${DIR}/dti/steps/eddy-correct.touch
fi

output=dti

echo "rotate_bvecs ${DIR}/${output}/data_corr.ecclog ${DIR}/${output}/data.bvec"
rotate_bvecs ${DIR}/${output}/data_corr.ecclog ${DIR}/${output}/data.bvec


echo "bet ${DIR}/${output}/data_corr ${DIR}/${output}/data_corr_brain -F -f 0.25 -g 0 -m"
bet ${DIR}/${output}/data_corr ${DIR}/${output}/data_corr_brain -F -f 0.25 -g 0 -m


echo "dtifit --data=${DIR}/${output}/data_corr.nii.gz --out=${DIR}/${output}/data_corr --mask=${DIR}/${output}/data_corr_brain_mask.nii.gz --bvecs=${DIR}/${output}/data.bvec --bvals=${DIR}/${output}/data.bval"
dtifit --data=${DIR}/${output}/data_corr.nii.gz --out=${DIR}/${output}/data_corr --mask=${DIR}/${output}/data_corr_brain_mask.nii.gz --bvecs=${DIR}/${output}/data.bvec --bvals=${DIR}/${output}/data.bval



