function CreateSCRoiBySubjectRes(aparc_file,epi_file,roisc_file,labels)

[pathstr,name,ext] = fileparts(epi_file);
roi_file = fullfile(pathstr,'aparc_2mm.nii'); 

if ~exist(roi_file,'file')
    cmd = sprintf('mri_convert -vs 2 2 2 %s %s',aparc_file,roi_file);
	unix(cmd);
end

hdr_epi = spm_vol(epi_file);
vol_epi = spm_read_vols(hdr_epi);
hdr_roi = spm_vol(roi_file);
vol_roi = spm_read_vols(hdr_roi);

[sx sy sz] = size(vol_roi);
sxy        = sx*sy;
dim        = size(vol_epi);

roi_epi = zeros(dim);
roi_epi = roi_epi(:);

for n = 1:length(labels.ind)
    
    disp(n)
    
    idx             = find(vol_roi(:)==labels.ind(n));
    roi_epi(idx)    = labels.ind(n);
    labels.voxel{n} = idx;

end

roi_epi = reshape(roi_epi,sx,sy,sz);

hdr_epi.fname = roisc_file;
spm_write_vol(hdr_epi,roi_epi);
