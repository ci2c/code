liste=dir('/NAS/tupac/protocoles/neuropain/FS53');
final_split={};

for i=1:length(liste)
    
    file=fullfile('/NAS/tupac/protocoles/neuropain/FS53/',liste(i).name,'rsfmri/run01/warepi_al.nii');
    Dir=strcat('/NAS/tupac/protocoles/neuropain/FS53/',liste(i).name,'/rsfmri/run01/temp');
    
    if exist(file) && exist(fullfile('/NAS/tupac/protocoles/neuropain/FS53/',liste(i).name,'rsfmri/run01/swarepi_al.nii')) == 0
        cmd = sprintf('mkdir %s',Dir);
        unix(cmd);
    
        Vo=spm_file_split(file,Dir);
        
        liste_split=dir(Dir);
        spm_jobman('initcfg');
        
%% Smoothing  

        if exist(fullfile('/NAS/tupac/protocoles/neuropain/FS53/',liste(i).name,'rsfmri/run01/temp/swarepi_al_00001.nii')) == 0

        for j=3:length(liste_split)
        file_2split=fullfile(Dir,liste_split(j).name);
        clear matlabbatch 
        matlabbatch = {};
            
        matlabbatch{1}.spm.spatial.smooth.data ={file_2split};
        matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';

        spm_jobman('run',matlabbatch);	
        end
        
        
% %% 3D to 4D
% 
% for j=3:length(liste_split)
% smooth_file=fullfile(Dir,['s' liste_split(j).name ]);
% final_split{end+1,1}={smooth_file};
% end
% 
% final_file=fullfile('/NAS/tupac/protocoles/neuropain/FS53',liste(i).name,'rsfmri/run01/swarepi_al.nii');
% 
% clear matlabbatch 
% matlabbatch = {};
% matlabbatch{1}.spm.util.cat.vols = final_split;
% matlabbatch{1}.spm.util.cat.name = final_file;
% matlabbatch{1}.spm.util.cat.dtype = 4;
% spm_jobman('run',matlabbatch);
        end
    end
end
