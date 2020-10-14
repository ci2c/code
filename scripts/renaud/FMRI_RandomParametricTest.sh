#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage:  FMRI_RandomParametricTest.sh  -map <map_mat>  -o <output_path>  -iter <number>  -mask <maskfile> "
	echo ""
	echo "  -map                         : File list (.mat) "
	echo "  -o                           : output folder "
	echo "  -iter                        : iteration number "
	echo "  -mask                        : mask file "
	echo ""
	echo "Usage:  FMRI_RandomParametricTest.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Dec 10, 2012"
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
		echo "Usage:  FMRI_RandomParametricTest.sh  -map <map_mat>  -o <output_path>  -iter <number>  -mask <maskfile> "
		echo ""
		echo "  -map                         : File list (.mat) "
		echo "  -o                           : output folder "
		echo "  -iter                        : iteration number "
		echo "  -mask                        : mask file "
		echo ""
		echo "Usage:  FMRI_RandomParametricTest.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Dec 10, 2012"
		echo ""
		exit 1
		;;
	-map)
		index=$[$index+1]
		eval mapmat=\${$index}
		echo "Filelist : ${mapmat}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : ${output}"
		;;
	-iter)
		index=$[$index+1]
		eval iter=\${$index}
		echo "iteration number : ${iter}"
		;;
	-mask)
		index=$[$index+1]
		eval maskfile=\${$index}
		echo "mask file : ${maskfile}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_RandomParametricTest.sh  -map <map_mat>  -o <output_path>  -iter <number>  -mask <maskfile> "
		echo ""
		echo "  -map                         : File list (.mat) "
		echo "  -o                           : output folder "
		echo "  -iter                        : iteration number "
		echo "  -mask                        : mask file "
		echo ""
		echo "Usage:  FMRI_RandomParametricTest.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -N <value>  -fwhm <value>  -refslice <value>  -acquis <name>  -coreg <name>  -resampling <value>  -o <output_directory>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Dec 10, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${mapmat} ]
then
	 echo "-map argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${iter} ]
then
	 echo "-iter argument mandatory"
	 exit 1
fi

if [ -z ${maskfile} ]
then
	 echo "-mask argument mandatory"
	 exit 1
fi

matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

load('${mapmat}');
T = randi(length(mapfiles),length(mapfiles),1);
tmpfiles = {};
for j = 1:length(T)
tmpfiles{j} = mapfiles{T(j)};
end
tmap = RandomParametricTest(tmpfiles,'${output}',${iter},'${maskfile}');
save(fullfile('${output}',['tmap_' num2str(${iter}) '.mat']),'tmap');

EOF
