function inverse_transfo_spm_12(transfo,base)
%
% SPM use
% Tanguy Hamel @ CHRU Lille, 2014
%
%
%%

change_path_spm12
transfo
spm('defaults', 'FMRI');
spm_jobman('initcfg');

matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.def = {transfo};
matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {base};
matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = 'inverse_transformation';
matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.savepwd = 1;


spm_jobman('run',matlabbatch);




%-----------------------------------------------------------------------
% Job saved on 31-Jan-2014 15:01:03 by cfg_util (rev $Rev: 4972 $)
% spm SPM - SPM12b (5593)
% cfg_basicio BasicIO - Unknown
% dtijobs DTI tools - Unknown
% impexp_NiftiMrStruct NiftiMrStruct - Unknown
%-----------------------------------------------------------------------


