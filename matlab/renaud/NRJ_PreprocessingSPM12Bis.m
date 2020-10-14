function NRJ_PreprocessingSPM12Bis(structFile,funcFile,steps,opt)

%%  INIT

%addpath('/home/global/matlab_toolbox/spm12b');

if nargin < 3
    steps = {'segmentation','slicetiming','realignment','coregistration','normalization','smoothing','initialization'};
end
if nargin < 4
    opt = struct('TR',2.4,'center',1,'reorient',eye(4),'vox',2,'fwhm',6,'fwhmsurf',1.5,'segment','new','acquisition','interleaved','structural_template',fullfile(fileparts(which('spm')),'templates','T1.nii'),'functional_template',fullfile(fileparts(which('spm')),'templates','EPI.nii'));
end

nsubjects = length(structFile);

for nsub=1:length(structFile),if ~iscell(structFile{nsub}),structFile{nsub}=cellstr(structFile{nsub});end;end

spm_get_defaults;

spm_jobman('initcfg');

for subj = 1:nsubjects
    
    disp(['********************************']);
    disp(['Preparing subject ']);
    disp(['********************************']);

%     V       = spm_vol(funcFile{subj}{1}{1});
%     nslices = V(1).dim(3);
    tempvol = spm_vol(funcFile{subj}{1}{1});
    nslices = tempvol.dim(3);

    if strcmp(opt.acquisition,'ascending')
        sliceorder = 1:1:nslices;
    elseif strcmp(opt.acquisition,'interleaved')
        sliceorder = [];
        space      = round(sqrt(nslices));
        for k=1:space
            tmp        = k:space:nslices;
            sliceorder = [sliceorder tmp];
        end
    elseif strcmp(opt.acquisition,'descending')
        sliceorder = [nslices:-2:1 nslices-1:-2:1];
    else
        sliceorder = 1:1:nslices;
    end

    matlabbatch={};    
    prefix={[],[],[]};

    % Coregister Anatomical
