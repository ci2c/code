#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  Ashs.sh -T1 <input-T1_dir> -T2 <input-T2_dir> -o <output_dir>"
	echo ""
	echo "	-T1			: directory of T1 files"
	echo "	-T2			: directory of T2 files"
	echo "	-o			: where directory for each subject will be create"
	echo ""
	echo ""
	echo "Please name your files as : Subject_T1.nii and Subject_T2.nii"
	echo ""
	echo ""
	echo "--------------------------------------------------------------------"
	echo ""
	echo "Clément Bournonville - CHU Lille - Mars 2015"
	echo ""
	echo ""
	exit 1
fi


index=1

while [ $index -le $# ]
do

	eval arg=\${$index}
	case "$arg" in 

	-h|help)
		echo ""
		echo "Usage:  Ashs.sh -T1 <input-T1_dir> -T2 <input-T2_dir> -o <output_dir>"
		echo ""
		echo "	-T1			: directory of T1 files"
		echo "	-T2			: directory of T2 files"
		echo "	-o			: where directory for each subject will be create"
		echo ""
		echo ""
		echo " Please name your files as : Subject_T1.nii and Subject_T2.nii "
		echo ""
		echo ""
		echo ""
		echo "--------------------------------------------------------------------"
		echo ""
		echo "Clément Bournonville - CHU Lille - Mars 2015"
		echo ""
		echo ""
		;;
	-T1)
		index=$[$index+1]
		eval T1_dir=\${$index}
		echo "Input T1 directory = $T1_dir"
		;;
	-T2)
		index=$[$index+1]
		eval T2_dir=\${$index}
		echo "Input T2 directory = $T2_dir"
		;;
	-o)
		index=$[$index+1]
		eval output_dir=\${$index}
		echo "Output work directory = $output_dir"
		;;
	-*) 
		eval infile=\${$index}
		echo "$infile : unknown option"		
		echo "Usage:  Ashs.sh -T1 <input-T1_dir> -T2 <input-T2_dir> -o <output_dir>"
		echo ""
		echo "	-T1			: directory of T1 files"
		echo "	-T2			: directory of T2 files"
		echo "	-o			: where directory for each subject will be create"
		echo ""
		echo ""
		echo "Please name your files as : Subject_T1.nii and Subject_T2.nii"
		;;
	esac
	index=$[$index+1]
done


user=whoami

#####################
##Test des entrées
#####################

if [ ! -de $T1_dir ] || [ ! -de $T2_dir ]
then
	echo " Unknow T1 or T2 directory, please verify "
	exit 1
fi

if [ ! -de output_dir ]
then
	echo " Unknow output directory, please verify "
	exit 1
fi

###################
##Récupération des sujets
###################

#Creation repertoire log
mkdir ${output_dir}/Log


for f in $T2_dir/*
do
	subj=`basename $f`
	subjid=${subj:0: (${#subj}-7)}

	if [ -e ${T2_dir}/${subjid}_T2.nii ]  && [ -e ${T1_dir}/${subjid}_T1.nii ] && [ ! -e ${output_dir}/${subjid} ]
	then
	
## Création du répertoire sujet 
		echo "mkdir $output_dir/${subjid}"
		mkdir $output_dir/${subjid}


## Test si les images sont dans le bon ref

	ori=$(/home/clement/ashs/ashs_Linux64_rev103_20140612/ext/Linux/bin/c3d ${T2_dir}/${subjid}_T2.nii -info)
	ori2=`echo $ori | cut -f 6 -d=`

	Obl=" Oblique"

		if [ "${ori2:0:8}" = "$Obl" ]
		then

## Lancement dans la q du script
		
		
		echo "qbatch -N ASHS_${subjid} -q three_job_q -oe ${output_dir}/Log /home/clement/ashs/ashs_Linux64_rev103_20140612/bin/ashs_main.sh -I ${subjid} -a /home/clement/ashs/atlases/final -g ${T1_dir}/${subjid}_T1.nii -f ${T2_dir}/${subjid}_T2.nii -w ${output_dir}/${subjid}"
		qbatch -N ASHS_${subjid} -oe ${output_dir}/Log/ -q U1404 /home/clement/ashs/ashs_Linux64_rev103_20140612/bin/ashs_main.sh -I ${subjid} -a /home/clement/ashs/atlases/final -g ${T1_dir}/${subjid}_T1.nii -f ${T2_dir}/${subjid}_T2.nii -w ${output_dir}/${subjid}
		sleep 1

		else

		echo "Orientation T2 mauvaise ${subjid}" >> Logerror

		fi 


	fi
done



