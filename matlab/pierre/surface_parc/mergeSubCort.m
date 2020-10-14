function mergeSubCort(fs, subj, orig_parc_name, orig_label_list, orig_ctab, parc_prefix, new_parc_name, new_label_list, new_ctab)
% usage : mergeSubCort(FSDIR, SUBJ,...
%                      ORIG_PARC_NAME, ORIG_LABEL_LIST, ORIG_CTAB, PARC_PREFIX,...
%                      NEW_PARC_NAME, NEW_LABEL_LIST, NEW_CTAB)
%
% INPUTS :
% --------
%   FSDIR            : Path to FreeSurfer directory, i.e. SUBJECTS_DIR
%   SUBJ             : Subject's name
%
%   ORIG_PARC_NAME   : Path to the segmented volume with parcellated cortex
%                        but non parcellated sub-cortical structures.
%   ORIG_LABEL_LIST  : Path to the original label list with parcellated
%                        cortex but non parcellated sub-cortical structures
%   ORIG_CTAB        : Path to input segmentation corresponding colortable file
%   PARC_PREFIX      : Prefix to the sub-cortical parcellation map. The
%                        function expects to find the files
%                        FSDIR/SUBJ/SUBCORTICAL_ROI/PARC_PREFIX.nii
%                        for each sub-cortical structure
%
%   NEW_PARC_NAME    : Path to the output segmented volume with parcellated
%                        cortex and parcellated sub-cortical structures
%                      The output volume is placed in the same space as
%                      ORIG_PARC_NAME
%   NEW_LABEL_LIST   : Path to the output label list with parcellated cortex 
%                        and parcellated sub-cortical structures
%   NEW_CTAB         : Path to the output colortable file
%
% Pierre Besson @ CHRU Lille, Sep. 2012

if nargin ~= 9
    error('invalid usage');
end


% Read input files
V_in = spm_vol(orig_parc_name);
[Y_in, XYZ_in] = spm_read_vols(V_in);
Y_in = round(Y_in);
Y_out = zeros(size(Y_in));

fid = fopen(orig_label_list, 'r');
T = textscan(fid, '%d %s');
LOI_in = T{1};
Name_in = char(T{2});
fclose(fid);
clear T;

fid = fopen(orig_ctab);
ctab_in = textscan(fid, '%d %s %d %d %d %d');
fclose(fid);

% Initialize correspondance table
% First col  : ID in original ctab
% Second col : ID in original structure list
corresp_table = [];

% Loop on structure names and 
% check if a directory of the same name exists (== sub cort structure)
% Put NaN in third column if cortical parcellation
% Put 0 in third column if non-parcellated sub-cortical structure
% Put 1 in third column if parcellated sub-cortical structure
for i = 1 : size(LOI_in)
    if ~isempty(strfind(char(Name_in(i, :)), 'lh_')) || ~isempty(strfind(char(Name_in(i, :)), 'rh_'))
        F = find(strcmp(ctab_in{2}, deblank(char(Name_in(i, :)))));
        corresp_table = [corresp_table; F, i, NaN];
    else
        if exist(deblank([fs, '/', subj, '/', char(Name_in(i, :))]), 'dir') == 7
            disp([deblank(char(Name_in(i,:))), ' is a subcortical structure']);
            F = find(strcmp(ctab_in{2}, deblank(char(Name_in(i, :)))));
            disp(['Line in ctab : ', num2str(F), ' ; Line in structures list : ', num2str(i)]);
            corresp_table = [corresp_table; F, i, 1];
        else
            F = find(strcmp(ctab_in{2}, deblank(char(Name_in(i, :)))));
            corresp_table = [corresp_table; F, i, 0];
        end
    end
end

% predefine new ctab
% ctab_new = ctab_in;
ctab_new{1} = ctab_in{1}( corresp_table(isnan(corresp_table(:, 3)), 1) ); % Structure Value
ctab_new{2} = ctab_in{2}( corresp_table(isnan(corresp_table(:, 3)), 1) ); % Structure Name
ctab_new{3} = ctab_in{3}( corresp_table(isnan(corresp_table(:, 3)), 1) ); % R
R = ctab_new{3};
ctab_new{4} = ctab_in{4}( corresp_table(isnan(corresp_table(:, 3)), 1) ); % G
G = ctab_new{4};
ctab_new{5} = ctab_in{5}( corresp_table(isnan(corresp_table(:, 3)), 1) ); % B
B = ctab_new{5};
ctab_new{6} = ctab_in{6}( corresp_table(isnan(corresp_table(:, 3)), 1) ); % 0

