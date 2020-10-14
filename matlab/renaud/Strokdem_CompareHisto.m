function Strokdem_CompareHisto(datapath,mapname,labelname,visu)

global X Y

if nargin < 4
    visu = 1;
end

map1_hdr = spm_vol(fullfile(datapath,'72H',['rrdata_corr_' mapname '.nii']));
map1     = spm_read_vols(map1_hdr);

map2_hdr = spm_vol(fullfile(datapath,'M6',['rrdata_corr_' mapname '.nii']));
map2     = spm_read_vols(map2_hdr);

map1 = map1(:);
map2 = map2(:);

switch labelname
    case 'brainmask'
        mask_hdr  = spm_vol(fullfile(datapath,'brainmask.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:)>0;        
    case 'greymatter'
        mask_hdr  = spm_vol(fullfile(datapath,'ribbon.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:);
        mask      = mask==42 | mask==3;
    case 'whitematter'
        mask_hdr  = spm_vol(fullfile(datapath,'aparc.a2009s+aseg.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:);
        mask      = mask==41 | mask==2;
    case 'labels'
        cmd = sprintf('mri_extract_label %s `cat %s` %s',fullfile(datapath,'aparc.a2009s+aseg.nii'),fullfile(datapath,'labelnum'),fullfile(datapath,'labelstmp.nii'));
        unix(cmd);
        mask_hdr  = spm_vol(fullfile(datapath,'labelstmp.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:)>0;
    case 'labelsmap'
        mask_hdr  = spm_vol(fullfile(datapath,'labelsmap.nii'));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:)>0;
    otherwise
        mask_hdr  = spm_vol(fullfile(datapath,[labelname '.nii']));
        mask      = spm_read_vols(mask_hdr);
        mask      = mask(:)>0;
end

map1 = map1(mask);
map2 = map2(mask);
map  = [map1 map2];

for k = 1:size(map,2)
    
    if (length(map(:,k))<100)
        [Y,X] = hist(map(:,k));
    else
        [Y,X] = hist(map(:,k),length(map(:,k))/100);
    end
    Y     = Y/(length(map(:,k))*(max(X)-min(X)))*length(X);

    % Gaussian parameters fitting.
    par = fminsearch('gaussien',[median(map(:,k));1.4826*median(abs(map(:,k)-median(map(:,k))))]);
    
    [err(k),val] = gaussien(par);

    if visu
        figure
        Y = Y*(length(map(:,k))*(max(X)-min(X)))*length(X);
        val = val*(length(map(:,k))*(max(X)-min(X)))*length(X);
        bar(X,Y); hold on; plot(X,val,'r');
        title('Empirical distribution and fitted gaussian function');
    end
    
    moy(k)   = mean(map(:,k));
    stdev(k) = std(map(:,k));
    [peakheight(k),ind] = max(val);
    peakloc(k) = X(ind);
    
end

disp(['moyenne : ' num2str(moy)])
disp(['ecart-type : ' num2str(stdev)])
disp(['hauteur du pic : ' num2str(peakheight)])
disp(['localisation du pic : ' num2str(peakloc)])

