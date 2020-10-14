#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: FMRI_EpilepsyMemory.sh -i <INPUT_DIR>  -subj <name>  -o <OUTPUT_NAME>  [-noprep] "
	echo ""
	echo "  -i                        : Path to input directory "
	echo "  -subj                     : subject's name "
	echo "  -o                        : Output name "
	echo "  -noprep                   : no preprocessing step "
	echo ""
	echo "Usage: FMRI_EpilepsyMemory.sh -i <INPUT_DIR>  -subj <name>  -o <OUTPUT_NAME>  [-noprep] "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
doprep=1
fwhmsurf=1.5
fwhmvol=6
refslice=1
acquis=interleaved
resamp=0
remframe=3
ncomps=40

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_EpilepsyMemory.sh -i <INPUT_DIR>  -subj <name>  -o <OUTPUT_NAME>  [-noprep] "
		echo ""
		echo "  -i                        : Path to input directory "
		echo "  -subj                     : subject's name "
		echo "  -o                        : Output name "
		echo "  -noprep                   : no preprocessing step "
		echo ""
		echo "Usage: FMRI_EpilepsyMemory.sh -i <INPUT_DIR>  -subj <name>  -o <OUTPUT_NAME>  [-noprep] "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "Path : $input"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subject's name : $SUBJ"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "Directory : $output"
		;;
	-noprep)
		doprep=0
		echo "doprep = ${doprep}"
		echo "No preprocessing step"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_EpilepsyMemory.sh -i <INPUT_DIR>  -subj <name>  -o <OUTPUT_NAME>  [-noprep] "
		echo ""
		echo "  -i                        : Path to input directory "
		echo "  -subj                     : subject's name "
		echo "  -o                        : Output name "
		echo "  -noprep                   : no preprocessing step "
		echo ""
		echo "Usage: FMRI_EpilepsyMemory.sh -i <INPUT_DIR>  -subj <name>  -o <OUTPUT_NAME>  [-noprep] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${input} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -d ${input}/${output}0_1 ]
then
	echo "rm -rf ${input}/${output}0_1"
	rm -rf ${input}/${output}0_1
fi

echo "mkdir ${input}/${output}0_1"
mkdir ${input}/${output}0_1

if [ -d ${input}/${output}0_2 ]
then
	echo "rm -rf ${input}/${output}0_2"
	rm -rf ${input}/${output}0_2
fi

echo "mkdir ${input}/${output}0_2"
mkdir ${input}/${output}0_2

if [ -d ${input}/${output}1_1 ]
then
	echo "rm -rf ${input}/${output}1_1"
	rm -rf ${input}/${output}1_1
fi

echo "mkdir ${input}/${output}1_1"
mkdir ${input}/${output}1_1

if [ -d ${input}/${output}1_2 ]
then
	echo "rm -rf ${input}/${output}1_2"
	rm -rf ${input}/${output}1_2
fi

echo "mkdir ${input}/${output}1_2"
mkdir ${input}/${output}1_2

