function call_ica_asl(basepath,resultdir)

% 
% basepath       = '/home/fatmike/aurelien/ASL/multi-TI/temoin01/temoin01_04/process/test/';
% resultdir      = '/home/fatmike/aurelien/ASL/multi-TI/temoin01/SICA_tempoin';
selectionName  = 'selection_1';
preprocessSICA = 'preprocess_SICA';

if(~exist([resultdir filesep selectionName]))
    [m1,m2] = mkdir(resultdir,selectionName);
end

flag.force   = 0;
removeSICA   = 0;
noise_comps  = [4 5 6 7 8 9 10];
sizeDataHier = 0;
numComps     = {};
test         = 1;

%% LOAD DATA

pathtemp=fileparts(basepath);
f=dir(basepath);
j=0;

for i=1:length(f);
    if ~f(i).isdir 
        y=1;
        if y && ~isempty(strfind(f(i).name, '.nii'))
        j=j+1;
        list_files(j,:)=fullfile(pathtemp,f(i).name);
        end
    end
end
% 
% try
% list_files=files_get(Inf,'*.img','Choose files',basepath);
% if isempty(list_files)
%     return;
% end
% catch exception
%         [list_files pathname]=uigetfiles('*.img','Pick files','MultiSelect','on');
% end
%         
            
%% SICA
if ~exist([resultdir filesep 'sica.mat']) || flag.force == 1
    opt_sica.detrend          = 2;
    opt_sica.norm             = 0;
    opt_sica.slice_correction = 0;
    opt_sica.algo             = 'Infomax';
    opt_sica.type_nb_comp     = 0;
    opt_sica.param_nb_comp    = 10;
    opt_sica.TR               = 3;

    sica = script_sica2(list_files,opt_sica);

    save([resultdir filesep 'sica.mat'],'list_files','sica','opt_sica');
else
    load([resultdir filesep 'sica.mat'],'list_files','sica','opt_sica');
end

% DETERMINE NORMALIZATION PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%
disp('*****************************************')
disp('COMPONENTS NORMALISATION...')
a = which('spm_normalise');
[path] = fileparts(a);
    
%---------compatibility with SPM5
if strcmp(spm('ver'),'SPM2')
    VG = fullfile(path,'templates','EPI.mnc');
elseif strcmp(spm('ver'),'SPM8')
    VG = fullfile(path,'templates','EPI.nii');
end

%------------------------------------

VF = list_files(1,:);
matname = '';
VWG = '';
VWF = '';
opt_normalize.estimate.smosrc = 8;
opt_normalize.estimate.smoref = 0;
opt_normalize.estimate.regtype = 'mni';
opt_normalize.estimate.weight = '';
opt_normalize.estimate.cutoff = 25;
opt_normalize.estimate.nits = 16;
opt_normalize.estimate.reg = 1;
opt_normalize.estimate.wtsrc = 0;

if ~exist([resultdir filesep 'param_normalize.mat']) || flag.force == 1
    params_normalize = spm_normalise(VG,VF,matname,VWG,VWF,opt_normalize.estimate);
    save([resultdir filesep 'param_normalize.mat'],'params_normalize');
else
    load([resultdir filesep 'param_normalize.mat'],'params_normalize');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CLUST COMP SELECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
comps     = 1:sica.nbcomp;
d         = sica.header;
maskBrain = sica.mask;
s         = sica.S;
clear sica
opt_normalize.write.preserve = 0;
opt_normalize.write.bb = [-78 -112 -50 ; 78 76 85];
%opt_normalize.write.bb = [-90 -126 -72 ; 90 90 108];
    
%% voxel size as raw data %%%%%%%%%
opt_normalize.write.vox = sqrt(sum(d.mat(1:3,1:3).^2));
%% arbitrary voxel size %%%%%%%%%%
%opt_normalize.write.vox = [3 3 3];   
    
