function nrrd2nii(nrrd_path, nii_ref, nii_out)
% usage : nrrd2nii(nrrd_path, nii_ref, nii_out)
%
% Inputs :
%       nrrd_path       : path to .nrrd image
%       nii_ref         : path to .nii image in the same space
%       nii_out         : path to the output image
%
% Pierre Besson @ CHRU Lille, Jan. 2013

if nargin ~= 3
    error('invalid usage');
end

[X, META] = nrrdread(nrrd_path);

V = spm_vol(nii_ref);

for i = 1 : size(X, 1)
    V_out = V;
    V_out.fname = ['temp', num2str(i), '.nii'];
    V_out.dt(1) = 16;
    spm_write_vol(V_out, squeeze(X(i,:,:,:)));
end

matlabbatch{1}.spm.util.cat.vols = {
                                    'temp1.nii,1'
                                    'temp2.nii,1'
                                    'temp3.nii,1'
                                    };
matlabbatch{1}.spm.util.cat.name = nii_out;
matlabbatch{1}.spm.util.cat.dtype = 16;

spm_jobman('initcfg');
spm_jobman('serial', matlabbatch);

delete('temp1.nii', 'temp2.nii', 'temp3.nii');