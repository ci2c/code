#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  T_Script_shape.sh -i <input_dir> -o <output_dir>"
	echo ""
	echo "  -i				: input dir"
	echo "  -o				: output dir"
	echo ""
	echo "Usage:  T_Script_shape.sh -i <input_dir> -o <output_dir>"
	echo ""
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
		echo "Usage:  T_Script_shape.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo "  -i				: input dir"
		echo "  -o				: output dir"
		echo ""
		echo "Usage:  T_Script_shape.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input_dir=\${$index}
		echo "input directory : ${input_dir}"
		;;
	-o)
		index=$[$index+1]
		eval output_dir=\${$index}
		echo "output directory : ${output_dir}"
		;;
	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  T_Script_shape.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo "  -i				: input dir"
		echo "  -o				: output dir"
		echo ""
		echo "Usage:  T_Script_shape.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


##########
### initialization parameters 
##########

space=0.5,0.5,0.5
iterSegPost=20
numberOfOptimizationIterations=200
subdiv=10
degree=12
numPerms=20000
signLevel=0.10
signSteps=10000



##########
### prep directories
##########

if [ ! -d ${output_dir} ]
then
	echo "mkdir -p ${output_dir}"
	mkdir -p ${output_dir}/template
	
else	
	echo "rm -f ${output_dir}/*"
	rm -Rf ${output_dir}
	mkdir -p ${output_dir}/template
fi

if [ ! -d ${input_dir}/post_proc ]
then
	echo "mkdir -p ${input_dir}/post_proc"
	mkdir -p ${input_dir}/post_proc
