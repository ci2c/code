function reorient_mirrorRL( image_path )

matlabbatch{1}.spm.util.reorient.srcfiles = {image_path};
matlabbatch{1}.spm.util.reorient.transform.transM = [-1 0 0 0
                                                     0 1 0 0
                                                     0 0 1 0
                                                     0 0 0 1];
matlabbatch{1}.spm.util.reorient.prefix = 'flip_';

fprintf(['Rorient image: ',image_path,' OK']);
fprintf('\n');
spm_jobman('run',matlabbatch);

end

