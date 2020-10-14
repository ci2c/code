echo ""
echo ""
echo "############################################"
echo "#                                          #"
echo "# Création des matrices de transformations #"
echo "#                                          #"
echo "############################################"
echo ""
echo ""



echo "sd=/NAS/dumbo/protocoles/ictus/ANTS_TBSS/recal_ANTS"
sd=/NAS/dumbo/protocoles/ictus/ANTS_TBSS/recal_ANTS

echo "target=FMRIB58_FA_1mm.nii"
targetbase=FMRIB58_FA_1mm.nii



for FA in `ls $sd | grep pat | grep nii`
do

echo "" 
echo ""
echo ""
echo $FA

fold=${FA%%.nii*}

#mkdir $sd/$fold
#cp -f $sd/$targetbase $sd/$fold/$targetbase
#cp -f $sd/$FA $sd/$fold/$FA

target=$sd/$fold/$targetbase
FA=$sd/$fold/$FA

echo "ANTS 3 -m CC[$target,$FA,1,5] -i 100*100*10 -o FA_to_target.nii"
echo "ANTS 3 -m CC[$target,$FA,1,5] -i 100*100*10 -o FA_to_target.nii" >> $sd/$fold/inst.txt
#qbatch -q M32_q -oe $sd/Logdir -N ANTS$fold ANTS 3 -m CC[$target,$FA,1,5] -i 100*100*10 -o $sd/$fold/FA_to_target.nii

base=$fold

echo "WarpImageMultiTransform 3 $sd/$fold/$FA $sd/$fold/${base}_to_target.nii -R $target $sd/$fold/FA_to_targetWarp.nii $sd/$fold/FA_to_targetAffine.txt"
echo "WarpImageMultiTransform 3 $sd/$fold/$FA $sd/$fold/${base}_to_target.nii -R $target $sd/$fold/FA_to_targetWarp.nii $sd/$fold/FA_to_targetAffine.txt" >> $sd/$fold/inst.txt
WarpImageMultiTransform 3 $FA $sd/$fold/${base}_to_target.nii -R $target $sd/$fold/FA_to_targetWarp.nii $sd/$fold/FA_to_targetAffine.txt

echo "WarpImageMultiTransform 3 $sd/$fold/$FA $sd/$fold/${base}_to_target_Affine.nii -R $target $sd/$fold/FA_to_targetAffine.txt"
echo "WarpImageMultiTransform 3 $sd/$fold/$FA $sd/$fold/${base}_to_target_Affine.nii -R $target $sd/$fold/FA_to_targetAffine.txt" >> $sd/$fold/inst.txt
WarpImageMultiTransform 3 $FA $sd/$fold/${base}_to_target_Affine.nii -R $target $sd/$fold/FA_to_targetAffine.txt

done



sd=`pwd`
for im in `ls | grep pat | grep nii`
do
echo $im
qbatch -q M32_q -oe $sd/Log -N $im ANTS 3 -m CC[$sd/data_corr_FA.nii,$sd./$im,1,2] -i 100*100*10 -o ANTS$im
done