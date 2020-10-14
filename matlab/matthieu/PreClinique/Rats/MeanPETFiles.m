function MeanPETFiles(InputPETFiles)

% Init of spm_jobman
spm_jobman('initcfg'); % SPM8 only

% Open the text file containinfg paths of the dicom images
fid = fopen(InputPETFiles, 'r');
T = textscan(fid,'%s','delimiter','\n');
fclose(fid);

% Creation of the Cell of Dicom Files
NbPetFiles = size(T{1},1);
CellPF = cell(NbPetFiles,1);
for k= 1 : NbPetFiles 
    CellPF{k,1} =T{1}{k};
end

% Execution of matlabbatch
matlabbatch{1}.spm.spatial.realign.estwrite.data = {
                                                    CellPF
                                                    }';
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 7;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'mean_';

fprintf('MeanPETFiles Setup: OK');
fprintf('\n')

spm('defaults', 'PET');
spm_jobman('run',matlabbatch);
