%% Open the text files containing patient groups and covariates %%
fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYP/V2_SPM_4Cov/Norm/TYP/glim.gn.fwhm10.txt', 'r');
TYP = textscan(fid,'%s','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYP/V2_SPM_4Cov/Norm/ATYP/glim.gn.fwhm10.txt', 'r');
ATYP = textscan(fid,'%s','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYP/V2_SPM_4Cov/Norm/Age_M0_TYPvsATYP.txt', 'r');
Age_M0 = textscan(fid,'%f','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYP/V2_SPM_4Cov/Norm/Sex_M0_TYPvsATYP.txt', 'r');
Sex_M0 = textscan(fid,'%d','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYP/V2_SPM_4Cov/Norm/MMS_M0_TYPvsATYP.txt', 'r');
MMS_M0 = textscan(fid,'%d','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYP/V2_SPM_4Cov/Norm/DureeMaladie_M0_TYPvsATYP.txt', 'r');
DD_M0 = textscan(fid,'%f','delimiter','\n');
fclose(fid);

%% Format the cells of patient groups %%
NbFilesTYP = size(TYP{1},1);
NbFilesATYP = size(ATYP{1},1);
Cell_TYP = cell(NbFilesTYP,1);
Cell_ATYP = cell(NbFilesATYP,1);

for k= 1 : NbFilesTYP 
    Cell_TYP{k,1} = [ TYP{1}{k} ',1' ];
end
for k= 1 : NbFilesATYP 
    Cell_ATYP{k,1} = [ ATYP{1}{k} ',1' ];
end

%% Init of spm_jobman %%
spm('defaults', 'PET');
spm_jobman('initcfg');
matlabbatch={};

%% Compute Two-sample T-test design %%
matlabbatch{end+1}.spm.stats.factorial_design.dir = {'/NAS/tupac/matthieu/SubCort_Analysis/V2_SPM_4Cov/Norm/TYPvsATYP.gn.sm10'};
matlabbatch{end}.spm.stats.factorial_design.des.t2.scans1 = Cell_TYP;
matlabbatch{end}.spm.stats.factorial_design.des.t2.scans2 = Cell_ATYP;
matlabbatch{end}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{end}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{end}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{end}.spm.stats.factorial_design.des.t2.ancova = 0;
matlabbatch{end}.spm.stats.factorial_design.cov(1).c = Age_M0{1};
matlabbatch{end}.spm.stats.factorial_design.cov(1).cname = 'Age';
matlabbatch{end}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{end}.spm.stats.factorial_design.cov(1).iCC = 1;
matlabbatch{end}.spm.stats.factorial_design.cov(2).c = Sex_M0{1};
matlabbatch{end}.spm.stats.factorial_design.cov(2).cname = 'Sex';
matlabbatch{end}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{end}.spm.stats.factorial_design.cov(2).iCC = 1;
matlabbatch{end}.spm.stats.factorial_design.cov(3).c = MMS_M0{1};
matlabbatch{end}.spm.stats.factorial_design.cov(3).cname = 'MMS';
matlabbatch{end}.spm.stats.factorial_design.cov(3).iCFI = 1;
matlabbatch{end}.spm.stats.factorial_design.cov(3).iCC = 1;
matlabbatch{end}.spm.stats.factorial_design.cov(4).c = DD_M0{1};
matlabbatch{end}.spm.stats.factorial_design.cov(4).cname = 'diseaseDuration';
matlabbatch{end}.spm.stats.factorial_design.cov(4).iCFI = 1;
matlabbatch{end}.spm.stats.factorial_design.cov(4).iCC = 1;
matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{end}.spm.stats.factorial_design.masking.em = {'${FS_DIR}/MNI152_T1_1mm/firstSeg/Subcortical_mask_2mm.nii,1'};
matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;

%% Estimate parameters %%
matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;

%% Define contrasts %%
matlabbatch{end+1}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'TYP > ATYP';
matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 0 0];
matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{end}.spm.stats.con.consess{2}.tcon.name = 'ATYP > TYP';
matlabbatch{end}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0 0 0 0];
matlabbatch{end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{end}.spm.stats.con.delete = 0;

spm_jobman('run',matlabbatch);