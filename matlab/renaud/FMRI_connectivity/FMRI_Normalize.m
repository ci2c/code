function Error = FMRI_Normalize(ProgramPath,opt,SPMversion,Error)


if (opt.IsNormalize>0)
    
    if (opt.IsNormalize==1) %Normalization by using the EPI template directly
        
        load(fullfile(ProgramPath,'Jobmats','Normalize.mat'));
        cd(fullfile(opt.DataProcessDir,'FunImg'));
        
        for i = 1:opt.SubjectNum
            cd(opt.SubjectID{i});
            DirImg=dir('ra*.nii');
            if length(DirImg)~=opt.TimePoints
                Error=[Error;{['Error in Normalize: ',opt.SubjectID{i}]}];
            end
            FileList=[];
            for j = 1:length(DirImg)
                FileList = [FileList;{fullfile(opt.DataProcessDir,'FunImg',opt.SubjectID{i},[DirImg(j).name,',1'])}];
            end
            MeanFilename = dir('mean*.nii');
            MeanFilename = fullfile(opt.DataProcessDir,'FunImg',opt.SubjectID{i},[MeanFilename.name,',1']);
            if i~=1
                jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.subj=[jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.subj,jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.subj(1,1)];
            end
            jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.subj(1,i).source   = {MeanFilename};
            jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.subj(1,i).resample = FileList;
            cd('..');
            fprintf(['Normalize Setup:',opt.SubjectID{i},' OK']);
        end
        
        fprintf('\n');
        [SPMPath, fileN, extn] = fileparts(which('spm.m'));
        jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.eoptions.template = {fullfile(SPMPath,'templates','EPI.nii,1')};
        jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.roptions.bb       = opt.BoundingBox;
        jobs{1,1}.spatial{1,1}.normalise{1,1}.estwrite.roptions.vox      = opt.VoxSize;
        
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
    
    
    if (opt.IsNormalize==3) % Normalization by using DARTEL. 
        
        % Backup the T1 images to T1ImgNewSegment
        cd(fullfile(opt.DataProcessDir,'T1Img'));
        
        % Check in co* image exist. 
        cd(opt.SubjectID{1});
        UseNoCoT1Image = 1;
        cd('..');
        
        for i = 1:opt.SubjectNum
            cd(opt.SubjectID{i});
            mkdir(fullfile('..','..','T1ImgNewSegment',opt.SubjectID{i}))
            % Check in co* image exist. 
            if UseNoCoT1Image==0
                copyfile('co*',fullfile('..','..','T1ImgNewSegment',opt.SubjectID{i}))
            else
                DirImg = dir('*.nii');
                copyfile(DirImg(1).name,fullfile('..','..','T1ImgNewSegment',opt.SubjectID{i},['co',DirImg(1).name]));
            end
            cd('..');
            fprintf(['Copying T1 image Files:',opt.SubjectID{i},' OK']);
        end
        fprintf('\n');
        
        % Coregister
        load([ProgramPath,filesep,'Jobmats',filesep,'Coregister.mat']);
        cd(fullfile(opt.DataProcessDir,filesep,'FunImg'));
        for i = 1:opt.SubjectNum
            RefDir     = dir(fullfile(opt.DataProcessDir,'FunImg',opt.SubjectID{i},'mean*.nii'));
            RefFile    = fullfile(opt.DataProcessDir,'FunImg',opt.SubjectID{i},[RefDir(1).name,',1']);
            SourceDir  = dir(fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},'co*.nii'));
            SourceFile = fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},SourceDir(1).name);
            if i~=1
                jobs = [jobs,{jobs{1,1}}];
            end
            jobs{1,i}.spatial{1,1}.coreg{1,1}.estimate.ref    = {RefFile};
            jobs{1,i}.spatial{1,1}.coreg{1,1}.estimate.source = {SourceFile};
            fprintf(['Normalize-Coregister Setup:',opt.SubjectID{i},' OK']);
        end
        fprintf('\n');
        if SPMversion==5
            spm_jobman('run',jobs);
        elseif SPMversion==8  %YAN Chao-Gan, 090925. SPM8 compatible.
            jobs = spm_jobman('spm5tospm8',{jobs});
            spm_jobman('run',jobs{1});
        else
            uiwait(msgbox('The current SPM version is not supported by DPARSF. Please install SPM5 or SPM8 first.','Invalid SPM Version.'));
            return
        end
        
        % New Segment
        T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
        load(fullfile(ProgramPath,'Jobmats','NewSegment.mat'));
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
        
        T1SourceFileSet=[]; % Save to use in the step of DARTEL normalize to MNI
        cd(fullfile(opt.DataProcessDir,T1ImgSegmentDirectoryName));
        for i = 1:opt.SubjectNum
            SourceDir  = dir(fullfile(opt.DataProcessDir,T1ImgSegmentDirectoryName,opt.SubjectID{i},'*.nii'));
            SourceFile = fullfile(opt.DataProcessDir,T1ImgSegmentDirectoryName,opt.SubjectID{i},SourceDir(1).name);
            if i~=1
                matlabbatch = [matlabbatch,{matlabbatch{1,1}}];
            end
            matlabbatch{1,i}.spm.tools.preproc8.channel.vols = {SourceFile};
            T1SourceFileSet                                  = [T1SourceFileSet;{SourceFile}];
            fprintf(['Normalize-Segment Setup:',opt.SubjectID{i},' OK']);
        end
        fprintf('\n');
        spm_jobman('run',matlabbatch);

        
        % DARTEL: Create Template
        load(fullfile(ProgramPath,'Jobmats','Dartel_CreateTemplate.mat'));
        % Look for rc1* and rc2* images.
        cd(fullfile(opt.DataProcessDir,'T1ImgNewSegment'));
        rc1FileList = [];
        rc2FileList = [];
        for i = 1:opt.SubjectNum
            cd(opt.SubjectID{i});
            DirImg      = dir('rc1*');
            rc1FileList = [rc1FileList;{fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},DirImg(1).name)}];
            DirImg      = dir('rc2*');
            rc2FileList = [rc2FileList;{fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},DirImg(1).name)}];
            cd('..');
        end
        matlabbatch{1,1}.spm.tools.dartel.warp.images{1,1} = rc1FileList;
        matlabbatch{1,1}.spm.tools.dartel.warp.images{1,2} = rc2FileList;
        fprintf(['Running DARTEL: Create Template.\n']);
        spm_jobman('run',matlabbatch);
        
        % DARTEL: Normalize to MNI space - GM, WM, CSF and T1 Images.
        load(fullfile(ProgramPath,'Jobmats','Dartel_NormaliseToMNI_ManySubjects.mat'));
        cd(fullfile(opt.DataProcessDir,'T1ImgNewSegment'));
        FlowFieldFileList = [];
        GMFileList        = [];
        WMFileList        = [];
        CSFFileList       = [];
        for i = 1:opt.SubjectNum
            cd(opt.SubjectID{i});
            DirImg            = dir('u_*');
            FlowFieldFileList = [FlowFieldFileList;{fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},DirImg(1).name)}];
            DirImg            = dir('c1*');
            GMFileList        = [GMFileList;{fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},DirImg(1).name)}];
            DirImg            = dir('c2*');
            WMFileList        = [WMFileList;{fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},DirImg(1).name)}];
            DirImg            = dir('c3*');
            CSFFileList       = [CSFFileList;{fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},filesep,DirImg(1).name)}];
            
            if i==1
                DirImg       = dir('Template_6.*');
                TemplateFile = {fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},DirImg(1).name)};
            end
            cd('..');
        end
        
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
        load(fullfile(ProgramPath,'Jobmats','Dartel_NormaliseToMNI_FewSubjects.mat'));
        
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm     = [0 0 0];
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb       = opt.BoundingBox;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox      = opt.VoxSize;
        
        DirImg = dir(fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{1},'Template_6.*'));
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.template = {fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{1},DirImg(1).name)};
        
        cd(fullfile(opt.DataProcessDir,'FunImg'));
        for i = 1:opt.SubjectNum
            cd(opt.SubjectID{i});
            DirImg = dir('ra*.nii');
            if length(DirImg)~=opt.TimePoints
                Error = [Error;{['Error in Normalize: ',opt.SubjectID{i}]}];
            end
            FileList = [];
            for j = 1:length(DirImg)
                FileList = [FileList;{fullfile(opt.DataProcessDir,'FunImg',opt.SubjectID{i},DirImg(j).name)}];
            end
            
            matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,i).images = FileList;
            
            DirImg = dir(fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},'u_*'));
            matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,i).flowfield = {fullfile(opt.DataProcessDir,'T1ImgNewSegment',opt.SubjectID{i},DirImg(1).name)};
            
            cd('..');
            fprintf(['Normalization by using DARTEL Setup:',opt.SubjectID{i},' OK']);
        end
        fprintf('\n');
        spm_jobman('run',matlabbatch);
        
    end
       
        
    % Copy the normalized files to DataProcessDir\FunImgNormalized. Check Head motion moved right after realign
    cd(fullfile(opt.DataProcessDir,'FunImg'));
    for i = 1:opt.SubjectNum
        cd(opt.SubjectID{i});
        mkdir(fullfile('..','..','FunImgNormalized',opt.SubjectID{i}))
        movefile('wra*',fullfile('..','..','FunImgNormalized',opt.SubjectID{i}))
        cd('..');
        fprintf(['Moving Normalized Files:',opt.SubjectID{i},' OK']);
    end
    fprintf('\n');
    
    cd(opt.DataProcessDir);
    if opt.IsDelFilesBeforeNormalize==1
        rmdir('FunImg','s')
    end
   
    %Generate the pictures for checking normalization %YAN Chao-Gan, 091001
    mkdir(fullfile(opt.DataProcessDir,'PicturesForChkNormalization'));
    cd(fullfile(opt.DataProcessDir,'PicturesForChkNormalization'));
    if license('test','image_toolbox') 
        global DPARSF_rest_sliceviewer_Cfg;
        h = DPARSF_rest_sliceviewer;
        [RESTPath, fileN, extn] = fileparts(which('rest.m'));
        Ch2Filename = fullfile(RESTPath,'Template','ch2.nii');
        set(DPARSF_rest_sliceviewer_Cfg.Config(1).hOverlayFile, 'String', Ch2Filename);
        DPARSF_rest_sliceviewer_Cfg.Config(1).Overlay.Opacity=0.2;
        DPARSF_rest_sliceviewer('ChangeOverlay', h);
        for i = 1:opt.SubjectNum
            Dir      = dir(fullfile(opt.DataProcessDir,'FunImgNormalized',opt.SubjectID{i},'*.nii'));
            Filename = fullfile(opt.DataProcessDir,'FunImgNormalized',opt.SubjectID{i},Dir(1).name);
            DPARSF_Normalized_TempImage = fullfile(tempdir,['DPARSF_Normalized_TempImage','_',rest_misc('GetCurrentUser'),'.nii']);
            y_Reslice(Filename,DPARSF_Normalized_TempImage,[1 1 1],0)
            set(DPARSF_rest_sliceviewer_Cfg.Config(1).hUnderlayFile, 'String', DPARSF_Normalized_TempImage);
            set(DPARSF_rest_sliceviewer_Cfg.Config(1).hMagnify ,'Value',2);
            DPARSF_rest_sliceviewer('ChangeUnderlay', h);
            eval(['print(''-dtiff'',''-r100'',''',opt.SubjectID{i},'.tif'',h);']);
            fprintf(['Generating the pictures for checking normalization: ',opt.SubjectID{i},' OK']);
        end
        close(h);
        fprintf('\n');
    else  
        fprintf('Since Image Processing Toolbox of MATLAB is not valid, the pictures for checking normalization will not be generated.\n');
        fid = fopen('Warning.txt','at+');
        fprintf(fid,'%s','Since Image Processing Toolbox of MATLAB is not valid, the pictures for checking normalization will not be generated.\n');
        fclose(fid);
    end
    
end
if ~isempty(Error)
    disp(Error);
    return;
end