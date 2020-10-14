#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: QSM_CreateMask.sh -echo <file>  -o <outdir>  [-m <value>  -sd <path>] "
	echo ""
	echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
	echo "  -o                           : output folder "
	echo "  Options  "
	echo "  -sd                          : path to subject's freesurfer folder "
	echo "  -m                           : which method 1: bet on Magnitude ; 2: FS mask (Default: 1) "
	echo ""
	echo "Usage: QSM_CreateMask.sh -echo <file>  -o <outdir>  [-m <value>  -sd <path>] "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1
FS=""
method="1"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: QSM_CreateMask.sh -echo <file>  -o <outdir>  [-m <value>  -sd <path>] "
		echo ""
		echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
		echo "  -o                           : output folder "
		echo "  Options  "
		echo "  -sd                          : path to subject's freesurfer folder "
		echo "  -m                           : which method 1: bet on Magnitude ; 2: FS mask (Default: 1) "
		echo ""
		echo "Usage: QSM_CreateMask.sh -echo <file>  -o <outdir>  [-m <value>  -sd <path>] "
		echo ""
		exit 1
		;;
	-o)
		index=$[$index+1]
		eval OUTDIR=\${$index}
		echo "output folder : ${OUTDIR}"
		;;
	-echo)
		index=$[$index+1]
		eval ECHO=\${$index}
		echo "1st echo image : ${ECHO}"
		;;
	-sd)
		index=$[$index+1]
		eval FS=\${$index}
		echo "path to freesurfer folder : ${FS}"
		;;
	-m)
		index=$[$index+1]
		eval method=\${$index}
		echo "method to use : ${method}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: QSM_CreateMask.sh -echo <file>  -o <outdir>  [-m <value>  -sd <path>] "
		echo ""
		echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
		echo "  -o                           : output folder "
		echo "  Options  "
		echo "  -sd                          : path to subject's freesurfer folder "
		echo "  -m                           : which method 1: bet on Magnitude ; 2: FS mask (Default: 1) "
		echo ""
		echo "Usage: QSM_CreateMask.sh -echo <file>  -o <outdir>  [-m <value>  -sd <path>] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${OUTDIR} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${ECHO} ]
then
	 echo "-echo argument mandatory"
	 exit 1
fi

# Create out folder
if [ ! -d ${OUTDIR} ]; then
	mkdir ${OUTDIR}
fi

# Create real image for registering
fslroi ${ECHO} ${OUTDIR}/real_gre 1 1
gunzip -f ${OUTDIR}/real_gre.nii.gz


# ==========================================================================================
#                                    CREATE MASK
# ==========================================================================================

if [ ${method} -eq "1" ]; then

	echo "method: magnitude mask"
	bet ${OUTDIR}/real_gre.nii ${OUTDIR}/real -m -n -f 0.5

else

	echo "method: FS mask"
	mri_binarize --i ${FS}/mri/aparc.a2009s+aseg.mgz --min 0.5 --o ${FS}/mri/aparc.a2009s.bin.nii.gz --binval 1
	mri_extract_label ${FS}/mri/aparc.a2009s+aseg.mgz 15 16 ${FS}/mri/masktmp.nii.gz
	mri_binarize --i ${FS}/mri/masktmp.nii.gz --min 0.5 --o ${FS}/mri/masktmp.nii.gz --binval 1
	fslmaths ${FS}/mri/aparc.a2009s.bin.nii.gz -sub ${FS}/mri/masktmp.nii.gz ${OUTDIR}/FS_mask.nii.gz
	rm -f ${FS}/mri/masktmp.nii.gz ${FS}/mri/aparc.a2009s.bin.nii.gz

	mri_convert ${FS}/mri/T1.mgz ${OUTDIR}/T1_las.nii --out_orientation LAS
	mri_convert ${OUTDIR}/FS_mask.nii.gz ${OUTDIR}/FS_mask_las.nii.gz --out_orientation LAS

	gunzip -f ${OUTDIR}/FS_mask_las.nii.gz
	rm -f ${OUTDIR}/FS_mask.nii.gz

	# Register T1 mask to 1st Echo
matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	cur_path=pwd;
	cd('${OUTDIR}');

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	% Coregister T1 -> ECHO
	matlabbatch{end+1}.spm.spatial.coreg.estwrite.ref             = cellstr('${OUTDIR}/real_gre.nii');
	matlabbatch{end}.spm.spatial.coreg.estwrite.source            = cellstr('${OUTDIR}/T1_las.nii');
	matlabbatch{end}.spm.spatial.coreg.estwrite.other             = cellstr('${OUTDIR}/FS_mask_las.nii');
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.sep      = [4 2];
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{end}.spm.spatial.coreg.estwrite.eoptions.fwhm     = [7 7];
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.interp   = 0;
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
	matlabbatch{end}.spm.spatial.coreg.estwrite.roptions.prefix   = 'r';

	spm_jobman('run',matlabbatch);

	cd(cur_path);
	
EOF

	rm -f ${OUTDIR}/FS_mask_las.nii ${OUTDIR}/T1_las.nii ${OUTDIR}/rT1_las.nii
	mv ${OUTDIR}/rFS_mask_las.nii ${OUTDIR}/FS_mask_las.nii
	fslmaths ${OUTDIR}/FS_mask_las.nii -nan ${OUTDIR}/FS_mask_las.nii.gz
	rm -f ${OUTDIR}/FS_mask_las.nii
	gunzip -f ${OUTDIR}/FS_mask_las.nii.gz

fi