else
	echo "rm -f ${input_dir}/post_proc/*"
	rm -f ${input_dir}/post_proc/*
fi

if [ ! -d ${input_dir}/Logdir ]
then
	echo "mkdir -p ${input_dir}/Logdir"
	mkdir -p ${input_dir}/Logdir/prep
	mkdir -p ${input_dir}/Logdir/morpho
	mkdir -p ${input_dir}/Logdir/SegPostProcess
	mkdir -p ${input_dir}/Logdir/GenParaMesh
	mkdir -p ${input_dir}/Logdir/ParaToSPHARMMesh
else
	echo "rm -f ${input_dir}/Logdir/*"
	rm -Rf ${input_dir}/Logdir/*
	mkdir -p ${input_dir}/Logdir/prep
	mkdir -p ${input_dir}/Logdir/morpho
	mkdir -p ${input_dir}/Logdir/SegPostProcess
	mkdir -p ${input_dir}/Logdir/GenParaMesh
	mkdir -p ${input_dir}/Logdir/ParaToSPHARMMesh
fi


if [ ! -d ${input_dir}/temp ]
then
	echo "mkdir -p ${input_dir}/temp"
	mkdir -p ${input_dir}/temp
else
	echo "rm -f ${input_dir}/temp/*"
	rm -f ${input_dir}/temp/*
fi

echo ""
echo ""
echo "proc_dir=${input_dir}/post_proc"
proc_dir=${input_dir}/post_proc



##########
### prep data
##########

echo ""
echo "##########"
echo "binarize data"
echo "##########"

for Image in `ls ${input_dir}/*.ni*`
do
	Im=`basename ${Image}`
	echo ""
	echo "Im : $Im"

	echo "qbatch -N fslmaths -q fs_q -oe ${input_dir}/Logdir fslmaths ${Image} -bin ${input_dir}/${Im%.ni*}_bin"
	qbatch -N fslmaths_$Im -q fs_q -oe ${input_dir}/Logdir/prep/ fslmaths ${Image} -bin ${input_dir}/temp/${Im%.ni*}_bin

done
	
JOBS=`qstat |grep fslmaths |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "fslmaths pas encore fini"
sleep 5
JOBS=`qstat | grep fslmaths | wc -l`
done

echo "extraction des fichiers gz"
echo "gunzip -f ${input_dir}/temp/*bin.nii.gz"
gunzip -f ${input_dir}/temp/*bin.nii.gz


echo ""
echo "##########"
echo "Morphological closing"
echo "##########"


for Image in `ls ${input_dir}/temp/*bin.ni*`
do
	Im=`basename ${Image}`
	echo ""
	echo "Im : $Im"

	echo "qbatch -N morpho_$Im -q fs_q -oe ${input_dir}/Logdir/morpho mri_morphology ${Image} close 1 ${input_dir}/temp/${Im%.ni*}_close.nii"
	qbatch -N morpho_$Im -q fs_q -oe ${input_dir}/Logdir/morpho mri_morphology ${Image} close 1 ${input_dir}/temp/${Im%.ni*}_close.nii

done


JOBS=`qstat |grep morpho |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "fermeture morphologique pas encore fini"
sleep 5
JOBS=`qstat | grep morpho | wc -l`
done


echo ""
echo "##########"
echo "Step 1 : SegPostProcess"
echo "##########"


for Image in `ls ${input_dir}/temp/*close.nii`
do
	Im=`basename ${Image}`
	echo ""
	echo "Im : $Im"

	echo "qbatch -oe ${input_dir}/Logdir/SegPostProcess -N SegPostProcess_$Im -q fs_q SegPostProcess ${Image} -o ${proc_dir}/${Im%.ni*}.gipl -space ${space} -label 1 -iter ${iterSegPost}"
	qbatch -oe ${input_dir}/Logdir/SegPostProcess -N SegPostProcess_$Im -q fs_q SegPostProcess ${Image} -o ${proc_dir}/${Im%.ni*}.gipl -space ${space} -label 1 -iter ${iterSegPost}
	sleep 1
done

JOBS=`qstat |grep SegPost |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "SegPost pas encore fini"
sleep 5
JOBS=`qstat | grep SegPost | wc -l`
done



echo ""
echo "##########"
echo "Step 2 : GenParaMesh"
echo "##########"



for Image in `ls ${proc_dir}/*gipl`
do
	Im=`basename ${Image}`
	echo ""
	echo ""
	echo "run GenParaMesh for $Im"
	echo ""
	echo "qbatch -N GenPara -oe ${input_dir}/Logdir/GenParaMesh -q fs_q GenParaMesh ${Image} -outbase ${Image%.gipl} -iter ${numberOfOptimizationIterations} -label 1"
	qbatch -N GenPara_$Im -oe ${input_dir}/Logdir/GenParaMesh -q fs_q GenParaMesh ${Image} -outbase ${Image%.gipl} -iter ${numberOfOptimizationIterations} -label 1
	sleep 5
done




JOBS=`qstat |grep GenPara |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "GenParaMesh pas encore fini"
sleep 30
JOBS=`qstat | grep GenPara | wc -l`
done


chmod u+wxr ${proc_dir}/*_surf.meta


echo ""
echo "##########"
echo "Step 3 : ParaToSPHARMMesh"
echo "##########"



# Take first mask as template

Surface=`ls ${proc_dir}/*_surf.meta -1 | head -1`
echo "ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/template/template_ -subdivLevel $subdiv -spharmDegree $degree" # remove -procRotationOff
ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/template/template_ -subdivLevel $subdiv -spharmDegree $degree template_made=1 



# Register to template

for Surface in `ls ${proc_dir}/*_surf.meta`
do
	Surf=`basename ${Surface}`
	echo "qbatch -N ParaToS_$Surf -q fs_q -oe ${input_dir}/Logdir/ParaToSPHARMMesh ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/${Surf%_surf.meta}_to_template  -subdivLevel $subdiv -spharmDegree $degree -flipTemplate ${output_dir}/template/template_SPHARM_ellalign.coef -regTemplate ${output_dir}/template_SPHARM_ellalign.meta -paraOut"
	qbatch -N ParaToS_$Surf -q fs_q -oe ${input_dir}/Logdir/ParaToSPHARMMesh ParaToSPHARMMesh ${Surface} ${Surface%_surf.meta}_para.meta -outbase ${output_dir}/${Surf%_surf.meta}_to_template  -subdivLevel $subdiv -spharmDegree $degree -flipTemplate ${output_dir}/template/template_SPHARM_ellalign.coef -regTemplate ${output_dir}/template_SPHARM_ellalign.meta -paraOut
done

JOBS=`qstat |grep ParaToS |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "ParaToSPHARMMesh pas encore fini"
sleep 30
JOBS=`qstat | grep ParaToS | wc -l`
done




