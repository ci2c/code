#!/bin/bash

SD=$1
SUBJ=$2

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}


for petdir in `ls ${DIR}`
do
if [ -d $DIR/$petdir ];
then
mkdir $DIR/pet
dcm2nii -o $DIR/$petdir $DIR/$petdir/*
nb=`ls -1 $DIR/$petdir/*gz |wc -l`
count=1
for i in `ls $DIR/$petdir/*nii.gz`
do
new=`echo "$nb-$count+1"|bc`
j=$(printf "%.4d" $new)
mv $i $DIR/$petdir/pet_$j.nii.gz
echo "rename : $i >> pet_$j.nii.gz"
count=$[$count+1]
done

fslmerge -z $DIR/$petdir/PET.nii.gz $DIR/$petdir/*gz
mri_convert $DIR/$petdir/PET.nii.gz --out_type spm --out_orientation LAS $DIR/$petdir/PET
rm $DIR/$petdir/*gz
mv $DIR/$petdir/PET* $DIR/pet
echo
fi
done

mkdir $DIR/raw
mv ${DIR}/*rec ${DIR}/*par $DIR/raw
dcm2nii -o ${DIR}/raw -a n -d n -f n -e n ${DIR}/raw/*rec
rm -fr ${DIR}/raw/co*3dt1*.nii
rm -fr ${DIR}/raw/o*3dt1*.nii
rm -fr ${DIR}/raw/o*t13d*.nii
rm -fr ${DIR}/raw/co*t13d*.nii
echo
echo

mkdir -p ${DIR}/mri/orig
mkdir ${DIR}/asl


for i in `ls ${DIR}/raw/*gz | grep -i -e star -e pcasl`
do
echo
echo "========================="
echo "correction du volume $i"
echo "========================="
echo
index=`echo $i |sed -n "s/^.*x\([0-9]\)\.nii.*/\1/p"`
eddy_correct $i ${DIR}/asl/raw_ASL_recal_${index}.nii 0
fslmaths ${DIR}/asl/raw_ASL_recal_${index}.nii.gz -Tmean ${DIR}/asl/Vol_${index}_mean.nii.gz -odt double
done

fslmaths ${DIR}/asl/Vol_2_mean.nii.gz -sub ${DIR}/asl/Vol_1_mean.nii.gz ${DIR}/asl/mean.nii.gz
mri_convert $DIR/asl/mean.nii.gz --out_type spm --out_orientation LAS $DIR/asl/ASL

for d in `ls ${DIR}/raw/*gz | grep -i 3dt1`
do
mri_convert $d --out_type spm --out_orientation LAS $DIR/mri/orig/T1
done

#recon-all -all -subjid ${SUBJ} -sd ${SD} -nuintensitycor-3T
#recon-all -qcache -subjid ${SUBJ} -sd ${SD}

echo "======================================================================="
echo "Vous devez traiter les cartos PET et ASL avec PVELAB avant de continuer"
echo "              Dans un terminal : taper pvelab !!!!!!!!       "				     
echo "======================================================================="



