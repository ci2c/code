function computeFeaturesZscore(fs, subj, template_dir, fwhm)
% 
% usage : computeFeaturesZscore(FS, SUBJ, TEMPLATE_DIR, FWHM)
%
% Z-scores subject's features w.r.t. template features.
%
% Requires Surface_features.sh to be processed on SUBJ !
%
% Inputs :
%      FS            : Freesurfer dir. Equivalent to $SUBJECTS_DIR
%      SUBJ          : Subject ID
%      TEMPLATE_DIR  : Directory of template's features
%      FWHM          : Blur of surface features (FWHM must be set to 5 or 10 or 15 or 20 or 25)
%
% Pierre Besson @ CHRU Lille, 2011

if nargin ~= 4
    error('invalid usage');
end

if ~ismember(fwhm, [5 10 15 20 25])
    error('invalid FWHM');
end

% Load template features
lh_grad_mean_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.mean.dxyz');
rh_grad_mean_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.mean.dxyz');
lh_int_mean_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.mean.intensity');
rh_int_mean_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.mean.intensity');
lh_thick_mean_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.mean.thickness');
rh_thick_mean_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.mean.thickness');
lh_depth_mean_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.mean.depth');
rh_depth_mean_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.mean.depth');
lh_curv_mean_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.mean.curv');
rh_curv_mean_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.mean.curv');
lh_comp_mean_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.mean.complexity');
rh_comp_mean_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.mean.complexity');

lh_grad_std_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.std.dxyz');
rh_grad_std_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.std.dxyz');
lh_int_std_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.std.intensity');
rh_int_std_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.std.intensity');
lh_thick_std_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.std.thickness');
rh_thick_std_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.std.thickness');
lh_depth_std_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.std.depth');
rh_depth_std_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.std.depth');
lh_curv_std_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.std.curv');
rh_curv_std_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.std.curv');
lh_comp_std_path = strcat(template_dir, '/', 'lh.fwhm', num2str(fwhm), '.fsaverage.std.complexity');
rh_comp_std_path = strcat(template_dir, '/', 'rh.fwhm', num2str(fwhm), '.fsaverage.std.complexity');

[lh_grad_mean, fnum] = read_curv(lh_grad_mean_path);
[rh_grad_mean, fnum] = read_curv(rh_grad_mean_path);
[lh_int_mean, fnum] = read_curv(lh_int_mean_path);
[rh_int_mean, fnum] = read_curv(rh_int_mean_path);
[lh_thick_mean, fnum] = read_curv(lh_thick_mean_path);
[rh_thick_mean, fnum] = read_curv(rh_thick_mean_path);
[lh_depth_mean, fnum] = read_curv(lh_depth_mean_path);
[rh_depth_mean, fnum] = read_curv(rh_depth_mean_path);
[lh_curv_mean, fnum] = read_curv(lh_curv_mean_path);
[rh_curv_mean, fnum] = read_curv(rh_curv_mean_path);
[lh_comp_mean, fnum] = read_curv(lh_comp_mean_path);
[rh_comp_mean, fnum] = read_curv(rh_comp_mean_path);
[lh_grad_std, fnum] = read_curv(lh_grad_std_path);
[rh_grad_std, fnum] = read_curv(rh_grad_std_path);
[lh_int_std, fnum] = read_curv(lh_int_std_path);
[rh_int_std, fnum] = read_curv(rh_int_std_path);
[lh_thick_std, fnum] = read_curv(lh_thick_std_path);
[rh_thick_std, fnum] = read_curv(rh_thick_std_path);
[lh_depth_std, fnum] = read_curv(lh_depth_std_path);
[rh_depth_std, fnum] = read_curv(rh_depth_std_path);
[lh_curv_std, fnum] = read_curv(lh_curv_std_path);
[rh_curv_std, fnum] = read_curv(rh_curv_std_path);
[lh_comp_std, fnum] = read_curv(lh_comp_std_path);
[rh_comp_std, fnum] = read_curv(rh_comp_std_path);

% Load subject features
lh_grad_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.dxyz.mgh');
rh_grad_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.dxyz.mgh');
lh_int_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.intensity.mgh');
rh_int_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.intensity.mgh');
lh_thick_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.thickness.mgh');
rh_thick_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.thickness.mgh');
lh_depth_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.depth.mgh');
rh_depth_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.depth.mgh');
lh_curv_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.curv.mgh');
rh_curv_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.curv.mgh');
lh_comp_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.complexity.mgh');
rh_comp_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.complexity.mgh');

