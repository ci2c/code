SD=/home/tanguy/NAS/tanguy/MCI
rm -Rf $SD/Vol_SPM12
mkdir $SD/Vol_SPM12
rm -Rf /home/tanguy/Logdir/vol
mkdir /home/tanguy/Logdir/vol

for nameminf in `ls /home/global/brainvisa/Database/MCI_V1/*.minf`
do

namei=`basename $nameminf`
name=${namei%%.*}
mkdir $SD/Vol_SPM12/$name

cp -f /home/global/brainvisa/Database/MCI_V1/$name/t1mri/*/$name.nii $SD/Vol_SPM12/$name/t1.nii

qbatch -N vol_$name -q fs_q -oe /home/tanguy/Logdir/vol get_vol_T1_spm12.sh -anatpath $SD/Vol_SPM12/$name

done
