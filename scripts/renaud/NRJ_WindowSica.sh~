#! /bin/bash

if [ $# -lt 14 ]
then
	echo ""
	echo "Usage:  NRJ_WindowSica.sh  -i <data_path>  -Ns <value>  -pref <prefix>  -w <value>  -ov <value>  -tr <value>  -N <value>"
	echo ""
	echo "  -i                    : Path to data "
	echo "  -Ns                   : number of sessions "
	echo "  -pref                 : prefix of input files"
	echo "  -w                    : number of windows "
	echo "  -ov                   : overlap between windows "
	echo "  -tr                   : TR value "
	echo "  -N                    : number of components "
	echo ""
	echo "Usage:  NRJ_WindowSica.sh  -i <data_path>  -Ns <value>  -pref <prefix>  -w <value>  -ov <value>  -tr <value>  -N <value>"
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
		echo "Usage:  NRJ_WindowSica.sh  -i <data_path>  -Ns <value>  -pref <prefix>  -w <value>  -ov <value>  -tr <value>  -N <value>"
		echo ""
		echo "  -i                    : Path to data "
		echo "  -Ns                   : number of sessions "
		echo "  -pref                 : prefix of input files"
		echo "  -w                    : number of windows "
		echo "  -ov                   : overlap between windows "
		echo "  -tr                   : TR value "
		echo "  -N                    : number of components "
		echo ""
		echo "Usage:  NRJ_WindowSica.sh  -i <data_path>  -Ns <value>  -pref <prefix>  -w <value>  -ov <value>  -tr <value>  -N <value>"
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
	-Ns)
		index=$[$index+1]
		eval Ns=\${$index}
		echo "number of sessions : ${Ns}"
		;;
	-pref)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix of input files : ${prefix}"
		;;
	-w)
		index=$[$index+1]
		eval nwind=\${$index}
		echo "number of windows : ${nwind}"
		;;
	-ov)
		index=$[$index+1]
		eval overlap=\${$index}
		echo "overlap : ${overlap}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR : ${TR}"
		;;
	-N)
		index=$[$index+1]
		eval ncomp=\${$index}
		echo "number of components : ${ncomp}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  NRJ_WindowSica.sh  -i <data_path>  -Ns <value>  -pref <prefix>  -w <value>  -ov <value>  -tr <value>  -N <value>"
		echo ""
		echo "  -i                    : Path to data "
		echo "  -Ns                   : number of sessions "
		echo "  -pref                 : prefix of input files"
		echo "  -w                    : number of windows "
		echo "  -ov                   : overlap between windows "
		echo "  -tr                   : TR value "
		echo "  -N                    : number of components "
		echo ""
		echo "Usage:  NRJ_WindowSica.sh  -i <data_path>  -Ns <value>  -pref <prefix>  -w <value>  -ov <value>  -tr <value>  -N <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${input} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${Ns} ]
then
	 echo "-Ns argument mandatory"
	 exit 1
fi

if [ -z ${nwind} ]
then
	 echo "-w argument mandatory"
	 exit 1
fi

if [ -z ${overlap} ]
then
	 echo "-ov argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-tr argument mandatory"
	 exit 1
fi

if [ -z ${ncomp} ]
then
	 echo "-N argument mandatory"
	 exit 1
fi


for (( i=1; i<=${Ns}; i++ ))
do

    echo " Preprocessing session $i "
    
    if [ ${i} -lt 10 ]
    then
      ses=sess0${i}
    else
      ses=sess${i}
    fi
    
    echo "FMRI_WindowSica.sh -i ${input}/fmri/${ses}/spm -pref ${prefix} -o ${input}/fmri/${ses} -w ${nwind} -ov ${overlap} -tr ${TR} -N ${ncomp}"
    qbatch -q fs_q -oe /home/renaud/log/ -N ica_${ses} FMRI_WindowSica.sh -i ${input}/fmri/${ses}/spm -pref ${prefix} -a ${input}/anat -o ${input}/fmri/${ses} -w ${nwind} -ov ${overlap} -tr ${TR} -N ${ncomp}

    sleep 5

done