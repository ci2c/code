function NormalizePet(fsdir)

labels = [7 8 46 47];
fwhm   = [5 10 15 20];

cmd = sprintf('mri_convert %s %s --out_orientation LAS',fullfile(fsdir,'mri','aparc.a2009s+aseg.mgz'),fullfile(fsdir,'mri','label.nii'));
unix(cmd);
    
Vpet   = spm_vol(fullfile(fsdir,'epilepsy','pve','rpet.img'));
pet    = spm_read_vols(Vpet);
dim    = size(pet);
pet    = pet(:);
Vlab   = spm_vol(fullfile(fsdir,'mri','label.nii'));
lab    = spm_read_vols(Vlab);
ind    = [];
for k = 1:length(labels)
	ind = [ind; find(lab(:)==labels(k))];
end
nval = mean(pet(ind));

% read and write map file
for k = 1:length(fwhm)
    
    petFile_lh = fullfile(fsdir,'epilepsy',['lh.fwhm' num2str(fwhm(k)) '.fsaverage.pet.mgh']);
    petFile_rh = fullfile(fsdir,'epilepsy',['rh.fwhm' num2str(fwhm(k)) '.fsaverage.pet.mgh']);
    pet_lh = SurfStatReadData(petFile_lh);
    pet_rh = SurfStatReadData(petFile_rh);
    pet_lh = pet_lh./nval;
    pet_rh = pet_rh./nval;

    % write map file
    petFile_lh = fullfile(fsdir,'epilepsy',['lh.fwhm' num2str(fwhm(k)) '.fsaverage.pet.norm']);
    petFile_rh = fullfile(fsdir,'epilepsy',['rh.fwhm' num2str(fwhm(k)) '.fsaverage.pet.norm']);
    write_curv(petFile_lh,pet_lh,327680);
    write_curv(petFile_rh,pet_rh,327680);
    
end