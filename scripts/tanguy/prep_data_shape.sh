#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage:  prep_data_shape.sh -i <input_dir> -o <output_dir> -morpho <morph_clos>"
	echo ""
	echo "  -i				: input dir"
	echo "  -o				: output dir"
	echo "	-morpho				: morphological closing value - 1 by default"
	echo ""
	echo "Usage:  prep_data_shape.sh -i <input_dir> -o <output_dir> -morpho <morph_clos>"
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
		echo ""
		echo "Usage:  prep_data_shape.sh -i <input_dir> -o <output_dir> -morpho <morph_clos>"
		echo ""
		echo "  -i				: input dir"
		echo "  -o				: output dir"
		echo "	-morpho				: morphological closing value - 1 by default"
		echo ""
		echo "Usage:  prep_data_shape.sh -i <input_dir> -o <output_dir> -morpho <morph_clos>"
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
	-morpho)
		index=$[$index+1]
		eval morpho=\${$index}
		echo "morphological closing value : ${morpho}"
		;;
	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  prep_data_shape.sh -i <input_dir> -o <output_dir> -morpho <morph_clos>"
		echo ""
		echo "  -i				: input dir"
		echo "  -o				: output dir"
		echo "	-morpho				: morphological closing value - 1 by default"
		echo ""
		echo "Usage:  prep_data_shape.sh -i <input_dir> -o <output_dir> -morpho <morph_clos>"
		echo ""
		echo ""
		exit 
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

	echo "qbatch -N morpho_$Im -q fs_q -oe ${input_dir}/Logdir/morpho mri_morphology ${Image} close $morpho ${input_dir}/temp/${Im%.ni*}_close.nii"
	qbatch -N morpho_$Im -q fs_q -oe ${input_dir}/Logdir/morpho mri_morphology ${Image} close $morpho ${input_dir}/temp/${Im%.ni*}_close.nii

done


JOBS=`qstat |grep morpho |wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "fermeture morphologique pas encore fini"
sleep 5
JOBS=`qstat | grep morpho | wc -l`
done
