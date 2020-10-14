#!/bin/bash

if [ $# -ne 6 ]
then
	echo ""
	echo "Usage: FMRI_PostProcessTA.sh  -i  <folder>  -pref <prefix>  -N <number> "
	echo ""
	echo "  -i folder                  : input folder "
	echo "  -pref prefix               : prefix name "
	echo "  -N                         : number of split "
	echo ""
	echo "Usage: FMRI_PostProcessTA.sh  -i  <folder>  -pref <prefix>  -N <number> "
	exit 1
fi

#### Inputs ####
index=1
echo "------------------------"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_PostProcessTA.sh  -i  <folder>  -pref <prefix>  -N <number> "
		echo ""
		echo "  -i folder                  : input folder "
		echo "  -pref prefix               : prefix name "
		echo "  -N                         : number of split "
		echo ""
		echo "Usage: FMRI_PostProcessTA.sh  -i  <folder>  -pref <prefix>  -N <number> "
		exit 1
		;;
	-i)
		indir=`expr $index + 1`
		eval indir=\${$indir}
		echo "  |-------> input folder : $indir"
		index=$[$index+1]
		;;
	-pref)
		pref=`expr $index + 1`
		eval pref=\${$pref}
		echo "  |-------> output prefix : ${pref}"
		index=$[$index+1]
		;;
	-N)
		Nsplit=`expr $index + 1`
		eval Nsplit=\${$Nsplit}
		echo "  |-------> Optional Number of splitting data : ${Nsplit}"
		index=$[$index+1]
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
#################

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	data=[]; tc=[]; tc_d=[]; tc_d2=[];
	for k = 1:${Nsplit}
	    
	    load(fullfile('${indir}',['${pref}' '_' num2str(k) '.mat']),'dtmp','TC_OUT','TC_D_OUT','TC_D2_OUT','ptmp');
	    if k==1
		param = ptmp;
	    else
		param.NbrVoxels = param.NbrVoxels + ptmp.NbrVoxels;
		param.IND       = [param.IND; ptmp.IND];
		param.VoxelIdx  = [param.VoxelIdx; ptmp.VoxelIdx];
	    end
	    
	    data  = [data dtmp];
	    tc    = [tc TC_OUT];
	    tc_d  = [tc_d TC_D_OUT];
	    tc_d2 = [tc_d2 TC_D2_OUT];
	    
	end

	TC_OUT    = tc;
	TC_D_OUT  = tc_d;
	TC_D2_OUT = tc_d2;
	clear tc tc_d tc_d2;
	
	save(fullfile('${indir}',['${pref}' '.mat']),'TC_OUT','TC_D_OUT','TC_D2_OUT','data','param');
	
EOF

