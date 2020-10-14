#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage:  Create_glm_file.sh -i <input_dir> -o <output_dir> -pref1 <prefix1> -val1 <value1> -val2 <value2> [-pref2 <prefix2> -cov <covariables file>]"
	echo ""
	echo "	-i				: input dir"
	echo "	-o				: output dir"
	echo "	-pref1				: prefix group 1 "
	echo "	-val1				: value group 1"
	echo "	-val2				: value group 2"
	echo "	-pref2				: FACULTATIF : prefix group2"
	echo "	-cov				: FACULTATIF : covariables file"
	echo ""
	echo "Usage:  Create_glm_file.sh -i <input_dir> -o <output_dir> -pref1 <prefix1> -val1 <value1> -val2 <value2> [-pref2 <prefix2> -cov <covariables file>]"
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
		echo "Usage:  Create_glm_file.sh -i <input_dir> -o <output_dir> -pref1 <prefix1> -val1 <value1> -val2 <value2> [-pref2 <prefix2> -cov <covariables file>]"
		echo ""
		echo "	-i				: input dir"
		echo "	-o				: output dir"
		echo "	-pref1				: prefix group 1 "
		echo "	-val1				: value group 1"
		echo "	-val2				: value group 2"
		echo "	-pref2				: FACULTATIF : prefix group2"
		echo ""
		echo "Usage:  Create_glm_file.sh -i <input_dir> -o <output_dir> -pref1 <prefix1> -val1 <value1> -val2 <value2> [-pref2 <prefix2> -cov <covariables file>]"
		echo ""
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval SD=\${$index}
		echo "input directory : ${SD}"
		;;
	-o)
		index=$[$index+1]
		eval output_dir=\${$index}
		echo "output directory : ${output_dir}"
		;;
	
	-pref1)
		index=$[$index+1]
		eval pregroup1=\${$index}
		echo "prefix group 1 : ${pregroup1}"
		;;
	-val1)
		index=$[$index+1]
		eval valuegroup1=\${$index}
		echo "value group 1 : ${valuegroup1}"
		;;
	-pref2)
		index=$[$index+1]
		eval pregroup2=\${$index}
		echo "prefix group 2 : ${pregroup2}"
		;;
	-val2)
		index=$[$index+1]
		eval valuegroup2=\${$index}
		echo "value group 2 : ${valuegroup2}"
		;;
	-cov)
		index=$[$index+1]
		eval cov=\${$index}
		echo "covariables file : ${cov}"
		;;
	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  Create_glm_file.sh -i <input_dir> -o <output_dir> -pref1 <prefix1> -val1 <value1> -val2 <value2> [-pref2 <prefix2> -cov <covariables file>]"
		echo ""
		echo "	-i				: input dir"
		echo "	-o				: output dir"
		echo "	-pref1				: prefix group 1 "
		echo "	-val1				: value group 1"
		echo "	-val2				: value group 2"
		echo "	-pref2				: FACULTATIF : prefix group2"
		echo ""
		echo "Usage:  Create_glm_file.sh -i <input_dir> -o <output_dir> -pref1 <prefix1> -val1 <value1> -val2 <value2> [-pref2 <prefix2> -cov <covariables file>]"
		echo ""
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

if [ ! -d $output_dir ]
then
	rm -f ${output_dir}/*txt
fi

### init

suff='ellalign.meta'
mkdir -p $output_dir


### traitement groupe 1

lpg1=${#pregroup1}

for file in `ls $SD/*$suff`
do

filename=`basename $file`
filepre=`expr substr $filename 1 $lpg1`


case "$filepre" in
$pregroup1 ) echo "$valuegroup1 1 $SD/$filename" >> $output_dir/glm.txt;;
* ) ;;
esac
done



### traitement groupe 2

if  [[ ! -z "$pregroup2" ]]
then

lpg2=${#pregroup2}

for file in `ls $SD/*$suff`
do

filename=`basename $file`
filepre=`expr substr $filename 1 $lpg2`


case "$filepre" in
$pregroup2 ) echo "$valuegroup2 1 $SD/$filename" >> $output_dir/glm.txt;;
* ) ;;
esac
done

else

for file in `ls $SD/*$suff`
do

filename=`basename $file`
filepre=`expr substr $filename 1 $lpg1`

case "$filepre" in
$pregroup1 ) ;;
* ) echo "$valuegroup2 1 $SD/$filename" >> $output_dir/glm.txt;;
esac
done

fi

glm_file=$output_dir/glm.txt

echo "cov : $cov"

if [[ ! -z "$cov" ]]
then
	echo "prise en compte des covariables"
	echo ""
	echo ""
		
/usr/local/matlab11/bin/matlab -nodisplay <<EOF


Complete_glm_file('$glm_file','$cov')

EOF

fi




