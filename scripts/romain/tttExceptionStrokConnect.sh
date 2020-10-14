#!/bin/bash
HOME="/home/romain";
DIR="/NAS/dumbo/protocoles/strokconnect/FS53/patients/NOYON^THADEE_I_CERE_2015-07-03/";
#SUBJ="patients/DIAS^ANTHONY_I_CERE_2015-10-20"
#DIR="/NAS/dumbo/protocoles/strokconnect/FS53/patients/GOSSEIN^JEAN_PIERRE_I_CERE_2014-08-13/";
outdir="resting_state_homeMade/";
FREESURFER_HOME="/home/global/freesurfer5.3/"
SUBJECTS_DIR="/NAS/dumbo/protocoles/strokconnect/FS53/"

#c Regress pas de segmentation donc pas de rvent.nii etc...
mkdir ${DIR}/${outdir}
cp ${DIR}/${outdir}/run01/arepi.nii ${DIR}/${outdir}/run01/arepi_sc_al.nii

/usr/local/matlab/bin/matlab -nodisplay <<EOF

        % Load Matlab Path
        cd ${HOME}
        p = pathdef;
        addpath(p);

        files_in  = '${DIR}/${outdir}/run01/arepi_sc_al.nii';
        [p,n,e]   = fileparts(files_in);
        outfolder = '${DIR}/${outdir}';

        files_out.dc_high       = fullfile(outfolder,'run01',[n '_dc_high.mat']);
        files_out.dc_low        = fullfile(outfolder,'run01',[n '_dc_low.mat']);
        files_out.filtered_data = 'gb_niak_omitted';
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outfolder '/run01/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',2.4,'hp',0.01,'lp',Inf);
        niak_brick_time_filter(files_in,files_out,opt);
        clear files_in files_out opt;

        files_in.fmri         = '${DIR}/${outdir}/run01/arepi_sc.nii';
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

        opt = struct('flag_compcor',0,'compcor',struct(),'nb_vol_min',40,'flag_scrubbing',1,'thre_fd',0.8,'flag_slow',1,...
                         'flag_high',0,'folder_out',[outfolder '/run01/'],'flag_verbose',1,'flag_motion_params',1,'flag_wm',1,...
                         'flag_vent',1,'flag_gsc',0,'flag_pca_motion',1,'flag_test',0,'pct_var_explained',0.95);

        FMRI_RegressConfoundsByNiak(files_in,files_out,opt);

        clear files_in files_out opt;
EOF

#f DoFiltering
/usr/local/matlab/bin/matlab -nodisplay <<EOF

        % Load Matlab Path
        cd ${HOME}
        p = pathdef;
        addpath(p);
%RV files_in = '${DIR}/${outdir}/run01/carepi_sc.nii';
        files_in = '${DIR}/${outdir}/run01/carepi_sc_al.nii';
        [p,n,e]  = fileparts(files_in);
        outdir   = '${DIR}/${outdir}/run01';

        files_out.dc_high       = 'gb_niak_omitted';
        files_out.dc_low        = 'gb_niak_omitted';
        files_out.filtered_data = fullfile(outdir,['f' n e]);
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',2.4,'hp',0.008,'lp',0.1);
        niak_brick_time_filter(files_in,files_out,opt);
        clear files_in files_out opt;

EOF

#AL alignement mais ne fonctionne pas car aps de segmentaion doncpas de rwhite surf..
bbregister --s ${SUBJ} --init-fsl --6 --bold --mov ${DIR}/${outdir}/run01/mean_arepi.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --init-reg-out ${DIR}/${outdir}/run01/init.register.dof6.dat --o ${DIR}/${outdir}/run01/mean_arepi_al.nii
tkregister2 --noedit --reg ${DIR}/${outdir}/run01/register.dof6.dat --mov ${DIR}/${outdir}/run01/mean_arepi.nii --targ ${DIR}/${outdir}/T1_las.nii --fslregout ${DIR}/${outdir}/fMRI2str.mat
mri_vol2vol --mov ${DIR}/${outdir}/run01/farepi_sc.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/farepi_sc_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg



        # MNI Normalization
/usr/local/matlab/bin/matlab -nodisplay <<EOF

cd ${HOME}
        p = pathdef;
        addpath(p);

        t = which('spm');
        t = dirname(t);

        spm_get_defaults;
        spm_jobman('initcfg');
        matlabbatch = {};

          matlabbatch{end+1}.spm.spatial.normalise.est.subj.vol        = cellstr('${DIR}/${outdir}/T1_las.nii');
          matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasreg  = 0.0001;
          matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
          matlabbatch{end}.spm.spatial.normalise.est.eoptions.tpm      = {[t '/tpm/TPM.nii']};
          matlabbatch{end}.spm.spatial.normalise.est.eoptions.affreg   = 'mni';
          matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
          matlabbatch{end}.spm.spatial.normalise.est.eoptions.fwhm     = 0;
          matlabbatch{end}.spm.spatial.normalise.est.eoptions.samp     = 3;

        spm_jobman('run',matlabbatch);

        [tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/fcarepi_sc_al.nii'); %arepi_al.nii');

        clear matlabbatch
        matlabbatch = {};

                % Load Matlab Path
                cd ${HOME}
                p = pathdef;
                addpath(p);

                spm_get_defaults;
                spm_jobman('initcfg');

                [tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/farepi_sc.nii');

                clear matlabbatch
                matlabbatch = {};
                  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1_las.nii');
                  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
                  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
                  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
                  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;

                spm_jobman('run',matlabbatch);

EOF
