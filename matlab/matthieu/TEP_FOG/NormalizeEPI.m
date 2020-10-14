function NormalizeEPI(PathFileMat,InputFile)

% Init of spm_jobman
spm_jobman('initcfg'); % SPM8 only

% Open the text file containinfg paths of the smooth svraepi_*.nii images
fid = fopen(InputFile, 'r');
T = textscan(fid,'%s','delimiter','\n');
fclose(fid);

% Creation of the Cell of Dicom Files
NbNiiFiles = size(T{1},1);
CellNF = cell(NbNiiFiles,1);
for k= 1 : NbNiiFiles 
    CellNF{k,1} =T{1}{k};
end

% Execution of matlabbatch
matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {PathFileMat};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = CellNF;
matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50
                                                          78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [3 3 3];
matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 2;
matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';

fprintf('Normalize_EPI Setup: OK');
fprintf('\n')

spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);