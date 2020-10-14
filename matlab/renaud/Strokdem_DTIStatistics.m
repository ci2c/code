function stats = Strokdem_DTIStatistics(fsdir,subjid,mapname,labelname,visu)

global X Y

if nargin < 4
    visu = 1;
end

map_hdr = spm_vol(fullfile(fsdir,subjid,'dti','warp',['rdata_corr_' mapname '.nii']));
map     = spm_read_vols(map_hdr);

map = map(:);

switch labelname
    case 'brainmask'
        if( ~exist(fullfile(fsdir,subjid,'dti','warp','brainmask.nii')) )
            cmd = sprintf('mri_convert %s %s --out_orientation RAS', fullfile(fsdir,subjid,'mri','brainmask.mgz'), fullfile(fsdir,subjid,'dti','warp','brainmask.nii'));
            unix(cmd);
        end
        mask_hdr  = spm_vol(fullfile(fsdir,subjid,'dti','warp','brainmask.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:)>0;        
    case 'greymatter'
        if( ~exist(fullfile(fsdir,subjid,'dti','warp','ribbon.nii')) )
            cmd = sprintf('mri_convert %s %s --out_orientation RAS', fullfile(fsdir,subjid,'mri','ribbon.mgz'), fullfile(fsdir,subjid,'dti','warp','ribbon.nii'));
            unix(cmd);
        end
        mask_hdr  = spm_vol(fullfile(fsdir,subjid,'dti','warp','ribbon.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:);
        mask      = mask==42 | mask==3;
    case 'whitematter'
        if( ~exist(fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii')) )
            cmd = sprintf('mri_convert %s %s --out_orientation RAS', fullfile(fsdir,subjid,'mri','aparc.a2009s+aseg.mgz'), fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii'));
            unix(cmd);
        end
        mask_hdr  = spm_vol(fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:);
        mask      = mask==41 | mask==2;
    case 'labels'
        if( ~exist(fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii')) )
            cmd = sprintf('mri_convert %s %s --out_orientation RAS', fullfile(fsdir,subjid,'mri','aparc.a2009s+aseg.mgz'), fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii'));
            unix(cmd);
        end
        cmd = sprintf('mri_extract_label %s `cat %s` %s',fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii'),fullfile(fsdir,subjid,'dti','warp','labelnum'),fullfile(fsdir,subjid,'dti','warp','labelstmp.nii'));
        unix(cmd);
        mask_hdr  = spm_vol(fullfile(fsdir,subjid,'dti','warp','labelstmp.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:)>0;
    otherwise
        if( ~exist(fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii')) )
            cmd = sprintf('mri_convert %s %s --out_orientation RAS', fullfile(fsdir,subjid,'mri','aparc.a2009s+aseg.mgz'), fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii'));
            unix(cmd);
        end
        if( ~exist(fullfile(fsdir,subjid,'dti','warp',[labelname '.nii'])) )
            cmd = sprintf('mri_extract_label %s `cat %s` %s',fullfile(fsdir,subjid,'dti','warp','aparc.a2009s+aseg.nii'),fullfile(fsdir,labelname),fullfile(fsdir,subjid,'dti','warp',[labelname '.nii']));
            unix(cmd);
        end
        mask_hdr  = spm_vol(fullfile(fsdir,subjid,'dti','warp',[labelname '.nii']));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:)>0;
end

map = map(mask);
ind = find(~isnan(map));
map = map(ind);

[Y,X] = hist(map,length(map)/300);
Y     = Y/(length(map)*(max(X)-min(X)))*length(X);

% Gaussian parameters fitting.
par = fminsearch('gaussien',[median(map);1.4826*median(abs(map-median(map)))]);

[err,val] = gaussien(par);

if visu
    figure
    Y = Y*(length(map)*(max(X)-min(X)))*length(X);
    val = val*(length(map)*(max(X)-min(X)))*length(X);
    bar(X,Y); hold on; plot(X,val,'r');
    title('Empirical distribution and fitted gaussian function');
end

stats.moy   = mean(map);
stats.stdev = std(map);
[stats.peakheight,ind] = max(val);
stats.peakloc = X(ind);

disp(['moyenne : ' num2str(stats.moy)])
disp(['ecart-type : ' num2str(stats.stdev)])
disp(['hauteur du pic : ' num2str(stats.peakheight)])
disp(['localisation du pic : ' num2str(stats.peakloc)])

clear map mask map_hdr X Y;
