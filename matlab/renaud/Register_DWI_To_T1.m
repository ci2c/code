function Register_DWI_To_T1(t1image,dwiimage,maskimage)

spm_get_defaults;
spm_jobman('initcfg');
matlabbatch = {};


matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(t1image);
matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(dwiimage);
matlabbatch{1}.spm.spatial.coreg.estimate.other = cellstr(maskimage);
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.coreg.write.ref = cellstr(t1image);
matlabbatch{2}.spm.spatial.coreg.write.source = cellstr(dwiimage);
matlabbatch{2}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{2}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{2}.spm.spatial.coreg.write.roptions.prefix = 'r';
matlabbatch{3}.spm.spatial.coreg.write.ref = cellstr(t1image);
matlabbatch{3}.spm.spatial.coreg.write.source = cellstr(maskimage);
matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);

