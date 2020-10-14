#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  correc_shape.sh -i <input_dir> -o <output_dir> -roi <ROI_file> -morpho <morphological closing>"
	echo ""
	echo "	-i				: input dir"
	echo "	-o				: output dir"
	echo "	-roi				: roi file to correc"
	echo "	-morpho				: morphological closing value"
	echo ""
	echo "Usage:  correc_shape.sh -i <input_dir> -o <output_dir> -roi <ROI_file> -morpho <morphological closing>"
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
		echo "Usage:  correc_shape.sh -i <input_dir> -o <output_dir> -roi <ROI_file> -morpho <morphological closing>"
		echo ""
		echo "	-i				: input dir"
		echo "	-o				: output dir"
		echo "	-roi				: roi file to correc"
		echo "	-morpho				: morphological closing value"
		echo ""
		echo "Usage:  correc_shape.sh -i <input_dir> -o <output_dir> -roi <ROI_file> -morpho <morphological closing>"
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
		echo "roi to correct : ${roi}"
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
		echo "Usage:  correc_shape.sh -i <input_dir> -o <output_dir> -roi <ROI_file> -morpho <morphological closing>"
		echo ""
		echo "	-i				: input dir"
		echo "	-o				: output dir"
		echo "	-roi				: roi file to correc"
		echo "	-morpho				: morphological closing value"
		echo ""
		echo "Usage:  correc_shape.sh -i <input_dir> -o <output_dir> -roi <ROI_file> -morpho <morphological closing>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

file_pre=${roi%%.ni*}

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
proc_dir=${input_dir}/post_proc


echo "proc_dir=${input_dir}/post_proc"
proc_dir=${input_dir}/post_proc


##########
### prep directories
##########

##########
### prep data
##########

echo ""
echo "##########"
echo "Morphological closing"
echo "##########"


Image=${input_dir}/temp/${file_pre}_bin.nii
Im=`basename ${Image}`
echo ""
echo "Im : $Im"

echo "mri_morphology ${Image} close $morpho ${input_dir}/temp/${file_pre}_bin_close.nii"
mri_morphology ${Image} close $morpho ${input_dir}/temp/${file_pre}_bin_close.nii


echo ""
echo "##########"
echo "Step 1 : SegPostProcess"
echo "##########"


Image=${input_dir}/temp/${file_pre}_bin_close.nii
Im=`basename ${Image}`
echo ""
echo "Im : $Im"

echo "SegPostProcess ${Image} -o ${proc_dir}/${file_pre}_bin_close.gipl -space ${space} -label 1 -iter ${iterSegPost}"
SegPostProcess ${Image} -o ${proc_dir}/${file_pre}_bin_close.gipl -space ${space} -label 1 -iter ${iterSegPost}



echo ""
echo "##########"
echo "Step 2 : GenParaMesh"
echo "##########"



Image=${proc_dir}/${file_pre}_bin_close.gipl
Im=`basename ${Image}`
echo ""
echo ""
echo "run GenParaMesh for $Im"
echo ""
echo "GenParaMesh ${Image} -outbase ${file_pre}_bin_close -iter ${numberOfOptimizationIterations} -label 1"
GenParaMesh ${Image} -outbase ${proc_dir}/${file_pre}_bin_close -iter ${numberOfOptimizationIterations} -label 1



echo ""
echo "##########"
echo "Step 3 : ParaToSPHARMMesh"
echo "##########"



# Register to template


Surface=${proc_dir}/${file_pre}_bin_close_surf.meta
Surf=`basename ${Surface}`
echo "ParaToSPHARMMesh ${Surface} ${proc_dir}/${file_pre}_bin_close_para.meta -outbase ${output_dir}/${file_pre}_bin_close_to_template  -subdivLevel $subdiv -spharmDegree $degree -flipTemplate ${output_dir}/template/template_SPHARM_ellalign.coef -regTemplate ${output_dir}/template_SPHARM_ellalign.meta -paraOut"
ParaToSPHARMMesh ${Surface} ${proc_dir}/${file_pre}_bin_close_para.meta -outbase ${output_dir}/${file_pre}_bin_close_to_template  -subdivLevel $subdiv -spharmDegree $degree -flipTemplate ${output_dir}/template/template_SPHARM_ellalign.coef -regTemplate ${output_dir}/template/template_SPHARM_ellalign.meta -paraOut





