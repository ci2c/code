
file="/home/fatmike/renaud/tep_fog/freesurfer/g2/"
for name in `ls $file --hide fsaverage --hide lh.EC_average --hide rh.EC_average`
do
	if [ -e $file/$name/dti/mrtrix/fa.nii ]
	then		
		echo "$name : faa ok"
	else
		echo "$name : faa absente"
	fi
done







file="/home/fatmike/renaud/tep_fog/freesurfer/g2/"
for name in `ls $file --hide fsaverage --hide lh.EC_average --hide rh.EC_average --hide ANDR --hide DAMB --hide HERL --hide LUCA --hide SALE`
do

	echo "DTI_ProcessMrtrix.sh -fs $file -subj $name -o dti -initLin & "
	qbatch -N $name -q fs_q -oe /home/tanguy/Logdir DTI_ProcessMrtrix.sh -fs $file -subj $name -o dti -initLin &

done



BISI  BOND  DAMB  DEBA  DELA  DENI  DETH  MARQ  POCH  VASS



file="/home/fatmike/renaud/tep_fog/freesurfer/g1/"
for name in `ls $file --hide fsaverage --hide lh.EC_average --hide rh.EC_average --hide ALIB --hide PETI`
do

	rm -f $file/$name/dti/*
	rm -Rf $file/$name/dti/steps

done





file="/home/fatmike/renaud/tep_fog/freesurfer/g2/"
for name in `ls $file --hide fsaverage --hide lh.EC_average --hide rh.EC_average  --hide PETI --hide AND --hide HERL --hide LUCA --hide SALE`
do

fslview $file/$name/dti/data_corr_FA.nii.gz $file/$name/dti/data_corr_V1.nii.gz &

done













LOI=/home/renaud/SVN/scripts/pierre/aparc2009LOI.txt
fs=/home/fatmike/renaud/tep_fog/freesurfer/g1/
file=/home/fatmike/renaud/tep_fog/freesurfer/g1/


for name in `ls $file --hide fsaverage --hide lh.EC_average --hide rh.EC_average --hide ANDR --hide DAMB --hide HERL --hide LUCA --hide SALE`
do


Subject=$name
DIR=$fs/$Subject
output=dti

echo "CMatrixVolume_mrtrix.sh -fs ${fs} -subj ${Subject} -parcname aparc.a2009s+aseg.mgz -labels ${LOI} -dti ${DIR}/${output}/data_corr_brain.nii.gz -bvecs ${DIR}/${output}/data.bvec -bvals ${DIR}/${output}/data.bval -outdir ${DIR}/${output}/mrtrix"
qbatch -N $name -q fs_q -oe /home/tanguy/Logdir CMatrixVolume_mrtrix.sh -fs ${fs} -subj ${Subject} -parcname aparc.a2009s+aseg.mgz -labels ${LOI} -dti ${DIR}/${output}/data_corr_brain.nii.gz -bvecs ${DIR}/${output}/data.bvec -bvals ${DIR}/${output}/data.bval -outdir ${DIR}/${output}/mrtrix -N 500000 &

	
done





