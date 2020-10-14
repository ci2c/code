#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage:  Main2_FMRI_SPM12.sh  -id <inputdir>  -rmframe <value> -TR <value> -f <selectedsubj> -fc <contrastpath> -fg <groupspath>"
	echo ""
	echo "  -id                          : Input preprocessed data directory "
	echo "  -TR                          : Time per frame "
	echo " 	-rmframe                     : frame for removal "
	echo "	-f  			      : path of the file SelectedSubj.txt"
	echo "  -fg			      : Path to the groups file Groups.txt "
	echo "  -fc			      : Path to the contrasts file ContrastName.txt "
	echo ""
	echo "Usage:  Main2_FMRI_SPM12.sh  -id <inputdir>  -rmframe <value> -TR <value> -f <selectedsubj> -fc <contrastpath> -fg <groupspath>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 28, 2013"
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
		echo "Usage:  Main2_FMRI_SPM12.sh  -id <inputdir>  -rmframe <value> -TR <value> -f <selectedsubj> -fc <contrastpath> -fg <groupspath>"
		echo ""
		echo "  -id                          : Input preprocessed data directory "
		echo "  -TR                          : Time per frame "
		echo " 	-rmframe                     : frame for removal "
		echo "	-f  			      : path of the file SelectedSubj.txt"
		echo "  -fg			      : Path to the groups file Groups.txt "
		echo "  -fc			      : Path to the contrasts file ContrastName.txt "
		echo ""
		echo "Usage:  Main2_FMRI_SPM12.sh  -id <inputdir>  -rmframe <value> -TR <value> -f <selectedsubj> -fc <contrastpath> -fg <groupspath>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 28, 2013"
		echo ""
		exit 1
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-id)
		index=$[$index+1]
		eval INDIR=\${$index}
		echo "Input directory : ${INDIR}"
		;;
	-f) 
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path of the file SelectedSubj.txt : ${FILE_PATH}"
		;;
	-TR) 
		index=$[$index+1]
		eval TR=\${$index}
		echo "Time per frame : ${TR}"
		;;
	-fg)
		index=$[$index+1]
		eval groupspath=\${$index}
		echo "Path of the groups file Groups.txt : ${groupspath}"
		;;
	-fc)
		index=$[$index+1]
		eval CON_PATH=\${$index}
		echo "Path to the contrasts file ContrastName.txt : ${CON_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  Main2_FMRI_SPM12.sh  -id <inputdir>  -rmframe <value> -TR <value> -f <selectedsubj> -fc <contrastpath> -fg <groupspath>"
		echo ""
		echo "  -id                          : Input preprocessed data directory "
		echo "  -TR                          : Time per frame "
		echo " 	-rmframe                     : frame for removal "
		echo "	-f  			      : path of the file SelectedSubj.txt"
		echo "  -fg			      : Path to the groups file Groups.txt "
		echo "  -fc			      : Path to the contrasts file ContrastName.txt "
		echo ""
		echo "Usage:  Main2_FMRI_SPM12.sh  -id <inputdir>  -rmframe <value> -TR <value> -f <selectedsubj> -fc <contrastpath> -fg <groupspath>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 28, 2013"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${remframe} ]
then
	 echo "-rmframe argument mandatory"
	 exit 1
fi

if [ -z ${INDIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
fi

if [ -z ${FILE_PATH} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi

if [ -z ${groupspath} ]
then
	 echo "-fg argument mandatory"
	 exit 1
fi

if [ -z ${CON_PATH} ]
then
	 echo "-fc argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-TR argument mandatory"
	 exit 1
fi

# if [ -e ${FILE_PATH}/SelectedSubj.txt ]
# then
# 	if [ -s ${FILE_PATH}/SelectedSubj.txt ]
# 	then	
# 		while read subject  
# 		do 
# 			if [ -f ${INDIR}/${subject}/sots_${subject}.mat ]
# 			then
# # 				TR=$(mri_info ${epi}/${subject}/run1.nii | grep TR | awk '{print $2}')
# # 				TR=$(echo "$TR/1000" | bc -l)
# 				qbatch -N ${subject}_FMRI_FL -q fs_q -oe ~/Logdir  FMRI_FirstLevel_SPM12.sh -sp ${INDIR}/${subject} -sub ${subject} -id ${INDIR}/${subject} -TR ${TR} -rmframe ${remframe}
# 				sleep 2
# 			else
# 			      echo "Le fichier sots_${subject}.mat n'existe pas" >> ${INDIR}/LogAlexis
# 			fi
# 		done < ${FILE_PATH}/SelectedSubj.txt
# 	else
# 		echo "Le fichier SelectedSubj.txt est vide" >> ${INDIR}/LogAlexis
# 		exit 1	
# 	fi	
# fi

if [ -e ${CON_PATH}/ContrastName.txt ]
then
	if [ -s ${CON_PATH}/ContrastName.txt ]
	then	
		if [ ! -d ${INDIR}/GroupAnalysis ]
		then
			mkdir ${INDIR}/GroupAnalysis
		else
			rm -rf ${INDIR}/GroupAnalysis/*
			mkdir ${INDIR}/GroupAnalysis
		fi

		num_contrast=1
		while read contrast  
		do 
#			WaitForJobs.sh *_FMRI_Pre
#			qbatch -N ${contrast}_FMRI_SL -q fs_q -oe ~/Logdir 
			FMRI_SecondLevel_SPM12.sh -id ${INDIR} -fg ${groupspath} -con ${contrast} -ncon ${num_contrast}
#			sleep 2
			num_contrast=$[$num_contrast+1]	
		done < ${CON_PATH}/ContrastName.txt
	else
		echo "Le fichier ContrastName.txt est vide" >> ${INDIR}/LogAlexis
		exit 1	
	fi	
else
	echo "Le fichier ContrastName.txt n'existe pas" >> ${INDIR}/LogAlexis
	exit 1	
fi
