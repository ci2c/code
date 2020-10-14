function FMRI_TwoSampleTtestByFMRISTAT(outdir,efFiles1,sdFiles1,efFiles2,sdFiles2,nameCon,contrast,maskFile)

addpath('/home/global/matlab_toolbox/spm12b');

if nargin < 3
    disp('not enough arguments');
    return;
end

if nargin < 4
    maskFile = '';
end

nsubj1 = size(efFiles1,1);
nsubj2 = size(efFiles2,1);
nsubjs = nsubj1 + nsubj2;
X      = zeros(nsubjs,2);
X(1:nsubj1,1) = 1;
X(nsubj1+1:nsubjs,2) = 1;

efFiles = [efFiles1; efFiles2];
sdFiles = [sdFiles1; sdFiles2];

which_stats = '_ef _sd _t _sdratio _fwhm';

fwhm_varatio = -100;

output_file_base = fullfile(outdir,nameCon);  
%df_mstat = multistat(efFiles, sdFiles, input_files_df, input_files_fwhm, X, contrast, output_file_base,which_stats, fwhm_varatio);
df_mstat = multistat(efFiles, sdFiles, [], [], X, contrast, output_file_base, which_stats, fwhm_varatio);

t_map = [output_file_base '_t.nii'];
[SUMMARY_CLUSTERS_POS SUMMARY_PEAKS_POS] = stat_summary( t_map, [], [], maskFile, [], 0.001, 1);
