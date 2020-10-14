#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage:  FMRI_SecondLevel_SPM12.sh -id <inputdir> -fg <groups_path> -con <contrast> -ncon <num_contrast>"
	echo ""
	echo "  -id                          : Input preprocessed subject data directory "
	echo "  -fg			      : Path to the groups file Groups.txt "
	echo "  -con                         : Contrast used "
	echo "  -ncon                        : Number of contrast used "
	echo ""
	echo "Usage:  FMRI_SecondLevel_SPM12.sh -id <inputdir> -fg <groups_path> -con <contrast> -ncon <num_contrast>"
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
		echo "Usage:  FMRI_SecondLevel_SPM12.sh -id <inputdir> -fg <groups_path> -con <contrast> -ncon <num_contrast>"
		echo ""
		echo "  -id                          : Input preprocessed subject data directory "
		echo "  -fg			      : Path to the groups file Groups.txt "
		echo "  -con                         : Contrast used "
		echo "  -ncon                        : Number of contrast used "
		echo ""
		echo "Usage:  FMRI_SecondLevel_SPM12.sh -id <inputdir> -fg <groups_path> -con <contrast> -ncon <num_contrast>"
		echo ""
		exit 1
		;;
	-fg)
		index=$[$index+1]
		eval groupspath=\${$index}
		echo "Path of the groups file Groups.txt : ${groupspath}"
		;;
	-id)
		index=$[$index+1]
		eval INDIR=\${$index}
		echo "Input preprocessed subject data directory : ${INDIR}"
		;;
	-con)
		index=$[$index+1]
		eval CONTRAST=\${$index}
		echo "Contrast used : ${CONTRAST}"
		;;
	-ncon)
		index=$[$index+1]
		eval nCONTRAST=\${$index}
		echo "Number of contrast used : ${nCONTRAST}"
		;;	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_SecondLevel_SPM12.sh -id <inputdir> -fg <groups_path> -con <contrast> -ncon <num_contrast>"
		echo ""
		echo "  -id                          : Input preprocessed subject data directory "
		echo "  -fg			      : Path to the groups file Groups.txt "
		echo "  -con                         : Contrast used "
		echo "  -ncon                        : Number of contrast used "
		echo ""
		echo "Usage:  FMRI_SecondLevel_SPM12.sh -id <inputdir> -fg <groups_path> -con <contrast> -ncon <num_contrast>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${groupspath} ]
then
	 echo "-fg argument mandatory"
	 exit 1
fi

if [ -z ${CONTRAST} ]
then
	 echo "-con argument mandatory"
	 exit 1
fi

if [ -z ${nCONTRAST} ]
then
	 echo "-ncon argument mandatory"
	 exit 1
fi

if [ -z ${INDIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF


fid = fopen(fullfile('${groupspath}','Groups.txt'));
G = textscan(fid, '%s %s %s');
fclose(fid);

for i = 1 : size(G{1},1)
    if (exist(fullfile('${INDIR}','GroupAnalysis',G{1}{i},'${CONTRAST}'))~=7)	
	mkdir(fullfile('${INDIR}','GroupAnalysis',G{1}{i},'${CONTRAST}'));
    end
    
    if isempty(G{3}{i})
	FMRI_SecondLevel_SPM12('${INDIR}',G{1}{i},G{2}{i},${nCONTRAST},'${CONTRAST}')
    else
	FMRI_SecondLevelVs_SPM12('${INDIR}',G{1}{i},G{2}{i},G{3}{i},${nCONTRAST},'${CONTRAST}');
    end
end

EOF