sd=$1
ref=$2
ref=${ref%%.nii*}

cd $sd

tbss_1_preproc_ants.sh *gz


mkdir -p $sd/FA/ANTS/Logdir
echo $ref >> $sd/FA/best.msf

gunzip $sd/FA/*gz

target=$sd/FA/${ref}_FA.nii

for FA in `ls $sd/FA | grep FA.nii`
do

echo "" 
echo ""
echo ""
echo $FA

base=${FA%%.nii*}

FA=$sd/FA/$FA

echo "qbatch -q fs_q -oe $sd/FA/ANTS/Logdir -N ANTS$base ANTS 3 -m CC[$target,$FA,1,5] -i 100*100*10 -o $sd/FA/ANTS/${base}_to_target.nii"
qbatch -q fs_q -oe $sd/FA/ANTS/Logdir -N ANTS$base ANTS 3 -m CC[$target,$FA,1,5] -i 100*100*10 -o $sd/FA/ANTS/${base}_to_target.nii
sleep 1

done

JOBS=`qstat | grep ANTS | wc -l`
while [ $JOBS -gt 0 ]
do
echo "ANTS recal is still runing"
JOBS=`qstat | grep ANTS | wc -l`
sleep 20
done



for FA in `ls $sd/FA | grep FA.nii`
do

echo "" 
echo ""
echo ""
echo $FA

base=${FA%%.nii*}
FA=$sd/FA/$FA


echo "qbatch -q fs_q -oe $sd/FA/ANTS/Logdir -N ANTS2$base WarpImageMultiTransform 3 $FA $sd/FA/ANTS/${base}_to_target.nii -R $target $sd/FA/ANTS/${base}_to_targetWarp.nii $sd/FA/ANTS/${base}_to_targetAffine.txt"
qbatch -q fs_q -oe $sd/FA/ANTS/Logdir -N ANTS2$base WarpImageMultiTransform 3 $FA $sd/FA/ANTS/${base}_to_target.nii -R $target $sd/FA/ANTS/${base}_to_targetWarp.nii $sd/FA/ANTS/${base}_to_targetAffine.txt

echo "qbatch -q fs_q -oe $sd/FA/ANTS/Logdir -N ANTS2A$base WarpImageMultiTransform 3 $FA $sd/FA/ANTS/${base}_to_targetAffine.nii -R $target $sd/FA/ANTS/${base}_to_targetAffine.txt"
qbatch -q fs_q -oe $sd/FA/ANTS/Logdir -N ANTS2A$base WarpImageMultiTransform 3 $FA $sd/FA/ANTS/${base}_to_targetAffine.nii -R $target $sd/FA/ANTS/${base}_to_targetAffine.txt

sleep 1

done

JOBS=`qstat | grep ANTS | wc -l`
while [ $JOBS -gt 0 ]
do
echo "ANTS recal is still runing"
sleep 20
JOBS=`qstat | grep ANTS | wc -l`
done




for FA in `ls $sd/FA | grep FA.nii`
do

echo "" 
echo ""
echo ""
echo $FA

base=${FA%%.nii*}
FA=$sd/FA/$FA

cp -f $sd/FA/ANTS/${base}_to_target.nii $sd/FA/${base}_FA_to_target.nii
gzip $sd/FA/${base}_FA_to_target.nii

done

mkdir -p $sd/stats/all_FA_to_target

cp -f $sd/FA/*FA_to_target.nii.gz $sd/stats/all_FA_to_target
fslmerge -t $sd/stats/all_FA $sd/stats/all_FA_to_target/*.gz

fslmaths $sd/stats/all_FA.nii.gz -Tmean $sd/stats/mean_FA.nii.gz
fslmaths $sd/stats/mean_FA.nii.gz -thr 0.05 $sd/stats/mean_FA_mask
fslmaths $sd/stats/mean_FA_mask.nii.gz -bin $sd/stats/mean_FA_mask.nii.gz
tbss_skeleton -i $sd/stats/mean_FA.nii.gz -o $sd/stats/mean_FA_skeleton.nii.gz



#tbss_fill tbss_tfce_corrp_tstat1 0.95 mean_FA tbss_fill_FA_1
#tbss_fill tbss_tfce_corrp_tstat2 0.95 mean_FA tbss_fill_FA_2
