function [XX,dof,sig2, brain_mask, nsubj, nr, nbleft] = bpm_ancova_surf(BPM)
%------------------------------------------------------------------------
%    This function performs the following tasks:
%
%    1) From the master flist reads all the subjects file names. 
%    2) Reads the brain mask.
%    3) Slice by slice load the data from the corresponding subjects files
%       and performs a one way ancova analysis using the glm model where it
%       is possible to use as covariates other imaging modalities data
%    4) The betas and residuals are stored in files.
%-------------------------------------------------------------------------
% Input parameters
% flist     - the name of the master flist
% maskfname - the name of the file containing the brain mask
% col_conf  - non-imaging covariates
%-------------------------------------------------------------------------
% Output parameters
% resulting from the GLM.
% XX   - cell containing 2D cells with the design matrices corresponding to
%       each voxel
% dof  - volume containing the degrees of freedom at ecah voxel
% sig2 - volume containing the variances at each voxel
% nsubj- number of subjects
% nr   - number of regressors
% brain_mask - mask containing the voxels inside the brain region
% Vtemp - information about the analyze images 
%--------------------------------------------------------------------------

flist = BPM.flist; maskfname = BPM.mask; 
col_conf = BPM.conf; XtXfname = BPM.XtX; 
type = BPM.type;
Robust_flag = BPM.robust; % if apply robust regression
Rwfun = BPM.rwfun;


%   Reading the modality files from the master file 
file_names = wfu_bpm_read_flist(flist);
no_mod = size(file_names,1);
for k = 1:no_mod
    file_names_mod{k} = file_names(k,:);    
end

%  Cell that will contain cells. Each cell element contains 
%  the file names (different groups) corresponding to a different modality 


% get the file names of the subjects 

file_names_subjs = cell(1,no_mod);        
for k = 1:no_mod
    [file_names_subjs{k},no_grp] = bpm_get_file_names_surf( file_names_mod{k} );
end

for k =1:BPM.DMS(1)
    ngsubj(k) = size(file_names_subjs{1}{k},1);
end
nsubj = sum(ngsubj);

% % ------- determining the size of the images ---------------------------%

data_surf = SurfStatReadData(file_names_subjs{1}{1}(1,:));
vec_size = length(data_surf);
data_surf_lh = SurfStatReadData(file_names_subjs{1}{1}{1,1});
nbleft   = length(data_surf_lh);

% Reading the brain mask
  
load(maskfname);
brain_mask = ~Mask;

% load the data and confound from the files
% data is a cell of arrays
data = cell(1,no_grp); 
confound = [] ;

% Reading the non-imaging covariates
if ~isempty(col_conf)
    col_conf = load(col_conf);
else 
    col_conf = [];
end

%----- Number of regressors --------------%
if strcmp(BPM.type,'REGRESSION')
    nr = sum(BPM.DMS);
else
    nr = sum(BPM.DMS)+1;
end

% Pre-allocating the memory

dof        = zeros(1,vec_size);
sig2       = zeros(1,vec_size);
beta_coef  = zeros(nr,vec_size);
E          = zeros(nsubj,vec_size);
XX         = zeros(nr*nr,vec_size);

% create output file in Big Endian for design matrix

[fid, message] = fopen(XtXfname, 'w', 'b');
if fid == -1
    disp(message);
end

for ng = 1:no_grp
    data{ng} = double(SurfStatReadData(file_names_subjs{1}{ng}));
    if no_mod > 1
        counter = 1;
        for nm = 2:no_mod
            confound{counter}{ng} = double(SurfStatReadData(file_names_subjs{nm}{ng}));
            counter = counter + 1;
        end        
    end
end

%%%%%%%%%%%%%%%%% GLM function %%%%%%%%%%%%%%%%%%%%%%%
% removing Nans from the data and confounds
data = wfu_bpm_remove_nan(data);
        
for ki = 1:max(size(confound))
    confound{ki} = wfu_bpm_remove_nan(confound{ki});    
end

[beta_coef,XX,dof,sig2,E] = bpm_glm_surf_opt(data,confound,col_conf,brain_mask,type,ngsubj,nr, beta_coef, E,sig2,dof,XX,Robust_flag,Rwfun);

% -------- Storing the beta coefficients -------------- %
        
for i = 1 : size(beta_coef,1)
    beta_coef_lh = beta_coef(i,1:nbleft);
    beta_coef_rh = beta_coef(i,nbleft+1:end);
    SurfStatWriteData(fullfile(BPM.result_dir,sprintf('%s%03d', 'lh.beta', i)), beta_coef_lh , 'b' );
    SurfStatWriteData(fullfile(BPM.result_dir,sprintf('%s%03d', 'rh.beta', i)), beta_coef_rh , 'b' );
end

% -------- Storing the residual images -------------- %

for i = 1 : size(E,1)
    E_lh = E(i,1:nbleft);
    E_rh = E(i,nbleft+1:end);
    SurfStatWriteData(fullfile(BPM.result_dir,sprintf('%s%03d', 'lh.Res', i)), E_lh , 'b' );
    SurfStatWriteData(fullfile(BPM.result_dir,sprintf('%s%03d', 'rh.Res', i)), E_rh , 'b' );
end

% store design matrix
if fid ~= -1
    count = fwrite(fid, XX, 'double');
    if count ~= prod(size(XX))
        str = sprintf('error writing X design matrix');
        disp(str);
    end
end

% close design matrix file
if fid ~= -1
    fclose(fid);
end
return
