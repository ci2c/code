#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: Script_shape.sh input_dir output_dir"
	exit 1
fi

input_dir=$1
output_dir=$2
#stat_file=$3

space=0.5,0.5,0.5
iterSegPost=20
numberOfOptimizationIterations=200
subdiv=10
degree=12
numPerms=20000
signLevel=0.10
signSteps=10000



if [ ! -d ${output_dir} ]
then
	mkdir -p ${output_dir}
else
	rm -f ${output_dir}/*
fi

if [ ! -d ${input_dir}/post_proc ]
then
	mkdir -p ${input_dir}/post_proc
else
	rm -f ${input_dir}/post_proc/*
fi


if [ ! -d ${input_dir}/temp ]
then
	mkdir -p ${input_dir}/temp
else
	rm -f ${input_dir}/temp/*
fi


proc_dir=${input_dir}/post_proc

for Image in `ls ${input_dir}/*.ni*`
do
	Im=`basename ${Image}`
	mri_convert ${Image} ${input_dir}/${Im%.ni*}_0.5.nii -vs 0.5 0.5 0.5
	echo "fslmaths ${Image}_0.5.nii -bin ${input_dir}/temp/${Im%.ni*}_bin"
	fslmaths ${input_dir}/${Im%.ni*}_0.5.nii -bin ${input_dir}/temp/${Im%.ni*}_bin
	rm -f ${input_dir}/${Im%.ni*}_0.5.nii
done

JOBS=`qstat |grep fslmaths |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "fslmaths pas encore fini"
sleep 15
JOBS=`qstat | grep fslmaths | wc -l`
done

for Image in `ls ${input_dir}/temp/*bin.ni*`
do
	Im=`basename ${Image}`
	#echo "mri_morphology ${Image} close 1 ${input_dir}/temp/${Im%.ni*}_fix.nii"
	#qbatch -N close -oe ~/log_sge -q long.q mri_morphology ${Image} close 1 ${proc_dir}/${Im%.ni*}_fix.nii
	echo "mri_morphology ${Image} dilate 2 ${proc_dir}/${Im%.ni*}_dilate.nii"
	mri_morphology ${Image} dilate 2 ${proc_dir}/${Im%.ni*}_dilate.nii
	echo "mri_morphology ${proc_dir}/${Im%.ni*}_dilate.nii erode 2 ${proc_dir}/${Im%.ni*}_close.nii"
	mri_morphology ${proc_dir}/${Im%.ni*}_dilate.nii erode 2 ${proc_dir}/${Im%.ni*}_close.nii
	echo "rm -f ${proc_dir}/${Im%.ni*}_dilate.nii"
	rm -f ${proc_dir}/${Im%.ni*}_dilate.nii
done

for Image in `ls ${proc_dir}/*close.nii`
do
	Im=`basename ${Image}`
	echo "SegPostProcess ${Image} -o ${Image%.ni*}.gipl -space ${space} -label 1 -iter ${iterSegPost}"
	qbatch -oe ~/log_sge -N SegPostProcess -q long.q SegPostProcess ${Image} -o ${Image%.ni*}.gipl -label 1 -iter ${iterSegPost} -asymClose
	sleep 5
done

JOBS=`qstat |grep SegPost |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "SegPost pas encore fini"
sleep 30
JOBS=`qstat | grep SegPost | wc -l`
done

for Image in `ls ${proc_dir}/*gipl`
do
	Im=`basename ${Image}`
	echo "GenParaMesh ${Image} -outbase ${Image%.gipl} -iter ${numberOfOptimizationIterations} -label 1"
	qbatch -oe ~/log_sge -N GenParaMesh -q long.q GenParaMesh ${Image} -outbase ${Image%.gipl} -iter ${numberOfOptimizationIterations} -label 1
	sleep 5
done

JOBS=`qstat |grep GenPara |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "GenPara pas encore fini"
sleep 30
JOBS=`qstat | grep GenPara | wc -l`
done

# Make template (take 1st as the ref)
template_made=0
for Surface in `ls ${proc_dir}/*_surf.meta`
do
	if [ ${template_made} -eq 0 ]
	then
		echo "ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/template_ -subdivLevel $subdiv -spharmDegree $degree"
		ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/template_ -subdivLevel $subdiv -spharmDegree $degree
		template_made=1
	fi
done

# Register to template
for Surface in `ls ${proc_dir}/*_surf.meta`
do
	Surf=`basename ${Surface}`
	echo "ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/${Surf%_surf.meta}_to_template  -subdivLevel $subdiv -spharmDegree $degree -flipTemplate ${output_dir}/template_SPHARM_ellalign.coef -regTemplate ${output_dir}/template_SPHARM_ellalign.meta -paraOut -procRotationOff"
	qbatch -oe ~/log_sge -N SPHARM -q long.q ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/${Surf%_surf.meta}_to_template  -subdivLevel $subdiv -spharmDegree $degree -flipTemplate ${output_dir}/template_SPHARM_ellalign.coef -regTemplate ${output_dir}/template_SPHARM_ellalign.meta -paraOut
	sleep 5
done

JOBS=`qstat |grep SPHARM |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "SPHARM pas encore fini"
sleep 30
JOBS=`qstat | grep SPHARM | wc -l`
done

echo "nettoyage"
rm -fr ${input_dir}/temp
echo "c'est fini"

