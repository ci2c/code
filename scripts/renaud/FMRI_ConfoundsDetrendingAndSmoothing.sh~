#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_ConfoundsDetrendingAndSmoothing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmvol <value>  -tr <value>  -doCompCor  -doFilt  -doSPMNorm  -oldNorm ] "
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -o                           : output path "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -tr                          : TR value "
	echo "  -doCompCor                   : Do CompCor correction "
	echo "  -doFilt                      : Do bandpass filtering (hp and lp values) "
	echo "  -doSPMNorm                   : Non-linear registration of T1 in MNI space (SPM function 'normalize') "
	echo "  -oldNorm                     : Do SPM8 Normalization (else SPM12) "
	echo ""
	echo "Usage: FMRI_ConfoundsDetrendingAndSmoothing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmvol <value>  -tr <value>  -doCompCor  -doFilt  -doSPMNorm  -oldNorm ] "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmvol=6
TRtmp=0
DoCompCor=0
DoFiltering=0
highpass=-1
lowpass=-1
DoSPMNorm=0
oldNorm=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ConfoundsDetrendingAndSmoothing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmvol <value>  -tr <value>  -doCompCor  -doFilt  -doSPMNorm  -oldNorm ] "
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -tr                          : TR value "
		echo "  -doCompCor                   : Do CompCor correction "
		echo "  -doFilt                      : Do bandpass filtering (hp and lp values) "
		echo "  -doSPMNorm                   : Non-linear registration of T1 in MNI space (SPM function 'normalize') "
		echo "  -oldNorm                     : Do SPM8 Normalization (else SPM12) "
		echo ""
		echo "Usage: FMRI_ConfoundsDetrendingAndSmoothing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmvol <value>  -tr <value>  -doCompCor  -doFilt  -doSPMNorm  -oldNorm ] "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "SUBJECTS DIR : $SUBJECTS_DIR"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subject's name : $SUBJ"
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
	-fwhmvol)
		index=$[$index+1]
		eval fwhmvol=\${$index}
		echo "fwhm volume : ${fwhmvol}"
		;;
	-tr)
		index=$[$index+1]
		eval TRtmp=\${$index}
		echo "TR value : ${TRtmp}"
		;;
	-doCompCor)
		DoCompCor=1
		echo "Do CompCorr correction"
		;;
	-doFilt)
		tmp=`expr $index + 1`
		eval highpass=\${$tmp}
		index=$[$index+1]
		tmp=`expr $index + 1`
		eval lowpass=\${$tmp}
		index=$[$index+1]
		echo "  |-------> Bandpass filtering : $highpass $lowpass"
		DoFiltering=1
		;;
	-doSPMNorm)
		DoSPMNorm=1
		echo "Non-linear registration of T1 in MNI space (SPM function 'normalize')"
		;;
	-oldNorm)
		oldNorm=1
		echo "Do SPM8 Normalization"
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SUBJECTS_DIR} ]
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

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi


#=========================================
#            Initialization...
#=========================================

# TR value
if [ ${TRtmp} -eq 0 ]
then
	TR=$(mri_info ${epi} | grep TR | awk '{print $2}')
	TR=$(echo "$TR/1000" | bc -l)
else
	TR=${TRtmp}
fi

# Number of slices
nslices=$(mri_info ${epi} | grep dimensions | awk '{print $6}')

echo $TR
echo $nslices

DIR=${SUBJECTS_DIR}/${SUBJ}


#=========================================
#              Processing...
#=========================================

epipre=${epi}

