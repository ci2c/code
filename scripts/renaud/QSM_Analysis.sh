#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: QSM_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>  -docsf  -e <value>  -sk <value> <value>] "
	echo ""
	echo "  -i                           : Path to dicom folder "
	echo "  -o                           : output folder "
	echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
	echo "  Options  "
	echo "  -sd                          : path to subject's freesurfer folder "
	echo "  -m                           : specify mask (.nii.gz or .nii) in 3D multi-echo space (Default: no mask) "
	echo "  -a                           : 1=matlab algo ; 2=binary algo (Default: 2) "
	echo "  -dosmv                       : do spherical mean operation (only work with binary algo) (Default: 0) "
	echo "  -r                           : radius for spherical mean operation (only work with binary algo) (Default: 5mm) "
	echo "  -docsf                       : do CSF correction (Default: 0) "
	echo "  -e                           : fix the number of echoes to be used (Default: all) "
	echo "  -sk                          : specify the first echo and intervals (Default: all) "
	echo ""
	echo "Usage: QSM_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>  -docsf  -e <value>  -sk <value> <value>] "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1
FS=""
mask=""
algo="2"
doSMV="0"
radius="5"
doCSF="0"
Necho=""
firstEcho=""
stepEcho=""

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: QSM_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>  -docsf  -e <value>  -sk <value> <value>] "
		echo ""
		echo "  -i                           : Path to dicom folder "
		echo "  -o                           : output folder "
		echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
		echo "  Options  "
		echo "  -sd                          : path to subject's freesurfer folder "
		echo "  -m                           : specify mask (.nii.gz or .nii) in 3D multi-echo space (Default: no mask) "
		echo "  -a                           : 1=matlab algo ; 2=binary algo (Default: 2) "
		echo "  -dosmv                       : do spherical mean operation (only work with binary algo) (Default: 0) "
		echo "  -r                           : radius for spherical mean operation (only work with binary algo) (Default: 5mm) "
		echo "  -docsf                       : do CSF correction (Default: 0) "
		echo "  -e                           : fix the number of echoes to be used (Default: all) "
		echo "  -sk                          : specify the first echo and intervals (Default: all) "
		echo ""
		echo "Usage: QSM_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>  -docsf  -e <value>  -sk <value> <value>] "
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
	-a)
		index=$[$index+1]
		eval algo=\${$index}
		echo "algo to use : ${algo}"
		;;
	-dosmv)
		doSMV="1"
		echo "Do spherical mean value operation"
		;;
	-docsf)
		doCSF="1"
		echo "Do CSF correction"
		;;
	-r)
		index=$[$index+1]
		eval radius=\${$index}
		echo "radius : ${radius}"
		;;
	-e)
		index=$[$index+1]
		eval Necho=\${$index}
		echo "Necho : ${Necho}"
		;;
	-sk)
		index=$[$index+1]
		eval firstEcho=\${$index}
		echo "firstEcho : ${firstEcho}"
		index=$[$index+1]
		eval stepEcho=\${$index}
		echo "stepEcho : ${stepEcho}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: QSM_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>  -docsf  -e <value>  -sk <value> <value>] "
		echo ""
		echo "  -i                           : Path to dicom folder "
		echo "  -o                           : output folder "
		echo "  -echo                        : 1st echo image (.nii.gz or .nii) "
		echo "  Options  "
		echo "  -sd                          : path to subject's freesurfer folder "
		echo "  -m                           : specify mask (.nii.gz or .nii) in 3D multi-echo space (Default: no mask) "
		echo "  -a                           : 1=matlab algo ; 2=binary algo (Default: 2) ; 3=NewMatlabAlgo"
		echo "  -dosmv                       : do spherical mean operation (only work with binary algo) (Default: 0) "
		echo "  -r                           : radius for spherical mean operation (only work with binary algo) (Default: 5mm) "
		echo "  -docsf                       : do CSF correction (Default: 0) "
		echo "  -e                           : fix the number of echoes to be used (Default: all) "
		echo "  -sk                          : specify the first echo and intervals (Default: all) "
		echo ""
		echo "Usage: QSM_Analysis.sh -i <dicomdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>  -docsf  -e <value>  -sk <value> <value>] "
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