lh_grad = SurfStatReadData(lh_grad_path);
rh_grad = SurfStatReadData(rh_grad_path);
lh_int = SurfStatReadData(lh_int_path);
rh_int = SurfStatReadData(rh_int_path);
lh_thick = SurfStatReadData(lh_thick_path);
rh_thick = SurfStatReadData(rh_thick_path);
lh_depth = SurfStatReadData(lh_depth_path);
rh_depth = SurfStatReadData(rh_depth_path);
lh_curv = SurfStatReadData(lh_curv_path);
rh_curv = SurfStatReadData(rh_curv_path);
lh_comp = SurfStatReadData(lh_comp_path);
rh_comp = SurfStatReadData(rh_comp_path);

% Computes z-score maps
lh_grad = (lh_grad - median(lh_grad)) ./ (prctile(lh_grad, 70) - prctile(lh_grad, 30));
lh_grad = lh_grad .* (prctile(lh_grad_mean, 70) - prctile(lh_grad_mean, 30)) + median(lh_grad_mean);
rh_grad = (rh_grad - median(rh_grad)) ./ (prctile(rh_grad, 70) - prctile(rh_grad, 30));
rh_grad = rh_grad .* (prctile(rh_grad_mean, 70) - prctile(rh_grad_mean, 30)) + median(rh_grad_mean);

lh_int = (lh_int - median(lh_int)) ./ (prctile(lh_int, 70) - prctile(lh_int, 30));
lh_int = lh_int .* (prctile(lh_int_mean, 70) - prctile(lh_int_mean, 30)) + median(lh_int_mean);
rh_int = (rh_int - median(rh_int)) ./ (prctile(rh_int, 70) - prctile(rh_int, 30));
rh_int = rh_int .* (prctile(rh_int_mean, 70) - prctile(rh_int_mean, 30)) + median(rh_int_mean);

lh_thick = (lh_thick - median(lh_thick)) ./ (prctile(lh_thick, 70) - prctile(lh_thick, 30));
lh_thick = lh_thick .* (prctile(lh_thick_mean, 70) - prctile(lh_thick_mean, 30)) + median(lh_thick_mean);
rh_thick = (rh_thick - median(rh_thick)) ./ (prctile(rh_thick, 70) - prctile(rh_thick, 30));
rh_thick = rh_thick .* (prctile(rh_thick_mean, 70) - prctile(rh_thick_mean, 30)) + median(rh_thick_mean);

lh_depth = (lh_depth - median(lh_depth)) ./ (prctile(lh_depth, 70) - prctile(lh_depth, 30));
lh_depth = lh_depth .* (prctile(lh_depth_mean, 70) - prctile(lh_depth_mean, 30)) + median(lh_depth_mean);
rh_depth = (rh_depth - median(rh_depth)) ./ (prctile(rh_depth, 70) - prctile(rh_depth, 30));
rh_depth = rh_depth .* (prctile(rh_depth_mean, 70) - prctile(rh_depth_mean, 30)) + median(rh_depth_mean);

lh_curv = (lh_curv - median(lh_curv)) ./ (prctile(lh_curv, 70) - prctile(lh_curv, 30));
lh_curv = lh_curv .* (prctile(lh_curv_mean, 70) - prctile(lh_curv_mean, 30)) + median(lh_curv_mean);
rh_curv = (rh_curv - median(rh_curv)) ./ (prctile(rh_curv, 70) - prctile(rh_curv, 30));
rh_curv = rh_curv .* (prctile(rh_curv_mean, 70) - prctile(rh_curv_mean, 30)) + median(rh_curv_mean);

lh_comp = (lh_comp - median(lh_comp)) ./ (prctile(lh_comp, 70) - prctile(lh_comp, 30));
lh_comp = lh_comp .* (prctile(lh_comp_mean, 70) - prctile(lh_comp_mean, 30)) + median(lh_comp_mean);
rh_comp = (rh_comp - median(rh_comp)) ./ (prctile(rh_comp, 70) - prctile(rh_comp, 30));
rh_comp = rh_comp .* (prctile(rh_comp_mean, 70) - prctile(rh_comp_mean, 30)) + median(rh_comp_mean);


