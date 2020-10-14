#!/bin/bash


SUBJECTS_DIR=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask
DirL=/NAS/tupac/protocoles/Strokdem/Lesions/M6

Template='/home/global/fsl/data/standard/MNI152_T1_1mm.nii.gz'

for f in $DirL/*_M6
do
	f2=`basename $f`
	subj=${f2:0:(${#f2}-3)}

	echo $subj

	if [ -e $SUBJECTS_DIR/$f2 ]; then
		T1=$SUBJECTS_DIR/$f2/mri/T1.mgz	
    	t1=$f/t1.nii.gz
    	t1brain=$f/t1_brain.nii.gz
    	brainmask=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/$f2/mri/brainmask.mgz
    	Lesions=$f/$subj'_lesions.nii.gz'
    	LesionsMNI=$f/$subj'_lesions_mni152.nii.gz'

    	affine=$f/norm_mni152_rigid
    	bspline=$f/norm_mni152
    #Estimer les champs de deformation 
    #Appliquer la transfo aux lesions
    	BEFORE=$SECONDS

    if  [ -e $T1 ] && [ ! -e $f/T1_mni152.nii.gz ]
    then
      echo "                             Recalage T1 -> MNI"
      mri_convert $T1 $t1
      if [ ! -e $f/T1_mni152_rigid.nii.gz ]
      then
	echo "                        RECALAGE LINEAIRE " 
	ANTS 3 -m MI[$Template,$t1,1,32] -o $affine -i 0 --rigid-affine
	WarpImageMultiTransform 3 $t1 $f/T1_mni152_rigid.nii.gz $affine'Affine.txt' -R $Template
      fi
      if [ ! -e  $f/T1_mni152.nii.gz ]
      then
      echo "                        RECALAGE NON-LINEAIRE " 
	ANTS 3 -m CC[$Template,$f/T1_mni152_rigid.nii.gz,1,4] -i 100x100x100x20 -o $bspline -t SyN[0.25] -r Gauss[3,0]
	WarpImageMultiTransform 3 $t1 $f/T1_mni152.nii.gz $bspline'Warp.nii.gz' $bspline'Affine.txt' $affine'Affine.txt' -R $Template --use-BSpline
      fi
      rm -f $t1
    fi
    
    if [ ! -e $LesionsMNI ] && [ -e $Lesions ]
    then 
      WarpImageMultiTransform 3 $Lesions $LesionsMNI $bspline'Warp.nii.gz' $bspline'Affine.txt' $affine'Affine.txt' -R $Template --use-NN
    fi

    ELAPSED=$(($SECONDS-$BEFORE))
   # echo 'Time '$((ELAPSED/60))
  else
      echo 'Pbs with FS5.1_T2mask/'$num 
  fi

done


