function [Tmap, dof, C, brain_mask, Ts, nbleft] = bpm_correlation_surf(BPM)
%----------------------------------------------------------------------------%
%                        BPM Correlation                                     %                         
%  This function is for carrying out correlation between two data sets       %
%  coming for different imaging modalities.  The correlation is computed     %
%  voxelwise voxel and one slice at a time.                                  %
%  --------------------------------------------------------------------------%
% Input parameters                                                           %
%       BPM structure                                                        %
% ---------------------------------------------------------------------------%
% Output parameters                                                          %
% Tmap        - generated Tmap                                               % 
% dof         - degrees of freedom                                           %
% C           - Correlation field                                            %
% brain_mask  - brain mask                                                   %
% Ts          - Total number of subjects                                     %
% Vtemp       - header of the analyze file                                   %
%----------------------------------------------------------------------------%

flist = BPM.flist; maskfname = BPM.mask; 
% --------- Reading the master file ------------------------------------%

file_names = wfu_bpm_read_flist(flist);
no_mod = size(file_names,1);
for k = 1:no_mod
    file_names_mod{k} = file_names(k,:);    
end

% Cell that will contain cells. Each cell element contains the file
% names (different groups) corresponding to a different modality.

file_names_subjs = cell(1,no_mod);    
% ------- get the file names of the subjects ---------------------------%
for k = 1:no_mod
    [file_names_subjs{k},no_grp] = bpm_get_file_names_surf( file_names_mod{k} );
end

Ts  = size(file_names_subjs{1}{1},1);

% -------- determining the size of the images ----------%
data_surf = SurfStatReadData(file_names_subjs{1}{1}(1,:));
vec_size = length(data_surf);
data_surf_lh = SurfStatReadData(file_names_subjs{1}{1}{1,1});
nbleft   = length(data_surf_lh);

% -------- Reading the brain mask -------------------%
load(maskfname);
brain_mask = ~Mask;

data = cell(1,2);  

% Pre-allocating the memory
Tmap       = zeros(1,vec_size);
C          = zeros(1,vec_size);
E          = zeros(Ts,vec_size);

% -------- Reading the data ------------------%
data{1} = double(SurfStatReadData(file_names_subjs{1}{1}));
data{2} = double(SurfStatReadData(file_names_subjs{2}{1}));
% -------- removing Nans from the data----------%
data = wfu_bpm_remove_nan(data);
% -------- computing the correlation coeffients and Tmap------%
[Tmap, dof, C, E]   = bpm_cc_tmap_res_surf(data, brain_mask, Tmap, C, E, Ts);
% -------- Storing the residual images -------------- %
for i = 1 : Ts
    E_lh = E(i,1:nbleft);        
    E_rh = E(i,nbleft+1:end);            
    SurfStatWriteData(fullfile(BPM.result_dir,sprintf('%s%03d', 'lh.Res', i)), E_lh , 'b' );     
    SurfStatWriteData(fullfile(BPM.result_dir,sprintf('%s%03d', 'rh.Res', i)), E_rh , 'b' );       
end
return


