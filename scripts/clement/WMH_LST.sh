#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:  WMH_LST.sh -i <input-T1_dir> -thresh <initial threshold> -probaLesMap <0 or 1> -BinaLesMap <0 or 1> -NormaLesMap <0 or 1> "
	echo ""
	echo "	-i			 : directory of a repertory which each subject, within 1 FLAIR and 1 3DT1"
	echo "	-thresh	     : threshold for the segmentation of the lesions. Must be tested with incrementation"
	echo "	-probaLesMap : generate the probability map of the WMH ( 1 per default )"
	echo "	-BinaLesMap	 : generate the binary map of the WMH ( 1 per default )"
	echo "	-NormaLesMap : generate a normalized (MNI) of the lesion map ( 0 per default )"
	echo ""
	echo ""
	echo "Please make sure that your FLAIR and T1 are in .nii extension"
	echo ""
	echo ""
	echo "--------------------------------------------------------------------"
	echo ""
	echo "Clément Bournonville - CHU Lille - Mai 2015"
	echo ""
	echo ""
	exit 1
fi

#Per Default
PLM=1
BLM=1
NLM=0

#Attribution
index=1

while [ $index -le $# ]
do

	eval arg=\${$index}
	case "$arg" in 

	-h|help)
		echo ""
		echo "Usage:  WMH_LST.sh -i <input-T1_dir> -thresh <initial threshold> -probaLesMap <0 or 1> -BinaLesMap <0 or 1> -NormaLesMap <0 or 1> "
		echo ""
		echo "	-i			 : directory of a repertory which each subject, within 1 FLAIR and 1 3DT1"
		echo "	-thresh	     : threshold for the segmentation of the lesions. Must be tested with incrementation"
		echo "	-probaLesMap : generate the probability map of the WMH ( 1 per default )"
		echo "	-BinaLesMap	 : generate the binary map of the WMH ( 1 per default )"
		echo "	-NormaLesMap : generate a normalized (MNI) of the lesion map ( 0 per default )"
		echo ""
		echo ""
		echo "Please make sure that your FLAIR and T1 are in .nii extension"
		echo "Please make sure that your files contain 'FLAIR' and 'T1' in their name"
		echo ""
		echo ""
		echo "--------------------------------------------------------------------"
		echo ""
		echo "Clément Bournonville - CHU Lille - Mai 2015"
		echo ""
		echo ""
		;;
	-i)
		index=$[$index+1]
		eval sub_dir=\${$index}
		echo "Input directory = $sub_dir"
		;;
	-thresh)
		index=$[$index+1]
		eval thresh=\${$index}
		echo "Initial Threshold = $thresh"
		;;
	-probaLesMap)
		index=$[$index+1]
		eval PLM=\${$index}
		echo " Probabilistic Lesion Map = $PLM"
		;;
	-BinaLesMap)
		index=$[$index+1]
		eval BLM=\${$index}
		echo "Binaly Lesion map = $BLM"
		;;
	-NormaLesMap)
		index=$[$index+1]
		eval NLM=\${$index}
		echo "Normalized Lesion map = $NLM"
		;;
	-*) 
		eval infile=\${$index}
		echo "Usage:  WMH_LST.sh -i <input-T1_dir> -thresh <initial threshold> -probaLesMap <0 or 1> -BinaLesMap <0 or 1> -NormaLesMap <0 or 1> "
		echo ""
		echo "	-i			 : directory of a repertory which each subject, within 1 FLAIR and 1 3DT1"
		echo "	-thresh	     : threshold for the segmentation of the lesions. Must be tested with incrementation"
		echo "	-probaLesMap : generate the probability map of the WMH ( 1 per default )"
		echo "	-BinaLesMap	 : generate the binary map of the WMH ( 1 per default )"
		echo "	-NormaLesMap : generate a normalized (MNI) of the lesion map ( 0 per default )"
		;;
	esac
	index=$[$index+1]
done

#Check of files

for f in $sub_dir/*
do


	f2=`basename $f`

	nii_test=$(ls -a $f/* | grep gz | wc -l)
	em_test=$(ls -a $f/* | sed -e "/\.$/d" | wc -l)
	t1_test=$(ls -a $f/* | grep T1 | wc -l)
	flair_test=$(ls -a $f/* | grep FLAIR | wc -l)
	test_done=$(ls -a $f/* | grep atlas | wc -l)


	if [ $nii_test -ne 0 ]; then
		echo "Files for $f2 are compressed nifti, please uncompress" >> $sub_dir/WMH_error.txt
	elif [ $em_test -eq 0 ]; then
		echo "Empty subject's repertory : $f" >> $sub_dir/WMH_error.txt
	elif [ $t1_test -eq 0 ] || [ $t1_test -gt 1 ]; then
		echo "No of more than 1 3DT1 for $f2" >> $sub_dir/WMH_error.txt
	elif [ $flair_test -eq 0 ] || [ $flair_test -gt 1 ]; then
		echo "No or more than 1 FLAIR for $f2" >> $sub_dir/WMH_error.txt
	fi

	echo "--------------------------------------------------------------------"
	echo "------------------------------RUN $f2-----------------------"
	echo "--------------------------------------------------------------------"

if [ $nii_test -eq 0 ] && [ $em_test -ne 0 ] && [ $t1_test -eq 1 ] && [ $flair_test -eq 1 ] && [ $test_done -eq 0 ]; then

		T1=$(ls -a $f/*T1*)
		FLAIR=$(ls -a $f/*FLAIR*)

		/usr/local/matlab11/bin/matlab -nodisplay <<EOF
		% Load Matlab Path

		t1image='${T1},1';
		flairimage='${FLAIR},1';
		threshold=${thresh};
		prob=${PLM};
		bin=${BLM};
		norm=${NLM};


		spm_get_defaults;
		spm_jobman('initcfg');
		matlabbatch = {};

	

		matlabbatch{1}.spm.tools.LST.lesiongrow.data_T1 = {t1image};
		matlabbatch{1}.spm.tools.LST.lesiongrow.data_FLAIR = {flairimage};
		matlabbatch{1}.spm.tools.LST.lesiongrow.segopts.initial = [threshold,(zeros(1,19))];
		matlabbatch{1}.spm.tools.LST.lesiongrow.segopts.belief = 0;
		matlabbatch{1}.spm.tools.LST.lesiongrow.segopts.mrf = 1;
		matlabbatch{1}.spm.tools.LST.lesiongrow.segopts.maxiter = 50;
		matlabbatch{1}.spm.tools.LST.lesiongrow.segopts.threshold = 0;
		matlabbatch{1}.spm.tools.LST.lesiongrow.output.lesions.prob = prob;
		matlabbatch{1}.spm.tools.LST.lesiongrow.output.lesions.binary = bin;
		matlabbatch{1}.spm.tools.LST.lesiongrow.output.lesions.normalized = norm;
		matlabbatch{1}.spm.tools.LST.lesiongrow.output.other = 1;

	

		spm_jobman('run',matlabbatch);

EOF
fi

done