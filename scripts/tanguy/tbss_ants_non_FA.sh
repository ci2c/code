#!/bin/sh

if [ _$1 = _ ] ; then
    echo "Usage: tbss_ants_non_FA <alternative-image-rootname>"
    echo "e.g.: tbss_ants_non_FA L2"
    exit 1
else
    ALTIM=$1
fi

sd=$2

nbperm=5000;


echo [`date`] [`hostname`] [`uname -a`] [`pwd`] [$0 $@] >> .tbsslog

target=`cat $sd/FA/best.msf`
target=$sd/FA/${target}_FA.nii.gz
echo "using pre-chosen registration target: $target"


for im in `ls $sd/$ALTIM`
do

echo "" 
echo ""
echo ""
echo $im

imbase=${im%%.nii.gz}
cp -f $sd/$ALTIM/$im $sd/FA/${imbase}_${ALTIM}.nii.gz


echo "qbatch -q fs_q -oe $sd/FA/ANTS/Logdir -N ANTS2${ALTIM}$imbase WarpImageMultiTransform 3 $sd/FA/${imbase}_${ALTIM}.nii.gz $sd/FA/ANTS/${imbase}_to_target_${ALTIM}.nii.gz -R $target $sd/FA/ANTS/${imbase}_to_targetWarp.nii $sd/FA/ANTS/${imbase}_to_targetAffine.txt"
qbatch -q short.q -oe $sd/FA/ANTS/Logdir -N ANTS2${ALTIM}$imbase WarpImageMultiTransform 3 $sd/FA/${imbase}_${ALTIM}.nii.gz $sd/FA/${imbase}_to_target_${ALTIM}.nii.gz -R $target $sd/FA/ANTS/${imbase}_FA_to_targetWarp.nii $sd/FA/ANTS/${imbase}_FA_to_targetAffine.txt

sleep 1

done

${ALTIM}
JOBS=`qstat | grep ANTS | wc -l`
while [ $JOBS -gt 0 ]
do
echo "ANTS recal is still runing"
JOBS=`qstat | grep ANTS | wc -l`
sleep 5
done



echo "merging all upsampled $ALTIM images into single 4D image"
${FSLDIR}/bin/fslmerge -t $sd/stats/all_$ALTIM $sd/FA/*to_target_${ALTIM}*
cd $sd/stats
$FSLDIR/bin/fslmaths all_$ALTIM -mas mean_FA_mask all_$ALTIM

echo "projecting all_$ALTIM onto mean FA skeleton"
thresh=`cat thresh.txt`
${FSLDIR}/bin/tbss_skeleton -i mean_FA -p $thresh mean_FA_skeleton_mask_dst ${FSLDIR}/data/standard/LowerCingulum_1mm all_FA all_${ALTIM}_skeletonised -a all_$ALTIM

echo "now runing stats"

cd $sd/stats
randomise -i all_${ALTIM}_skeletonised -o tbss_${ALTIM} -m mean_FA_skeleton_mask -d design.mat -t design.con -n $nbperm --T2 -V
