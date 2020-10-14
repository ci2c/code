function apply_transf_norma_spm12(input,transfo)
%
% SPM use
% Tanguy Hamel @ CHRU Lille, 2014
%
%
%%

change_path_spm12

spm('defaults', 'FMRI');
spm_jobman('initcfg');


matlabbatch{1}.spm.spatial.normalise.write.subj.def = {transfo};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {input};
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;

spm_jobman('run',matlabbatch);