#!/bin/bash

if [ ! $# -eq 6 ]
then
	echo "Usage: Convert_all_labels.sh subject subjects_dir annotation hemi outdir 3d_dti"
	echo 
	echo "Converts all surface labels obtained from the annotation file in a serie of volumes"
	echo ""
	echo "  subject           : name of the subject to process"
	echo "  subjects_dir      : equivalent to the freesurfer SUBJECTS_DIR"
	echo "  annotation        : name of the annotation file such as hemi.annotation.annot"
	echo "  hemi              : lh or rh"
	echo "  outdir            : output directory for the volume labels"
	echo "  3d_dti            : 3D dti image for resampling informations"
	exit 1
fi

subject=$1
SUBJECTS_DIR=$2
annotation=$3
hemi=$4
outdir=$5
DTI=$6

echo "----------------------------"
echo "mri_annotation2label --subject ${subject} --hemi ${hemi} --outdir ${outdir} --annotation ${annotation}"
echo "----------------------------"
mri_annotation2label --subject ${subject} --hemi ${hemi} --outdir ${outdir} --annotation ${annotation}

for label in `ls ${outdir}/ | grep .label`
do
	do_cmd 1.9 mri_label2vol --label ${outdir}/${label} --temp ${SUBJECTS_DIR}/${subject}/mri/orig/001.mgz --labvoxvol 8 --o ${outdir}/${label%.label}.mgz --proj frac 0 .1 .1 --subject ${subject} --hemi ${hemi}
done

wait

for label in `ls ${outdir}/ | grep .mgz`
do
	do_cmd 3 mgz2FSLnii.sh ${label} ${DTI} ${SUBJECTS_DIR}/${subject} ${outdir}/${label%.mgz} ${outdir}/${subject}_t1_to_dti.mat
done
