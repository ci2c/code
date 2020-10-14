function FMRI_GroupSubCorticalLinearRegressionOneClass(dataroot,subjFile,coi,outdir)

addpath('/home/global/matlab_toolbox/spm12b');

disp('Group Analysis (NonParametric statistics)')

subjlist = textread(subjFile,'%s','delimiter','\n');
    
disp(['COI: ' num2str(coi)])

output = fullfile(outdir,['coi' num2str(coi)]);
if(exist(output,'dir'))
    cmd = sprintf('rm -rf %s',output);
    unix(cmd);
end
cmd = sprintf('mkdir -p %s',output);
unix(cmd);

mapFiles={};
for j = 1:length(subjlist)

    subj = subjlist{j};

    tmpFile  = fullfile(dataroot,subj,'coi',['wcon_coi' num2str(coi) '.nii']);
    if filexist(tmpFile)
        mapFiles{end+1} = tmpFile;
    end
    
end

save(fullfile(output,'maps.mat'),'mapFiles');

spm('defaults', 'FMRI');
%spm_jobman('initcfg');

matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(output);
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = mapFiles;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ['coi' num2str(coi)];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

spm_jobman('run',matlabbatch);