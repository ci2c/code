#! /bin/bash

if [ $# -lt 16 ]
then
	echo ""
	echo "Usage: FMRI_PatientAlexisFmristat.sh -d <datapath> -mat <matfile> -xls <xlsfile> -o <outname> -pref <prefix_prepo> -tr <tr> -ndyn <nf> -Ns <value>"
	echo ""
	echo "  -d                           : Path to data"
	echo "  -mat                         : matlab file"
	echo "  -xls                         : excel file"
	echo "  -o                           : Output name"
	echo "  -pref                        : Preprocessing folder prefix" 
	echo "  -tr                          : TR value" 
	echo "  -ndyn                        : number of frames" 
	echo "  -Ns                          : number of slices" 
	echo ""
	echo "Usage: FMRI_PatientAlexisFmristat.sh -d <datapath> -mat <matfile> -xls <xlsfile> -o <outname> -pref <prefix_prepo> -tr <tr> -ndyn <nf> -Ns <value>"
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
		echo "Usage: FMRI_PatientAlexisFmristat.sh -d <datapath> -mat <matfile> -xls <xlsfile> -o <outname> -pref <prefix_prepo> -tr <tr> -ndyn <nf> -Ns <value>"
		echo ""
		echo "  -d                           : Path to data"
		echo "  -mat                         : matlab file"
		echo "  -xls                         : excel file"
		echo "  -o                           : Output name"
		echo "  -pref                        : Preprocessing folder prefix" 
		echo "  -tr                          : TR value" 
		echo "  -ndyn                        : number of frames" 
		echo "  -Ns                          : number of slices" 
		echo ""
		echo "Usage: FMRI_PatientAlexisFmristat.sh -d <datapath> -mat <matfile> -xls <xlsfile> -o <outname> -pref <prefix_prepo> -tr <tr> -ndyn <nf> -Ns <value>"
		echo ""
		exit 1
		;;
	-d)
		index=$[$index+1]
		eval datapath=\${$index}
		echo "Path to data : ${datapath}"
		;;
	-mat)
		index=$[$index+1]
		eval matfile=\${$index}
		echo "matlab file : ${matfile}"
		;;
	-xls)
		index=$[$index+1]
		eval xlsfile=\${$index}
		echo "excel file : ${xlsfile}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "Output name : ${output}"
		;;
	-pref)
		index=$[$index+1]
		eval pref=\${$index}
		echo "Preprocessing folder prefix : ${pref}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-ndyn)
		index=$[$index+1]
		eval ndyn=\${$index}
		echo "number of frames : ${ndyn}"
		;;
	-Ns)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of slices : ${N}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_PatientAlexisFmristat.sh -d <datapath> -mat <matfile> -xls <xlsfile> -o <outname> -pref <prefix_prepo> -tr <tr> -ndyn <nf> -Ns <value>"
		echo ""
		echo "  -d                           : Path to data"
		echo "  -mat                         : matlab file"
		echo "  -xls                         : excel file"
		echo "  -o                           : Output name"
		echo "  -pref                        : Preprocessing folder prefix" 
		echo "  -tr                          : TR value" 
		echo "  -ndyn                        : number of frames" 
		echo "  -Ns                          : number of slices" 
		echo ""
		echo "Usage: FMRI_PatientAlexisFmristat.sh -d <datapath> -mat <matfile> -xls <xlsfile> -o <outname> -pref <prefix_prepo> -tr <tr> -ndyn <nf> -Ns <value>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${datapath} ]
then
	 echo "-d argument mandatory"
	 exit 1
fi

if [ -z ${matfile} ]
then
	 echo "-mat argument mandatory"
	 exit 1
fi

if [ -z ${xlsfile} ]
then
	 echo "-xls argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${pref} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-tr argument mandatory"
	 exit 1
fi

if [ -z ${ndyn} ]
then
	 echo "-ndyn argument mandatory"
	 exit 1
fi

if [ -z ${N} ]
then
	 echo "-Ns argument mandatory"
	 exit 1
fi

matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd /home/renaud/scripts

outfile = fullfile('${datapath}','design_matrix.mat');
[sot,rem_beg,last_dyn] = FMRI_DesignMatrixAlexis('${matfile}','${xlsfile}',${TR},${ndyn});
save(outfile,'sot','rem_beg','last_dyn');

FMRI_RunLevelAlexisFmriStat_2('${datapath}','${output}','${pref}',sot,${TR},${N},${ndyn});

EOF

