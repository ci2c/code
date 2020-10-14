clear all;
close all;
clc;

%% PATHS

ProgramPath    = '/home/renaud/matlab/rest_toolbox/DPARSF';
DataProcessDir = '/home/fatmike/renaud/test_rest';
SubjectNum     = 1;
SubjectID{1}   = 'Sub_001';
T1name         = 'anat.nii';
Funcname       = 'meanepi_0000.nii';
AffineRegul    = 'mni';
SPMversion     = 8;
BoundingBox    = [-90 -126 -72;90 90 108];
VoxSize        = [3 3 3];
TimePoints     = 250;

%% COREGISTER

% load([ProgramPath,filesep,'Jobmats',filesep,'Coregister.mat']);
% cd([DataProcessDir,filesep,'FunImg']);
% 
% for i = 1:SubjectNum
%     RefFile    = fullfile(DataProcessDir,'FunImg',SubjectID{i},[Funcname ',1']);
%     SourceFile = fullfile(DataProcessDir,'T1Img',SubjectID{i},T1name);
%     if i~=1
%         jobs = [jobs,{jobs{1,1}}];
%     end
%     jobs{1,i}.spatial{1,1}.coreg{1,1}.estimate.ref    = {RefFile};
%     jobs{1,i}.spatial{1,1}.coreg{1,1}.estimate.source = {SourceFile};
%     fprintf(['Normalize-Coregister Setup:',SubjectID{i},' OK']);
% end
% fprintf('\n');
% if SPMversion==5
%     spm_jobman('run',jobs);
% elseif SPMversion==8  
%     jobs = spm_jobman('spm5tospm8',{jobs});
%     spm_jobman('run',jobs{1});
% else
%     uiwait(msgbox('The current SPM version is not supported by DPARSF. Please install SPM5 or SPM8 first.','Invalid SPM Version.'));
%     return
% end


%% NEW SEGMENT

% load(fullfile(ProgramPath,'Jobmats','NewSegment.mat'));
% [SPMPath, fileN, extn] = fileparts(which('spm.m'));
% for k = 1:6
%     matlabbatch{1,1}.spm.tools.preproc8.tissue(1,k).tpm{1,1} = fullfile(SPMPath,'toolbox','Seg',['TPM.nii',',',num2str(k)]);
%     matlabbatch{1,1}.spm.tools.preproc8.tissue(1,k).warped   = [0 0]; % Do not need warped results. Warp by DARTEL
% end
% if strcmpi(AffineRegul,'mni')
%     matlabbatch{1,1}.spm.tools.preproc8.warp.affreg = 'mni';
% else
%     matlabbatch{1,1}.spm.tools.preproc8.warp.affreg = 'eastern';
% end
% 
% T1SourceFileSet = []; % Save to use in the step of DARTEL normalize to MNI
% cd(fullfile(DataProcessDir,'T1Img'));
% 
% for i = 1:SubjectNum
% 
%     SourceFile = fullfile(DataProcessDir,'T1Img',SubjectID{i},T1name);
%     if i~=1
%         matlabbatch = [matlabbatch,{matlabbatch{1,1}}];
%     end
%     matlabbatch{1,i}.spm.tools.preproc8.channel.vols = {SourceFile};
%     T1SourceFileSet                                  = [T1SourceFileSet;{SourceFile}];
%     fprintf(['Normalize-Segment Setup:',SubjectID{i},' OK']);
%     
% end
% fprintf('\n');
% spm_jobman('run',matlabbatch);


%% DARTEL: Create Template

% load(fullfile(ProgramPath,'Jobmats','Dartel_CreateTemplate.mat'));
% % Look for rc1* and rc2* images.
% cd(fullfile(DataProcessDir,'T1Img'));
% 
% rc1FileList = [];
% rc2FileList = [];
% for i = 1:SubjectNum
%     
%     cd(SubjectID{i});
%     DirImg      = dir('rc1*');
%     rc1FileList = [rc1FileList;{fullfile(DataProcessDir,'T1Img',SubjectID{i},DirImg(1).name)}];
%     DirImg      = dir('rc2*');
%     rc2FileList = [rc2FileList;{fullfile(DataProcessDir,'T1Img',SubjectID{i},DirImg(1).name)}];
%     cd('..');
%     
% end
% matlabbatch{1,1}.spm.tools.dartel.warp.images{1,1} = rc1FileList;
% matlabbatch{1,1}.spm.tools.dartel.warp.images{1,2} = rc2FileList;
% fprintf(['Running DARTEL: Create Template.\n']);
% spm_jobman('run',matlabbatch);


