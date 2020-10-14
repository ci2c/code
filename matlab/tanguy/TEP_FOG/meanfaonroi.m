function meanfaonroi(sd,name,roi)


outname=strcat('mean_fa_',roi,'.mat');
outfile=fullfile(sd,name,'dti/mrtrix/tracto',outname);

roiname=strcat(roi,'.nii');
roi_path=fullfile(sd,name,'dti/ROI/temp/',roiname);
V_roi=spm_vol(roi_path);
map_roi=spm_read_vols(V_roi);

map_roi(map_roi~=0)=1;


fa_path=fullfile(sd,name,'dti/mrtrix/fa.nii')
V_fa=spm_vol(fa_path);
map_fa=spm_read_vols(V_fa);


fa_on_roi = map_fa .* map_roi;
fa_on_roi=fa_on_roi(:);
fa_on_roi(fa_on_roi==0)=[];

mean_fa_on_roi=mean(fa_on_roi);


save(outfile,'mean_fa_on_roi','V_fa','V_roi');