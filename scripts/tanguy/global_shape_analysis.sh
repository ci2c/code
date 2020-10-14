#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  global_shape_analysis.sh -i <input_dir> -o <output_dir>"
	echo ""
	echo "	-i				: input dir"
	echo "	-o				: output dir"
	echo ""
	echo "Usage:  global_shape_analysis.sh -i <input_dir> -o <output_dir>"
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
		echo "Usage:  global_shape_analysis.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo "  -i				: input dir"
		echo "  -o				: output dir"
		echo ""
		echo "Usage:  global_shape_analysis.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo ""
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
		echo "Usage:  global_shape_analysis.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo "  -i				: input dir"
		echo "  -o				: output dir"
		echo ""
		echo "Usage:  global_shape_analysis.sh -i <input_dir> -o <output_dir>"
		echo ""
		echo ""
		;;
	esac
	index=$[$index+1]
done


##########
### prep directories
##########

#init output_dir or erase content
if [ ! -d ${output_dir} ]
then
	echo "mkdir -p ${output_dir}"
	mkdir -p ${output_dir}/template
	
else	
	echo "rm -f ${output_dir}/*"
	rm -Rf ${output_dir}
	mkdir -p ${output_dir}/template
fi


#init post_proc dir or erase content
if [ ! -d ${input_dir}/post_proc ]
then
	echo "mkdir -p ${input_dir}/post_proc"
	mkdir -p ${input_dir}/post_proc
else
	echo "rm -f ${input_dir}/post_proc/*"
	rm -Rf ${input_dir}/post_proc/*
fi


#erase Logdir content if it exists
if [ -d ${input_dir}/Logdir ]
then
	echo "rm -f ${input_dir}/Logdir/*"
	rm -Rf ${input_dir}/Logdir/*	
fi


#init Log directories
echo "mkdir -p ${input_dir}/Logdir"
mkdir -p ${input_dir}/Logdir/prep
mkdir -p ${input_dir}/Logdir/morpho
mkdir -p ${input_dir}/Logdir/SegPostProcess
mkdir -p ${input_dir}/Logdir/GenParaMesh
mkdir -p ${input_dir}/Logdir/ParaToSPHARMMesh
mkdir -p ${input_dir}/Logdir/corr


#init temp dir or erase content
if [ ! -d ${input_dir}/temp ]
then
	echo "mkdir -p ${input_dir}/temp"
	mkdir -p ${input_dir}/temp
else
	echo "rm -f ${input_dir}/temp/*"
	rm -Rf ${input_dir}/temp/*
fi

echo ""
echo ""

#proc_dir variable
echo "proc_dir=${input_dir}/post_proc"
proc_dir=${input_dir}/post_proc

#create folders for verif
mkdir $output_dir/verif
mkdir $output_dir/verif/ver_touch
mkdir $output_dir/verif/ver_touch/euler
touch $output_dir/verif/verif.txt

##########
### run shape extraction
##########


run_shape.sh -i ${input_dir} -o ${output_dir}


ex=0

morpho=1


##########
### correction for failed ROIs
##########


while [ $ex -ne 1 ]
do


	# Verifications 
	echo "verif_global_shape.sh -i $input_dir -o $output_dir -m $morpho"
	verif_global_shape.sh -i $input_dir -o $output_dir -m $morpho

	n=`ls ${output_dir}/verif/ver_touch/euler | wc -l`

	echo ""
	echo ""
	echo "morphological closing : $morpho"
	echo "fail for $n subjects"
	echo ""
	echo ""


	if [ $morpho -gt 6 ]
	then
		ex=1
	elif [ $n -gt 0 ]
	then
		morpho=$((morpho+1))
		for roi in `ls ${output_dir}/verif/ver_touch/euler`
		do
			roi=`basename $roi`
			echo "qbatch -N corr_${morpho}_$roi -q fs_q -oe ${input_dir}/Logdir/corr correc_shape.sh  -i $input_dir -o $output_dir -roi $roi -morpho $morpho"
			qbatch -N corr_${morpho}_$roi -q fs_q -oe ${input_dir}/Logdir/corr correc_shape.sh  -i $input_dir -o $output_dir -roi $roi -morpho $morpho
		done
		rm -f ${output_dir}/verif/ver_touch/euler/*	

	else
		ex=1
	fi

	JOBS=`qstat |grep corr_${morpho} |wc -l`
	while [ ${JOBS} -ge 1 ]
	do
	echo "runing correction with morphological closing value : $morpho"
	sleep 20
	JOBS=`qstat | grep corr | wc -l`
	done

done















