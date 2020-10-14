#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: VBM_CreateTemplateBySPM.sh  -subjectdir <folder>  -subjs <file>  -seg <folder>  -t1name <name>  "
	echo ""
	echo "  -subjectdir       : T1 file"
	echo "  -subjs            : output folder"
	echo "  -seg              : segmentation folder "
	echo "  -t1name           : T1 name "
	echo ""
	echo "Usage: VBM_CreateTemplateBySPM.sh -subjectdir <folder>  -subjs <file>  -seg <folder>  -t1name <name> "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo ""
		echo "Usage: VBM_CreateTemplateBySPM.sh  -subjectdir <folder>  -subjs <file>  -seg <folder>  -t1name <name>  "
		echo ""
		echo "  -subjectdir       : T1 file"
		echo "  -subjs            : output folder"
		echo "  -seg              : segmentation folder "
		echo "  -t1name           : T1 name "
		echo ""
		echo "Usage: VBM_CreateTemplateBySPM.sh -subjectdir <folder>  -subjs <file>  -seg <folder>  -t1name <name> "
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
	-t1name)
		index=$[$index+1]
		eval T1BASENAME=\${$index}
		echo "T1 name : $T1BASENAME"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: VBM_CreateTemplateBySPM.sh  -subjectdir <folder>  -subjs <file>  -seg <folder>  -t1name <name>  "
		echo ""
		echo "  -subjectdir       : T1 file"
		echo "  -subjs            : output folder"
		echo "  -seg              : segmentation folder "
		echo "  -t1name           : T1 name "
		echo ""
		echo "Usage: VBM_CreateTemplateBySPM.sh -subjectdir <folder>  -subjs <file>  -seg <folder>  -t1name <name> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# Create template
echo "Create template"
/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	subjs = textread('${SUBJFILE}','%s');

	gmfiles = {};
	wmfiles = {};
	for k = 1:length(subjs)
		gmfiles{k,1} = fullfile('${SUBJDIR}',subjs{k},'${SEGDIR}',['rc1' '${T1BASENAME}' '.nii']);
		wmfiles{k,1} = fullfile('${SUBJDIR}',subjs{k},'${SEGDIR}',['rc2' '${T1BASENAME}' '.nii']);
	end
	allfiles{1,1} = gmfiles;
	allfiles{1,2} = wmfiles;

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	matlabbatch{end+1}.spm.tools.dartel.warp.images = allfiles;
	matlabbatch{end}.spm.tools.dartel.warp.settings.template = 'TemplatePredistim';
	matlabbatch{end}.spm.tools.dartel.warp.settings.rform = 0;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(1).its = 3;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(1).K = 0;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(1).slam = 16;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(2).its = 3;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(2).K = 0;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(2).slam = 8;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(3).its = 3;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(3).K = 1;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(3).slam = 4;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(4).its = 3;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(4).K = 2;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(4).slam = 2;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(5).its = 3;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(5).K = 4;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(5).slam = 1;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(6).its = 3;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(6).K = 6;
	matlabbatch{end}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
	matlabbatch{end}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
	matlabbatch{end}.spm.tools.dartel.warp.settings.optim.cyc = 3;
	matlabbatch{end}.spm.tools.dartel.warp.settings.optim.its = 3;

	spm_jobman('run',matlabbatch);

EOF

