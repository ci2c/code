function FMRI_SubCorticalRegression(dataroot,subj,prefepi,maskFile,TR,clus_file,COIs,outdir,defFile)

if (exist(outdir,'dir'))
    cmd = sprintf('rm -rf %s',outdir);
    unix(cmd);
end
cmd = sprintf('mkdir %s',outdir);
unix(cmd);

%% Read clustering results

load(clus_file);

%%  GLM

tica = [];
mapFiles = {};
seed = [];
namecoi = {};

for i = 1:length(COIs)
    
    COI = COIs(i);

    AA_lh = char(resClust.compsName_lh{find(resClust.P == COI)});
    AA_rh = char(resClust.compsName_rh{find(resClust.P == COI)});

    keepS = [];

    for k = 1:size(AA_lh,1)

        if(strcmp(AA_lh(k,end),' '))
            file_lh{k} = AA_lh(k,1:end-1);
            file_rh{k} = AA_rh(k,1:end-1);
        else
            file_lh{k} = AA_lh(k,1:end);
            file_rh{k} = AA_rh(k,1:end);
        end

        if ( length(findstr(file_lh{k},subj)) > 0 )
            keepS = [keepS k];
        end

    end

    if(length(keepS)>0)
        
        [pathstr,name,ext] = fileparts(file_lh{keepS(1)});
        
        if(size(tica,1)==0)
            load(fullfile(pathstr,'sica.mat'));
            tica = sica.A;
        end
        
        if ( strcmp(name(end-1),'_') )
            cmp = str2num(name(end));
        else
            cmp = str2num(name(end-1:end));
        end
        seed = [seed tica(:,cmp)];
        
        namecoi{end+1} = ['coi' num2str(i)];
        
        mapFiles{end+1} = fullfile(outdir,['con_000' num2str(size(seed,2)) '.img']);
        mapFiles{end+1} = fullfile(outdir,['spmT_000' num2str(size(seed,2)) '.img']);
        
    end
    
end

% GLM
FMRI_SeedConnectivityByGLM(dataroot,outdir,prefepi,seed,namecoi,maskFile,TR);

nmapFiles={};
for k = 1:length(namecoi)
    
    cmd = sprintf('mri_convert %s %s',mapFiles{2*(k-1)+1},fullfile(outdir,['con_' namecoi{k} '.nii']));
    unix(cmd);
    cmd = sprintf('mri_convert %s %s',mapFiles{2*(k-1)+2},fullfile(outdir,['spmT_' namecoi{k} '.nii']));
    unix(cmd);
    nmapFiles{end+1} = fullfile(outdir,['con_' namecoi{k} '.nii']);
    nmapFiles{end+1} = fullfile(outdir,['spmT_' namecoi{k} '.nii']);
    
end

%% NORMALIZATION

spm('defaults', 'FMRI');

%y = spm_select('FPList', dataroot, ['^y_rmeanepi_.*\.nii$']);

matlabbatch{1}.spm.spatial.normalise.write.subj.def = cellstr(defFile);
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = nmapFiles;
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;

spm_jobman('run',matlabbatch);

