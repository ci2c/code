#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_ActivityDetection2.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -rmframe <value>  -noprep  -noseg  -nofilt  -nodetrend  -nosmooth  -noica  -lp <value>  -hp <value>  -N <value> ]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -ospm                        : output spm directory "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -rmframe                     : frame for removal "
	echo "  -noprep                      : no preprocessing step "
	echo "  -noseg                       : no segmentation step "
	echo "  -nofilt                      : no temporal filtering step "
	echo "  -nodetrend                   : no detrending step "
	echo "  -nosmooth                    : no smoothing step "
	echo "  -noica                       : no ICA step "
	echo "  -lp                          : low-pass filtering "
	echo "  -hp                          : high-pass filtering "
	echo "  -N                           : number of components "
	echo ""
	echo "Usage: FMRI_ActivityDetection2.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -rmframe <value>  -noprep  -noseg  -nofilt  -nodetrend  -nosmooth  -noica  -lp <value>  -hp <value>  -N <value> ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmvol=6
refslice=1
acquis=no
remframe=5
doprep=1
#highpass=0.005
#lowpass=0.1
highpass=0.01   # Apply a high-pass filter at cut-off frequency 0.01Hz (slow time drifts)
lowpass=Inf     # Do not apply low-pass filter. Low-pass filter induce a big loss in degrees of freedom without sgnificantly improving the SNR.
doseg=1
dofilter=1
dodetrend=1
dosmooth=1
doica=1
ncomps=40

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ActivityDetection2.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -rmframe <value>  -noprep  -noseg  -nofilt  -nodetrend  -noica  -nosmooth  -lp <value>  -hp <value>  -N <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -ospm                        : output spm directory "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -rmframe                     : frame for removal "
		echo "  -noprep                      : no preprocessing step "
		echo "  -noseg                       : no segmentation step "
		echo "  -nofilt                      : no temporal filtering step "
		echo "  -nodetrend                   : no detrending step "
		echo "  -nosmooth                    : no smoothing step "
		echo "  -noica                       : no ICA step "
		echo "  -lp                          : low-pass filtering "
		echo "  -hp                          : high-pass filtering "
		echo "  -N                           : number of components "
		echo ""
		echo "Usage: FMRI_ActivityDetection2.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -rmframe <value>  -noprep  -noseg  -nofilt  -nodetrend  -noica  -nosmooth  -lp <value>  -hp <value>  -N <value> ]"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SD=\${$index}
		echo "SD : $SD"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subj : $SUBJ"
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "fMRI file : $epi"
		;;
	-ospm)
		index=$[$index+1]
		eval spmout=\${$index}
		echo "output spm directory : $spmout"
		;;
	-fwhmvol)
		index=$[$index+1]
		eval fwhmvol=\${$index}
		echo "fwhm volume : ${fwhmvol}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-noprep)
		doprep=0
		echo "doprep = ${doprep}"
		echo "No preprocessing step"
		;;
	-noseg)
		doseg=0
		echo "doseg = ${doseg}"
		echo "No preprocessing step"
		;;
	-nofilt)
		dofilter=0
		echo "dofilter = ${dofilter}"
		echo "No temporal filtering step"
		;;
	-nodetrend)
		dodetrend=0
		echo "dodetrend = ${dodetrend}"
		echo "No detrending step"
		;;
	-nosmooth)
		dosmooth=0
		echo "dosmooth = ${dosmooth}"
		echo "No smoothing step"
		;;
	-noica)
		doica=0
		echo "doica = ${doica}"
		echo "No ICA step"
		;;
	-lp)
		index=$[$index+1]
		eval lowpass=\${$index}
		echo "low-pass filtering : ${lowpass}"
		;;
	-hp)
		index=$[$index+1]
		eval highpass=\${$index}
		echo "high-pass filtering : ${highpass}"
		;;
	-N)
		index=$[$index+1]
		eval ncomps=\${$index}
		echo "number of components : ${ncomps}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ActivityDetection2.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -rmframe <value>  -noprep  -noseg  -nofilt  -nodetrend  -noica  -nosmooth  -lp <value>  -hp <value>  -N <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -ospm                        : output spm directory "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -rmframe                     : frame for removal "
		echo "  -noprep                      : no preprocessing step "
		echo "  -noseg                       : no segmentation step "
		echo "  -nofilt                      : no temporal filtering step "
		echo "  -nodetrend                   : no detrending step "
		echo "  -nosmooth                    : no smoothing step "
		echo "  -noica                       : no ICA step "
		echo "  -lp                          : low-pass filtering "
		echo "  -hp                          : high-pass filtering "
		echo "  -N                           : number of components "
		echo ""
		echo "Usage: FMRI_ActivityDetection2.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -rmframe <value>  -noprep  -noseg  -nofilt  -nodetrend  -noica  -nosmooth  -lp <value>  -hp <value>  -N <value> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SD} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

