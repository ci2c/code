#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage:  Alexis_design_matrix.sh  -o <outputdir> -s <subject> -xls <eventstimes> -mat <paradigm>"
	echo ""
	echo "  -o                           : ouutput directory "
	echo "  -s                           : subject "
	echo "  -xls                         : .xls file describing the events times for 2 runs "
	echo "  -mat                         : .mat file containing the paradigm used during aquisition "
	echo ""
	echo "Usage:  Alexis_design_matrix.sh  -o <outputdir> -s <subject> -xls <eventstimes> -mat <paradigm>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 24, 2013"
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
		echo "Usage:  Alexis_design_matrix.sh  -o <outputdir> -s <subject> -xls <eventstimes> -mat <paradigm>"
		echo ""
		echo "  -o                           : ouutput directory "
		echo "  -s                           : subject "
		echo "  -xls                         : .xls file describing the events times for 2 runs "
		echo "  -mat                         : .mat file containing the paradigm used during aquisition "
		echo ""
		echo "Usage:  Alexis_design_matrix.sh  -o <outputdir> -s <subject> -xls <eventstimes> -mat <paradigm>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 24, 2013"
		echo ""
		exit 1
		;;
	-o)
		index=$[$index+1]
		eval OUTDIR=\${$index}
		echo "Output directory : ${OUTDIR}"
		;;
	-s)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subject name : ${SUBJ}"
		;;
	-xls)
		index=$[$index+1]
		eval fxls=\${$index}
		echo ".xls file describing the events times for 2 runs : ${fxls}"
		;;
	-mat)
		index=$[$index+1]
		eval fmat=\${$index}
		echo ".mat file containing the paradigm used during aquisition : ${fmat}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  Alexis_design_matrix.sh  -o <outputdir> -s <subject> -xls <eventstimes> -mat <paradigm>"
		echo ""
		echo "  -o                           : ouutput directory "
		echo "  -s                           : subject "
		echo "  -xls                         : .xls file describing the events times for 2 runs "
		echo "  -mat                         : .mat file containing the paradigm used during aquisition "
		echo ""
		echo "Usage:  Alexis_design_matrix.sh  -o <outputdir> -s <subject> -xls <eventstimes> -mat <paradigm>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 24, 2013"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${OUTDIR} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-s argument mandatory"
	 exit 1
fi

if [ -z ${fxls} ]
then
	 echo "-xls argument mandatory"
	 exit 1
fi

if [ -z ${fmat} ]
then
	 echo "-mat argument mandatory"
	 exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF
Alexis_design_matrix('${OUTDIR}','${SUBJ}','${fmat}','${fxls}');
EOF