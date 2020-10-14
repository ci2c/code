#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: FMRI_AlexisFmristat.sh -o <outname> -pref <prefprepro>"
	echo ""
	echo "  -o                           : Output name"
	echo "  -pref                        : Preprocessing folder prefix"  
	echo ""
	echo "Usage: FMRI_AlexisFmristat.sh -o <outname> -pref <prefprepro>"
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
		echo "Usage: FMRI_AlexisFmristat.sh -o <outname> -pref <prefprepro>"
		echo ""
		echo "  -o                           : Output name"
		echo "  -pref                        : Preprocessing folder prefix"  
		echo ""
		echo "Usage: FMRI_AlexisFmristat.sh -o <outname> -pref <prefprepro>"
		echo ""
		exit 1
		;;
	-o)
		index=$[$index+1]
		eval outname=\${$index}
		echo "Output name : ${outname}"
		;;
	-pref)
		index=$[$index+1]
		eval prefprepro=\${$index}
		echo "Preprocessing folder prefix : ${prefprepro}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_AlexisFmristat.sh -o <outname> -pref <prefprepro>"
		echo ""
		echo "  -o                           : Output name"
		echo "  -pref                        : Preprocessing folder prefix"  
		echo ""
		echo "Usage: FMRI_AlexisFmristat.sh -o <outname> -pref <prefprepro>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${outname} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${prefprepro} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

TR=2.4
Nf=190
i=0
prefix=pat

# Patient 1
Nslices=45
matname=alexcis_suj1_patient_06-Feb-2012.mat
xlsname=patient_06-Feb-2012.xls
datapath=/home/fatmike/renaud/alexis/patient01

matfile=${datapath}/${matname}
xlsfile=${datapath}/${xlsname}

A=$(printf "%.4d" ${i})
qbatch -N ${prefix}${A} -q fs_q -oe /home/renaud/log FMRI_PatientAlexisFmristat.sh -d ${datapath} -mat ${matfile} -xls ${xlsfile} -o ${outname} -pref ${prefprepro} -tr ${TR} -ndyn ${Nf} -Ns ${Nslices}
sleep 5
i=$[$i+1]

# Patient 2
Nslices=40
matname=alexcis_suj690119_morel_19-Mar-2012.mat
xlsname=morel_19-Mar-2012.xls
datapath=/home/fatmike/renaud/alexis/patient02

matfile=${datapath}/${matname}
xlsfile=${datapath}/${xlsname}

A=$(printf "%.4d" ${i})
qbatch -N ${prefix}${A} -q fs_q -oe /home/renaud/log FMRI_PatientAlexisFmristat.sh -d ${datapath} -mat ${matfile} -xls ${xlsfile} -o ${outname} -pref ${prefprepro} -tr ${TR} -ndyn ${Nf} -Ns ${Nslices}
sleep 5
i=$[$i+1]

# Patient 3
Nslices=40
matname=alexcis_suj1_colin_02-Apr-2012.mat
xlsname=colin_02-Apr-2012.xls
datapath=/home/fatmike/renaud/alexis/patient03

matfile=${datapath}/${matname}
xlsfile=${datapath}/${xlsname}

A=$(printf "%.4d" ${i})
qbatch -N ${prefix}${A} -q fs_q -oe /home/renaud/log FMRI_PatientAlexisFmristat.sh -d ${datapath} -mat ${matfile} -xls ${xlsfile} -o ${outname} -pref ${prefprepro} -tr ${TR} -ndyn ${Nf} -Ns ${Nslices}
sleep 5
i=$[$i+1]

# Patient 4
Nslices=40
matname=alexcis_suj4_pat_04-Apr-2012.mat
xlsname=vermeulen_04-Apr-2012.xls
datapath=/home/fatmike/renaud/alexis/patient04

matfile=${datapath}/${matname}
xlsfile=${datapath}/${xlsname}

A=$(printf "%.4d" ${i})
qbatch -N ${prefix}${A} -q fs_q -oe /home/renaud/log FMRI_PatientAlexisFmristat.sh -d ${datapath} -mat ${matfile} -xls ${xlsfile} -o ${outname} -pref ${prefprepro} -tr ${TR} -ndyn ${Nf} -Ns ${Nslices}
sleep 5
i=$[$i+1]

# Patient 5
Nslices=40
matname=alexcis_suj5_pat_04-Apr-2012.mat
xlsname=monchy_04-Apr-2012.xls
datapath=/home/fatmike/renaud/alexis/patient05

matfile=${datapath}/${matname}
xlsfile=${datapath}/${xlsname}

A=$(printf "%.4d" ${i})
qbatch -N ${prefix}${A} -q fs_q -oe /home/renaud/log FMRI_PatientAlexisFmristat.sh -d ${datapath} -mat ${matfile} -xls ${xlsfile} -o ${outname} -pref ${prefprepro} -tr ${TR} -ndyn ${Nf} -Ns ${Nslices}
sleep 5
i=$[$i+1]

WaitForJobs.sh ${prefix}

