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
numberOfOptimizationIterations=1000
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
	mkdir ${input_dir}/post_proc
else
	rm -f ${input_dir}/post_proc/*
fi

proc_dir=${input_dir}/post_proc

for Image in `ls ${input_dir}/*.ni*`
do
	Im=`basename ${Image}`
	echo "fslmaths ${Image} -bin ${input_dir}/${Im%.ni*}_bin"
	fslmaths ${Image} -bin ${input_dir}/${Im%.ni*}_bin
done

echo "gunzip des fichiers gz"
gunzip -f ${input_dir}/*bin.nii.gz

for Image in `ls ${input_dir}/*bin.ni*`
do
	Im=`basename ${Image}`
	echo "mri_morphology ${Image} close 1 ${proc_dir}/${Im%.ni*}_close.nii"
	mri_morphology ${Image} close 1 ${proc_dir}/${Im%.ni*}_close.nii
done

for Image in `ls ${proc_dir}/*.nii`
do
	Im=`basename ${Image}`
	echo "SegPostProcess ${Image} -o ${Image%.ni*}.gipl -space ${space} -label 1 -iter ${iterSegPost}"
	qbatch -N SegPostProcess -q fs_q SegPostProcess ${Image} -o ${Image%.ni*}.gipl -space ${space} -label 1 -iter ${iterSegPost}
	sleep 2
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
	qbatch -N GenParaMesh -q fs_q GenParaMesh ${Image} -outbase ${Image%.gipl} -iter ${numberOfOptimizationIterations} -label 1
	sleep 2
done

JOBS=`qstat |grep GenPara |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "GenPara pas encore fini"
sleep 30
JOBS=`qstat | grep GenPara | wc -l`
done

# Make template (take 1st mask as the ref)
template_made=0
for Surface in `ls ${proc_dir}/*_surf.meta`
do
	if [ ${template_made} -eq 0 ]
	then
		echo "ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/template_ -subdivLevel $subdiv -spharmDegree $degree" # remove -procRotationOff
		ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/template_ -subdivLevel $subdiv -spharmDegree $degree
		template_made=1
	fi
done

# Register to template
for Surface in `ls ${proc_dir}/*_surf.meta`
do
	Surf=`basename ${Surface}`
	echo "ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/${Surf%_surf.meta}_to_template  -subdivLevel $subdiv -spharmDegree $degree -flipTemplate ${output_dir}/template_SPHARM_ellalign.coef -regTemplate ${output_dir}/template_SPHARM_ellalign.meta -paraOut"
	ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/${Surf%_surf.meta}_to_template  -subdivLevel $subdiv -spharmDegree $degree -flipTemplate ${output_dir}/template_SPHARM_ellalign.coef -regTemplate ${output_dir}/template_SPHARM_ellalign.meta -paraOut
done

# Performs stats
#G=0
#echo \# groupID scalingFactor meshfile > ${output_dir}/stats_file.txt
#for Group in `cat ${stat_file}`
#do
#  for Surface in `ls ${output_dir}/*SPHARM_procalign.meta | grep ${Group}`
#  do
#    echo ${G} 1.0 ${Surface} >> ${output_dir}/stats_file.txt
#  done
#  G=$[$G+1]
#done

#echo "StatNonParamTestPDM ${output_dir}/stats_file.txt -surfList -numPerms ${numPerms} -signLevel ${signLevel} -signSteps ${signSteps} -out ${output_dir}/nonParamTest"
#StatNonParamTestPDM ${output_dir}/stats_file.txt -surfList -numPerms ${numPerms} -signLevel ${signLevel} -signSteps ${signSteps} -out ${output_dir}/nonParamTest