opt_normalize.write.interp = 1;
opt_normalize.write.wrap = [0 0 0];
if ~exist([resultdir filesep 'spatialComp']) || flag.force == 1
    if ~exist([resultdir filesep 'spatialComp' filesep 'wsica_comp0001.nii']) || flag.force == 1
        [m1,m2] = mkdir(resultdir,'spatialComp');
        delete([resultdir filesep 'spatialComp' filesep 'wsica_comp*.*'])
        delete([resultdir filesep 'spatialComp' filesep 'sica_comp*.*'])
        for i=1:length(comps)
		
    		if i<10 
             	d.fname = [resultdir filesep 'spatialComp' filesep 'sica_comp000' num2str(comps(i)) '.nii'];
            elseif i<100
                d.fname = [resultdir filesep 'spatialComp' filesep 'sica_comp00' num2str(comps(i)) '.nii'];
            else
                d.fname = [resultdir filesep 'spatialComp' filesep 'sica_comp0' num2str(comps(i)) '.nii'];
            end	

            if length(size(s))<3
                vol = st_1Dto3D(s(:,comps(i)),maskBrain);
            else
                vol = squeeze(s(:,:,:,comps(i)));
            end
            [vol_c] = st_correct_vol(vol,maskBrain);
            st_write_analyze(vol_c,d,d.fname);

            % WRITE NORMALIZED COMP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            warning('off')
            spm_write_sn(d.fname,params_normalize,opt_normalize.write);

        end
    end
end
sizeDataHier = sizeDataHier + length(comps);
clear s a
d.fname = [resultdir filesep 'maskB.nii'];
st_write_analyze(double(maskBrain),d,d.fname);
flagsn = opt_normalize.write;
flagsn.interp = 0;
spm_write_sn(d.fname,params_normalize,flagsn);
[path,fname,ext] = fileparts(d.fname);
[wmask,V] = st_read_analyze(['w',fname,ext],path,0);
if test
    maskB = ones(size(wmask));
    test = 0;
end
maskB = maskB & wmask>0;

V.fname = [resultdir filesep selectionName filesep 'maskB_sica.nii'];
st_write_analyze(double(maskB),V,V.fname);

opt_normalize.write.vox = sqrt(sum(d.mat(1:3,1:3).^2));
d.fname = [resultdir filesep selectionName filesep 'rawVoxSize.nii'];
st_write_analyze(double(maskBrain),d,d.fname);
spm_write_sn(d.fname,params_normalize,opt_normalize.write);
delete([resultdir filesep selectionName filesep 'rawVoxSize.nii'])
%delete([resultdir filesep selectionName filesep 'rawVoxSize.hdr'])

PP = [resultdir filesep selectionName filesep 'wrawVoxSize.nii'];
PP = strvcat(PP,[resultdir filesep selectionName filesep 'maskB_sica.nii']);
flag_reslice.interp = 0;
flag_reslice.wrap = [0 0 0];
flag_reslice.mask = 1;
flag_reslice.mean = 0;
flag_reslice.which = 1;
spm_reslice(PP,flag_reslice)

if(isunix)
    unix(['mv ', resultdir filesep selectionName filesep 'rmaskB_sica.nii ', resultdir filesep selectionName filesep 'maskB.nii']);
   % unix(['mv ', resultdir filesep selectionName filesep 'rmaskB_sica.hdr ', resultdir filesep selectionName filesep 'maskB.hdr']);
elseif(ispc)
    movefile([resultdir filesep selectionName filesep 'rmaskB_sica.nii'],[resultdir filesep selectionName filesep 'maskB.nii']);
   % movefile([resultdir filesep selectionName filesep 'rmaskB_sica.hdr'],[resultdir filesep selectionName filesep 'maskB.hdr']);
end


save([resultdir filesep selectionName filesep 'sizeDataHier.mat'],'sizeDataHier');
clear vol vol_c maskBrain wmask

%%%%%%%%%%%%%%% fin do_sica %%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% REMOVE COMPONENTS:
if(removeSICA==1)
    load([resultdir filesep 'sica.mat'],'list_files','sica','opt_sica');
    opt_data_r.comps  = noise_comps;
    opt_data_r.addres = 1;
    nt                = size(sica.data_name,1);
    data              = st_suppress_comp(sica,opt_data_r);

    if strcmp(spm('ver'),'SPM8')    
        sica.header.dt = [16 0];
    end

    header = sica.header;

    files   = list_files;
    files2  = '';
    if(~exist([resultdir filesep preprocessSICA]))
        [m1,m2] = mkdir(resultdir,preprocessSICA);
    end
    outpath = [resultdir filesep preprocessSICA];
    for num_t = 1:nt
        [pname,fname,ext] = fileparts(files(num_t,:));
        fname             = strcat('c',fname,ext);
        files2            = strvcat(files2,fullfile(outpath,fname));
    end
    st_write_vol(data,header,files2);
    varRem = round(100*sum(sica.contrib(noise_comps)));
    disp([num2str(varRem) '% of data variance removed'])
    clear data
end



 