#!/bin/bash

# 0 : recalage linéaire par ANTS  ;  1 : recalage linéaire par SPM
Linrecal=1

SUBJECTS_DIR=/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask
DirL='/home/fatmike/Protocoles_3T/Strokdem/Lesions/72H'

Template='/home/global/fsl/data/standard/MNI152_T1_1mm.nii.gz'

for f in $DirL/*_72H
do
	num=`basename $f`

	num2=${num:0: ( ${#num}-4 ) } # num2 prend la sous chaine de num de 0 à longueur de num total (${#num}) - 4 

	echo $num2

	if [ -e $SUBJECTS_DIR/$num ]
	then
		T1=$SUBJECTS_DIR/$num/mri/T1.mgz	
		t1=$f/t1.nii.gz
		t1brain=$f/t1_brain.nii.gz
		brainmask=/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/$num/mri/brainmask.mgz
		b0=$f/dwi_b_0001.nii.gz
		b0brain=$f/dwi_b_0001_brain.nii.gz
		b0T1=$f/dwi_b_0001_refT1.nii.gz
		b0aff=$f/T1_affine
		b0spline=$f/T1_spline
		b0MNI=$f/dwi_b_0001_refMNI152.nii.gz
		lesions=$f/$num2'_lesions.nii.gz'
		Lesions=$f/$num2'_lesions_refT1.nii.gz'
		LesionsMNI=$f/$num2'_lesions_mni152.nii.gz'
		#   echo $LesionsMNI

		affine=$f/norm_mni152_rigid
		bspline=$f/norm_mni152
		#Estimer les champs de deformation 
		#Appliquer la transfo aux lesions
		BEFORE=$SECONDS


		if [ -e $b0 ] && [ -e $T1 ] && [ -e $lesions ] && [ ! -e $Lesions ]
		then
			echo "            Recalage rigid DWI -> T1 " 
			#bbregister --s $num --mov $b0  --init-header --t2 --reg $f/DWIreg.dat --o $b0T1
			#echo 'apply'
			#mri_vol2vol --mov $lesions --targ $T1 --o $Lesions --reg $f/DWIreg.dat --nearest
			mri_convert $T1 $t1
			mri_convert $brainmask $t1brain
			#bet $t1 $t1brain -m
			bet $b0 $b0brain -m #enlève le crâne

			if [ ${Linrecal} -eq 0 ]
			then
			      ANTS 3 -m MI[$t1brain,$b0brain,1,32] -o  $b0aff -i 0 --rigid-affine
			      WarpImageMultiTransform 3 $b0brain $f/dwi_brain_T1_rigid.nii.gz $b0aff'Affine.txt' -R $t1
			      WarpImageMultiTransform 3 $lesions $Lesions $b0aff'Affine.txt' -R $t1 --use-NN
			else

				dwirec=$f/dwi_brain_T1_rigid.nii

				gunzip -k $t1 $b0 $lesions $b0brain $Lesions $t1brain

				Lesions=$f/$num2'_lesions_refT1.nii'
				t1brain_nii=$f'/t1_brain.nii'
				b0brain_nii=$f'/dwi_b_0001_brain.nii'
				lesions_nii=$f/$num2'_lesions.nii'

/usr/local/matlab/bin/matlab -nodisplay <<EOF
				% Load Matlab Path

				t1image='${t1brain_nii}'
				dwiimage='${b0brain_nii}'
				maskimage='${lesions_nii}'


				Register_DWI_To_T1(t1image,dwiimage,maskimage);
				[p,n,e]=fileparts(maskimage);
				cmd = sprintf('mv %s %s',fullfile(p,['r' n e]),'${Lesions}');
				unix(cmd);
				[p,n,e]=fileparts(dwiimage);
				cmd = sprintf('mv %s %s',fullfile(p,['r' n e]),fullfile(p,'dwi_brain_T1_rigid.nii'));
				unix(cmd);
EOF
				gzip ${Lesions}
				gzip ${dwirec}
				Lesions=$f/$num2'_lesions_refT1.nii.gz'
			fi

      			#rm -f $t1 $t1brain

	
    		fi

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
    		if [ ! -e $b0MNI ] && [ -e $b0 ]
    		then
      			WarpImageMultiTransform 3 $f/dwi_brain_T1_rigid.nii.gz $b0MNI $bspline'Warp.nii.gz' $bspline'Affine.txt' $affine'Affine.txt' -R $Template --use-Bspline
		fi	

    		ELAPSED=$(($SECONDS-$BEFORE))
   		# echo 'Time '$((ELAPSED/60))
	else
		echo 'Pbs with FS5.1_T2mask/'$num 
  	fi
done


 [/home/global/fsl/data/standard/MNI152_T1_1mm.nii.gz, ../T1.nii,1,32]