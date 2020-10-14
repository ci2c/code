#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: VBM_NormaliseToMNIBySPM.sh  -subjectdir <folder>  -subjs <file>  -seg <folder>  -temp <file>  -tempname <name>  -t1name <name>  [-fwhm <value>]  "
	echo ""
	echo "  -subjectdir       : T1 file"
	echo "  -subjs            : output folder"
	echo "  -seg              : segmentation folder "
	echo "  -temp             : Template's file "
	echo "  -tempname         : Template's name "
	echo "  -t1name           : T1 name "
	echo "  OPTIONS "
	echo "  -fwhm             : smoothing value "
	echo ""
	echo "Usage: VBM_NormaliseToMNIBySPM.sh -subjectdir <folder>  -subjs <file>  -seg <folder>  -temp <folder>  -tempname <name>  -t1name <name>  [-fwhm <value>] "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1
FWHM="8"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo ""
		echo "Usage: VBM_NormaliseToMNIBySPM.sh  -subjectdir <folder>  -subjs <file>  -seg <folder>  -temp <file>  -tempname <name>  -t1name <name>  [-fwhm <value>]  "
		echo ""
		echo "  -subjectdir       : T1 file"
		echo "  -subjs            : output folder"
		echo "  -seg              : segmentation folder "
		echo "  -temp             : Template's file "
		echo "  -tempname         : Template's name "
		echo "  -t1name           : T1 name "
		echo "  OPTIONS "
		echo "  -fwhm             : smoothing value "
		echo ""
		echo "Usage: VBM_NormaliseToMNIBySPM.sh -subjectdir <folder>  -subjs <file>  -seg <folder>  -temp <folder>  -tempname <name>  -t1name <name>  [-fwhm <value>] "
		echo ""
		exit 1
		;;
	-subjectdir)
		index=$[$index+1]
		eval SUBJDIR=\${$index}
		echo "subjects' dir : $SUBJDIR"
		;;
	-subjs)
		index=$[$index+1]
		eval SUBJFILE=\${$index}
		echo "subjects' file : $SUBJFILE"
		;;
	-seg)
		index=$[$index+1]
		eval SEGDIR=\${$index}
		echo "segmentation folder : $SEGDIR"
		;;
	-temp)
		index=$[$index+1]
		eval TEMPFILE=\${$index}
		echo "Template's file : $TEMPFILE"
		;;
	-tempname)
		index=$[$index+1]
		eval TEMPBASENAME=\${$index}
		echo "Template's name : $TEMPBASENAME"
		;;
	-t1name)
		index=$[$index+1]
		eval T1BASENAME=\${$index}
		echo "T1 name : $T1BASENAME"
		;;
	-fwhm)
		index=$[$index+1]
		eval FWHM=\${$index}
		echo "smoothing value : $FWHM"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: VBM_NormaliseToMNIBySPM.sh  -subjectdir <folder>  -subjs <file>  -seg <folder>  -temp <file>  -tempname <name>  -t1name <name>  [-fwhm <value>]  "
		echo ""
		echo "  -subjectdir       : T1 file"
		echo "  -subjs            : output folder"
		echo "  -seg              : segmentation folder "
		echo "  -temp             : Template's file "
		echo "  -tempname         : Template's name "
		echo "  -t1name           : T1 name "
		echo "  OPTIONS "
		echo "  -fwhm             : smoothing value "
		echo ""
		echo "Usage: VBM_NormaliseToMNIBySPM.sh -subjectdir <folder>  -subjs <file>  -seg <folder>  -temp <folder>  -tempname <name>  -t1name <name>  [-fwhm <value>] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# Normalise to MNI and smoothing
echo "Normalise to MNI and smoothing"
/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	subjs = textread('${SUBJFILE}','%s');

	flowfields = {};
	c1images   = {};
	for k = 1:length(subjs)
		flowfields{k,1} = fullfile('${SUBJDIR}',subjs{k},'${SEGDIR}',['u_rc1' '${T1BASENAME}' '_' '${TEMPBASENAME}' '.nii']);
		c1images{k,1}   = fullfile('${SUBJDIR}',subjs{k},'${SEGDIR}',['c1' '${T1BASENAME}' '.nii']);
	end
	allimages{1,1} = c1images;

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	matlabbatch{end+1}.spm.tools.dartel.mni_norm.template            = cellstr('${TEMPFILE}');
	matlabbatch{end}.spm.tools.dartel.mni_norm.data.subjs.flowfields = flowfields;
	matlabbatch{end}.spm.tools.dartel.mni_norm.data.subjs.images     = allimages;
	matlabbatch{end}.spm.tools.dartel.mni_norm.vox      = [NaN NaN NaN];
	matlabbatch{end}.spm.tools.dartel.mni_norm.bb       = [NaN NaN NaN; NaN NaN NaN];
	matlabbatch{end}.spm.tools.dartel.mni_norm.preserve = 1;
	matlabbatch{end}.spm.tools.dartel.mni_norm.fwhm     = [8 8 8];

	spm_jobman('run',matlabbatch);

EOF

