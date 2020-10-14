#! /bin/bash

if [ $# -lt 6 ]
then
		echo ""
		echo "Usage: label2volandflip.sh -dir <DATA_DIR> -label <LABEL> -o <OUTPUT_DIR>"
		echo " input : right label"
		echo " output : right and left volumes"
		echo ""
		echo "-dir                            : Data Dir : directory containing the label"
		echo ""
		echo "-label				: label - name like 'name.label'"
		echo ""
		echo "-o				: Output Dir"
		echo ""
		echo "Usage: label2volandflip.sh -dir <DATA_DIR> -label <LABEL> "
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
fi


index=1


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: label2volandflip.sh -dir <DATA_DIR> -label <LABEL> -o <OUTPUT_DIR>"
		echo ""
		echo "-dir                            : Data Dir : directory containing the label"
		echo ""
		echo "-label				: label"
		echo ""
		echo "-o				: Output Dir"
		echo ""
		echo "Usage: label2volandflip.sh -dir <DATA_DIR> -label <LABEL> "
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
		;;
	-dir)
		
		DIR=`expr $index + 1`
		eval DIR=\${$DIR}
		echo "DIR : $DIR"
		;;

	-label)
		
		LABEL=`expr $index + 1`
		eval LABEL=\${$LABEL}
		echo "LABEL : $LABEL"
		;;

	-o)
		OUTDIR=`expr $index + 1`
		eval OUTDIR=\${$OUTDIR}
		echo "OUTDIR : $OUTDIR"
		;;


	
	esac
	index=$[$index+1]
done


name=${LABEL%.*}
model="/home/global/freesurfer/mni/bin/../share/mni_autoreg/average_305.mnc"

#passage du label droit en volume .nii
echo "mri_label2vol --label $DIR/$LABEL --o $DIR/$name.nii --identity --temp $model"
mri_label2vol --label $DIR/$LABEL --o $DIR/$name.nii --identity --temp $model



 $DIR/$LABEL --o $OUTDIR/$name.nii --identity --temp $model

#flip pour obtenir le label gauche

matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);
cd $DIR
reorient_mirrorRL('$OUTDIR/$name.nii')


EOF

#rectification de l'orientation
name_gauche=${name%_*}

mri_convert $OUTDIR/flip_$name.nii $OUTDIR/${name_gauche}_gauche.nii --out_orientation LAS
mri_convert $OUTDIR/$name.nii $OUTDIR/$name.nii --out_orientation LAS
rm -f $OUTDIR/flip_$name.nii



#création du masque du template

#condition sur existence dossier Mask -> création
if [ -d $DIR/../Mask ]
then
	echo ""
else
	mkdir $DIR/../Mask
fi

#condition sur présence du template.nii
if [ -e $DIR/../Mask/template.nii ]
then
	echo "template file present"
else
	mri_convert $model $DIR/../Mask/template.nii --out_orientation LAS
fi

#condition sur existence masque template -> run
if [ -e $DIR/../Mask/template_mask.nii ]
then
	echo "template mask present"
else
	mask_way=${model%/*}
	mri_convert $mask_way/average_305_mask.mnc $DIR/../Mask/template_mask.nii --out_orientation LAS
fi

#application du masque du template

fslmaths $OUTDIR/$name.nii -mas $DIR/../Mask/template_mask.nii $OUTDIR/$name.nii
fslmaths $OUTDIR/${name_gauche}_gauche.nii -mas $DIR/../Mask/template_mask.nii $OUTDIR/${name_gauche}_gauche.nii
rm -f $OUTDIR/$name.nii $OUTDIR/${name_gauche}_gauche.nii
gunzip $OUTDIR/$name.nii.gz $OUTDIR/${name_gauche}_gauche.nii.gz








	
