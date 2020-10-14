function Error = NRJ_NormalizeOneSubject(datapath,Ns,opt,BoundingBox,VoxSize,SPMversion)

% usage : Error = FMRI_NormalizeOneSubject(datapath,opt,[BoundingBox,VoxSize,SPMversion])
%
% Inputs :
%    datapath      : subject folder
%    Ns            : number of sessions
%    opt           : structure: IsNormalize 
%                               AffineRegularisationInSegmentation -
%                               IsDelFilesBeforeNormalize
%
% Options :
%    BoundingBox   : bounding box (Default: [-90 -126 -72;90 90 108])
%    VoxSize       : voxel size (Default: [3 3 3])
%    SPMversion    : SPM version (Default: 8)
%
% Renaud Lopes @ CHRU Lille, June 2012

Error = [];

if nargin ~= 3 && nargin ~= 4 && nargin ~= 5 && nargin ~= 6
    error('invalid usage');
end

% check args
if nargin < 4
    BoundingBox = [-90 -126 -72;90 90 108];
end
if nargin < 5
    VoxSize = [3 3 3];
end
if nargin < 6
    SPMversion = 8;
end

cur_path = pwd;

if (opt.IsNormalize>0)
    
    if (opt.IsNormalize==1) % Normalization by using the EPI template directly
        
        load('FMRI_Normalize.mat');
        
        for i = 1:Ns
            
            if i<10
                ses = ['sess0' num2str(i)];
            else
                ses = ['sess0' num2str(i)];
            end
            
            cd(fullfile(datapath,'fmri',ses,'spm'));

            DirImg=dir('ra*.nii');
            FileList=[];
            for j = 1:length(DirImg)
                FileList = [FileList;{fullfile(datapath,'fmri',ses,'spm',[DirImg(j).name,',1'])}];
            end
            MeanFilename = dir('mean*.nii');
            MeanFilename = fullfile(datapath,'fmri',ses,'spm',[MeanFilename.name,',1']);
            jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.subj(1,1).source   = {MeanFilename};
            jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.subj(1,1).resample = FileList;
            cd('../../..');
            fprintf(['Normalize Setup: ',datapath,' OK']);

            fprintf('\n');
            [SPMPath, fileN, extn] = fileparts(which('spm.m'));
            jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.eoptions.template = {fullfile(SPMPath,'templates','EPI.nii,1')};
            jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.roptions.bb       = BoundingBox;
            jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.roptions.vox      = VoxSize;

            if SPMversion==5
                spm_jobman('run',jobs);
            elseif SPMversion==8  
                jobs = spm_jobman('spm5tospm8',{jobs});
                spm_jobman('run',jobs{1});
            else
                uiwait(msgbox('The current SPM version is not supported. Please install SPM5 or SPM8 first.','Invalid SPM Version.'));
                return
            end
            
        end
        
    end
    
    
    if (opt.IsNormalize==2) % Normalization by using DARTEL. 
        
        % Backup the T1 images to T1ImgNewSegment
        cd(fullfile(datapath,'anat'));

        % Check in co* image exist. 
        DirImg = dir('*.nii');
        cd('..');
        fprintf(['Copying T1 image Files: ',datapath,' OK']);
        fprintf('\n');
                
        % New Segment
        T1ImgSegmentDirectoryName = 'anat';
        load('FMRI_NewSegment.mat');
        [SPMPath, fileN, extn] = fileparts(which('spm.m'));
        for T1ImgSegmentDirectoryNameue = 1:6
            matlabbatch{1,1}.spm.tools.preproc8.tissue(1,T1ImgSegmentDirectoryNameue).tpm{1,1} = fullfile(SPMPath,'toolbox','Seg',['TPM.nii',',',num2str(T1ImgSegmentDirectoryNameue)]);
            matlabbatch{1,1}.spm.tools.preproc8.tissue(1,T1ImgSegmentDirectoryNameue).warped   = [0 0]; % Do not need warped results. Warp by DARTEL
        end
        if strcmpi(opt.AffineRegularisationInSegmentation,'mni')
            matlabbatch{1,1}.spm.tools.preproc8.warp.affreg = 'mni';
        else
            matlabbatch{1,1}.spm.tools.preproc8.warp.affreg = 'eastern';
        end
        
        T1SourceFileSet = []; % Save to use in the step of DARTEL normalize to MNI
        cd(fullfile(datapath,'anat'));
        SourceDir  = dir(fullfile(datapath,'anat','*.nii'));
        SourceFile = fullfile(datapath,'anat',SourceDir(1).name);
        matlabbatch{1,1}.spm.tools.preproc8.channel.vols = {SourceFile};
        T1SourceFileSet                                  = [T1SourceFileSet;{SourceFile}];
        fprintf(['Normalize-Segment Setup: ',datapath,' OK']);
        fprintf('\n');
        spm_jobman('run',matlabbatch);
        
        % DARTEL: Create Template
        load('FMRI_Dartel_CreateTemplate.mat');
        % Look for rc1* and rc2* images.
        cd(fullfile(datapath,'anat'));
        rc1FileList = [];
        rc2FileList = [];
        DirImg      = dir('rc1*');
        rc1FileList = [rc1FileList;{fullfile(datapath,'anat',DirImg(1).name)}];
        DirImg      = dir('rc2*');
        rc2FileList = [rc2FileList;{fullfile(datapath,'anat',DirImg(1).name)}];
        cd('..');
        matlabbatch{1,1}.spm.tools.dartel.warp.images{1,1} = rc1FileList;
        matlabbatch{1,1}.spm.tools.dartel.warp.images{1,2} = rc2FileList;
        fprintf(['Running DARTEL: Create Template.\n']);
        spm_jobman('run',matlabbatch);
                
        % DARTEL: Normalize to MNI space - GM, WM, CSF and T1 Images.
        load('FMRI_Dartel_NormaliseToMNI_ManySubjects.mat');
        cd(fullfile(datapath,'anat'));
        FlowFieldFileList = [];
        GMFileList        = [];
        WMFileList        = [];
        CSFFileList       = [];
        DirImg            = dir('u_*');
        FlowFieldFileList = [FlowFieldFileList;{fullfile(datapath,'anat',DirImg(1).name)}];
        DirImg            = dir('c1*');
        GMFileList        = [GMFileList;{fullfile(datapath,'anat',DirImg(1).name)}];
        DirImg            = dir('c2*');
        WMFileList        = [WMFileList;{fullfile(datapath,'anat',DirImg(1).name)}];
        DirImg            = dir('c3*');
        CSFFileList       = [CSFFileList;{fullfile(datapath,'anat',DirImg(1).name)}];
        DirImg            = dir('Template_6.*');
        TemplateFile      = {fullfile(datapath,'anat',DirImg(1).name)};
        
        cd('..');
       
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.template               = TemplateFile;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.flowfields  = FlowFieldFileList;
        
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,1} = GMFileList;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,2} = WMFileList;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,3} = CSFFileList;
        
        fprintf(['Running DARTEL: Normalize to MNI space for VBM. Modulated version With smooth kernel [8 8 8].\n']);
        spm_jobman('run',matlabbatch);
        
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm = [0 0 0]; % Do not want to perform smooth
        fprintf(['Running DARTEL: Normalize to MNI space for VBM. Modulated version.\n']);
        spm_jobman('run',matlabbatch);
        
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
        if exist('T1SourceFileSet','var')
            matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,4} = T1SourceFileSet;
        end
        fprintf(['Running DARTEL: Normalize to MNI space for VBM. Unmodulated version.\n']);
        spm_jobman('run',matlabbatch);

        % DARTEL: Normalize to MNI space - Functional Images.
        load('FMRI_Dartel_NormaliseToMNI_FewSubjects.mat');
        
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm     = [0 0 0];
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb       = BoundingBox;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox      = VoxSize;
        
        DirImg = dir(fullfile(datapath,'anat','Template_6.*'));
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.template = {fullfile(datapath,'anat',DirImg(1).name)};
        
        for i = 1:Ns
            
            if i<10
                ses = ['sess0' num2str(i)];
            else
                ses = ['sess' num2str(i)];
            end
            
            cd(fullfile(datapath,'fmri',ses,'spm'));

            DirImg = dir('ra*.nii');
            FileList = [];
            for j = 1:length(DirImg)
                FileList = [FileList;{fullfile(datapath,'fmri',ses,'spm',DirImg(j).name)}];
            end

            matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images = FileList;

            DirImg = dir(fullfile(datapath,'anat','u_*'));
            matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield = {fullfile(datapath,'anat',DirImg(1).name)};

            cd('..');
            fprintf(['Normalization by using DARTEL Setup: ',datapath,' OK']);

            fprintf('\n');
            spm_jobman('run',matlabbatch);
        
        end
        
    end
                   
       
end
if ~isempty(Error)
    disp(Error);
    return;
end

cd(cur_path);
