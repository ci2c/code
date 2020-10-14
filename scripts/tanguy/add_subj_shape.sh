#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage:  add_subj_shape.sh -i <input_dir> -o <output_dir> -roi <ROI>"
	echo ""
	echo "	-i				: input dir"
	echo "	-o				: output dir"
	echo "	-roi				: ROI to add"
	echo ""
	echo "Usage:  add_subj_shape.sh -i <input_dir> -o <output_dir> -roi <ROI>"
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
		echo "Usage:  add_subj_shape.sh -i <input_dir> -o <output_dir> -roi <ROI>"
		echo ""
		echo "	-i				: input dir"
		echo "	-o				: output dir"
		echo "	-roi				: ROI to add"
		echo ""
		echo "Usage:  add_subj_shape.sh -i <input_dir> -o <output_dir> -roi <ROI>"
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
	-roi)
		index=$[$index+1]
		eval roi=\${$index}
		echo "ROI to add : ${roi}"
		;;

	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  add_subj_shape.sh -i <input_dir> -o <output_dir> -roi <ROI>"
		echo ""
		echo "	-i				: input dir"
		echo "	-o				: output dir"
		echo "	-roi				: ROI to add"
		echo ""
		echo "Usage:  add_subj_shape.sh -i <input_dir> -o <output_dir> -roi <ROI>"
		echo ""
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done




echo ""
echo ""

#proc_dir variable
echo "proc_dir=${input_dir}/post_proc"
proc_dir=${input_dir}/post_proc


##########
### run shape extraction
##########

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
### prep data
##########

echo ""
echo "##########"
echo "binarize data"
echo "##########"

Im=${roi%%.ni*}
echo "fslmaths ${input_dir}/${roi} -bin ${input_dir}/temp/${Im%.ni*}_bin"
fslmaths ${input_dir}/${roi} -bin ${input_dir}/temp/${Im%.ni*}_bin



echo "extraction des fichiers gz"
echo "gunzip -f ${input_dir}/temp/${Im}_bin.nii.gz"
gunzip -f ${input_dir}/temp/${Im}_bin.nii.gz

echo ""
echo ""
echo ""



morpho=1

	
echo "correc_shape.sh -i ${input_dir} -o ${output_dir} -roi $roi -morpho $morpho"
correc_shape.sh -i ${input_dir} -o ${output_dir} -roi $roi -morpho $morpho

if [ ! -f ${output_dir}/${Im}_bin_close_to_templateSPHARM_ellalign.meta ]
then
	
	touch ${output_dir}/verif/ver_touch/euler/$roi
	ex=0
else
	ex=1
fi

while [ $ex -eq 0 ]
do

	morpho=$((morpho+1))
	if [ -f ${output_dir}/verif/ver_touch/euler/$roi ]
	then
		echo "correc_shape.sh -i ${input_dir} -o ${output_dir} -roi $roi -morpho $morpho"
		correc_shape.sh -i ${input_dir} -o ${output_dir} -roi $roi -morpho $morpho
	fi


	if [ -f ${output_dir}/${Im}_bin_close_to_templateSPHARM_ellalign.meta ]
	then
		rm -f ${output_dir}/verif/ver_touch/euler/$roi
		ex=1
	fi

done
		


