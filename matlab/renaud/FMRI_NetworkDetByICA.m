function FMRI_NetworkDetByICA(datapath,subjfile,outfolder,prefix,opt_ned)

% usage : FMRI_NetworkDetByICA(datapath,subjfile,outfolder,prefix,opt_ned)
%
% Inputs :
%    datapath        : path to data
%    subjfile        : subject list (.txt)
%    outfolder       : output folder
%    prefix          : preprocess fmri prefix
%    opt_ned         : structure: Ncomp = number of components
%                                 TR = TR value
%                                 numvox = minimum size of clusters
%                                 threshT = threshold value
%                                 Ttype = type of thresholding
%
%
% Renaud Lopes @ CHRU Lille, June 2012

if nargin ~= 5
    error('invalid usage');
end

infolder = 'fmri/spm';

[m1,m2]  = mkdir(fullfile(outfolder,'nedica'));

%% READ SUBJECTS
fid = fopen( subjfile );
if fid == -1
    error( [ 'cannot open file ' subjfile ] );
end
value = fgetl( fid );
row   = 1;
while ~isnumeric(value)
    subjectlist{row} = value;
    row   = row+1;
    value = fgetl( fid );
end
fclose( fid );
    
%% ICA decomposition

% opt_sica.detrend          = 2;
% opt_sica.norm             = 0;
% opt_sica.slice_correction = 1;
% opt_sica.algo             = 'Infomax';
% opt_sica.type_nb_comp     = 0;
% opt_sica.param_nb_comp    = opt_ned.Ncomp;
% opt_sica.TR               = opt_ned.TR;
% 
% sizeDataHier = FMRI_SicaAllSubjects(datapath,infolder,outfolder,subjectlist,prefix,opt_sica);
%  
% save(fullfile(outfolder,'nedica','sizeDataHier.mat'),'sizeDataHier');
% 
% 
% %% HIERARCHICAL CLUSTERING
% 
% [resClust,dataHier] = FMRI_HierClustering(outfolder,subjectlist,opt_ned.Ncomp);
% 
% resClust.subjects = subjectlist;
% 
% save(fullfile(outfolder,'nedica','resClust.mat'),'resClust');
% save(fullfile(outfolder,'nedica','resClustData.mat'),'dataHier');
% 
% clear dataHier;


%% CLASSES DETERMINATION

maskfile = fullfile(outfolder,'nedica','maskB.nii');
load(fullfile(outfolder,'nedica','resClust.mat'),'resClust');

opt.numvox        = opt_ned.numvox;
opt.thresT        = opt_ned.threshT;
opt.nbclasses     = 15;
opt.thresHierType = 'auto'; % 'manual' 
opt.typeCorr      = opt_ned.Ttype; % 'BONF' or 'FDR' or 'UNC'

[nbclasses,resClust] = FMRI_ClassesDetermination(fullfile(outfolder,'nedica'),resClust,maskfile,subjectlist,opt);
save(fullfile(outfolder,'nedica','resClust.mat'),'resClust');

%% THRESHOLDING

load(fullfile(outfolder,'nedica','resClust.mat'),'resClust');
resClust = FMRI_Thresholding(fullfile(outfolder,'nedica'),resClust,opt);
save(fullfile(outfolder,'nedica','resClust.mat'),'resClust');

%% Display components with factors (represent and unicity) higher than threshold value

load(fullfile(outfolder,'nedica','resClust.mat'),'resClust');

thresF = 0.8;
keepC  = [];
for k = 1:length(resClust.represent)
    if(resClust.represent(k)>thresF && resClust.unicity(k)>thresF)
        keepC = [keepC k];
    end
end
resClust.keepC = keepC;
disp(keepC)

save(fullfile(outfolder,'nedica','resClust.mat'),'resClust');

