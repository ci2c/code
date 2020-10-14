#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: FMRI_DynamicConnectivity.sh -i <path>  -o <path>  [-w <value>  -tr <value>  -mc <value>  -alpha <value>  -dodetrend  -dospike  -doL1 ] "
	echo ""
	echo "  -i                           : mat file with 'tseries' variable (nodex x times)"
	echo "  -o                           : output file (.mat) "
	echo "  -w                           : window size "
	echo "  -tr                          : TR value "
	echo "  -dospike                     : despiking step "
	echo "  -doL1                        : compute precision matrix with GLASSO instead of linear correlation "
	echo ""
	echo "Usage: FMRI_DynamicConnectivity.sh -i <path>  -o <path>  [-w <value>  -tr <value>  -mc <value>  -alpha <value>  -dodetrend  -dospike  -doL1 ] "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
window=30
TR=2.4
dospiking=false
methodCorr=correlation
mccount=1000
alpha=0.95
detrending=false

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_DynamicConnectivity.sh -i <path>  -o <path>  [-w <value>  -tr <value>  -dospike  -doL1 ] "
		echo ""
		echo "  -i                           : mat file with 'tseries' variable (nodex x times)"
		echo "  -o                           : output file (.mat) "
		echo "  -w                           : window size "
		echo "  -tr                          : TR value "
		echo "  -dospike                     : despiking step "
		echo "  -doL1                        : compute precision matrix with GLASSO instead of linear correlation "
		echo ""
		echo "Usage: FMRI_DynamicConnectivity.sh -i <path>  -o <path>  [-w <value>  -tr <value>  -dospike  -doL1 ] "
		echo ""
		exit 1
		;;
	-i)
		dataFile=`expr $index + 1`
		eval dataFile=\${$dataFile}
		echo "  |-------> mat file : $dataFile"
		index=$[$index+1]
		;;
	-o)
		output=`expr $index + 1`
		eval output=\${$output}
		echo "  |-------> Output folder : $output"
		index=$[$index+1]
		;;
	-w)
		window=`expr $index + 1`
		eval window=\${$window}
		echo "  |-------> Window size : $window"
		index=$[$index+1]
		;;
	-mc)
		mccount=`expr $index + 1`
		eval mccount=\${$mccount}
		echo "  |-------> mccount value : $mccount"
		index=$[$index+1]
		;;
	-tr)
		TR=`expr $index + 1`
		eval TR=\${$TR}
		echo "  |-------> TR value : $TR"
		index=$[$index+1]
		;;
	-alpha)
		alpha=`expr $index + 1`
		eval alpha=\${$alpha}
		echo "  |-------> alpha value : $alpha"
		index=$[$index+1]
		;;
	-dodetrend)
		detrending=true
		echo "  |-------> do detrending step : $detrending "
		;;
	-dospike)
		dospiking=true
		echo "  |-------> do despiking step : $dospiking "
		;;
	-doL1)
		methodCorr=L1
		echo "  |-------> buidling of connectivity matrix : $methodCorr "
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done

echo "method : ${methodCorr}"
echo "do despiking : ${dospiking}"
echo "do detrending : ${detrending}"
echo "alpha : ${alpha}"
echo "TR value : ${TR}"
echo "window : ${window}"
echo "mccount : ${mccount}"

## Check mandatory arguments
if [ -z ${dataFile} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi


matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	addpath('/home/renaud/NAS/renaud/scripts/wtc-r16');

	% read data
	load('${dataFile}');
	
	window     = ${window};
	methodCorr = '${methodCorr}';
	mccount    = ${mccount};
	alpha      = ${alpha};
	dodetrend  = ${detrending};
	dodespike  = ${dospiking};
	[FNCdyn,FNCsig,changeSig,numOfStates,windowTimes,FNCdynres] = DynFC_bootstrap(tseries,'TR',${TR},'detrending',dodetrend,'despiking',dodespike,'window',window,'methodCorr',methodCorr,'alpha',alpha,'mccount',mccount);

	% save data	
	save('${output}','FNCdyn','FNCsig','changeSig','numOfStates','windowTimes','FNCdynres','window','methodCorr','mccount','alpha','dodetrend','dodespike');
	
EOF
