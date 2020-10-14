#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: FMRI_SurfICAClustering.sh  -sd <path>  -mat <matFile>  -o <outdir>  -pref <name>  -ica <folder>  -thres <value>  -clusSize <value>  -tr <value> "
	echo ""
	echo "  -sd                           : freesurfer subjects directory "
	echo "  -mat                          : .mat File (2 cells: subjlist and datalist) "
	echo "  -o                            : output folder "
	echo "  -pref                         : prefix of epi data "
	echo "  -ica                          : ica folder "
	echo "  -thres                        : threshold value "
	echo "  -clusSize                     : cluster size "
	echo "  -tr                           : TR value "
	echo ""
	echo "Usage: FMRI_SurfICAClustering.sh  -sd <path>  -mat <matFile>  -o <outdir>  -pref <name>  -ica <folder>  -thres <value>  -clusSize <value>  -tr <value> "
	echo ""
	exit 1
fi

index=1
clus=100
thresVal=0.95
TR=2

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_SurfICAClustering.sh  -sd <path>  -mat <matFile>  -o <outdir>  -pref <name>  -ica <folder>  -thres <value>  -clusSize <value>  -tr <value> "
		echo ""
		echo "  -sd                           : freesurfer subjects directory "
		echo "  -mat                          : .mat File (2 cells: subjlist and datalist) "
		echo "  -o                            : output folder "
		echo "  -pref                         : prefix of epi data "
		echo "  -ica                          : ica folder "
		echo "  -thres                        : threshold value "
		echo "  -clusSize                     : cluster size "
		echo "  -tr                           : TR value "
		echo ""
		echo "Usage: FMRI_SurfICAClustering.sh  -sd <path>  -mat <matFile>  -o <outdir>  -pref <name>  -ica <folder>  -thres <value>  -clusSize <value>  -tr <value> "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval fsdir=\${$index}
		echo "freesurfer path : ${fsdir}"
		;;
	-mat)
		index=$[$index+1]
		eval matFile=\${$index}
		echo ".mat file : ${matFile}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : ${output}"
		;;
	-pref)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix : ${prefix}"
		;;
	-ica)
		index=$[$index+1]
		eval icafolder=\${$index}
		echo "ica folder : ${icafolder}"
		;;
	-thres)
		index=$[$index+1]
		eval thresVal=\${$index}
		echo "threshold value : ${thresVal}"
		;;
	-clusSize)
		index=$[$index+1]
		eval clus=\${$index}
		echo "cluster value : ${clus}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_SurfICAClustering.sh  -sd <path>  -mat <matFile>  -o <outdir>  -pref <name>  -ica <folder>  -thres <value>  -clusSize <value>  -tr <value> "
		echo ""
		echo "  -sd                           : freesurfer subjects directory "
		echo "  -mat                          : .mat File (2 cells: subjlist and datalist) "
		echo "  -o                            : output folder "
		echo "  -pref                         : prefix of epi data "
		echo "  -ica                          : ica folder "
		echo "  -thres                        : threshold value "
		echo "  -clusSize                     : cluster size "
		echo "  -tr                           : TR value "
		echo ""
		echo "Usage: FMRI_SurfICAClustering.sh  -sd <path>  -mat <matFile>  -o <outdir>  -pref <name>  -ica <folder>  -thres <value>  -clusSize <value>  -tr <value> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${fsdir} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${matFile} ]
then
	 echo "-mat argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${prefix} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

if [ -z ${icafolder} ]
then
	 echo "-ica argument mandatory"
	 exit 1
fi

if [ -z ${thresVal} ]
then
	 echo "-thres argument mandatory"
	 exit 1
fi

if [ -z ${clus} ]
then
	 echo "-clusSize argument mandatory"
	 exit 1
fi

## Delete out dir
if [ -d ${output} ]
then
	echo "rm -rf ${output}"
	rm -rf ${output}
fi

## Creates output folder
echo "mkdir ${output}"
mkdir ${output}


/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	load('${matFile}');
	
	datalist  = {};
	for k = 1 : length(subjlist)    
	    datalist{k} = fullfile('${fsdir}',subjlist{k},'rsfmri','run01','${icafolder}');       
	end

	optfunc.hierclus   = 1;
	optfunc.groupmaps  = 1;
	optfunc.threshmaps = 1;
	optfunc.threshclus = 1;
	optfunc.tiffmaps   = 0;
	optfunc.subcort    = 1;
	optfunc.thresP     = ${thresVal};
	optfunc.threshC    = ${clus};
	optfunc.TR         = ${TR};

	FMRI_ClusteringICAMaps('${fsdir}',datalist,subjlist,'${output}','${prefix}',optfunc);

EOF