%     if ~isempty(strmatch('coregistration',steps,'exact')) || ~isempty(strmatch('normalization',steps,'exact')),
%         if opt.center || any(any(opt.reorient~=eye(4))),
%             a     = spm_vol(structFile{subj}{1});b=spm_read_vols(a);
%             a.mat = opt.reorient*a.mat;
%             if opt.center, a.mat(1:3,4)=-a.mat(1:3,1:3)*a.dim'/2; end
%             spm_write_vol(a,b);
%         end
%         matlabbatch{end+1}.spm.spatial.coreg.estimate.ref  = cellstr(opt.structural_template);
%         matlabbatch{end}.spm.spatial.coreg.estimate.source = structFile{subj};
%     end

    % Segment Anatomical
    if ~isempty(strmatch('segmentation',steps,'exact')),

        if strcmp(opt.segment,'old')
            matlabbatch{end+1}.spm.tools.oldseg.data         = structFile{subj};
            matlabbatch{end}.spm.tools.oldseg.output.GM      = [1 1 1];
            matlabbatch{end}.spm.tools.oldseg.output.WM      = [1 1 1];
            matlabbatch{end}.spm.tools.oldseg.output.CSF     = [1 1 1];
            matlabbatch{end}.spm.tools.oldseg.output.biascor = 1;
            matlabbatch{end}.spm.tools.oldseg.output.cleanup = 0;
            matlabbatch{end}.spm.tools.oldseg.opts.tpm       = {
                                                                '/home/global/matlab_toolbox/spm12b/toolbox/OldSeg/grey.nii'
                                                                '/home/global/matlab_toolbox/spm12b/toolbox/OldSeg/white.nii'
                                                                '/home/global/matlab_toolbox/spm12b/toolbox/OldSeg/csf.nii'
                                                               };
            matlabbatch{end}.spm.tools.oldseg.opts.ngaus       = [2;2;2;4];
            matlabbatch{end}.spm.tools.oldseg.opts.regtype     = 'mni';
            matlabbatch{end}.spm.tools.oldseg.opts.warpreg     = 1;
            matlabbatch{end}.spm.tools.oldseg.opts.warpco      = 25;
            matlabbatch{end}.spm.tools.oldseg.opts.biasreg     = 0.0001;
            matlabbatch{end}.spm.tools.oldseg.opts.biasfwhm    = 60;
            matlabbatch{end}.spm.tools.oldseg.opts.samp        = 3;
            matlabbatch{end}.spm.tools.oldseg.opts.msk         = {''};
        else 
            matlabbatch{end+1}.spm.spatial.preproc.channel.vols   = structFile{subj};
            matlabbatch{end}.spm.spatial.preproc.channel.biasreg  = 0.001;
            matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
            matlabbatch{end}.spm.spatial.preproc.channel.write    = [0 0];
            matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,1'};
            matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus  = 1;
            matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 1];
            matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [1 1];
            matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,2'};
            matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus  = 1;
            matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 1];
            matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [1 1];
            matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,3'};
            matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus  = 2;
            matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 1];
            matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [1 1];
            matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,4'};
            matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus  = 3;
            matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [0 0];
            matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
            matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,5'};
            matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus  = 4;
            matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [0 0];
            matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
            matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm    = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,6'};
            matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus  = 2;
            matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
            matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];
            matlabbatch{end}.spm.spatial.preproc.warp.mrf         = 1;
            matlabbatch{end}.spm.spatial.preproc.warp.cleanup     = 1;
            matlabbatch{end}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
            matlabbatch{end}.spm.spatial.preproc.warp.affreg      = 'mni';
            matlabbatch{end}.spm.spatial.preproc.warp.fwhm        = 0;
            matlabbatch{end}.spm.spatial.preproc.warp.samp        = 3;
            matlabbatch{end}.spm.spatial.preproc.warp.write       = [0 0];

        end
        prefix{2}=['m',prefix{2}];
    end

    % Skull-stripped anatomical
    if ~isempty(strmatch('coregistration',steps,'exact')),
        matlabbatch{end+1}.spm.util.imcalc.expression  = '(i1+i2+i3).*i4';
        matlabbatch{end}.spm.util.imcalc.input         = cat(1,conn_prepend('c1',structFile{subj}),conn_prepend('c2',structFile{subj}),conn_prepend('c3',structFile{subj}),structFile{subj});
        matlabbatch{end}.spm.util.imcalc.output        = conn_prepend('c0',structFile{subj}{1});
        matlabbatch{end}.spm.util.imcalc.options.dtype = spm_type('float32');
    end

    % Realign Functional
    if ~isempty(strmatch('realignment',steps,'exact')),
        matlabbatch{end+1}.spm.spatial.realign.estwrite.data         = funcFile{subj};
        matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm   = 1;
        matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which = [2,1];
        prefix{1} = ['r',prefix{1}];
    end
    
    % Corrects slice-timing Functional
    if ~isempty(strmatch('slicetiming',steps,'exact')),
        matlabbatch{end+1}.spm.temporal.st.scans  = conn_prepend(prefix{1},funcFile{subj});
        matlabbatch{end}.spm.temporal.st.tr       = opt.TR;
        matlabbatch{end}.spm.temporal.st.nslices  = nslices;
        matlabbatch{end}.spm.temporal.st.ta       = opt.TR*(1-1/nslices);
        matlabbatch{end}.spm.temporal.st.refslice = floor(nslices/2);
        matlabbatch{end}.spm.temporal.st.so       = sliceorder;
        prefix{1}=['a',prefix{1}];
    end
    prefix1 = prefix{1};

    % Coregister Functional
    if ~isempty(strmatch('coregistration',steps,'exact')),
        matlabbatch{end+1}.spm.spatial.coreg.estimate.ref  = structFile{subj};
        matlabbatch{end}.spm.spatial.coreg.estimate.source = conn_prepend('mean',cellstr(funcFile{subj}{1}{1}));
        temp = conn_prepend(prefix{1},funcFile{subj});
        matlabbatch{end}.spm.spatial.coreg.estimate.other  = cat(1,temp{:});
    end
    
    % Smooth Functional (native + surface)
    if ~isempty(strmatch('smoothing',steps,'exact')),
        temp = conn_prepend(prefix{1},funcFile{subj});
        matlabbatch{end+1}.spm.spatial.smooth.data = cat(1,temp{:});
        matlabbatch{end}.spm.spatial.smooth.fwhm   = opt.fwhmsurf*[1 1 1];
        matlabbatch{end}.spm.spatial.smooth.prefix = 'ss';
    end
    
    % Smooth Functional (native + volume)
    if ~isempty(strmatch('smoothing',steps,'exact')),
        temp = conn_prepend(prefix{1},funcFile{subj});
        matlabbatch{end+1}.spm.spatial.smooth.data = cat(1,temp{:});
        matlabbatch{end}.spm.spatial.smooth.fwhm   = opt.fwhm*[1 1 1];
        matlabbatch{end}.spm.spatial.smooth.prefix = 'sv';
    end

    % Normalize Structural/Functional
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
        matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = conn_prepend('c0',structFile{subj});
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = opt.vox*[1 1 1];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
        
        matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = conn_prepend('y_',structFile{subj});
        matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = structFile{subj};
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = opt.vox*[1 1 1];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;

        matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = conn_prepend('y_',structFile{subj});
        temp = conn_prepend(prefix{1},funcFile{subj});
        matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cat(1,temp{:},conn_prepend('mean',cellstr(funcFile{subj}{1}{1})));
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = opt.vox*[1 1 1];
        matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
        
        prefix{1} = ['w',prefix{1}];
        prefix{2} = ['w',prefix{2}];
        prefix{3} = ['w',prefix{3}];
    elseif ~isempty(strmatch('normalization_old',steps,'exact')),
        matlabbatch{end+1}.spm.spatial.normalise.write.subj.matname = conn_prepend('',structFile{subj},'_seg_sn.mat');
        temp = conn_prepend(prefix{1},funcFile{subj});
        matlabbatch{end}.spm.spatial.normalise.write.subj.resample  = cat(1,temp{:},conn_prepend('mean',cellstr(funcFile{subj}{1}{1})),conn_prepend(prefix{2},structFile{subj}));
        matlabbatch{end}.spm.spatial.normalise.write.roptions.vox   = opt.vox*[1 1 1];
        prefix{1} = ['w',prefix{1}];
        prefix{2} = ['w',prefix{2}];
        prefix{3} = ['w',prefix{3}];
    elseif ~isempty(strmatch('coregistration',steps,'exact')),
        t=load(char(conn_prepend('',structFile{subj},'_seg_sn.mat')));t.Tr=[];save(char(conn_prepend('',structFile{subj},'_seg_sn_aff.mat')),'-struct','t');
        matlabbatch{end+1}.spm.spatial.normalise.write.subj.matname = conn_prepend('',structFile{subj},'_seg_sn_aff.mat');
        temp = conn_prepend(prefix{1},funcFile{subj});
        matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cat(1,temp{:},conn_prepend(['mean',prefix1],cellstr(funcFile{subj}{1}{1})),conn_prepend(prefix{2},structFile{subj}));
        matlabbatch{end}.spm.spatial.normalise.write.roptions.vox    = opt.vox*[1 1 1];
        matlabbatch{end}.spm.spatial.normalise.write.roptions.prefix = 'r';
        prefix{1} = ['r',prefix{1}];
        prefix{2} = ['r',prefix{2}];
    end

    % Smooth Functional
    if ~isempty(strmatch('smoothing',steps,'exact')),
        temp = conn_prepend(prefix{1},funcFile{subj});
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
        tmp{1,1} = opt.parc;
        tmp{2,1} = fullfile(path_anat,'wm.nii');
        tmp{3,1} = fullfile(path_anat,'csf.nii');
        tmp{4,1} = fullfile(path_anat,'vent.nii');

        matlabbatch{end+1}.spm.spatial.coreg.write.ref           = conn_prepend('mean',cellstr(funcFile{subj}{1}{1}));
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

    if ~isempty(matlabbatch),
        spm_jobman('run',matlabbatch);
    end
    
end