sub_cort_ID = 1;
temp_table{1} = [];
temp_table{2} = [];
temp_table{3} = [];
temp_table{4} = [];
temp_table{5} = [];
temp_table{6} = [];
% Loop on found subcortical structures
for i = 1 : size(corresp_table, 1)
    if ~isnan(corresp_table(i, 3))
        if corresp_table(i,3) ~= 0
            % Load the parcellated subcort volume
            struct_name = deblank(char(Name_in(corresp_table(i, 2), :)));
            im_path = [fs, '/', subj, '/', struct_name, '/', parc_prefix, '.nii'];
            V_sub = spm_vol(im_path);
            [Y_sub, XYZ_sub] = spm_read_vols(V_sub);
            Y_sub = round(Y_sub);
            % Change its orientation matrix so it's in ORIG_PARC_NAME space
            V_sub.mat = V_in.mat;
            V_sub.dt  = V_in.dt;
            % Replace the original subcortical structure with the parcellated one
            % Y_in(Y_in == LOI_in(corresp_table(i,1))) = Y_sub(Y_in == LOI_in(corresp_table(i,1))) + sub_cort_ID - 1;
            % Y_out(Y_in == LOI_in(corresp_table(i,2))) = 0;
            Y_out(Y_sub~=0) = Y_sub(Y_sub~=0) + sub_cort_ID - 1;
            for j = 1 : max(Y_sub(:))
                temp_table{1} = [temp_table{1}; sub_cort_ID + j - 1];
                temp_table{2} = [temp_table{2}; {[deblank(char(Name_in(corresp_table(i, 2), :))), '_', num2str(j, '%.3d')]}];
                RGB = randi([1 255], 1, 3);
                while max(RGB(1) == R + RGB(2) == G + RGB(3) == B) == 3
                    RGB = randi([1 255], 1, 3);
                end
                temp_table{3} = [temp_table{3}; RGB(1)];
                R = [R; RGB(1)];
                temp_table{4} = [temp_table{4}; RGB(2)];
                G = [G; RGB(2)];
                temp_table{5} = [temp_table{5}; RGB(3)];
                B = [B; RGB(3)];
                temp_table{6} = [temp_table{6}; 0];
            end
            sub_cort_ID = sub_cort_ID + max(Y_sub(:));
        else
            % It is a sub-cortical structure but not parcellated
            % Do nothing but add +1 to sub-cort ID
            % Y_in(Y_in == LOI_in(corresp_table(i,1))) = sub_cort_ID;
            Y_out(Y_in == LOI_in(corresp_table(i,2))) = sub_cort_ID;
            RGB = randi([1 255], 1, 3);
            while max(RGB(1) == R + RGB(2) == G + RGB(3) == B) == 3
                RGB = randi([1 255], 1, 3);
            end
            temp_table{1} = [temp_table{1}; sub_cort_ID];
            temp_table{2} = [temp_table{2}; {deblank(char(Name_in(corresp_table(i, 2), :)))}];
            temp_table{3} = [temp_table{3}; RGB(1)];
            R = [R; RGB(1)];
            temp_table{4} = [temp_table{4}; RGB(2)];
            G = [G; RGB(2)];
            temp_table{5} = [temp_table{5}; RGB(3)];
            B = [B; RGB(3)];
            temp_table{6} = [temp_table{6}; 0];
            sub_cort_ID = sub_cort_ID + 1;
        end
    else
        % Cortical parcellation
        Y_out(Y_in == LOI_in(corresp_table(i,2))) = LOI_in(corresp_table(i,2));
    end
end

% Concat sub-cort parcellations to cortical parcellations
ctab_new{1} = cat(1, temp_table{1}, ctab_new{1});
ctab_new{2} = cat(1, temp_table{2}, ctab_new{2});
ctab_new{3} = cat(1, temp_table{3}, ctab_new{3});
ctab_new{4} = cat(1, temp_table{4}, ctab_new{4});
ctab_new{5} = cat(1, temp_table{5}, ctab_new{5});
ctab_new{6} = cat(1, temp_table{6}, ctab_new{6});

% Save output volume
V_in.fname = new_parc_name;
V_in.dt(1) = 16;
spm_write_vol(V_in, Y_out);

% save label list
fid  = fopen(new_label_list, 'w');
fid2 = fopen(new_ctab, 'w');
for i = 1 : length(ctab_new{1})
    fprintf(fid, '%d %s\n', ctab_new{1}(i), char(ctab_new{2}(i, :)));
    fprintf(fid2, '%d %s %d %d %d %d\n', ctab_new{1}(i), char(ctab_new{2}(i,:)), ctab_new{3}(i), ctab_new{4}(i), ctab_new{5}(i), ctab_new{6}(i));
end