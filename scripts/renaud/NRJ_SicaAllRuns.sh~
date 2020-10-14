#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage:  NRJ_SicaAllRuns.sh  -i <data_path>  -pref <name>  -TR <value>  -Ns <value>  -Ncomp <value>"
	echo ""
	echo "  -i                           : Path to data "
	echo "  -pref                        : Prefix of epi files "
	echo "  -TR                          : TR value "
	echo "  -Ns                          : Number of sessions "
	echo "  -Ncomp                       : Number of components "
	echo ""
	echo "Usage:  NRJ_SicaAllRuns.sh  -i <data_path>  -pref <name>  -TR <value>  -Ns <value>  -Ncomp <value>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
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
		echo "Usage:  NRJ_SicaAllRuns.sh  -i <data_path>  -pref <name>  -TR <value>  -Ns <value>  -Ncomp <value>"
		echo ""
		echo "  -i                           : Path to data "
		echo "  -pref                        : Prefix of epi files "
		echo "  -TR                          : TR value "
		echo "  -Ns                          : Number of sessions "
		echo "  -Ncomp                       : Number of components "
		echo ""
		echo "Usage:  NRJ_SicaAllRuns.sh  -i <data_path>  -pref <name>  -TR <value>  -Ns <value>  -Ncomp <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data : ${input}"
		;;
	-pref)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix of input files : ${prefix}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-Ns)
		index=$[$index+1]
		eval Ns=\${$index}
		echo "number of sessions : ${Ns}"
		;;
	-Ncomp)
		index=$[$index+1]
		eval ncomp=\${$index}
		echo "number of components : ${ncomp}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  NRJ_SicaAllRuns.sh  -i <data_path>  -pref <name>  -TR <value>  -Ns <value>  -Ncomp <value>"
		echo ""
		echo "  -i                           : Path to data "
		echo "  -pref                        : Prefix of epi files "
		echo "  -TR                          : TR value "
		echo "  -Ns                          : Number of sessions "
		echo "  -Ncomp                       : Number of components "
		echo ""
		echo "Usage:  NRJ_SicaAllRuns.sh  -i <data_path>  -pref <name>  -TR <value>  -Ns <value>  -Ncomp <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

NRJ_SicaAllRuns('${input}',${Ns},'${prefix}',${ncomp},${TR});
 
EOF