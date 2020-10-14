#!/bin/bash

INPUT_DIR=$1
SUBJECT_ID=$2
# TP=$3
OUTPUT_DIR=$3

dcm2nii_exec=/home/global/mricron082014/

# rm -rf ${INPUT_DIR}/${SUBJECT_ID}/ASL

# ## TEP ##
# exam_date=`basename ${INPUT_DIR}/${SUBJECT_ID}`
# cd ${INPUT_DIR}/${SUBJECT_ID}/..
# name=$(pwd)
# name=`basename ${name}`
# 
# if [ ! -d ${OUTPUT_DIR}/${name}_${exam_date} ]
# then
# 	mkdir -p ${OUTPUT_DIR}/${name}_${exam_date}
# else
# 	rm -f ${OUTPUT_DIR}/${name}_${exam_date}/*
# fi
# 
# # /home/global/mricron082014/dcm2nii -o ${OUTPUT_DIR}/${name}_${exam_date} ${INPUT_DIR}/${SUBJECT_ID}/CERVEAU_GRANULEUX_3D_AC/*
# /home/global/mriconvert_22072015/mcverter -o ${OUTPUT_DIR}/${name}_${exam_date} -f nifti -n ${INPUT_DIR}/${SUBJECT_ID}/CERVEAU_GRANULEUX_3D_AC/*
# gzip ${OUTPUT_DIR}/${name}_${exam_date}/*.nii

# ## IRM ##
# # if [ ! -d ${OUTPUT_DIR}/${SUBJECT_ID}/nii ]
# # then
# # 	mkdir -p ${OUTPUT_DIR}/${SUBJECT_ID}/nii
# # else
# # 	rm -f ${OUTPUT_DIR}/${SUBJECT_ID}/nii/*
# # fi
# 
if [ ! -d ${OUTPUT_DIR}/${SUBJECT_ID} ]
then
	mkdir ${OUTPUT_DIR}/${SUBJECT_ID}
else
	rm -f ${OUTPUT_DIR}/${SUBJECT_ID}/*
fi

# # /home/global/mricron082014/dcm2nii -o ${OUTPUT_DIR}/${SUBJECT_ID} ${INPUT_DIR}/${SUBJECT_ID}/*
${dcm2nii_exec}dcm2nii -x n -r n -g n -o ${OUTPUT_DIR}/${SUBJECT_ID} ${INPUT_DIR}/${SUBJECT_ID}/mr/*
echo gz compression ...					
pigz -p 8 -v ${OUTPUT_DIR}/${SUBJECT_ID}/*.nii

# if [ -s ${OUTPUT_DIR}/${SUBJECT_ID}/nii/2*[0-9]s3DT1*.nii.gz ]
# then
# 	mv ${OUTPUT_DIR}/${SUBJECT_ID}/nii/2*[0-9]s3DT1*.nii.gz ${OUTPUT_DIR}/${SUBJECT_ID}/nii/3DT1.nii.gz
# fi
# 
# if [ -s ${OUTPUT_DIR}/${SUBJECT_ID}/nii/2*WIPs3DT1*.nii.gz ]
# then
# 	mv ${OUTPUT_DIR}/${SUBJECT_ID}/nii/2*WIPs3DT1*.nii.gz ${OUTPUT_DIR}/${SUBJECT_ID}/nii/3DT1.nii.gz
# fi

# T1=$(ls ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/2*3DT1*.nii.gz)
# mv ${T1} ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/3DT1.nii.gz
# # gunzip ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/3DT1.nii.gz
# 
# # ASL=$(ls ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/2*PCASLSENSE*.nii.gz)
# # ASLCorr=$(ls ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/2*PCASLCORRECTIONSENSE*.nii.gz)
# 
# EPI=$(ls ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/2*EPI64x64resting*.nii.gz)
# EPICorr=$(ls ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/2*SEFMRICORRAPSENSE*.nii.gz)
# 
# mkdir ${OUTPUT_DIR}/${SUBJECT_ID}/temp
# # cp -t ${OUTPUT_DIR}/${SUBJECT_ID}/temp ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/3DT1.nii.gz ${ASL} ${ASLCorr}
# cp -t ${OUTPUT_DIR}/${SUBJECT_ID}/temp ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/3DT1.nii.gz ${EPI} ${EPICorr}
# rm -rf ${OUTPUT_DIR}/${SUBJECT_ID}/ASL
# mv ${OUTPUT_DIR}/${SUBJECT_ID}/temp ${OUTPUT_DIR}/${SUBJECT_ID}/ASL
# mv ${OUTPUT_DIR}/${SUBJECT_ID}/ASL/* ${OUTPUT_DIR}/${SUBJECT_ID}
# rm -rf ${OUTPUT_DIR}/${SUBJECT_ID}/ASL


# rm -Rf ${INPUT_DIR}/${SUBJECT_ID}/Nifti
# if [ ! -d ${OUTPUT_DIR}/${SUBJECT_ID}_${TP} ]
# then
#     mkdir -p ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti
# fi
# dcm2nii -o ${OUTPUT_DIR}/${SUBJECT_ID}/${TP} ${INPUT_DIR}/${SUBJECT_ID}/${TP}/*

# if [ -d ${INPUT_DIR}/${SUBJECT_ID}/${TP} ]
# then
#     cp -t ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti ${INPUT_DIR}/${SUBJECT_ID}/${TP}/*DTI*SENSE*.nii.gz ${INPUT_DIR}/${SUBJECT_ID}/${TP}/*DTI*SENSE*.bval ${INPUT_DIR}/${SUBJECT_ID}/${TP}/*DTI*SENSE*.bvec
#     base=`basename ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti/*DTI*SENSE*.bval`
#     base=${base%.bval}
#     mv ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti/${base}.nii.gz ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti/dti.nii.gz
#     mv ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti/${base}.bval ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti/dti.bval
#     mv ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti/${base}.bvec ${OUTPUT_DIR}/${SUBJECT_ID}_${TP}/dti/dti.bvec
# fi