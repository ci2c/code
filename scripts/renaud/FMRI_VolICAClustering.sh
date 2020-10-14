#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: FMRI_VolICAClustering.sh  -fsdir <path>  -mat <matFile>  -o <outdir>  -ica <folder>  -pref <name>  -thres <value>  -clusSize <value> "
	echo ""
	echo "  -fsdir                        : path to freesurfer folder "
	echo "  -mat                          : .mat File (2 cells: subjlist and datalist) "
	echo "  -o                            : output folder "
	echo "  -ica                          : ica folder "
	echo "  -pref                         : prefix of epi data "
	echo "  -thres                        : threshold value "
	echo "  -clusSize                     : cluster size "
	echo ""
	echo "Usage: FMRI_VolICAClustering.sh  -fsdir <path>  -mat <matFile>  -o <outdir>  -ica <folder>  -pref <name>  -thres <value>  -clusSize <value> "
	echo ""
	exit 1
fi

index=1
clus=10
thresVal=0.05

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_VolICAClustering.sh  -fsdir <path>  -mat <matFile>  -o <outdir>  -ica <folder>  -pref <name>  -thres <value>  -clusSize <value> "
		echo ""
		echo "  -fsdir                        : path to freesurfer folder "
		echo "  -mat                          : .mat File (2 cells: subjlist and datalist) "
		echo "  -o                            : output folder "
		echo "  -ica                          : ica folder "
		echo "  -pref                         : prefix of ICA map (example: wica_map_) "
		echo "  -thres                        : threshold value "
		echo "  -clusSize                     : cluster size "
		echo ""
		echo "Usage: FMRI_VolICAClustering.sh  -fsdir <path>  -mat <matFile>  -o <outdir>  -ica <folder>  -pref <name>  -thres <value>  -clusSize <value> "
		echo ""
		exit 1
		;;
	-fsdir)
		index=$[$index+1]
		eval input=\${$index}
		echo "path to freesurfer folder : ${input}"
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
	-ica)
		index=$[$index+1]
		eval icafolder=\${$index}
		echo "ica folder : ${icafolder}"
		;;
	-pref)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix : ${prefix}"
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
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_VolICAClustering.sh  -fsdir <path>  -mat <matFile>  -o <outdir>  -ica <folder>  -pref <name>  -thres <value>  -clusSize <value> "
		echo ""
		echo "  -fsdir                        : path to freesurfer folder "
		echo "  -mat                          : .mat File (2 cells: subjlist and datalist) "
		echo "  -o                            : output folder "
		echo "  -ica                          : ica folder "
		echo "  -pref                         : prefix of epi data "
		echo "  -thres                        : threshold value "
		echo "  -clusSize                     : cluster size "
		echo ""
		echo "Usage: FMRI_VolICAClustering.sh  -fsdir <path>  -mat <matFile>  -o <outdir>  -ica <folder>  -pref <name>  -thres <value>  -clusSize <value> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${input} ]
then
	 echo "-fsdir argument mandatory"
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

if [ -z ${icafolder} ]
then
	 echo "-ica argument mandatory"
	 exit 1
fi

if [ -z ${prefix} ]
then
	 echo "-pref argument mandatory"
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

### Creates output folder
echo "mkdir ${output}"
mkdir ${output}


/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	load('${matFile}');
	
	subjL={};
	dataL={};
	for k = 1:length(subjlist)
	    
	    subjL{k} = subjlist{k};
	    dataL{k} = fullfile('${input}',subjL{k},'rsfmri','run01','${icafolder}');
	    
	end

	maskFile = fullfile('${input}',subjL{1},'rsfmri','run01','wepi_mask.nii');
	
	optfunc.hierclus   = 1;
	optfunc.groupmaps  = 1;
	optfunc.threshmaps = 1;
	optfunc.clusters   = 1;
	optfunc.SgroupAna  = 1;
	optfunc.mapMNI     = 1;
	optfunc.thresP     = ${thresVal};
	optfunc.typeCorr   = 'FDR';
	optfunc.numVox     = ${clus};
	optfunc.clusC      = 30;
	optfunc.sizeVox    = [2 2 2];
	optfunc.csize      = 30;
	optfunc.cdist      = 30;

	FMRI_VolClusteringICAMaps(dataL,subjL,'${output}','${prefix}',optfunc,maskFile);

EOF