if [ -z ${epi} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${spmout} ]
then
	 echo "-ospm argument mandatory"
	 exit 1
fi


DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

if [ ! -d ${DIR}/${spmout} ]
then
	echo "mkdir ${DIR}/${spmout}"
	mkdir ${DIR}/${spmout}
fi

if [ ! -f ${DIR}/${spmout}/orig.nii ]
then
	echo "mri_convert ${DIR}/mri/orig.mgz ${DIR}/${spmout}/orig.nii"
	mri_convert ${DIR}/mri/orig.mgz ${DIR}/${spmout}/orig.nii
fi

if [ ! -f ${DIR}/${spmout}/aparc.nii ]
then
	echo "mri_convert ${DIR}/mri/aparc.a2009s+aseg.mgz ${DIR}/${spmout}/aparc.nii"
	mri_convert ${DIR}/mri/aparc.a2009s+aseg.mgz ${DIR}/${spmout}/aparc.nii
fi

if [ ! -f ${DIR}/${spmout}/ribbon.nii ]
then
	echo "mri_convert ${DIR}/mri/ribbon.mgz ${DIR}/${spmout}/ribbon.nii"
	mri_convert ${DIR}/mri/ribbon.mgz ${DIR}/${spmout}/ribbon.nii
fi

LOI=/home/renaud/SVN/scripts/renaud/aparc2009LOIConn.txt

TR=$(mri_info ${epi} | grep TR | awk '{print $2}')
TR=$(echo "$TR/1000" | bc -l)
N=$(mri_info ${epi} | grep dimensions | awk '{print $6}')

echo $TR
echo $N


