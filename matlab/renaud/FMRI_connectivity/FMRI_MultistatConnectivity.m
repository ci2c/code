clear all;
close all;

subjects = {'sub05676','sub08224','sub08889','sub09607','sub14864','sub18604'};
dataroot = 'C:\Users\Seb\Downloads\NYU_TRT_session2a';

for j = 1:length(subjects)
    input_files_Y(j,:) = fullfile(dataroot,subjects{j},'func\tmap_seed_001_mag_ef.nii');
    input_files_sd(j,:)= fullfile(dataroot,subjects{j},'func\tmap_seed_001_mag_sd.nii');
end

X = ones(length(subjects),1);
        
contrast = 1;

which_stats = '_ef _sd _t _sdratio _fwhm';

fwhm_varatio = -100;

output_file_base = fullfile(dataroot,'group_seed');  
%df_mstat = multistat(input_files_Y, input_files_sd, input_files_df, input_files_fwhm, X, contrast, output_file_base,which_stats, fwhm_varatio);
df_mstat = multistat(input_files_Y, input_files_sd, [], [], X, contrast, output_file_base,which_stats, fwhm_varatio);

t_map = [output_file_base '_t.nii'];
[SUMMARY_CLUSTERS_POS SUMMARY_PEAKS_POS] = stat_summary( t_map, [], [], [], [], 0.001, 1);