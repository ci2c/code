#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: R2_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>] "
	echo ""
	echo "  -i                           : Path to dicom folder "
	echo "  -o                           : output folder "
	echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
	echo "  Options  "
	echo "  -sd                          : path to subject's freesurfer folder "
	echo "  -m                           : specify mask (.nii) in 3D multi-echo space (Default: no mask) "
	echo ""
	echo "Usage: R2_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>] "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1
FS=""
mask=""

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: R2_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>] "
		echo ""
		echo "  -i                           : Path to dicom folder "
		echo "  -o                           : output folder "
		echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
		echo "  Options  "
		echo "  -sd                          : path to subject's freesurfer folder "
		echo "  -m                           : specify mask (.nii) in 3D multi-echo space (Default: no mask) "
		echo ""
		echo "Usage: R2_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>] "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval DICOMDIR=\${$index}
		echo "DICOM folder : ${DICOMDIR}"
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
		eval mask=\${$index}
		echo "mask to use : ${mask}"
		;;
	-r)
		index=$[$index+1]
		eval radius=\${$index}
		echo "radius : ${radius}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: R2_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>] "
		echo ""
		echo "  -i                           : Path to dicom folder "
		echo "  -o                           : output folder "
		echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
		echo "  Options  "
		echo "  -sd                          : path to subject's freesurfer folder "
		echo "  -m                           : specify mask (.nii) in 3D multi-echo space (Default: no mask) "
		echo ""
		echo "Usage: R2_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${DICOMDIR} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

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
#                                    R2* ANALYSIS
# ==========================================================================================

cp -rf ${DICOMDIR} ${OUTDIR}/DICOMFILES

echo "R2* Analysis..."

if [ ! -z ${mask} ]; then

	echo "Convert mask format"
	cp -f ${mask} ${OUTDIR}/Mask.nii

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	QSM_ConvertNiiToBin('${mask}',fullfile('${OUTDIR}','Mask.bin'),'int32');

EOF

fi

cur_path=`pwd`
cd ${OUTDIR}
CMD="-of R"

if [ ! -z ${mask} ]; then
	CMD=`echo "$CMD"" -m ${OUTDIR}/Mask.bin"" "`
fi

echo "CMD=$CMD"
/NAS/tupac/renaud/QSM/MEDI/medin ${CMD} ${OUTDIR}/DICOMFILES
cd ${cur_path}

# convert results
dcm2nii -o ${OUTDIR}/ ${OUTDIR}/Echo*/*
R2f=$(ls ${OUTDIR}/ | egrep '^20')
echo "R2map=$R2f"
mv ${OUTDIR}/${R2f} ${OUTDIR}/R2map.nii.gz
gunzip -f ${OUTDIR}/R2map.nii.gz

# remove dicom files
rm -rf ${OUTDIR}/DICOMFILES


# ==========================================================================================
#                                  REGISTRATION TO T1
# ==========================================================================================

if [ ! -z ${FS} ]; then

	# T1
	if [ ! -f ${FS}/mri/T1_las.nii ]; then
		mri_convert ${FS}/mri/T1.mgz ${FS}/mri/T1_las.nii --out_orientation LAS
	fi
	T1=${FS}/mri/T1_las.nii

	# decompress
	extension="${T1##*.}"
	if [ "${extension}" == "gz" ]
	then
		gunzip -f ${T1}
		T1="${T1%.*}"
	fi
	echo ${T1}

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	cur_path=pwd;
	cd('${OUTDIR}');

	% spm path
	t = which('spm');
	t = dirname(t);

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	% Coregister ECHO -> T1
	sfile={};
	Maps = {'Mask.nii','R2map.nii'};
	for k = 1:length(Maps)
		if exist(fullfile('${OUTDIR}',Maps{k}),'file')
			sfile{end+1,1} = fullfile('${OUTDIR}',Maps{k});
		end
	end

	matlabbatch{end+1}.spm.spatial.coreg.estimate.ref             = cellstr('${T1}');
	matlabbatch{end}.spm.spatial.coreg.estimate.source            = cellstr('${OUTDIR}/real_gre.nii');
	matlabbatch{end}.spm.spatial.coreg.estimate.other             = sfile;
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

	if ~exist('${FS}/mri/y_T1_las.nii','file')
		% Normalize T1 into MNI
		matlabbatch{end+1}.spm.spatial.normalise.est.subj.vol = cellstr('${T1}');
		matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
		matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
		matlabbatch{end}.spm.spatial.normalise.est.eoptions.tpm = {[t '/tpm/TPM.nii']};
		matlabbatch{end}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
		matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
		matlabbatch{end}.spm.spatial.normalise.est.eoptions.fwhm = 0;
		matlabbatch{end}.spm.spatial.normalise.est.eoptions.samp = 3;
	end

	% Write QSM into MNI
	sfile={};
	Maps = {'R2map.nii'};
	for k = 1:length(Maps)
		if exist(fullfile('${OUTDIR}',Maps{k}),'file')
			sfile{end+1,1} = fullfile('${OUTDIR}',Maps{k});
		end
	end
	matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${FS}/mri/y_T1_las.nii');
	matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = sfile;
	matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
	matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [1 1 1];
	matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
	matlabbatch{end}.spm.spatial.normalise.write.woptions.prefix = 'w';

	if exist(fullfile('${OUTDIR}','Mask.nii'),'file')
		matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${FS}/mri/y_T1_las.nii');
		matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr('${OUTDIR}/Mask.nii');
		matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [1 1 1];
		matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 0;
		matlabbatch{end}.spm.spatial.normalise.write.woptions.prefix = 'w';
	end

	spm_jobman('run',matlabbatch);

	cd(cur_path);


EOF

	if [ -f ${OUTDIR}/wMask.nii ]; then
		fslmaths ${OUTDIR}/wMask.nii -nan ${OUTDIR}/wMask.nii.gz
		rm -f ${OUTDIR}/wMask.nii
	fi
	fslmaths ${OUTDIR}/wR2map.nii -nan ${OUTDIR}/wR2map.nii.gz
	rm -f ${OUTDIR}/wR2map.nii
		
fi

if [ -f ${OUTDIR}/Mask.nii ]; then
	fslmaths ${OUTDIR}/Mask.nii -nan ${OUTDIR}/Mask.nii.gz
	rm -f ${OUTDIR}/Mask.nii
fi
fslmaths ${OUTDIR}/R2map.nii -nan ${OUTDIR}/R2map.nii.gz
rm -f ${OUTDIR}/R2map.nii


