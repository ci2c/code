#!/bin/bash
#

dim=3 # image dimensionality
AP="/home/global//ANTs_2.2/bin/" 
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=2  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
f=$1 ; m=$2    # fixed and moving image file names
mysetting=$3
if [[ ! -s $f ]] ; then echo no fixed $f ; exit; fi
if [[ ! -s $m ]] ; then echo no moving $m ;exit; fi
if [[ ${#mysetting} -eq 0 ]] ; then
echo usage is
echo $0 fixed.nii.gz moving.nii.gz mysetting
echo  where mysetting is either forproduction or fastfortesting
exit
fi

outputDir=`dirname $f`/
cd $outputDir

nm1=` basename $f | cut -d '.' -f 1 `
nm2=` basename $m | cut -d '.' -f 1 `
reg=${AP}antsRegistration           # path to antsRegistration
if [[ $mysetting == "fastfortesting" ]] ; then
  its=10000x0x0
  percentage=0.3
  syn="100x0x0,0,5"
else
  its=10000x111110x11110
  percentage=0.3
  syn="100x100x50,-0.01,5"
  mysetting=forproduction
fi
echo affine $m $f outname is $nm am using setting $mysetting
nm=${outputDir}${nm1}_fixed_${nm2}_moving_setting_is_${mysetting}   # construct output prefix

cmd="$reg -d $dim -r [ $f, $m ,1 ]  \
                        -m mattes[  $f, $m , 1 , 32, regular, $percentage ] \
                         -t translation[ 0.1 ] \
                         -c [ $its,1.e-8,20 ]  \
                         -s 4x2x1vox  \
                         -f 6x4x2 -l 1 \
                        -m mattes[  $f, $m , 1 , 32, regular, $percentage ] \
                         -t rigid[ 0.1 ] \
                         -c [ $its,1.e-8,20 ]  \
                         -s 4x2x1vox  \
                         -f 3x2x1 -l 1 \
                        -m mattes[  $f, $m , 1 , 32, regular, $percentage ] \
                         -t affine[ 0.1 ] \
                         -c [ $its,1.e-8,20 ]  \
                         -s 4x2x1vox  \
                         -f 3x2x1 -l 1 \
                       -o [ ${nm},${nm}_diff.nii.gz,${nm}_inv.nii.gz]"
echo ${cmd}; eval ${cmd}

#Pour appliquer le recalage si une autre image est passée en parametres 

index=4
while [ $index -le $# ]
do
	eval arg=\${$index}
	nm3=` basename $arg | cut -d '.' -f 1 `
	nmNew=${outputDir}${nm1}_fixed_${nm3}_moving_setting_is_${mysetting}   # construct output prefix
	CMD="${AP}antsApplyTransforms -d $dim -i $arg -r $f -n NearestNeighbor -t ${nm}0GenericAffine.mat -o ${nmNew}_warped.nii.gz"
	echo $CMD; eval $CMD
	index=$[$index+1]
done

#bash /home/romain/SVN/scripts/romain/antsReg_RigidOnly.sh /NAS/deathrow/protocoles/predistim/2018-12-12_3dmultigre/01/01007HC/QSM_matlab2019/real_gre.nii /NAS/deathrow/protocoles/predistim/FS60_VB/01007HC/mri/T1_las.nii forproduction
