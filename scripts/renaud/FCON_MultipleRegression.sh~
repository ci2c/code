#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: FCON_MultipleRegression.sh  -def <file>  -epi <fmri_file>  -o <path>  -reg <file>  -tr <value> "
	echo ""
	echo "  -def                         : Deformation file"
	echo "  -epi                         : fmri file "
	echo "  -o                           : output path "
	echo "  -reg                         : regressors file (.mat) "
	echo "  -tr                          : TR value "
	echo ""
	echo "Usage: FCON_MultipleRegression.sh -def <file>  -epi <fmri_file>  -o <path>  -reg <file>  -tr <value> "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FCON_MultipleRegression.sh  -def <file>  -epi <fmri_file>  -o <path>  -reg <file>  -tr <value> "
		echo ""
		echo "  -def                         : Deformation file"
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -reg                         : regressors file (.mat) "
		echo "  -tr                          : TR value "
		echo ""
		echo "Usage: FCON_MultipleRegression.sh -def <file>  -epi <fmri_file>  -o <path>  -reg <file>  -tr <value> "
		echo ""
		exit 1
		;;
	-def)
		index=$[$index+1]
		eval defFile=\${$index}
		echo "Deformation file : $defFile"
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "fMRI file : $epi"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "output path : $outdir"
		;;
	-reg)
		index=$[$index+1]
		eval regressor=\${$index}
		echo "regressors file : ${regressor}"
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
		echo "Usage: FCON_MultipleRegression.sh  -def <file>  -epi <fmri_file>  -o <path>  -reg <file>  -tr <value> "
		echo ""
		echo "  -def                         : Deformation file"
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -reg                         : regressors file (.mat) "
		echo "  -tr                          : TR value "
		echo ""
		echo "Usage: FCON_MultipleRegression.sh -def <file>  -epi <fmri_file>  -o <path>  -reg <file>  -tr <value> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${defFile} ]
then
	 echo "-def argument mandatory"
	 exit 1
fi

if [ -z ${regressor} ]
then
	 echo "-reg argument mandatory"
	 exit 1
fi

if [ -z ${epi} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-tr argument mandatory"
	 exit 1
fi

echo "FConn_MultipleRegression('${epi}','${outdir}',${TR},seed,motion,covariate);"

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	%addpath('/home/global/matlab_toolbox/spm12b')

	load('${regressor}');
	FConn_MultipleRegression('${epi}','${outdir}',${TR},seed,motion,covariate);
  
	spm_get_defaults;
	spm_jobman('initcfg');
	
	matlabbatch={};
	matlabbatch{end+1}.spm.spatial.normalise.write.subj.def    = cellstr('${defFile}');
	mapT = cellstr(conn_dir(fullfile('${outdir}','spmT_0001.img')));
	mapC = cellstr(conn_dir(fullfile('${outdir}','con_0001.img')));
	map  = cat(1,mapT,mapC);
	matlabbatch{end}.spm.spatial.normalise.write.subj.resample = map;
	matlabbatch{end}.spm.spatial.normalise.write.woptions.bb   = [-78 -112 -70; 78 76 85];
	matlabbatch{end}.spm.spatial.normalise.write.woptions.vox  = [2 2 2];
	matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
	if ~isempty(matlabbatch),
		spm_jobman('run',matlabbatch);
    	end

EOF