lh_grad_z = (lh_grad - lh_grad_mean') ./ lh_grad_std';
rh_grad_z = (rh_grad - rh_grad_mean') ./ rh_grad_std';
lh_int_z = (lh_int - lh_int_mean') ./ lh_int_std';
rh_int_z = (rh_int - rh_int_mean') ./ rh_int_std';
lh_thick_z = (lh_thick - lh_thick_mean') ./ lh_thick_std';
rh_thick_z = (rh_thick - rh_thick_mean') ./ rh_thick_std';
lh_depth_z = (lh_depth - lh_depth_mean') ./ lh_depth_std';
rh_depth_z = (rh_depth - rh_depth_mean') ./ rh_depth_std';
lh_curv_z = (lh_curv - lh_curv_mean') ./ lh_curv_std';
rh_curv_z = (rh_curv - rh_curv_mean') ./ rh_curv_std';
lh_comp_z = (lh_comp - lh_comp_mean') ./ lh_comp_std';
rh_comp_z = (rh_comp - rh_comp_mean') ./ rh_comp_std';

% Clean z-scores
lh_grad_z(isnan(lh_grad_z) | isinf(lh_grad_z)) = 0;
rh_grad_z(isnan(rh_grad_z) | isinf(rh_grad_z)) = 0;
lh_int_z(isnan(lh_int_z) | isinf(lh_int_z)) = 0;
rh_int_z(isnan(rh_int_z) | isinf(rh_int_z)) = 0;
lh_thick_z(isnan(lh_thick_z) | isinf(lh_thick_z)) = 0;
rh_thick_z(isnan(rh_thick_z) | isinf(rh_thick_z)) = 0;
lh_depth_z(isnan(lh_depth_z) | isinf(lh_depth_z)) = 0;
rh_depth_z(isnan(rh_depth_z) | isinf(rh_depth_z)) = 0;
lh_curv_z(isnan(lh_curv_z) | isinf(lh_curv_z)) = 0;
rh_curv_z(isnan(rh_curv_z) | isinf(rh_curv_z)) = 0;
lh_comp_z(isnan(lh_comp_z) | isinf(lh_comp_z)) = 0;
rh_comp_z(isnan(rh_comp_z) | isinf(rh_comp_z)) = 0;

% Save data
lh_grad_z_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.zscore.dxyz');
rh_grad_z_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.zscore.dxyz');
lh_int_z_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.zscore.intensity');
rh_int_z_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.zscore.intensity');
lh_thick_z_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.zscore.thickness');
rh_thick_z_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.zscore.thickness');
lh_depth_z_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.zscore.depth');
rh_depth_z_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.zscore.depth');
lh_curv_z_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.zscore.curv');
rh_curv_z_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.zscore.curv');
lh_comp_z_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.zscore.complexity');
rh_comp_z_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.zscore.complexity');

% write_curv(lh_grad_z_path, lh_grad_z', fnum);
% write_curv(rh_grad_z_path, rh_grad_z', fnum);
% write_curv(lh_int_z_path, lh_int_z', fnum);
% write_curv(rh_int_z_path, rh_int_z', fnum);
% write_curv(lh_thick_z_path, lh_thick_z', fnum);
% write_curv(rh_thick_z_path, rh_thick_z', fnum);
% write_curv(lh_depth_z_path, lh_depth_z', fnum);
% write_curv(rh_depth_z_path, rh_depth_z', fnum);
% write_curv(lh_curv_z_path, lh_curv_z', fnum);
% write_curv(rh_curv_z_path, rh_curv_z', fnum);

write_curv_properly(lh_grad_z, lh_grad_z_path);
write_curv_properly(rh_grad_z, rh_grad_z_path);
write_curv_properly(lh_int_z, lh_int_z_path);
write_curv_properly(rh_int_z, rh_int_z_path);
write_curv_properly(lh_thick_z, lh_thick_z_path);
write_curv_properly(rh_thick_z, rh_thick_z_path);
write_curv_properly(lh_depth_z, lh_depth_z_path);
write_curv_properly(rh_depth_z, rh_depth_z_path);
write_curv_properly(lh_curv_z, lh_curv_z_path);
write_curv_properly(rh_curv_z, rh_curv_z_path);
write_curv_properly(lh_comp_z, lh_comp_z_path);
write_curv_properly(rh_comp_z, rh_comp_z_path);

% Compute and save composite z-score map
lh_composite_z = lh_int_z + lh_thick_z - lh_grad_z;
rh_composite_z = rh_int_z + rh_thick_z - rh_grad_z;
lh_composite_z_path = strcat(fs, '/', subj, '/epilepsy/lh.fwhm', num2str(fwhm), '.fsaverage.composite');
rh_composite_z_path = strcat(fs, '/', subj, '/epilepsy/rh.fwhm', num2str(fwhm), '.fsaverage.composite');
write_curv_properly(lh_composite_z, lh_composite_z_path);
write_curv_properly(rh_composite_z, rh_composite_z_path);