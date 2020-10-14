#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: VBM_SegmentBySPM.sh -i <T1file>  -o <outfolder> "
	echo ""
	echo "  -i        : T1 file"
	echo "  -o        : output folder"
	echo ""
	echo "Usage: VBM_SegmentBySPM.sh -i <T1file>  -o <outfolder> "
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
		echo "Usage: VBM_SegmentBySPM.sh -i <T1file>  -o <outfolder> "
		echo ""
		echo "  -i        : T1 file"
		echo "  -o        : output folder"
		echo ""
		echo "Usage: VBM_SegmentBySPM.sh -i <T1file>  -o <outfolder> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval T1=\${$index}
		echo "T1 file : $T1"
		;;
	-o)
		index=$[$index+1]
		eval OUTDIR=\${$index}
		echo "output folder : $OUTDIR"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: VBM_SegmentBySPM.sh -i <T1file>  -o <outfolder> "
		echo ""
		echo "  -i        : T1 file"
		echo "  -o        : output folder"
		echo ""
		echo "Usage: VBM_SegmentBySPM.sh -i <T1file>  -o <outfolder> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# create out folder
echo "if [ ! -d ${OUTDIR} ]; then mkdir ${OUTDIR}; fi"
if [ ! -d ${OUTDIR} ]; then mkdir ${OUTDIR}; fi

# convert T1
echo "if [ ! -f ${OUTDIR}/T1_las.nii ]; then mri_convert ${T1} ${OUTDIR}/T1_las.nii --out_orientation LAS; fi"
if [ ! -f ${OUTDIR}/T1_las.nii ]; then mri_convert ${T1} ${OUTDIR}/T1_las.nii --out_orientation LAS; fi

# Segment grey matter, white matter and LCS
echo "Segment grey matter, white matter and LCS"
/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	spmpath = which('spm');
	spmpath = dirname(spmpath);

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	matlabbatch{end+1}.spm.spatial.preproc.channel.vols = cellstr(fullfile('${OUTDIR}','T1_las.nii'));
	matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
	matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
	matlabbatch{end}.spm.spatial.preproc.channel.write = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = cellstr(fullfile(spmpath,'tpm/TPM.nii,1'));
	matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 1;
	matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 1];
	matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = cellstr(fullfile(spmpath,'tpm/TPM.nii,2'));
	matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 1;
	matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 1];
	matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = cellstr(fullfile(spmpath,'tpm/TPM.nii,3'));
	matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
	matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = cellstr(fullfile(spmpath,'tpm/TPM.nii,4'));
	matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
	matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = cellstr(fullfile(spmpath,'tpm/TPM.nii,5'));
	matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
	matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm = cellstr(fullfile(spmpath,'tpm/TPM.nii,6'));
	matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus = 2;
	matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.warp.mrf = 1;
	matlabbatch{end}.spm.spatial.preproc.warp.cleanup = 1;
	matlabbatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
	matlabbatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
	matlabbatch{end}.spm.spatial.preproc.warp.fwhm = 0;
	matlabbatch{end}.spm.spatial.preproc.warp.samp = 3;
	matlabbatch{end}.spm.spatial.preproc.warp.write = [0 0];

	spm_jobman('run',matlabbatch);

EOF

