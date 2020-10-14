function ASL_PreprocessingBySPM12(structFile,aslFile,steps,opt)

nsubjects = length(structFile);

for nsub=1:length(structFile),if ~iscell(structFile{nsub}),structFile{nsub}=cellstr(structFile{nsub});end;end

spm_get_defaults;

spm_jobman('initcfg');

for subj = 1:nsubjects
    
    disp(['********************************']);
    disp(['Preparing subject ']);
    disp(['********************************']);

    tempvol = spm_vol(aslFile{subj}{1}{1});
    nslices = tempvol.dim(3);

    matlabbatch={};    
    prefix={[],[],[]};

    % Realign Functional
    if ~isempty(strmatch('realignment',steps,'exact')),
        matlabbatch{end+1}.spm.spatial.realign.estwrite.data         = aslFile{subj};
        matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm   = 1;
        matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which = [2,1];
        prefix{1} = ['r',prefix{1}];
    end

    % Coregister ASL
    if ~isempty(strmatch('coregistration',steps,'exact')),
        matlabbatch{end+1}.spm.spatial.coreg.estimate.ref  = structFile{subj};
        matlabbatch{end}.spm.spatial.coreg.estimate.source = conn_prepend('mean',cellstr(aslFile{subj}{1}{1}));
        temp = conn_prepend(prefix{1},aslFile{subj});
        matlabbatch{end}.spm.spatial.coreg.estimate.other  = cat(1,temp{:});
    end
    
    % Smooth ASL (native + surface)
    if ~isempty(strmatch('smoothing',steps,'exact')),
        temp = conn_prepend(prefix{1},aslFile{subj});
        matlabbatch{end+1}.spm.spatial.smooth.data = cat(1,temp{:});
        matlabbatch{end}.spm.spatial.smooth.fwhm   = opt.fwhmsurf*[1 1 1];
        matlabbatch{end}.spm.spatial.smooth.prefix = 'ss';
    end
    
    % Smooth ASL (native + volume)
    if ~isempty(strmatch('smoothing',steps,'exact')),
        temp = conn_prepend(prefix{1},aslFile{subj});
        matlabbatch{end+1}.spm.spatial.smooth.data = cat(1,temp{:});
        matlabbatch{end}.spm.spatial.smooth.fwhm   = opt.fwhm*[1 1 1];
        matlabbatch{end}.spm.spatial.smooth.prefix = 'sv';
    end

    % Normalize Structural/ASL
    if ~isempty(strmatch('normalization',steps,'exact')),
        matlabbatch{end+1}.spm.spatial.normalise.est.subj.vol        = structFile{subj};
        matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasreg  = 0.0001;
        matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
        matlabbatch{end}.spm.spatial.normalise.est.eoptions.tpm      = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
        matlabbatch{end}.spm.spatial.normalise.est.eoptions.affreg   = 'mni';
        matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
        matlabbatch{end}.spm.spatial.normalise.est.eoptions.fwhm     = 0;
        matlabbatch{end}.spm.spatial.normalise.est.eoptions.samp     = 3;
        
        matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = conn_prepend('y_',structFile{subj});
        matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = structFile{subj};
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = opt.vox*[1 1 1];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;

        matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = conn_prepend('y_',structFile{subj});
        temp = conn_prepend(prefix{1},aslFile{subj});
        matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cat(1,temp{:},conn_prepend('mean',cellstr(aslFile{subj}{1}{1})));
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = opt.vox*[1 1 1];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
        
        prefix{1} = ['w',prefix{1}];
        prefix{2} = ['w',prefix{2}];
        prefix{3} = ['w',prefix{3}];
    end

    % Smooth Functional
    if ~isempty(strmatch('smoothing',steps,'exact')),
        temp = conn_prepend(prefix{1},aslFile{subj});
        matlabbatch{end+1}.spm.spatial.smooth.data = cat(1,temp{:});
        matlabbatch{end}.spm.spatial.smooth.fwhm   = opt.fwhm*[1 1 1];
        prefix{1} = ['s',prefix{1}];
    end
    
    if isfield(opt,'parc')
        % WM, CSF and ventricles masks
        [path_anat,n,e] = fileparts(structFile{subj}{1});
        cmd = sprintf('mri_convert %s %s',opt.parc,fullfile(path_anat,'parc.nii'));
        unix(cmd);
        cmd = sprintf('mri_extract_label %s 41 2 %s',opt.parc,fullfile(path_anat,'wm.nii'));
        unix(cmd);
        cmd = sprintf('mri_extract_label %s 24 %s',opt.parc,fullfile(path_anat,'csf.nii'));
        unix(cmd);
        cmd = sprintf('mri_extract_label %s 43 4 %s',opt.parc,fullfile(path_anat,'vent.nii'));
        unix(cmd);

        % reslicing masks
        tmp      = {};
        tmp{1,1} = fullfile(path_anat,'parc.nii');
        tmp{2,1} = fullfile(path_anat,'wm.nii');
        tmp{3,1} = fullfile(path_anat,'csf.nii');
        tmp{4,1} = fullfile(path_anat,'vent.nii');

        matlabbatch{end+1}.spm.spatial.coreg.write.ref           = conn_prepend('mean',cellstr(aslFile{subj}{1}{1}));
        matlabbatch{end}.spm.spatial.coreg.write.source          = tmp;
        matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
        matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
        matlabbatch{end}.spm.spatial.coreg.write.roptions.mask   = 0;
        matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
        
        % normalization      
        matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = conn_prepend('y_',structFile{subj});
        matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = tmp;
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = opt.vox*[1 1 1];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 0;
    end
    
    % outlier identification
    matlabbatch{end+1}.spm.tools.art.sess.motionfiletype.SPM.mvmtfile = cellstr(conn_prepend('rp_',aslFile{subj}{1}{1},'.txt'));
    temp = conn_prepend(prefix{1},aslFile{subj});
    matlabbatch{end}.spm.tools.art.sess.nscan                         = cat(1,temp{:});
    matlabbatch{end}.spm.tools.art.sess.threshold.globalsig.globaldiff.zthresh          = 3;
    matlabbatch{end}.spm.tools.art.sess.threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
    matlabbatch{end}.spm.tools.art.sess.threshold.compflag = 1;
    matlabbatch{end}.spm.tools.art.maskfile                = {''};
    matlabbatch{end}.spm.tools.art.savefiles.motionflag    = 1;
    matlabbatch{end}.spm.tools.art.savefiles.analysisflag  = 1;
    matlabbatch{end}.spm.tools.art.savefiles.voxvarflag    = 1;
    matlabbatch{end}.spm.tools.art.savefiles.SNRflag       = 1;
    matlabbatch{end}.spm.tools.art.closeflag               = 1;
    matlabbatch{end}.spm.tools.art.interp                  = 0;


    if ~isempty(matlabbatch),
        spm_jobman('run',matlabbatch);
    end
    
end