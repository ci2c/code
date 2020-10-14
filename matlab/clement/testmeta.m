fid = fopen('/NAS/tupac/protocoles/Strokdem/test/temp_craddock/Ck_nodes.txt', 'r');
T   = textscan(fid, '%d');
lid = double(T{1});
fclose(fid);
clear T;

% Load first volume
[V,Y] = niak_read_vol(fullfile('/NAS/tupac/protocoles/Strokdem/test/temp_craddock/Craddock_Parc/tmp.TJCzzEHxlQ/',['wrcrad_loi_', num2str(lid(1)), '.nii']));

Labels = zeros(size(Y));
Max    = zeros(size(Y));
Labels(Y > 0.01) = lid(1);
Max(Y > 0.01)    = Y(Y > 0.01);

% Loop the volumes
for i = 2 : length(lid)
disp(['Processing step ', num2str(i), ' out of ', num2str(length(lid))]);
[V,Y] = niak_read_vol(fullfile('/NAS/tupac/protocoles/Strokdem/test/temp_craddock/Craddock_Parc/tmp.TJCzzEHxlQ/',['wrcrad_loi_', num2str(lid(i)), '.nii']));
Labels( ((Y > 0.01) .* (Y > Max)) ~=0 ) = lid(i);
Max( ((Y > 0.01) .* (Y > Max)) ~= 0 ) = Y( ((Y > 0.01) .* (Y > Max)) ~= 0 );
end
    
% Connectivity matrix
epiFiles{1}   = '/NAS/tupac/protocoles/Strokdem/test/temp_craddock/Craddock_Parc/EPI.nii';
annotFiles{1} = fullfile('/NAS/tupac/protocoles/Strokdem/test/temp_craddock/Craddock_Parc/','final_epi_crad.nii');
dovoxels      = 0;
typeCorr      = 'R';
[Cmat,labels,tseries,std_tseries] = FMRI_ConnectivityMatrixOnVolume(epiFiles,annotFiles,dovoxels,typeCorr);
Connectome             = struct();
Connectome.Cmat        = Cmat;
Connectome.labidx      = labels;
Connectome.parc        = '/NAS/tupac/protocoles/Strokdem/test/temp_craddock/Craddock_Parc/final_epi_crad.nii';
Connectome.tseries     = tseries;
Connectome.std_tseries = std_tseries;