fslreorient2std ${ECHO} ${OUTDIR}/pre_RAS.nii.gz
mri_convert --out_orientation RAS ${OUTDIR}/pre_RAS.nii.gz ${OUTDIR}/RAS.nii.gz
ECHO=${OUTDIR}/RAS.nii.gz

# Create real image for registering
fslroi ${ECHO} ${OUTDIR}/real_gre 1 1
gunzip -f ${OUTDIR}/real_gre.nii.gz

if [ ! -z ${mask} ]; then

	echo "Convert mask format"
	cp -f ${mask} ${OUTDIR}/
	filename=$(basename "$mask")
	filedir=$(dirname "$mask")
	extension="${filename##*.}"
	if [ "${extension}" == "gz" ]
	then
		gunzip -f ${OUTDIR}/${filename}
		filename="${filename%.*}"
	elif [ "${extension}" == "mgz" ]
	then
		mri_convert ${OUTDIR}/${filename} ${OUTDIR}/r_ras_${filename%.*}.nii --out_orientation RAS -rl ${OUTDIR}/real_gre.nii -rt nearest
		fslmaths ${OUTDIR}/r_ras_${filename%.*}.nii -bin ${OUTDIR}/b_r_ras_${filename%.*}.nii.gz
		rm -f ${OUTDIR}/r_ras_${filename%.*}.nii
		gunzip -f ${OUTDIR}/b_r_ras_${filename%.*}.nii.gz 
		filename=/b_r_ras_${filename%.*}.nii
	fi
	
	mask=${OUTDIR}/${filename}
	cp -f ${mask} ${OUTDIR}/Mask.nii
	rm -f ${mask}
	mask=${OUTDIR}/Mask.nii
fi

# ==========================================================================================
#                                    QSM ANALYSIS
# ==========================================================================================

echo "QSM Analysis..."

if [ ${algo} -eq "1" ]; then

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	disp('computeQSM(DicomFolder,outdir,echo,all)');
	steps = {'data','mask','noise','normalization','magnitude','fieldmap','unwrapping','fieldremoval','qsm'};
	if isempty('${mask}')
		disp(1)
		computeQSM('${DICOMDIR}','${OUTDIR}','${OUTDIR}/real_gre.nii',steps);
	else
		disp(2)
		computeQSM('${DICOMDIR}','${OUTDIR}','${OUTDIR}/real_gre.nii',steps,'${mask}');
	end
	
