#! /bin/bash

if [ $# -lt 2 ]
then
		echo ""
		echo "Usage: extract_roi.sh -SD <Subj_Dir> -subj <Subj_ID>"
		echo ""
		echo " -SD				: Subj Dir"
		echo ""
		echo ""
		echo " -subj				: Subj ID"
		echo ""
		echo "Usage: extract_roi.sh -aparc <FS_aparc_file>"
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
			echo "Usage: extract_roi.sh -SD <Subj_Dir> -subj <Subj_ID>"
			echo ""
			echo " -SD				: Subj Dir"
			echo ""
			echo ""
			echo " -subj				: Subj ID"
			echo ""
			echo "Usage: extract_roi.sh -aparc <FS_aparc_file>"
			echo ""
			echo "Author: Tanguy Hamel - CHRU Lille - 2013"
			echo ""
			exit 1
			;;
	-SD)
		
		SD=`expr $index + 1`
		eval SD=\${$SD}
		echo "Subject Directory  : $SD"
		;;
	
	-subj)
		
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "Subject ID  : $SUBJ"
		;;

	esac
	index=$[$index+1]
done

echo ""
echo ""
echo ""
echo ""
echo "run extract_roi.sh"
echo ""
echo "Author: Tanguy Hamel - CHRU Lille - 2014"
echo ""
echo ""
echo ""


### Initialisation 

aparc_path=$SD/$SUBJ/FS/mri/aparc.a2009s+aseg.mgz

roi_path=/home/lucie/memoire/ROI

outdir=$SD/$SUBJ/FS/ROI_analyse/init
moutdir=$SD/$SUBJ/FS/ROI_analyse/mROI

if [ ! -d $outdir ]
then
	echo "mkdir -p $outdir"
	mkdir -p $outdir
fi

# test présence roi_path

if [ ! -d $roi_path ]
then
	echo ""
	echo ""
	echo "impossible de trouver le dossier $roi_path"
	echo ""
	echo ""
	exit
fi

# test présence du fichier aparc

if [ ! -f $aparc_path ]
then
	echo ""
	echo ""
	echo "impossible de trouver le fichier aparc de FreeSurfer : "
	echo ""
	echo "$aparc_path"
	echo ""
	echo ""
	exit
fi


## extraction des volumes ROI à partir de la segmentation Freesurfer

echo ""
echo ""
echo "extraction des ROI à partir de la segmentation Freesurfer"
echo ""
echo ""

for roi_name in `ls $roi_path`
do
	echo ""
	echo "extraction de :"
	echo "$roi_name"
	echo ""

	echo "mri_extract_label $aparc_path `cat $roi_path/$roi_name` $outdir/${roi_name}.nii"
	mri_extract_label $aparc_path `cat $roi_path/$roi_name` $outdir/${roi_name}_$SUBJ.nii
done


cp -Rf $outdir $moutdir
cp -f $SD/$SUBJ/FS/mri/T1.mgz $moutdir

