function PRESTO_Par2Nii(parfile,outdir,outname)

% Dependencie: NeuroElf

% % CREATE OUT FOLDER
% cmd = sprintf('mkdir -p %s',fullfile(outdir,'tmp'));
% unix(cmd);

% READ PAR FILE
prefepi = 'presto_';
v = partoanalyze75(parfile,fullfile(outdir,'tmp',[prefepi '%04d.img']));
clear v;

% REORIENT DATA
spm('defaults', 'FMRI');
spm_jobman('initcfg'); % SPM8 or spm12
f = spm_select('FPList', fullfile(outdir,'tmp'), ['^' prefepi '.*\.img$']);
matlabbatch{1}.spm.util.reorient.srcfiles = editfilenames(f,'prefix','');
matlabbatch{1}.spm.util.reorient.transform.transM = [0 0 1 0; 1 0 0 0; 0 1 0 0; 0 0 0 1];
matlabbatch{1}.spm.util.reorient.prefix = 'o';
spm_jobman('run',matlabbatch);

% % MERGE DATA
% cmd = sprintf('fslmerge -t %s %s',fullfile(outdir,[outname '.nii']),fullfile(outdir,'tmp',['o' prefepi '*.img']));
% unix(cmd);
% cmd = sprintf('gunzip %s',fullfile(outdir,[outname '.nii.gz']));
% unix(cmd);
% 
% % DELETE TEMP FILES
% cmd = sprintf('rm -rf %s',fullfile(outdir,'tmp'));
% unix(cmd);
