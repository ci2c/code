% Open the text files containing patient groups and covariates %%
fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYPvsCN/ANTs_3Cov/TYP/glim.gn.fwhm5.txt', 'r');
TYP = textscan(fid,'%s','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYPvsCN/ANTs_3Cov/ATYP/glim.gn.fwhm5.txt', 'r');
ATYP = textscan(fid,'%s','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYPvsCN/ANTs_3Cov/CN/glim.gn.fwhm5.txt', 'r');
CN = textscan(fid,'%s','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYPvsCN/ANTs_3Cov/Age_M0_TYPvsATYPvsCN.txt', 'r');
Age_M0 = textscan(fid,'%f','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYPvsCN/ANTs_3Cov/Sex_M0_TYPvsATYPvsCN.txt', 'r');
Sex_M0 = textscan(fid,'%f','delimiter','\n');
fclose(fid);

fid = fopen('/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsATYPvsCN/ANTs_3Cov/MMS_M0_TYPvsATYPvsCN.txt', 'r');
MMS_M0 = textscan(fid,'%f','delimiter','\n');
fclose(fid);

%% Format the cells of patient groups %%
NbFilesTYP = size(TYP{1},1);
NbFilesATYP = size(ATYP{1},1);
NbFilesCN = size(CN{1},1);
Cell_TYP = cell(NbFilesTYP,1);
Cell_ATYP = cell(NbFilesATYP,1);
Cell_CN = cell(NbFilesCN,1);

for k= 1 : NbFilesTYP 
    Cell_TYP{k,1} = [ TYP{1}{k} ',1' ];
end
for k= 1 : NbFilesATYP 
    Cell_ATYP{k,1} = [ ATYP{1}{k} ',1' ];
end
for k= 1 : NbFilesCN 
    Cell_CN{k,1} = [ CN{1}{k} ',1' ];
end

%% Init of spm_jobman %%
spm('defaults', 'PET');
spm_jobman('initcfg');
matlabbatch={};

matlabbatch{end+1}.spm.stats.factorial_design.dir = {'/NAS/tupac/matthieu/SubCort_Analysis/TYPvsATYPvsCN/ANTs_3Cov/TYPvsATYPvsCN.gn.sm5'};
matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.name = 'Patient Groups';
matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.levels = 3;
matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.dept = 0;
matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.variance = 1;
matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.gmsca = 0;
matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.ancova = 0;
matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(1).levels = 1;
matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(1).scans = Cell_TYP;
matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(2).levels = 2;
matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(2).scans = Cell_ATYP;
matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(3).levels = 3;
matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(3).scans = Cell_CN;
matlabbatch{end}.spm.stats.factorial_design.des.fd.contrasts = 1;
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
matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{end}.spm.stats.factorial_design.masking.em = {'${FS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_1mm_subCort_mask.nii,1'};
matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch);