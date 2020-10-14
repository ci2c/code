function FMRI_OneSampleTtestByFMRISTAT(outdir,efFiles,sdFiles,nameCon,maskFile)

addpath('/home/global/matlab_toolbox/spm12b');

if nargin < 3
    disp('not enough arguments');
    return;
end

if nargin < 4
    maskFile = '';
end

X = ones(size(efFiles,1),1);
        
contrast = 1;

which_stats = '_ef _sd _t _sdratio _fwhm';

fwhm_varatio = 0;

output_file_base = fullfile(outdir,nameCon);  
%df_mstat = multistat(efFiles, sdFiles, input_files_df, input_files_fwhm, X, contrast, output_file_base,which_stats, fwhm_varatio);
df_mstat = multistat(efFiles, sdFiles, [], [], X, contrast, output_file_base, which_stats, fwhm_varatio);

t_map = [output_file_base '_t.nii'];
[SUMMARY_CLUSTERS_POS SUMMARY_PEAKS_POS] = stat_summary( t_map, [], [], maskFile, [], 0.001, 1);