%% DARTEL: Normalize to MNI space - GM, WM, CSF and T1 Images.

% load(fullfile(ProgramPath,'Jobmats','Dartel_NormaliseToMNI_ManySubjects.mat'));
% cd(fullfile(DataProcessDir,'T1Img'));
% 
% FlowFieldFileList = [];
% GMFileList        = [];
% WMFileList        = [];
% CSFFileList       = [];
% for i = 1:SubjectNum
%     
%     cd(SubjectID{i});
%     DirImg            = dir('u_*');
%     FlowFieldFileList = [FlowFieldFileList;{fullfile(DataProcessDir,'T1Img',SubjectID{i},DirImg(1).name)}];
%     DirImg            = dir('c1*');
%     GMFileList        = [GMFileList;{fullfile(DataProcessDir,'T1Img',SubjectID{i},DirImg(1).name)}];
%     DirImg            = dir('c2*');
%     WMFileList        = [WMFileList;{fullfile(DataProcessDir,'T1Img',SubjectID{i},DirImg(1).name)}];
%     DirImg            = dir('c3*');
%     CSFFileList       = [CSFFileList;{fullfile(DataProcessDir,'T1Img',SubjectID{i},DirImg(1).name)}];
% 
%     if i==1
%         DirImg = dir('Template_6.*');
%         TemplateFile = {fullfile(DataProcessDir,'T1Img',SubjectID{i},DirImg(1).name)};
%     end
%     cd('..');
%     
% end
% 
% matlabbatch{1,1}.spm.tools.dartel.mni_norm.template               = TemplateFile;
% matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.flowfields  = FlowFieldFileList;
% 
% matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,1} = GMFileList;
% matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,2} = WMFileList;
% matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,3} = CSFFileList;
% 
% fprintf(['Running DARTEL: Normalize to MNI space for VBM. Modulated version With smooth kernel [8 8 8].\n']);
% spm_jobman('run',matlabbatch);
% 
% matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm = [0 0 0]; % Do not want to perform smooth
% fprintf(['Running DARTEL: Normalize to MNI space for VBM. Modulated version.\n']);
% spm_jobman('run',matlabbatch);
% 
% matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
% if exist('T1SourceFileSet','var')
%     matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subjs.images{1,4} = T1SourceFileSet;
% end
% fprintf(['Running DARTEL: Normalize to MNI space for VBM. Unmodulated version.\n']);
% spm_jobman('run',matlabbatch);


%% DARTEL: Normalize to MNI space - Functional Images.

load(fullfile(ProgramPath,'Jobmats','Dartel_NormaliseToMNI_FewSubjects.mat'));

matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm     = [0 0 0];
matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb       = BoundingBox;
matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox      = VoxSize;

DirImg = dir(fullfile(DataProcessDir,'T1Img',SubjectID{1},'Template_6.*'));
matlabbatch{1,1}.spm.tools.dartel.mni_norm.template = {fullfile(DataProcessDir,'T1Img',SubjectID{1},DirImg(1).name)};

cd(fullfile(DataProcessDir,'FunImg'));

for i = 1:SubjectNum
    
    cd(SubjectID{i});
    DirImg = dir('repi*.nii');
    if length(DirImg) ~= TimePoints
        Error = [Error;{['Error in Normalize: ',SubjectID{i}]}];
    end
    FileList = [];
    for j = 1:length(DirImg)
        FileList = [FileList;{fullfile(DataProcessDir,'FunImg',SubjectID{i},DirImg(j).name)}];
    end

    matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,i).images = FileList;

    DirImg = dir(fullfile(DataProcessDir,'T1Img',SubjectID{i},'u_*'));
    matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,i).flowfield = {fullfile(DataProcessDir,'T1Img',SubjectID{i},DirImg(1).name)};

    cd('..');
    fprintf(['Normalization by using DARTEL Setup:',SubjectID{i},' OK']);
    
end
fprintf('\n');
spm_jobman('run',matlabbatch);

