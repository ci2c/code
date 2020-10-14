#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  run_script_shape.sh -i <input_dir> -o <output_dir>"
	echo ""
	echo "  -i				: input dir"
	echo "  -o				: output dir"
	echo ""
	echo "Usage:  run_script_shape.sh -i <input_dir> -o <output_dir>"
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
		echo "Usage:  run_script_shape.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo "  -i				: input dir"
		echo "  -o				: output dir"
		echo ""
		echo "Usage:  run_script_shape.sh -i <input_dir> -o <output_dir>"
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
		echo "Usage:  run_script_shape.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo "  -i				: input dir"
		echo "  -o				: output dir"
		echo ""
		echo "Usage:  run_script_shape.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

ex=0
while [ $ex -ne 1 ]
do
	T_Script_shape.sh -i $input_dir -o $output_dir -morpho 1
	
	
	n=`ls ${output_dir}/verif/ver_touch/euler | wc -l`
	
	if [ $n -gt 0



