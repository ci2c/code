#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: NEDICA_ICA.sh -i <input>  -m <file>  -TR <value>  -N <value>  -pref <prefix>  -o <name> "
	echo ""
	echo "  -i                           : epi folder "
	echo "  -m                           : mean epi file "
	echo "  -TR                          : TR value "
	echo "  -N                           : Number of components "
	echo "  -pref                        : prefix "
	echo "  -o                           : output folder "
	echo ""
	echo "Usage: NEDICA_ICA.sh -i <input>  -m <file>  -TR <value>  -N <value>  -pref <prefix>  -o <name> "
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
		echo "Usage: NEDICA_ICA.sh -i <input>  -m <file>  -TR <value>  -N <value>  -pref <prefix>  -o <name> "
		echo ""
		echo "  -i                           : epi folder "
		echo "  -m                           : mean epi file "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of components "
		echo "  -pref                        : prefix "
		echo "  -o                           : output folder "
		echo ""
		echo "Usage: NEDICA_ICA.sh -i <input>  -m <file>  -TR <value>  -N <value>  -pref <prefix>  -o <name> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "epi folder : ${input}"
		;;
	-m)
		index=$[$index+1]
		eval meanFile=\${$index}
		echo "mean epi file : ${meanFile}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-N)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of components : ${N}"
		;;
	-pref)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix : ${prefix}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : ${output}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: NEDICA_ICA.sh -i <input>  -m <file>  -TR <value>  -N <value>  -pref <prefix>  -o <name> "
		echo ""
		echo "  -i                           : epi folder "
		echo "  -m                           : mean epi file "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of components "
		echo "  -pref                        : prefix "
		echo "  -o                           : output folder "
		echo ""
		echo "Usage: NEDICA_ICA.sh -i <input>  -m <file>  -TR <value>  -N <value>  -pref <prefix>  -o <name> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

if [ -z ${input} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${meanFile} ]
then
	 echo "-m argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-TR argument mandatory"
	 exit 1
fi

if [ -z ${N} ]
then
	 echo "-N argument mandatory"
	 exit 1
fi

if [ -z ${prefix} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi


if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

## Delete out dir
if [ -d ${output} ]
then
	echo "rm -rf ${output}"
	rm -rf ${output}
fi
mkdir ${output}

matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

opt_sica.detrend          = 2;
opt_sica.norm             = 0;
opt_sica.slice_correction = 1;
opt_sica.algo             = 'Infomax';
opt_sica.type_nb_comp     = 0;
opt_sica.param_nb_comp    = ${N};
opt_sica.TR               = ${TR};

sica = NEDICA_Sica('${input}','${prefix}','${meanFile}',opt_sica,'${output}');
save(fullfile('${output}','sica.mat'),'sica','opt_sica');

EOF


