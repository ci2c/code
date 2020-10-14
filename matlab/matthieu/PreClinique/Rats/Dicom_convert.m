function Dicom_convert(OutputDir,InputFile)

% Init of spm_jobman
spm_jobman('initcfg'); % SPM8 only

% Open the text file containinfg paths of the dicom images
fid = fopen(InputFile, 'r');
T = textscan(fid,'%s','delimiter','\n');
fclose(fid);

% Creation of the Cell of Dicom Files
NbDicomFiles = size(T{1},1);
CellDF = cell(NbDicomFiles,1);
for k= 1 : NbDicomFiles 
    CellDF{k,1} =T{1}{k};
end

% Execution of matlabbatch
matlabbatch{1}.spm.util.dicom.data = CellDF;
matlabbatch{1}.spm.util.dicom.root = 'flat';
matlabbatch{1}.spm.util.dicom.outdir = {OutputDir};
matlabbatch{1}.spm.util.dicom.convopts.format = 'nii';
matlabbatch{1}.spm.util.dicom.convopts.icedims = 0;

fprintf('Dicom_convert Setup: OK');
fprintf('\n')

spm('defaults', 'PET');
spm_jobman('run',matlabbatch);
