#!/bin/bash

dim=3 # image dimensionality
AP="/home/global//ANTs_2.2/bin/" 
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
f=$1 ; m=$2 # fixed and moving image file names

if [[ ! -s $f ]] ; then echo no fixed $f ; exit; fi
if [[ ! -s $m ]] ; then echo no moving $m ;exit; fi

nm=` basename $m | cut -d '.' -f 1 `
outputDir=`dirname $m`
cd $outputDir

#Pour gérer les masque il faut l'inverser
#ImageMath 3 data/neg_lesion2.nii.gz Neg data/LesionMap.nii.gz

cmd="antsRegistrationSyNQuick.sh -d 3 -m $m -f $f -t s -o ${nm}_diff"
echo $cmd; eval $cmd
cmd="CreateJacobianDeterminantImage 3 ${nm}_diff1Warp.nii.gz ${nm}_jacobian.nii.gz 1"
echo $cmd; eval $cmd
cmd="CreateWarpedGridImage 3 ${nm}_diff1Warp.nii.gz ${nm}_grid.nii.gz 1x0x1 10x10x10 3x3x3"
echo $cmd; eval $cmd

#j'essaye de gérer une (et une seule) transfo inverse avec le quatriem arg si (et seulement si) le troisième arg est -inv (c'est special pour predistim) attention 
#a l'interpolation plus proche voisin ou lineaire
case $3 in 
	"-inv")
		nm2=` basename $4 | cut -d '.' -f 1 `
		outputDir=`dirname $m`
		cmd="${AP}antsApplyTransforms -d $dim -i $4 -r $m -n NearestNeighbor -t ${nm}_diff1InverseWarp.nii.gz -t [${nm}_diff0GenericAffine.mat,1] -o ${nm2}_warped.nii.gz"
		echo $cmd; eval $cmd
		shift 4
	;;
	*)
		shift 2
	;;
esac

for ima in $*
do
	nm2=` basename $ima | cut -d '.' -f 1 `
	cmd="${AP}antsApplyTransforms -d $dim -i $ima -r $f -n linear -t ${nm}_diff1Warp.nii.gz -t ${nm}_diff0GenericAffine.mat -o ${nm2}_warped.nii.gz"
	echo $cmd; eval $cmd
done





#FINI
exit $?

if [[ ${#mysetting} -eq 0 ]] ; then
	echo usage is
	echo $0 fixed.nii.gz moving.nii.gz others_image.nii.gz
exit
fi

nm1=` basename $f | cut -d '.' -f 1 `
nm2=` basename $m | cut -d '.' -f 1 `
reg=${AP}antsRegistration           # path to antsRegistration
if [[ $mysetting == "fastfortesting" ]] ; then
  its=10000x0x0
  percentage=0.1
  syn="100x0x0,0,5"
else
  its=10000x111110x11110
  percentage=0.3
  syn="100x100x50,-0.01,5"
  mysetting=forproduction
fi
echo affine $m $f outname is $nm am using setting $mysetting
nm=${D}${nm1}_fixed_${nm2}_moving_setting_is_${mysetting}   # construct output prefix

CMD="$reg -d $dim -r [ $f, $m ,1 ]  \
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
                        -m mattes[  $f, $m , 0.5 , 32 ] \
                        -m cc[  $f, $m , 0.5 , 4 ] \
                         -t SyN[ .20, 3, 0 ] \
                         -c [ $syn ]  \
                        -s 1x0.5x0vox  \
                        -f 4x2x1 -l 1 -u 1 -z 1 \
                       -o [ ${nm},${nm}_diff.nii.gz,${nm}_inv.nii.gz]"

echo ${CMD}; eval ${CMD}

CMD="${AP}antsApplyTransforms -d $dim -i $m -r $f -n linear -t ${nm}1Warp.nii.gz -t ${nm}0GenericAffine.mat -o ${nm}_warped.nii.gz"
echo ${CMD}; eval ${CMD}

#Pour appliquer le recalage si une autre image est passée en parametres 

if [ $# -eq 4 ]; then
	nm3=` basename $4 | cut -d '.' -f 1 `
	nmNew=${D}${nm1}_fixed_${nm3}_moving_setting_is_${mysetting}   # construct output prefix
	CMD="${AP}antsApplyTransforms -d $dim -i $4 -r $f -n NearestNeighbor -t ${nm}1Warp.nii.gz -t ${nm}0GenericAffine.mat -o ${nmNew}_warped.nii.gz"
	echo $CMD; eval $CMD
fi