if [ $DoCompCor -eq 1 ]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

        files_in  = '${epipre}';
	[p,n,e]   = fileparts(files_in);
	outfolder = '${DIR}/${outdir}';

        files_out.dc_high       = fullfile(outfolder,'run01',[n '_dc_high.mat']); 
        files_out.dc_low        = fullfile(outfolder,'run01',[n '_dc_low.mat']);
        files_out.filtered_data = 'gb_niak_omitted';
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outfolder '/run01/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',${TR},'hp',0.01,'lp',Inf);
        niak_brick_time_filter(files_in,files_out,opt);
        clear files_in files_out opt;

        files_in.fmri         = '${epipre}';
        files_in.dc_low       = fullfile(outfolder,'run01',[n '_dc_low.mat']);
        files_in.dc_high      = fullfile(outfolder,'run01',[n '_dc_high.mat']); 
        files_in.custom_param = 'gb_niak_omitted';
        files_in.motion_param = fullfile(outfolder,'run01','mcprextreg');
        files_in.mask_brain   = fullfile(outfolder,'masks','brain.nii');
        files_in.mask_vent    = fullfile(outfolder,'run01','rvent.nii');
        files_in.mask_wm      = fullfile(outfolder,'run01','rwm.nii');

        files_out.scrubbing       = 'gb_niak_omitted';
        files_out.compcor_mask    = fullfile(outfolder,'run01',['compcor_mask_' n '.mat']);
        files_out.confounds       = fullfile(outfolder,'run01',['confounds_gs_' n '_cor' '.mat']);
        files_out.filtered_data   = fullfile(outfolder,'run01',['c' n e]);
        files_out.qc_compcor      = fullfile(outfolder,'run01',[n '_qc_compcor' e]);
        files_out.qc_slow_drift   = fullfile(outfolder,'run01',[n '_qc_slow_drift' e]);
        files_out.qc_high         = 'gb_niak_omitted';
        files_out.qc_wm           = fullfile(outfolder,'run01',[n '_qc_wm' e]);
        files_out.qc_vent         = fullfile(outfolder,'run01',[n '_qc_vent' e]);
        files_out.qc_motion       = fullfile(outfolder,'run01',[n '_qc_motion' e]);
        files_out.qc_custom_param = 'gb_niak_omitted';
        files_out.qc_gse          = fullfile(outfolder,'run01',[n '_qc_gse' e]);

        opt = struct('flag_compcor',1,'compcor',struct(),'nb_vol_min',40,'flag_scrubbing',0,'thre_fd',0.5,'flag_slow',1,...
                     'flag_high',0,'folder_out',[outfolder '/run01/'],'flag_verbose',1,'flag_motion_params',1,'flag_wm',0,...
                     'flag_vent',0,'flag_gsc',0,'flag_pca_motion',1,'flag_test',0,'pct_var_explained',0.95);

        %niak_brick_regress_confounds(files_in,files_out,opt);

        FMRI_RegressConfoundsByNiak(files_in,files_out,opt);

        clear files_in files_out opt;

EOF

	epipre=${DIR}/${outdir}/run01/carepi.nii
	
	# smoothing
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};
	[tempa,tempb,tempc] = fileparts('${epipre}');

	matlabbatch{end+1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	matlabbatch{end}.spm.spatial.smooth.fwhm   = [${fwhmvol} ${fwhmvol} ${fwhmvol}];
	matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
	matlabbatch{end}.spm.spatial.smooth.im     = 0;
	matlabbatch{end}.spm.spatial.smooth.prefix = ['s' num2str(${fwhmvol})];
	
	spm_jobman('run',matlabbatch);
	
EOF

	# MNI Normalization
	if [ $DoSPMNorm -eq 1 ]
	then
		mri_vol2vol --mov ${DIR}/${outdir}/run01/carepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/carepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
		mri_vol2vol --mov ${DIR}/${outdir}/run01/s${fwhmvol}carepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/s${fwhmvol}carepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/s${fwhmvol}carepi_al.nii');

		spm_get_defaults;
		spm_jobman('initcfg');
		
		clear matlabbatch 
		matlabbatch = {};
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		spm_jobman('run',matlabbatch);

		[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/carepi_al.nii');

		clear matlabbatch 
		matlabbatch = {};
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		spm_jobman('run',matlabbatch);
	

EOF

	fi

fi


if [ $DoFiltering -eq 1 ]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	files_in = '${epipre}';
	[p,n,e]  = fileparts(files_in);
	outdir   = '${DIR}/${outdir}/run01';

        files_out.dc_high       = 'gb_niak_omitted'; 
        files_out.dc_low        = 'gb_niak_omitted';
        files_out.filtered_data = fullfile(outdir,['f' n e]);
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',${TR},'hp',${highpass},'lp',${lowpass});
        niak_brick_time_filter(files_in,files_out,opt);
        clear files_in files_out opt;

EOF

	epipre=${DIR}/${outdir}/run01/fcarepi.nii
	# smoothing
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};
	[tempa,tempb,tempc] = fileparts('${epipre}');

	matlabbatch{end+1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	matlabbatch{end}.spm.spatial.smooth.fwhm   = [${fwhmvol} ${fwhmvol} ${fwhmvol}];
	matlabbatch{end}.spm.spatial.smooth.dtype  = 0;
	matlabbatch{end}.spm.spatial.smooth.im     = 0;
	matlabbatch{end}.spm.spatial.smooth.prefix = ['s' num2str(${fwhmvol})];
	
	spm_jobman('run',matlabbatch);
	
EOF
	
	# MNI Normalization
	if [ $DoSPMNorm -eq 1 ]
	then

		mri_vol2vol --mov ${DIR}/${outdir}/run01/fcarepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/fcarepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
		mri_vol2vol --mov ${DIR}/${outdir}/run01/s${fwhmvol}fcarepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/s${fwhmvol}fcarepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/s${fwhmvol}fcarepi_al.nii');
		
		spm_get_defaults;
		spm_jobman('initcfg');
		
		clear matlabbatch 
		matlabbatch = {};
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		spm_jobman('run',matlabbatch);

		[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/fcarepi_al.nii');

		clear matlabbatch 
		matlabbatch = {};
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		spm_jobman('run',matlabbatch);

EOF

	fi

fi