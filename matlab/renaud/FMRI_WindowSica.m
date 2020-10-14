function FMRI_WindowSica(datapath,prefix,anatpath,outdir,nwind,overlap,TR,ncomp,normalize,VoxSize,BoundingBox)

% usage : V = FMRI_WindowSica(datapath,prefix,anatpath,outdir,nwind,overlap,TR,[ncomp])
%
% Inputs :
%    datapath      : EPI path
%    prefix        : prefix of input files
%    anatpath      : Structural path
%    outdir        : output folder
%    nwind         : number of windows
%    overlap       : overlap between two windows
%    TR            : TR value
%
% Options :
%    nbcomp        : number of components (Default: 40)
%    normalize     : boolean : true or false
%    VoxSize       : voxel size (Default: [3 3 3])
%    BoundinBox    : bounding box (Default: [-90 -126 -72;90 90 108])
%
% Renaud Lopes @ CHRU Lille, June 2012

if nargin ~= 7 && nargin ~= 8 && nargin ~= 9 && nargin ~= 10 && nargin ~= 11
    error('invalid usage');
end

default_nbcomp = 40;

% check args
if nargin < 8
    ncomp = default_nbcomp;
end
% check args
if nargin < 8
    normalize = false;
end
if nargin < 10
    VoxSize = [3 3 3];
end
if nargin < 11
    BoundingBox = [-90 -126 -72;90 90 108];
end

cur_path = pwd;

DirImg   = dir(fullfile(datapath,[prefix '*.nii']));
FileList = [];
for j = 1:length(DirImg)
    FileList = [FileList;fullfile(datapath,[DirImg(j).name])];
end

opt_sica.detrend          = 2;
opt_sica.norm             = 0;
opt_sica.slice_correction = 1;
opt_sica.algo             = 'Infomax';
opt_sica.type_nb_comp     = 0;
opt_sica.param_nb_comp    = ncomp;
opt_sica.TR               = TR;

nbframes = size(FileList,1);
timeline = [0:TR:(nbframes-1)*TR];
d        = [];
windows  = FMRI_GetWindows(timeline,nwind,overlap,d);
nw       = size(windows,1);
mw       = mean(windows,2);

for k = 1:nw
    
    F         = FileList(windows(k,:)',:);
    list_f{1} = F;
    sica      = FMRI_Sica(list_f,opt_sica);
        
    comps     = 1:sica.nbcomp;
    d         = sica.header;
    maskBrain = sica.mask;
    s         = sica.S;

    [m1,m2] = mkdir(outdir,['spatialComp_' num2str(k)]);
    delete(fullfile(outdir,['spatialComp_' num2str(k)],'wsica_comp*.*'))
    delete(fullfile(outdir,['spatialComp_' num2str(k)],'sica_comp*.*'))

    save(fullfile(outdir,['spatialComp_' num2str(k)],'sica.mat'),'sica');
    clear sica;

    for i = 1:length(comps)

        if i<10 
            d.fname = fullfile(outdir,['spatialComp_' num2str(k)],['sica_comp000' num2str(comps(i)) '.nii']);
        elseif i<100
            d.fname = fullfile(outdir,['spatialComp_' num2str(k)],['sica_comp00' num2str(comps(i)) '.nii']);
        else
            d.fname = fullfile(outdir,['spatialComp_' num2str(k)],['sica_comp0' num2str(comps(i)) '.nii']);
        end	

        if length(size(s))<3
            vol = st_1Dto3D(s(:,comps(i)),maskBrain);
        else
            vol = squeeze(s(:,:,:,comps(i)));
        end
        vol_c   = st_correct_vol(vol,maskBrain);
        st_write_analyze(vol_c,d,d.fname);

    end

    if(normalize)
        % DARTEL: Normalize to MNI space - Functional Images.
        load('FMRI_Dartel_NormaliseToMNI_FewSubjects.mat');

        matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm     = [0 0 0];
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb       = BoundingBox;
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox      = VoxSize;

        DirImg = dir(fullfile(anatpath,'Template_6.*'));
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.template = {fullfile(anatpath,DirImg(1).name)};

        cd(fullfile(outdir,['spatialComp_' num2str(k)]));

        DirImg = dir('sica_comp*.nii');
        CompList = [];
        for j = 1:length(DirImg)
            CompList = [CompList;{fullfile(outdir,['spatialComp_' num2str(k)],DirImg(j).name)}];
        end

        matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images = CompList;

        DirImg = dir(fullfile(anatpath,'u_*'));
        matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield = {fullfile(anatpath,DirImg(1).name)};

        cd('..');
        fprintf(['Normalization by using DARTEL Setup: ',outdir,' OK']);

        fprintf('\n');
        spm_jobman('run',matlabbatch);

        cd(cur_path);
    end
    
end