EOF
elif [ ${algo} -eq "2" ]; then

	if [ ! -z ${mask} ]; then

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
	CMD=""
	if [ ${doSMV} -eq "0" ]; then
		CMD=`echo "$CMD""-nosmv"" "`
	else		
		CMD=`echo "$CMD""-ra ${radius}"" "`
	fi
	if [ ! -z ${mask} ]; then
		CMD=`echo "$CMD""-m ${OUTDIR}/Mask.bin"" "`
	fi
	if [ ${doCSF} -eq "1" ]; then
		CMD=`echo "$CMD""-CSF"" "`
	fi
	if [ ! -z ${Necho} ]; then
		CMD=`echo "$CMD""-e ${Necho}"" "`
	fi
	if [ ! -z ${firstEcho} ]; then
		CMD=`echo "$CMD""-sk ${firstEcho} ${stepEcho}"" "`
	fi
	echo "CMD=$CMD"
	echo "/NAS/tupac/renaud/QSM/MEDI/medin ${CMD} ${DICOMDIR}"
	/NAS/tupac/renaud/QSM/MEDI/medin ${CMD} ${DICOMDIR}
	cd ${cur_path}
	
	# convert results
	dcm2nii -o ${OUTDIR}/ ${OUTDIR}/Echo*/*
	QSMf=$(ls ${OUTDIR}/ | egrep '^20')
	echo "QSM=$QSMf"
	mv ${OUTDIR}/${QSMf} ${OUTDIR}/QSM.nii.gz
	gunzip -f ${OUTDIR}/QSM.nii.gz

	matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	disp('QSM_ConvertBinToNii(${OUTDIR}/real_gre.nii,${OUTDIR})');
	QSM_ConvertBinToNii('${OUTDIR}/real_gre.nii','${OUTDIR}');
	
EOF

elif [ ${algo} -eq "3" ]; then
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	%steps = {'data','mask','noise','normalization','magnitude','fieldmap','unwrapping','fieldremoval','qsm'};
	steps = {'mask','noise','normalization','magnitude','fieldmap','unwrapping','fieldremoval','qsm'};
	if isempty('${mask}')
		disp('computeQSM_2019(${DICOMDIR},${OUTDIR},${OUTDIR}/real_gre.nii,steps)');
		computeQSM_2019('${DICOMDIR}','${OUTDIR}','${OUTDIR}/real_gre.nii',steps);
	else
		disp('computeQSM_2019(${DICOMDIR},${OUTDIR},${OUTDIR}/real_gre.nii,steps,${mask})');
		computeQSM_2019('${DICOMDIR}','${OUTDIR}','${OUTDIR}/real_gre.nii',steps,'${mask}');
	end
EOF
	###
	# convert results
	###

	#QSMf=$(ls ${OUTDIR}/iFreq | egrep '^20.*nii.gz')
	#echo "iFreq=$QSMf"
	#mv ${OUTDIR}/iFreq/${QSMf} ${OUTDIR}/iFreq.nii.gz
	#unzip -f ${OUTDIR}/iFreq.nii.gz
	
	#QSMf=$(ls ${OUTDIR}/iFreq_raw | egrep '^20.*nii.gz')
	#echo "iFreq_raw=$QSMf"
	#mv ${OUTDIR}/iFreq_raw/${QSMf} ${OUTDIR}/iFreq_raw.nii.gz
	#gunzip -f ${OUTDIR}/iFreq_raw.nii.gz
	
	#QSMf=$(ls ${OUTDIR}/RDF | egrep '^20.*nii.gz')
	#echo "RDF=$QSMf"
	#mv ${OUTDIR}/RDF/${QSMf} ${OUTDIR}/RDF.nii.gz
	#gunzip -f ${OUTDIR}/RDF.nii.gz
	
	#QSMf=$(ls ${OUTDIR}/Mask | egrep '^20.*nii.gz')
	#echo "Mask=$QSMf"
	#mv ${OUTDIR}/Mask/${QSMf} ${OUTDIR}/Mask.nii.gz
	#gunzip -f ${OUTDIR}/Mask.nii.gz
	
	#QSMf=$(ls ${OUTDIR}/QSM | egrep '^20.*nii.gz')
	#echo "QSM=$QSMf"
	#mv ${OUTDIR}/QSM/${QSMf} ${OUTDIR}/QSM.nii.gz
	#gunzip -f ${OUTDIR}/QSM.nii.gz
fi


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
	restoredefaultpath
	addpath('/home/global/matlab_toolbox/spm12/')
	addpath('/home/global/freesurfer6_0/')

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
	Maps = {'Mask.nii','iFreq_raw.nii','iFreq.nii','RDF.nii','QSM.nii'};
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
	Maps = {'iFreq_raw.nii','iFreq.nii','RDF.nii','QSM.nii'};
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
	fslmaths ${OUTDIR}/wQSM.nii -nan ${OUTDIR}/wQSM.nii.gz
	rm -f ${OUTDIR}/wQSM.nii
		
fi

if [ -f ${OUTDIR}/Mask.nii ]; then
	fslmaths ${OUTDIR}/Mask.nii -nan ${OUTDIR}/Mask.nii.gz
	rm -f ${OUTDIR}/Mask.nii
fi
fslmaths ${OUTDIR}/QSM.nii -nan ${OUTDIR}/QSM.nii.gz
rm -f ${OUTDIR}/QSM.nii

