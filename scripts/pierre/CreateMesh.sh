#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: CreateMesh.sh input_label.mgz output_fs_mesh"
	exit 1
fi


LABEL=$1
MESH=$2
DIR=`dirname ${LABEL}`

echo "mri_binarize --i ${LABEL} --o ${LABEL%.mgz}_bin.mgz --min 0.0001 --max inf"
mri_binarize --i ${LABEL} --o ${LABEL%.mgz}_bin.mgz --min 0.0001 --max inf

echo "mri_pretess ${LABEL%.mgz}_bin.mgz label ${LABEL} ${LABEL%.mgz}_filled.mgz"
mri_pretess ${LABEL%.mgz}_bin.mgz label ${LABEL} ${LABEL%.mgz}_filled.mgz

rm -f ${LABEL%.mgz}_bin.mgz

echo "mri_tessellate ${LABEL%.mgz}_filled.mgz 1 ${MESH}.nofix"
mri_tessellate ${LABEL%.mgz}_filled.mgz 1 ${MESH}.nofix
rm -f ${LABEL%.mgz}_filled.mgz

echo "mris_extract_main_component ${MESH}.nofix ${MESH}.nofix"
mris_extract_main_component ${MESH}.nofix ${MESH}.nofix

echo "mris_smooth -nw -seed 1234 ${MESH}.nofix ${MESH}"
mris_smooth -nw -seed 1234 ${MESH}.nofix ${MESH}

#rm -f ${MESH}.nofix
