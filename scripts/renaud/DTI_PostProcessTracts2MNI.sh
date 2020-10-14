#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_PostProcessTracts2MNI.sh  -i <input_dir>  -mat_name <mat_name_pattern>"
	echo ""
	echo "  -i <input_dir>                     : Path to fiber output directory (ex: FS/SUBJ/dti/MNIspace)"
	echo "  -mat_name <mat_name_pattern>       : Prefix of the .mat files"
	echo "                                      For example set whole_brain_6_1500000 if files"
	echo "                                      whole_brain_6_1500000_part000001.mat whole_brain_6_1500000_part000002.mat ..."
	echo "                                      were generated using the script DTI_NonLinearTransTracts2MNI.sh"
	echo "                                      The final output will be stored as MAT_NAME_PATTERN.mat in FS/SUBJ/dti/MNIspace"
	echo " "
	echo "Usage: DTI_PostProcessTracts2MNI.sh  -i <input_dir>  -mat_name <mat_name_pattern>"
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
		echo "Usage: DTI_PostProcessTracts2MNI.sh  -i <input_dir>  -mat_name <mat_name_pattern>"
		echo ""
		echo "  -i <input_dir>                     : Path to fiber output directory (ex: FS/SUBJ/dti/MNIspace)"
		echo "  -mat_name <mat_name_pattern>       : Prefix of the .mat files"
		echo "                                      For example set whole_brain_6_1500000 if files"
		echo "                                      whole_brain_6_1500000_part000001.mat whole_brain_6_1500000_part000002.mat ..."
		echo "                                      were generated using the script DTI_NonLinearTransTracts2MNI.sh"
		echo "                                      The final output will be stored as MAT_NAME_PATTERN.mat in FS/SUBJ/dti/MNIspace"
		echo " "
		echo "Usage: DTI_PostProcessTracts2MNI.sh  -i <input_dir>  -mat_name <mat_name_pattern>"
		echo ""
		exit 1
		;;
	-i)
		INDIR=`expr $index + 1`
		eval INDIR=\${$INDIR}
		echo "fiber dir : $INDIR"
		;;
	-mat_name)
		mat_name=`expr $index + 1`
		eval mat_name=\${$mat_name}
		echo "Mat prefix : $mat_name"
		;;
	esac
	index=$[$index+1]
done

matlab -nodisplay <<EOF

cur_path=pwd;
cd ${INDIR}
List = rdir('${mat_name}_part*mat');

ii=1;
load(char(List(ii).name));
fibmni_final = fibmni;
mbeg_final = mbeg;
mend_final = mend;

for ii = 2 : length(List)
	disp(ii)
	load(char(List(ii).name));
	fibmni_final.nFiberNr = fibmni_final.nFiberNr+fibmni.nFiberNr;
	fibmni_final.fiber = cat(2, fibmni_final.fiber, fibmni.fiber);
	mbeg_final = mbeg_final + mbeg;
	mend_final = mend_final + mend;
	clear fibmni;
end

fibmni = fibmni_final;

clear fibmni_final;
save('${INDIR}/${mat_name}.mat', 'fibmni','mbeg','mend','-v7.3');

cd(cur_path)

EOF

