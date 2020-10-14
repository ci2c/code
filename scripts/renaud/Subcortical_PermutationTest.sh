#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage:  Subcortical_PermutationTest.sh  -i <maps_file>  -n <value>  -o <output_directory>  -m <mask>"
	echo ""
	echo "  -i                         : maps file "
	echo "  -n                         : iteration "
	echo "  -o                         : Output directory "
	echo "  -m                         : mask file "
	echo ""
	echo "Usage:  Subcortical_PermutationTest.sh  -i <maps_file>  -n <value>  -o <output_directory>  -m <mask>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Jan 15, 2013"
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
		echo "Usage:  Subcortical_PermutationTest.sh  -i <maps_file>  -n <value>  -o <output_directory>  -m <mask>"
		echo ""
		echo "  -i                         : maps file "
		echo "  -n                         : iteration "
		echo "  -o                         : Output directory "
		echo "  -m                         : mask file "
		echo ""
		echo "Usage:  Subcortical_PermutationTest.sh  -i <maps_file>  -n <value>  -o <output_directory>  -m <mask>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 15, 2013"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval maps=\${$index}
		echo "maps file : ${maps}"
		;;
	-n)
		index=$[$index+1]
		eval iter=\${$index}
		echo "iteration : ${iter}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-m)
		index=$[$index+1]
		eval mask=\${$index}
		echo "mask file : ${mask}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  Subcortical_PermutationTest.sh  -i <maps_file>  -n <value>  -o <output_directory>  -m <mask>"
		echo ""
		echo "  -i                         : maps file "
		echo "  -n                         : iteration "
		echo "  -o                         : Output directory "
		echo "  -m                         : mask file "
		echo ""
		echo "Usage:  Subcortical_PermutationTest.sh  -i <maps_file>  -n <value>  -o <output_directory>  -m <mask>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 15, 2013"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${maps} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${iter} ]
then
	 echo "-n argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${mask} ]
then
	 echo "-m argument mandatory"
	 exit 1
fi


/usr/local/matlab11/bin/matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

Subcortical_PermutationTestForBash('${maps}','${outdir}','${mask}',${iter});
 
EOF

