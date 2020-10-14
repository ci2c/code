function sizeDataHier = FMRI_SicaAllSubjects(datapath,infolder,outfolder,subjectlist,prefix,opt_sica)

a    = which('spm_normalise');
path = fileparts(a);
VG   = fullfile(path,'templates','EPI.nii');

sizeDataHier = 0;

for k = 1:length(subjectlist)
    
    subj = subjectlist{k};
    
    [m1,m2] = mkdir(fullfile(outfolder,'nedica',subj));
    
    % mask
    VF       = fullfile(datapath,subj,infolder,'meanepi.nii');
    maskfile = fullfile(datapath,subj,infolder,'maskepi.nii');
    cmd      = sprintf('bet %s %s',VF,maskfile);
    unix(cmd);
    cmd      = sprintf('gunzip -f %s',[maskfile '.gz']);
    unix(cmd);
    
    DirImg = dir(fullfile(datapath,subj,infolder,'RawEPI',[prefix '*.nii']));
    FileList = [];
    for j = 1:length(DirImg)
        FileList = [FileList;fullfile(datapath,subj,infolder,'RawEPI',[DirImg(j).name])];
    end
    
    sica           = FMRI_SicaOneSubject(FileList,maskfile,opt_sica);
    sica.subject   = subj;
    sica.resfolder = fullfile(outfolder,'nedica',subj);
    save(fullfile(outfolder,'nedica',subj,'sica.mat'),'sica');
    
    % DETERMINE NORMALIZATION PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%
    disp('*****************************************')
    disp('COMPONENTS NORMALISATION...')
        
    matname = '';
    VWG     = '';
    VWF     = '';
    opt_normalize.estimate.smosrc  = 8;
    opt_normalize.estimate.smoref  = 0;
    opt_normalize.estimate.regtype = 'mni';
    opt_normalize.estimate.weight  = '';
    opt_normalize.estimate.cutoff  = 25;
    opt_normalize.estimate.nits    = 16;
    opt_normalize.estimate.reg     = 1;
    opt_normalize.estimate.wtsrc   = 0;

    params_normalize = spm_normalise(VG,VF,matname,VWG,VWF,opt_normalize.estimate);
    save(fullfile(outfolder,'nedica',subj,'param_normalize.mat'),'params_normalize');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % CLUST COMP SELECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    comps     = 1:sica.nbcomp;
    d         = sica.header;
    maskBrain = sica.mask;
    s         = sica.S;
    clear sica
    opt_normalize.write.preserve = 0;
    opt_normalize.write.bb       = [-78 -112 -50 ; 78 76 85];
    
    % arbitrary voxel size %%%%%%%%%%
    opt_normalize.write.vox    = [3 3 3];       
    opt_normalize.write.interp = 7;  % spline
    opt_normalize.write.wrap   = [0 0 0];

    [m1,m2] = mkdir(fullfile(outfolder,'nedica',subj,'spatialComp'));
    delete(fullfile(outfolder,'nedica',subj,'spatialComp','wsica_comp*.*'))
    delete(fullfile(outfolder,'nedica',subj,'spatialComp','sica_comp*.*'))
    for i=1:length(comps)

        if i<10 
            d.fname = fullfile(outfolder,'nedica',subj,'spatialComp',['sica_comp000' num2str(comps(i)) '.nii']);
        elseif i<100
            d.fname = fullfile(outfolder,'nedica',subj,'spatialComp',['sica_comp00' num2str(comps(i)) '.nii']);
        else
            d.fname = fullfile(outfolder,'nedica',subj,'spatialComp',['sica_comp0' num2str(comps(i)) '.nii']);
        end	

        if length(size(s))<3
            vol = st_1Dto3D(s(:,comps(i)),maskBrain);
        else
            vol = squeeze(s(:,:,:,comps(i)));
        end
        [vol_c] = st_correct_vol(vol,maskBrain);
        spm_write_vol(d,vol_c);

        % WRITE NORMALIZED COMP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        warning('off')
        spm_write_sn(d.fname,params_normalize,opt_normalize.write);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end

    sizeDataHier  = sizeDataHier + length(comps);
    clear s a
    flagsn        = opt_normalize.write;
    flagsn.interp = 0;
    spm_write_sn(maskfile,params_normalize,flagsn);
    [path,fname,ext] = fileparts(maskfile);
    V     = spm_vol(fullfile(path,['w',fname,ext]));
    wmask = spm_read_vols(V);
    
    if k==1
        maskB = ones(size(wmask));
    end
    maskB = maskB & wmask>0;
    
end

V.fname = fullfile(outfolder,'nedica','maskB_sica.nii');
spm_write_vol(V,double(maskB));

opt_normalize.write.vox = [3 3 3];
d.fname = fullfile(outfolder,'nedica','rawVoxSize.nii');
spm_write_vol(d,double(maskBrain));
spm_write_sn(d.fname,params_normalize,opt_normalize.write);
delete(fullfile(outfolder,'nedica','rawVoxSize.nii'))

PP = fullfile(outfolder,'nedica','wrawVoxSize.nii');
PP = strvcat(PP,fullfile(outfolder,'nedica','maskB_sica.nii'));
flag_reslice.interp = 0;
flag_reslice.wrap   = [0 0 0];
flag_reslice.mask   = 1;
flag_reslice.mean   = 0;
flag_reslice.which  = 1;
spm_reslice(PP,flag_reslice)

unix(['mv ', outfolder filesep 'nedica' filesep 'rmaskB_sica.nii ', outfolder filesep 'nedica' filesep 'maskB.nii']);

clear maskBrain wmask maskB;
