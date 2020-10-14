function CreateSCRoiBySubject(aparc_file,epi_file,roisc_file,labels)

[pathstr,name,ext] = fileparts(epi_file);
roi_file = fullfile(pathstr,'aparc_las.nii'); 
cmd = sprintf('mri_convert %s %s --out_orientation LAS',aparc_file,roi_file);
unix(cmd);
% cmd = sprintf('mri_morphology %s dilate 1 %s',roi_file,roi_file);
% unix(cmd);

hdr_epi = spm_vol(epi_file);
vol_epi = spm_read_vols(hdr_epi);
hdr_roi = spm_vol(roi_file);
vol_roi = spm_read_vols(hdr_roi);

[sx sy sz] = size(vol_roi);
sxy        = sx*sy;
rot_mri    = hdr_roi.mat(1:3,1:3);
trans_mri  = hdr_roi.mat(1:3,4);

rot_epi   = hdr_epi.mat(1:3,1:3);
trans_epi = hdr_epi.mat(1:3,4);

roi_epi = zeros(size(vol_epi));

for n = 1:length(labels.ind)
    
    disp(n)
    
    idx = find(vol_roi(:)==labels.ind(n));

    for k = 1:length(idx)

        cz = floor(idx(k)/sxy);

        if( rem(idx(k),sxy)==0 )
            cz = cz-1;        
        end

        ind = idx(k)-sxy*cz;
        cy  = floor(ind/sx);

        if(rem(ind,sx)==0)
            cy = cy-1;
        end

        cx = ind-cy*sx;

        coordx = cx;
        coordy = cy+1;
        coordz = cz+1;

        coord = [coordx coordy coordz]';
        coord = (rot_mri * coord + trans_mri)';

        vox(k,:) = round(inv(rot_epi)*(coord' - trans_epi))';

    end

    vox = unique(vox,'rows');
    labels.voxel{n} = vox;

    for k = 1:size(vox,1)
        if ( vox(k,1)<=size(roi_epi,1) && vox(k,2)<=size(roi_epi,2) && vox(k,3)<=size(roi_epi,3) && vox(k,1)>0 && vox(k,2)>0 && vox(k,3)>0 )
            roi_epi(vox(k,1),vox(k,2),vox(k,3)) = labels.ind(n);
        end
    end

end

hdr_epi.fname = roisc_file;
spm_write_vol(hdr_epi,roi_epi);
