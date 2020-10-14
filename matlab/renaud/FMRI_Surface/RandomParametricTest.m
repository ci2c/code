function tmap = RandomParametricTest(mapfiles,outdir,n,maskfile)
    
cmd = sprintf('mkdir %s',fullfile(outdir,['tmp_' num2str(n)]));
unix(cmd);

spm('defaults', 'FMRI');
spm_jobman('initcfg');

matlabbatch{1}.spm.stats.factorial_design.dir                    = {fullfile(outdir,['tmp_' num2str(n)])};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans           = mapfiles;
matlabbatch{1}.spm.stats.factorial_design.cov                    = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none     = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im             = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em             = {maskfile};
%matlabbatch{1}.spm.stats.factorial_design.masking.em             = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit         = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm        = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(outdir,['tmp_' num2str(n)],'SPM.mat'));

matlabbatch{3}.spm.stats.con.spmmat                 = cellstr(fullfile(outdir,['tmp_' num2str(n)],'SPM.mat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name   = sprintf('Positive %s',num2str(n));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = 1;

spm_jobman('run',matlabbatch);

clear matlabbatch

V    = spm_vol(maskfile);
mask = spm_read_vols(V);
ind  = find(mask(:)>0);

Vmap = spm_vol(fullfile(outdir,['tmp_' num2str(n)],'spmT_0001.img'));
tmap = spm_read_vols(Vmap);
tmap = tmap(:);
tmap = tmap(ind);

clear mask V Vmap ind;

cmd = sprintf('rm -rf %s',fullfile(outdir,['tmp_' num2str(n)]));
unix(cmd);