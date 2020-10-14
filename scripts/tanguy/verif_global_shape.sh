#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  verif_global_shape.sh -i <input_dir> -o <output_dir> -m <morph_clos>"
	echo ""
	echo "	-i				: input dir"
	echo "	-o				: output dir"
	echo "	-m				: morpholocal closing value"
	echo ""
	echo "Usage:  verif_global_shape.sh -i <input_dir> -o <output_dir> -m <morph_clos>"
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
		echo "Usage:  verif_global_shape.sh -i <input_dir> -o <output_dir> -m <morph_clos>"
		echo ""
		echo "	-i				: input dir"
		echo "	-o				: output dir"
		echo "	-m				: morpholocal closing value"
		echo ""
		echo "Usage:  verif_global_shape.sh -i <input_dir> -o <output_dir> -m <morph_clos>"
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

	-m)
		index=$[$index+1]
		eval morpho=\${$index}
		echo "morphological closing value : ${morpho}"
		;;
	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  verif_global_shape.sh -i <input_dir> -o <output_dir> -m <morph_clos>"
		echo ""
		echo "	-i				: input dir"
		echo "	-o				: output dir"
		echo "	-m				: morpholocal closing value"
		echo ""
		echo "Usage:  verif_global_shape.sh -i <input_dir> -o <output_dir> -m <morph_clos>"
		echo ""
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done



echo "" >> $output_dir/verif/verif.txt
echo "" >> $output_dir/verif/verif.txt
echo "verification de l'execution du script T_Script_shape.sh" >> $output_dir/verif/verif.txt
echo "$(date +%Y%m%d) - $(date +%H%M)" >> $output_dir/verif/verif.txt
echo "morphological closing : $morpho" >> $output_dir/verif/verif.txt
echo "" >> $output_dir/verif/verif.txt
echo "" >> $output_dir/verif/verif.txt



for roi_init in `ls $input_dir/*.nii`
do
	roiinit=`basename $roi_init`
	roiname=${roiinit%%.nii*}

	
	echo "" >> $output_dir/verif/verif.txt
	echo "" >> $output_dir/verif/verif.txt
	echo $roiname >> $output_dir/verif/verif.txt
	echo "test for file : ${output_dir}/${roiname}_bin_close_to_templateSPHARM_ellalign.meta" >> $output_dir/verif/verif.txt
	if [ ! -f $output_dir/${roiname}_bin_close_to_templateSPHARM_ellalign.meta ]
	then
		echo "problème durant le traitement de $roiname :" >> $output_dir/verif/verif.txt
		echo "Description: Warning: Euler equation not satisfied." >> $output_dir/verif/verif.txt
		echo "problème de ROI" >> $output_dir/verif/verif.txt
		echo "modifier la ROI puis relancer le script" >> $output_dir/verif/verif.txt
		touch $output_dir/verif/ver_touch/euler/$roiinit
					
	else
		echo "traitement de $roiname ok" >> $output_dir/verif/verif.txt
	fi
done



