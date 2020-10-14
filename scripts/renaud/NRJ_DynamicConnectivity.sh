#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: NRJ_DynamicConnectivity.sh -i <path>  -o <path>  -pref <name>  -m <path>  -t <value>  [-w <value>  -tr <value>  -dospike  -doL1 ]"
	echo ""
	echo "  -i                           : mat file"
	echo "  -o                           : output folder "
	echo "  -pref                        : epi prefix "
	echo "  -m                           : marker file "
	echo "  -t                           : type of events "
	echo "  -w                           : window size "
	echo "  -tr                          : TR value "
	echo "  -dospike                     : despiking step "
	echo "  -doL1                        : compute precision matrix with GLASSO instead of linear correlation "
	echo ""
	echo "Usage: NRJ_DynamicConnectivity.sh -i <path>  -o <path>  -pref <name>  -m <path>  -t <value>  [-w <value>  -tr <value>  -dospike  -doL1 ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
window=8
TR=2
dospiking=no
methodCorr=correlation

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: NRJ_DynamicConnectivity.sh -i <path>  -o <path>  -pref <name>  -m <path>  -t <value>  [-w <value>  -tr <value>  -dospike  -doL1 ]"
		echo ""
		echo "  -i                           : mat file"
		echo "  -o                           : output folder "
		echo "  -pref                        : epi prefix "
		echo "  -m                           : marker file "
		echo "  -t                           : type of events "
		echo "  -w                           : window size "
		echo "  -tr                          : TR value "
		echo "  -dospike                     : despiking step "
		echo "  -doL1                        : compute precision matrix with GLASSO instead of linear correlation "
		echo ""
		echo "Usage: NRJ_DynamicConnectivity.sh -i <path>  -o <path>  -pref <name>  -m <path>  -t <value>  [-w <value>  -tr <value>  -dospike  -doL1 ]"
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
	-pref)
		prefepi=`expr $index + 1`
		eval prefepi=\${$prefepi}
		echo "  |-------> EPI prefix : $prefepi"
		index=$[$index+1]
		;;
	-m)
		markerFile=`expr $index + 1`
		eval markerFile=\${$markerFile}
		echo "  |-------> Marker file : $markerFile"
		index=$[$index+1]
		;;
	-t)
		type=`expr $index + 1`
		eval type=\${$type}
		echo "  |-------> Type of events : $type"
		index=$[$index+1]
		;;
	-w)
		window=`expr $index + 1`
		eval window=\${$window}
		echo "  |-------> Window size : $window"
		index=$[$index+1]
		;;
	-tr)
		TR=`expr $index + 1`
		eval TR=\${$TR}
		echo "  |-------> TR value : $TR"
		index=$[$index+1]
		;;
	-dospike)
		dospiking=yes
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
echo "TR value : ${TR}"
echo "window : ${window}"
echo "type : ${type}"

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

if [ -z ${prefepi} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

if [ -z ${markerFile} ]
then
	 echo "-m argument mandatory"
	 exit 1
fi

if [ -z ${type} ]
then
	 echo "-t argument mandatory"
	 exit 1
fi

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	% read data
	load('${dataFile}');

	tseries = [];
	for k = 1:length(tseries_all)
	    tseries = [tseries tseries_all{k}];
	end
	tseries = tseries';
	
	% calculation of dynamical connectivity    
	[FNCdyn,windowTimes,blambda,tcwin,A,Pdyn] = DynamicFunctionalConnectivityAnalysis(tseries,'TR',${TR},'wsize',${window},'method','${methodCorr}','allVoxels','no','detrending',true,'window_alpha',1,'Despiking','${dospiking}');
	wind=${window};
	save(fullfile('${output}',['DynConn_' num2str(${window}) '_dospiking' '${dospiking}' '_' '${methodCorr}' '.mat']),'FNCdyn','windowTimes','blambda','tcwin','A','wind','Pdyn'); 

	% windows of interest
	epiFiles = conn_dir(fullfile('${output}',['${prefepi}' '*.nii']));
	%WOI = NRJ_WindowsOfInterest(epiFiles,'${markerFile}',${TR},${window},${type});
	WOI = NRJ_WindowsOfInterest(epiFiles,'${markerFile}',${TR},${window},[]);
	save(fullfile('${output}',['WOI_window' num2str(${window}) '.mat']),'WOI');

	FNCdynres = zeros(length(windowTimes),size(FNCdyn,2));
	deb = min(find(windowTimes==1));
	fin = max(find(windowTimes==1));
	FNCdynres(deb:fin,:) = FNCdyn;
	
	% STUDY AROUND SPIKES
	before_spike_fnc   = FNCdynres(WOI.befIdur_timing(find(WOI.befIdur_type==${type})),:)';
	during_spike_fnc   = FNCdynres(WOI.durIbefUaft_timing(find(WOI.durIbefUaft_type==${type})),:)';
	after_spike_fnc    = FNCdynres(WOI.aftIdur_timing(find(WOI.aftIdur_type==${type})),:)';
	during_nospike_fnc = FNCdynres(WOI.noEventsW_timing,:)';
	moyenne_fnc        = [mean(during_nospike_fnc,2) mean(before_spike_fnc,2) mean(during_spike_fnc,2) mean(after_spike_fnc,2)];

	if strcmp('${methodCorr}','L1')

		Pdynres = zeros(length(windowTimes),size(Pdyn,2));
		Pdynres(deb:fin,:) = Pdyn;

		before_spike_P   = Pdynres(WOI.befIdur_timing(find(WOI.befIdur_type==${type})),:)';
		during_spike_P   = Pdynres(WOI.durIbefUaft_timing(find(WOI.durIbefUaft_type==${type})),:)';
		after_spike_P    = Pdynres(WOI.aftIdur_timing(find(WOI.aftIdur_type==${type})),:)';
		during_nospike_P = Pdynres(WOI.noEventsW_timing,:)';
		moyenne_P        = [mean(during_nospike_P,2) mean(before_spike_P,2) mean(during_spike_P,2) mean(after_spike_P,2)];

		typ=${type};
		save(fullfile('${output}',['WOIConn_window' num2str(${window}) '_dospiking' '${dospiking}' '_' '${methodCorr}' '_type' num2str(${type}) '.mat']),'WOI','FNCdynres','Pdynres','before_spike_fnc','during_spike_fnc','after_spike_fnc','during_nospike_fnc','moyenne_fnc','before_spike_P','during_spike_P','after_spike_P','during_nospike_P','moyenne_P','typ');
	
	else

		typ=${type};
		save(fullfile('${output}',['WOIConn_window' num2str(${window}) '_dospiking' '${dospiking}' '_' '${methodCorr}' '_type' num2str(${type}) '.mat']),'WOI','FNCdynres','before_spike_fnc','during_spike_fnc','after_spike_fnc','during_nospike_fnc','moyenne_fnc','typ');

	end

EOF