if [ ! -f ${input}/3dt1.nii ]
then
	echo "dcm2nii -o ${input}/ ${input}/*.rec"
	dcm2nii -o ${input}/ -g N ${input}/*.rec
	
	echo "rm -f ${input}/co*.nii ${input}/o*.nii"
	rm -f ${input}/co*.nii ${input}/o*.nii
	
	echo "ftemp=`find ${input}/*3dt1*.nii`"
	ftemp=`find ${input}/*3dt1*.nii`
	echo "mv ${ftemp} ${input}/3dt1.nii"
	mv ${ftemp} ${input}/3dt1.nii
	
	echo "ftemp=`find ${input}/*run1*.nii`"
	ftemp=`find ${input}/*run1*.nii`
	echo "mv ${ftemp} ${input}/run1.nii"
	mv ${ftemp} ${input}/run1.nii
	
	echo "ftemp=`find ${input}/*run2*.nii`"
	ftemp=`find ${input}/*run2*.nii`
	echo "mv ${ftemp} ${input}/run2.nii"
	mv ${ftemp} ${input}/run2.nii
	
	echo "cp ${input}/3dt1.nii ${input}/orig.nii"
	cp ${input}/3dt1.nii ${input}/orig.nii
fi

TR=$(mri_info ${input}/run1.nii | grep TR | awk '{print $2}')
TR=$(echo "$TR/1000" | bc -l)
N=$(mri_info ${input}/run1.nii | grep dimensions | awk '{print $6}')

echo $TR
echo $N

#=========================================================================================
#                           PREPROCESSING WITH SPM8
#=========================================================================================
echo "Preprocessing step ..."
if [ ${doprep} -eq 1 ]
then
	
	# RUN 1
	
	if [ -d ${input}/spm ]
	then
		rm -rf ${input}/spm
	fi
	mkdir ${input}/spm
	if [ -d ${input}/spm1 ]
	then
		rm -rf ${input}/spm1
	fi
	
	echo "fslsplit ${input}/run1.nii ${input}/spm/epi_ -t"
	fslsplit ${input}/run1.nii ${input}/spm/epi_ -t
	for ((ind = 0; ind < ${remframe}; ind += 1))
	do
		filename=`ls -1 ${input}/spm/ | sed -ne "1p"`
		rm -f ${input}/spm/${filename}
	done
	
	echo "gunzip ${input}/spm/*.gz"
	gunzip ${input}/spm/*.gz
	
	echo "${input}/spm"
	cd ${input}/spm

	echo "FMRI_SurfPreprocessSPM8('${input}',${TR},${N},${refslice},${fwhmsurf},${fwhmvol},'epi2anat','${acquis}',${resamp});"
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	FMRI_SurfPreprocessSPM8('${input}',${TR},${N},${refslice},${fwhmsurf},${fwhmvol},'epi2anat','${acquis}',${resamp});
  
EOF

	echo "mv ${input}/spm ${input}/spm1"
	mv ${input}/spm ${input}/spm1
	
	if [ -f ${input}/run1_mask.nii ]
	then
		rm -f ${input}/run1_mask.nii
	fi
	filename=`ls -1 ${input}/spm1/mean* | sed -ne "1p"`
	echo "bet ${filename} ${input}/run1 -m -n -f 0.5"
	bet ${filename} ${input}/run1 -m -n -f 0.5
	gunzip ${input}/run1_mask.nii.gz
	
	if [ -f ${input}/run1_pre_vol.nii ]
	then
		rm -f ${input}/run1_pre_vol.nii
	fi
	echo "fslmerge -t ${input}/run1_pre_vol.nii ${input}/spm1/sv*"
	fslmerge -t ${input}/run1_pre_vol.nii ${input}/spm1/sv*
	echo "gunzip ${input}/run1_pre_vol.nii.gz"
	gunzip ${input}/run1_pre_vol.nii.gz
	
	
	# RUN 2
	
	if [ -d ${input}/spm ]
	then
		rm -rf ${input}/spm
	fi
	mkdir ${input}/spm
	if [ -d ${input}/spm2 ]
	then
		rm -rf ${input}/spm2
	fi
	
	echo "fslsplit ${input}/run2.nii ${input}/spm/epi_ -t"
	fslsplit ${input}/run2.nii ${input}/spm/epi_ -t
	for ((ind = 0; ind < ${remframe}; ind += 1))
	do
		filename=`ls -1 ${input}/spm/ | sed -ne "1p"`
		rm -f ${input}/spm/${filename}
	done
	
	echo "gunzip ${input}/spm/*.gz"
	gunzip ${input}/spm/*.gz
	
	echo "${input}/spm"
	cd ${input}/spm

	echo "FMRI_SurfPreprocessSPM8('${input}',${TR},${N},${refslice},${fwhmsurf},${fwhmvol},'epi2anat','${acquis}',${resamp});"
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	FMRI_SurfPreprocessSPM8('${input}',${TR},${N},${refslice},${fwhmsurf},${fwhmvol},'epi2anat','${acquis}',${resamp});
  
EOF

	echo "mv ${input}/spm ${input}/spm2"
	mv ${input}/spm ${input}/spm2
	
	if [ -f ${input}/run2_mask.nii ]
	then
		rm -f ${input}/run2_mask.nii
	fi
	filename=`ls -1 ${input}/spm2/mean* | sed -ne "1p"`
	echo "bet ${filename} ${input}/run2 -m -n -f 0.5"
	bet ${filename} ${input}/run2 -m -n -f 0.5
	gunzip ${input}/run2_mask.nii.gz
	
	if [ -f ${input}/run2_pre_vol.nii ]
	then
		rm -f ${input}/run2_pre_vol.nii
	fi
	echo "fslmerge -t ${input}/run2_pre_vol.nii ${input}/spm2/sv*"
	fslmerge -t ${input}/run2_pre_vol.nii ${input}/spm2/sv*
	echo "gunzip ${input}/run2_pre_vol.nii.gz"
	gunzip ${input}/run2_pre_vol.nii.gz
	
fi

#=========================================================================================
#                              ICA Decomposition (Run 1)
#=========================================================================================

outdir=ica1_${ncomps}_vol_sm

if [ ! -f ${input}/${outdir}/ica_map_1.nii -o ${doprep} -eq 1 ]
then
	## Delete out dir
	if [ -d ${input}/${outdir} ]
	then
		echo "rm -rf ${input}/${outdir}"
		rm -rf ${input}/${outdir}
	fi

	## Creates output folder
	if [ ! -d ${input}/${outdir} ]
	then
		echo "mkdir ${input}/${outdir}"
		mkdir ${input}/${outdir}
	fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	hdr  = spm_vol('${input}/run1_pre_vol.nii');
	vol  = spm_read_vols(hdr);
	dim  = size(vol);
	sica = FMRI_ICA(vol,'${input}/run1_mask.nii',${TR},${ncomps});

	save(fullfile('${input}','${outdir}','sica.mat'),'sica');

	mask = 1:size(sica.S,1);

	mepiFile = spm_select('FPList', '${input}/spm1', '^mean.*\.nii$');
	hdrmap   = spm_vol(mepiFile);
	ind      = find(sica.mask(:)>0);

	mapFiles = {};
	for j = 1:sica.nbcomp
		sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,0);
	
		map      = zeros(dim(1)*dim(2)*dim(3),1);
		map(ind) = sig_c;
		map      = reshape(map,dim(1),dim(2),dim(3));
	
		mapFiles{j} = fullfile('${input}','${outdir}',['ica_map_' num2str(j) '.nii']);
	 	hdrmap.fname = mapFiles{j};
		spm_write_vol(hdrmap,map);
	end

	mapFiles{end+1} = '${input}/run1_mask.nii';

	% Template Normalization
	spm('Defaults','fMRI');
	spm_jobman('initcfg'); % SPM8 only

	clear jobs
	jobs = {};

	a = which('spm_normalise');
	[path] = fileparts(a);
	    
	jobs{1}.spm.spatial.normalise.estwrite.subj.source       = {mepiFile};
	jobs{1}.spm.spatial.normalise.estwrite.subj.wtsrc        = '';
	jobs{1}.spm.spatial.normalise.estwrite.subj.resample     = mapFiles;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.template = {fullfile(path,'templates/EPI.nii')};
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.weight   = '';
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.smosrc   = 8;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.smoref   = 0;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.regtype  = 'mni';
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.cutoff   = 25;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.nits     = 16;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.reg      = 1;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.bb       = [-78 -112 -50
		                                                 78 76 85];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.vox      = [3 3 3];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.interp   = 3;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.wrap     = [0 0 0];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.prefix   = 'w';

	spm_jobman('run',jobs);

EOF
	
else
	echo "ICA decomposition: already done"
fi


#=========================================================================================
#                              ICA Decomposition (Run 2)
#=========================================================================================

outdir=ica2_${ncomps}_vol_sm

if [ ! -f ${input}/${outdir}/ica_map_1.nii -o ${doprep} -eq 1 ]
then
	## Delete out dir
	if [ -d ${input}/${outdir} ]
	then
		echo "rm -rf ${input}/${outdir}"
		rm -rf ${input}/${outdir}
	fi

	## Creates output folder
	if [ ! -d ${input}/${outdir} ]
	then
		echo "mkdir ${input}/${outdir}"
		mkdir ${input}/${outdir}
	fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	hdr  = spm_vol('${input}/run2_pre_vol.nii');
	vol  = spm_read_vols(hdr);
	dim  = size(vol);
	sica = FMRI_ICA(vol,'${input}/run2_mask.nii',${TR},${ncomps});

	save(fullfile('${input}','${outdir}','sica.mat'),'sica');

	mask = 1:size(sica.S,1);

	mepiFile = spm_select('FPList', '${input}/spm2', '^mean.*\.nii$');
	hdrmap   = spm_vol(mepiFile);
	ind      = find(sica.mask(:)>0);

	mapFiles = {};
	for j = 1:sica.nbcomp
		sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,0);
	
		map      = zeros(dim(1)*dim(2)*dim(3),1);
		map(ind) = sig_c;
		map      = reshape(map,dim(1),dim(2),dim(3));
	
		mapFiles{j} = fullfile('${input}','${outdir}',['ica_map_' num2str(j) '.nii']);
	 	hdrmap.fname = mapFiles{j};
		spm_write_vol(hdrmap,map);
	end

	mapFiles{end+1} = '${input}/run2_mask.nii';

	% Template Normalization
	spm('Defaults','fMRI');
	spm_jobman('initcfg'); % SPM8 only

	clear jobs
	jobs = {};

	a = which('spm_normalise');
	[path] = fileparts(a);
	    
	jobs{1}.spm.spatial.normalise.estwrite.subj.source       = {mepiFile};
	jobs{1}.spm.spatial.normalise.estwrite.subj.wtsrc        = '';
	jobs{1}.spm.spatial.normalise.estwrite.subj.resample     = mapFiles;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.template = {fullfile(path,'templates/EPI.nii')};
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.weight   = '';
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.smosrc   = 8;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.smoref   = 0;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.regtype  = 'mni';
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.cutoff   = 25;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.nits     = 16;
	jobs{1}.spm.spatial.normalise.estwrite.eoptions.reg      = 1;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.bb       = [-78 -112 -50
		                                                 78 76 85];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.vox      = [3 3 3];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.interp   = 3;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.wrap     = [0 0 0];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.prefix   = 'w';

	spm_jobman('run',jobs);

EOF
	
else
	echo "ICA decomposition: already done"
fi


#=========================================================================================
#                                     Processing
#=========================================================================================

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	Memory_SPMAnalysis2Runs(1,'${input}',fullfile('${input}',['${output}' '0' '_1']),fullfile('${input}',['${SUBJ}' '.mat']),${TR},'svra',${remframe},0);
	Memory_SPMAnalysis2Runs(2,'${input}',fullfile('${input}',['${output}' '0' '_2']),fullfile('${input}',['${SUBJ}' '.mat']),${TR},'svra',${remframe},0);
	Memory_SPMAnalysis2Runs(1,'${input}',fullfile('${input}',['${output}' '1' '_1']),fullfile('${input}',['${SUBJ}' '.mat']),${TR},'svra',${remframe},1);
	Memory_SPMAnalysis2Runs(2,'${input}',fullfile('${input}',['${output}' '1' '_2']),fullfile('${input}',['${SUBJ}' '.mat']),${TR},'svra',${remframe},1);
	
EOF