#=========================================================================================
#                           PREPROCESSING WITH SPM8
#=========================================================================================
echo "Preprocessing step ..."
if [ ${doprep} -eq 1 ]
then
 
	if [ ! -d ${DIR}/${spmout}/spm ]
	then
		mkdir ${DIR}/${spmout}/spm
	else
		rm -rf ${DIR}/${spmout}/spm/*
	fi

	echo "fslsplit ${epi} ${DIR}/${spmout}/spm/epi_ -t"
	fslsplit ${epi} ${DIR}/${spmout}/spm/epi_ -t
	for ((ind = 0; ind < ${remframe}; ind += 1))
	do
		filename=`ls -1 ${DIR}/${spmout}/spm/ | sed -ne "1p"`
		rm -f ${DIR}/${spmout}/spm/${filename}
	done

	echo "gunzip ${DIR}/${spmout}/spm/*.gz"
	gunzip ${DIR}/${spmout}/spm/*.gz

	echo "${DIR}/${spmout}/spm"
	cd ${DIR}/${spmout}/spm

	echo "FMRI_PreprocessSPM8ForConn('${DIR}/${spmout}',${TR},${N},${refslice},${fwhmvol},'epi2anat','${acquis}');"
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	FMRI_PreprocessSPM8ForConn2('${DIR}/${spmout}',${TR},${N},${refslice},${fwhmvol},'${acquis}');

EOF

	echo "fslmerge -t ${DIR}/${spmout}/repi.nii ${DIR}/${spmout}/spm/repi*"
	fslmerge -t ${DIR}/${spmout}/repi.nii ${DIR}/${spmout}/spm/repi*
	echo "fslmerge -t ${DIR}/${spmout}/srepi.nii ${DIR}/${spmout}/spm/sr*"
	fslmerge -t ${DIR}/${spmout}/srepi.nii ${DIR}/${spmout}/spm/sr*
	
	echo "fslmerge -t ${DIR}/${spmout}/wrepi.nii ${DIR}/${spmout}/spm/wrepi*"
	fslmerge -t ${DIR}/${spmout}/wrepi.nii ${DIR}/${spmout}/spm/wrepi*
	echo "fslmerge -t ${DIR}/${spmout}/srepi.nii ${DIR}/${spmout}/spm/swr*"
	fslmerge -t ${DIR}/${spmout}/swrepi.nii ${DIR}/${spmout}/spm/swr*

	filename=`ls -1 ${DIR}/${spmout}/spm/mean* | sed -ne "1p"`
	echo "bet ${filename} ${DIR}/${spmout}/epi -m -n -f 0.5"
	bet ${filename} ${DIR}/${spmout}/epi -m -n -f 0.5
	
	if [ ! -f ${DIR}/${spmout}/orig_epi.nii ]
	then

		meanFile=`ls -1 ${DIR}/${spmout}/spm/mean* | sed -ne "1p"`

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
	
		spm('Defaults','fMRI');
		spm_jobman('initcfg'); % SPM8 only

		clear matlabbatch;
		matlabbatch{1}.spm.spatial.coreg.write.ref = {'${meanFile}'};
		matlabbatch{1}.spm.spatial.coreg.write.source = {
				                                 '${DIR}/${spmout}/aparc.nii,1'
				                                 '${DIR}/${spmout}/orig.nii,1'
				                                 };
		matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
		matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
		matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
		matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
	
		spm_jobman('run',matlabbatch);
	
EOF

		if [ ! -f ${DIR}/${spmout}/atlas_epi.nii ]
		then
			"mri_extract_label ${DIR}/${spmout}/waparc.nii `cat /home/renaud/SVN/scripts/renaud/aparc2009LOIConnInd.txt` ${DIR}/${spmout}/atlas_epi.nii"
			mri_extract_label ${DIR}/${spmout}/waparc.nii `cat /home/renaud/SVN/scripts/renaud/aparc2009LOIConnInd.txt` ${DIR}/${spmout}/atlas_epi.nii
		fi

	fi

	if [ ! -f ${DIR}/${spmout}/wrepi.nii.gz ]
	then
		echo "no preprocessing epi file"
		exit 1
	fi

	cp /home/global/matlab_toolbox/nbw_0.1/nbw_main_0.1/aal/struct.* ${DIR}/${spmout}/
	cp /home/global/matlab_toolbox/nbw_0.1/nbw_main_0.1/aal/aal.* ${DIR}/${spmout}/
	
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		hdr_tmap = spm_vol(fullfile('${DIR}/${spmout}/spm','wrepi_0005.nii'));
		
		hdr_ch2 = spm_vol(fullfile('${DIR}/${spmout}','struct.img'));
		PP = strvcat(hdr_tmap.fname,hdr_ch2.fname);
		flag_reslice.interp = 1;
		flag_reslice.wrap   = [0 0 0];
		flag_reslice.mask   = 0;
		flag_reslice.mean   = 0;
		flag_reslice.which  = 1;
		warning('off')
		spm_reslice(PP,flag_reslice);
		
		hdr_aal = spm_vol(fullfile('${DIR}/${spmout}','aal.img'));
		PP = strvcat(hdr_tmap.fname,hdr_aal.fname);
		flag_reslice.interp = 1;
		flag_reslice.wrap   = [0 0 0];
		flag_reslice.mask   = 0;
		flag_reslice.mean   = 0;
		flag_reslice.which  = 1;
		warning('off')
		spm_reslice(PP,flag_reslice);

EOF
fi


	
#=======================================================================================
#                       Segmentation WM / GM / CSF
#=======================================================================================
echo "Segmentation step ..."
if [ ${doseg} -eq 1 ]
then

# WM and CSF
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

T1_NewSegment('${DIR}/${spmout}/orig.nii');

EOF

echo "binarize segmentation"
mri_binarize --i ${DIR}/${spmout}/c1orig.nii --min 0.9 --o ${DIR}/${spmout}/bc1orig.nii
mri_binarize --i ${DIR}/${spmout}/c2orig.nii --min 0.9 --o ${DIR}/${spmout}/bc2orig.nii
mri_binarize --i ${DIR}/${spmout}/c3orig.nii --min 0.9 --o ${DIR}/${spmout}/bc3orig.nii

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

matlabbatch{1}.spm.spatial.coreg.write.ref = {'${DIR}/${spmout}/orig_epi.nii,1'};
matlabbatch{1}.spm.spatial.coreg.write.source = {
                                                 '${DIR}/${spmout}/bc1orig.nii,1'
                                                 '${DIR}/${spmout}/bc2orig.nii,1'
                                                 '${DIR}/${spmout}/bc3orig.nii,1'
                                                 };
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask   = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);

EOF

gunzip ${DIR}/${spmout}/epi_mask.nii.gz

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

spm('Defaults','fMRI');
spm_jobman('initcfg'); % SPM8 only

matlabbatch{1}.spm.spatial.normalise.write.subj.matname  = {'${DIR}/${spmout}/orig_sn.mat'};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {
                                                            '${DIR}/${spmout}/bc1orig.nii,1'
                                                            '${DIR}/${spmout}/bc2orig.nii,1'
                                                            '${DIR}/${spmout}/bc3orig.nii,1'
                                                            '${DIR}/${spmout}/epi_mask.nii,1'
                                                            };
matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
matlabbatch{1}.spm.spatial.normalise.write.roptions.bb       = [-78 -112 -50; 78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.roptions.vox      = [3 3 3];
matlabbatch{1}.spm.spatial.normalise.write.roptions.interp   = 0;
matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap     = [0 0 0];
matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix   = 'w';

spm_jobman('run',matlabbatch);

EOF

	fslmaths ${DIR}/${spmout}/raal.img -mul ${DIR}/${spmout}/wepi_mask.nii ${DIR}/${spmout}/raal_mask.nii
fi


#=======================================================================================
#                             Temporal Filtering
#=======================================================================================
echo "Filtering step ..."
if [ ${dofilter} -eq 1 ]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

opt.hp = ${highpass};
opt.lp = ${lowpass};
opt.tr = ${TR};
opt.folder_out = '${DIR}/${spmout}';

files_out.filtered_data = '${DIR}/${spmout}/fwrepi.nii.gz';

[files_in,files_out,opt] = niak_brick_time_filter('${DIR}/${spmout}/wrepi.nii.gz',files_out,opt);

EOF

fi


#=======================================================================================
#                                 Detrending
#=======================================================================================
echo "Detrending step ..."
if [ ${dodetrend} -eq 1 ]
then

motion=$(ls ${DIR}/${spmout}/spm/rp*)

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

infile   = '${DIR}/${spmout}/fwrepi.nii.gz';
outfile  = '${DIR}/${spmout}/dfwrepi.nii.gz';
maskfile = '${DIR}/${spmout}/wepi_mask.nii';
wmfile   = '${DIR}/${spmout}/wbc2orig.nii';
csffile  = '${DIR}/${spmout}/wbc2orig.nii';
X        = FMRI_Detrending(infile,outfile,maskfile,wmfile,csffile,'${motion}',${TR});
save('${DIR}/${spmout}/trend.mat','X');

EOF

fi


#=======================================================================================
#                                   Smoothing
#=======================================================================================
echo "Smoothing step ..."
if [ ${dosmooth} -eq 1 ]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

infile   = '${DIR}/${spmout}/dfwrepi.nii.gz';
outfile  = '${DIR}/${spmout}/sdfwrepi.nii.gz';
opt.fwhm = [6 6 6];
[files_in,files_out,opt] = niak_brick_smooth_vol(infile,outfile,opt);

infile   = '${DIR}/${spmout}/fwrepi.nii.gz';
outfile  = '${DIR}/${spmout}/sfwrepi.nii.gz';
opt.fwhm = [6 6 6];
[files_in,files_out,opt] = niak_brick_smooth_vol(infile,outfile,opt);

EOF

fi


#=========================================================================================
#                              ICA Decomposition
#=========================================================================================

outdir=ica_${ncomps}_vol_sm

if [ ${doica} -eq 1 ]
then
	## Delete out dir
	if [ -d ${DIR}/${spmout}/${outdir} ]
	then
		echo "rm -rf ${DIR}/${spmout}/${outdir}"
		rm -rf ${DIR}/${spmout}/${outdir}
	fi

	## Creates output folder
	echo "mkdir ${DIR}/${spmout}/${outdir}"
	mkdir ${DIR}/${spmout}/${outdir}
	
	cp ${DIR}/${spmout}/epi_mask.nii ${DIR}/${spmout}/ima_mask.nii

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	[hdr,vol] = niak_read_vol('${DIR}/${spmout}/srepi.nii.gz');
	dim = size(vol);
	[hmask,mask] = niak_read_vol('${DIR}/${spmout}/epi_mask.nii');
	
	tseries = reshape(vol,dim(1)*dim(2)*dim(3),dim(4));
	ind     = find(mask(:)>0);
	tseries = tseries(ind,:);
	tseries = tseries';
	
	%% DETRENDING

	ord_detr = 2;
	fprintf('Correction of %ith order polynomial trends \n',ord_detr)
	tseries = detrend_array(tseries,ord_detr);

	%% NORMALISE

	type_norm = 0;
	fprintf('Correction to zero mean and unit temporal variance \n');
	[tseries,M,Varr] = st_normalise(tseries,type_norm);
	
	%% SICA

	% sica computation
	optsica.algo          = 'Infomax';
	optsica.param_nb_comp = ${ncomps};
	optsica.type_nb_comp  = 0;

	res_ica = st_do_sica(tseries,optsica);

	sica.S       = res_ica.composantes;
	res_ica      = rmfield(res_ica,'composantes');
	sica.A       = res_ica.poids;
	res_ica      = rmfield(res_ica,'poids');
	sica.nbcomp  = res_ica.nbcomp;
	sica.contrib = res_ica.contrib;
	sica.mask    = mask;
	if isfield(res_ica,'residus')
	    sica.residus = res_ica.residus;
	end
	if isfield(res_ica,'prior')
	    sica.prior = res_ica.prior;
	end
	clear res_ica
	sica.TR = ${TR};

	save(fullfile('${DIR}/${spmout}','${outdir}','sica.mat'),'sica');

	mask = 1:size(sica.S,1);

	mepiFile = spm_select('FPList', '${DIR}/${spmout}/spm', '^mean.*\.nii$');
	[hdrmap,mm] = niak_read_vol(mepiFile);
	ind      = find(sica.mask(:)>0);

	mapFiles = {};
	for j = 1:sica.nbcomp
		sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,0);
	
		map      = zeros(dim(1)*dim(2)*dim(3),1);
		map(ind) = sig_c;
		map      = reshape(map,dim(1),dim(2),dim(3));
	
		mapFiles{j} = fullfile('${DIR}/${spmout}','${outdir}',['ica_map_' num2str(j) '.nii']);
		hdrmap.file_name = mapFiles{j};
		niak_write_vol(hdrmap,map);
	end

	mapFiles{end+1} = '${DIR}/${spmout}/ima_mask.nii';

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
	jobs{1}.spm.spatial.normalise.estwrite.roptions.vox      = [2 2 2];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.interp   = 3;
	jobs{1}.spm.spatial.normalise.estwrite.roptions.wrap     = [0 0 0];
	jobs{1}.spm.spatial.normalise.estwrite.roptions.prefix   = 'w';

	spm_jobman('run',jobs);

EOF

	rm -f ${DIR}/${spmout}/ima_mask.nii
	
else
	echo "ICA decomposition: already done"
fi


