%%
% 
% Generate_variables allows you to manage secondary variables 
% for automatic classification of Focal Cortical Dysplasia
% 
% It concerns actions which don't need to be modified each time (creating
% of folders, loading data, ...)
% 
% It need to be used before each use of classification.
%
% It adds some fields to the Matlab structure init (created by initvar)
% 
% usage : generate_variables;
% 
% 
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012



%%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012

%% Random selection of a control name
% 
% Data will be normalize on a control subject
% This subject is randomly selected
%
% If you want to fix it, you can write "init.ref = 'name_of_control' ".
%
% Example : 
% init.ref_num = round(1+(length(init.cont)-1)*rand);
% init.ref = init.cont{init.ref_num};
% sprintf(strcat('\n \npatient selected for normalization : \n \n',init.ref,'\n \n'))


init.ref_num = floor(1+(length(init.cont))*rand);
init.ref = init.cont{init.ref_num};
msg = sprintf(strcat('\n \npatient selected for normalization : \n \n',init.ref,'\n \n'));
disp(msg); clear msg

%% Creatinh template folders
%

if exist(strcat(init.temp_dir,'/normalization')) ~= 7
    disp('creating the folder for the normalization template');
    mkdir(strcat(init.temp_dir,'/normalization'));
end


if exist(strcat(init.temp_dir,'/zscore')) ~= 7
    disp('creating the folder for zscore template');
    mkdir(strcat(init.temp_dir,'/zscore'));
end

%% Reading Surface template & Mask
%
% The way to find them is into initvar
%
% init.fsaverage_dir & init.mask_way are removed after use

% Loading Surface

init.Surf = SurfStatReadSurf({strcat(init.fsaverage_dir,'surf/lh.white') strcat(init.fsaverage_dir,'surf/rh.white')});

init = rmfield(init,'fsaverage_dir');

% Loading Mask
%
% If init.mask_way = '', the mask is null

if isempty(init.mask_way)
    init.mask = zeros(size(init.Surf.coord,2));
else
    load(init.mask_way)
    init.Mask = Mask;
    init.lh_mask = init.Mask(1:length(init.Mask)/2);
    init.rh_mask = init.Mask((length(init.Mask)/2)+1:end);
end

clear Mask
init = rmfield(init,'mask_way');


%% Number of features
%
% Sum of features for T1, FLAIR & TEP

init.size = length(init.features) + length(init.features_flair);


