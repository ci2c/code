#!/bin/bash


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_FA_ictus.sh -sd <Subject DIR> -subj <Subject> "
	echo ""
	echo "	-sd 					: Subject directory"
	echo ""
	echo "	-subj 					: Subject"
	echo "Usage: DTI_FA_ictus.sh -sd <Subject DIR> -subj <Subject> "
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
		echo "Usage: DTI_FA_ictus.sh -sd <Subject DIR> -subj <Subject> "
		echo ""
		echo "	-sd 					: Subject directory"
		echo ""
		echo "	-subj 					: Subject"
		echo "Usage: DTI_FA_ictus.sh -sd <Subject DIR> -subj <Subject> "
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

bvec_ref='/home/tanguy/dumbo/tanguy/ictus/TBSS/Data/TEMOINS_temp/bvecref.bvec'

echo "DIR=${sd}/${subj}"
DIR=${sd}/${subj}

dti=`ls $DIR/*bval`
dti=`basename $dti`
dti=${dti%%.*}

echo "dti basename : $dti"

dti_info=$(sed 's/ /\n/g' $DIR/${dti}.bval | sort | uniq -c)
ndir=$( echo $dti_info | awk '{print $((NF-1))}')
nb0=$( echo $dti_info | awk '{print $((NF-3))}')



echo ""
echo ""
echo ""
echo "DTI_mean_B0.sh -dti $DIR/${dti}.nii.gz $DIR/dti/orig/dti1.nii.gz"
DTI_mean_B0.sh -dti $DIR/${dti}.nii.gz 



#si besoin : harmonisation à 25dir



if [ -f $DIR/${dti}.nii ]
	then
	echo "gzip $DIR/${dti}.nii"
	gzip $DIR/${dti}.nii
elif [ ! -f $DIR/${dti}.nii.gz ]
	then
	echo "ne trouve pas le fichier dti"
fi

if [ $ndir -gt 25 ]
	then
	echo ""	
	echo "dti pour $subj à $ndir directions"
	echo "harmonisation à 25 dir"
	echo "reference pour l'harmonisation : gaulier_annunziata.bvec"
	echo ""
	echo ""
	echo "DTI_reduce_dir.sh -dti $DIR/${dti}.nii.gz -b $bvec_ref -n 25"
	DTI_reduce_dir.sh -dti $DIR/${dti}.nii.gz -b $bvec_ref -n 25

	echo "DIR=$DIR/DTI_25dir"
	DIR=$DIR/DTI_25dir
	echo "dti=DTI_25_dir_${dti}"
	dti=DTI_25_dir_${dti}

elif [ $ndir -lt 25 ]
	
	then
	echo "pas assez de directions"
	exit 1
else
	mkdir $DIR/DTI_25dir
	echo "cp -f $DIR/${dti}.bval $DIR/DTI_25dir/DTI_25_dir_${dti}.bval"
	cp -f $DIR/${dti}.bval $DIR/DTI_25dir/DTI_25_dir_${dti}.bval
	echo "cp -f $DIR/${dti}.bvec $DIR/DTI_25dir/DTI_25_dir_${dti}.bvec"
	cp -f $DIR/${dti}.bvec $DIR/DTI_25dir/DTI_25_dir_${dti}.bvec
	echo "cp -f $DIR/${dti}.nii.gz $DIR/DTI_25dir/DTI_25_dir_${dti}.nii.gz"
	cp -f $DIR/${dti}.nii.gz $DIR/DTI_25dir/DTI_25_dir_${dti}.nii.gz
	DIR=${DIR}/DTI_25dir
	dti=DTI_25_dir_${dti}

fi



echo "mkdir -p $DIR/dti/orig"
mkdir -p $DIR/dti/orig



if [ -f $DIR/${dti}.nii ]
	then
	gzip $DIR/${dti}.nii
elif [ ! -f $DIR/${dti}.nii.gz ]
	then
	echo "impossible de trouver le fichier dti"
	echo "$DIR/${dti}.nii"
	exit 1
fi



echo "cp -f $DIR/${dti}.nii.gz $DIR/dti/orig/dti1.nii.gz"
cp -f $DIR/${dti}.nii.gz $DIR/dti/orig/dti1.nii.gz
echo "cp -f $DIR/${dti}.bval $DIR/dti/orig/dti1.bval"
cp -f $DIR/${dti}.bval $DIR/dti/orig/dti1.bval
echo "cp -f $DIR/${dti}.bvec $DIR/dti/orig/dti1.bvec"
cp -f $DIR/${dti}.bvec $DIR/dti/orig/dti1.bvec



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
