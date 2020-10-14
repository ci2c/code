function seed = FMRI_RegressionOnSSCortical(subj,icaFile,COIs,coiNames,clusFile,maskFile,motionFile,spmDir,outdir)

%%  ICA SEED

mapFiles = {};

load(icaFile);
tica = sica.A;
TR   = sica.TR;

load(clusFile);

ncoi = length(COIs);
seed = zeros(size(tica,1),ncoi);

for i = 1:ncoi
    
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
        
        if ( strcmp(name(end-1),'_') )
            cmp = str2num(name(end));
        else
            cmp = str2num(name(end-1:end));
        end
        seed(:,i) = tica(:,cmp);
        
    end
    
end

if exist(outdir,'dir')
    rmdir(outdir,'s');
end
mkdir(outdir);

spm('Defaults','fMRI');
spm_jobman('initcfg'); % SPM8 only

clear matlabbatch
matlabbatch = {};

f = spm_select('FPList', spmDir, '^epi_.*\.nii$');

matlabbatch{1}.spm.stats.fmri_spec.dir            = {outdir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units   = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT      = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t  = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans     = editfilenames(f,'prefix','rsvr');
matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
cp=0;
for k = 1:ncoi
    if max(seed(:,k))>0
        cp=cp+1;
        matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cp).name = coiNames{k};
        matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cp).val  = seed(:,k);
    end
end
nbeta = cp;
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg   = {motionFile};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf         = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt             = 1;
matlabbatch{1}.spm.stats.fmri_spec.global           = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mask             = {maskFile};
matlabbatch{1}.spm.stats.fmri_spec.cvi              = 'AR(1)';

spm_jobman('run',matlabbatch);

clear matlabbatch
matlabbatch = {};

matlabbatch{1}.spm.stats.fmri_est.spmmat           = {fullfile(outdir,'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch);

if nbeta > 0
    
    % Contrast
    clear matlabbatch
    matlabbatch = {};

    matlabbatch{1}.spm.stats{1}.con.spmmat = cellstr(fullfile(outdir,'SPM.mat'));
    cp = 0;
    for k = 1:ncoi
        if max(seed(:,k))>0
            cp = cp+1;
            C = zeros(1,nbeta+7);
            C(cp) = 1;
            matlabbatch{1}.spm.stats{1}.con.consess{cp}.tcon.name = [coiNames{k} ' >'];
            matlabbatch{1}.spm.stats{1}.con.consess{cp}.tcon.convec = C;
        end
    end

    spm_jobman('run',matlabbatch);

    % Rename output
    cp=0;
    mapFiles={};
    for k = 1:ncoi
        if max(seed(:,k))>0
            cp=cp+1;
            cmd=sprintf('mv %s %s',fullfile(outdir,['spmT_000' num2str(cp) '.img']),fullfile(outdir,['spmT_' coiNames{k} '.img']));
            unix(cmd);
            cmd=sprintf('mv %s %s',fullfile(outdir,['spmT_000' num2str(cp) '.hdr']),fullfile(outdir,['spmT_' coiNames{k} '.hdr']));
            unix(cmd);
            cmd=sprintf('mv %s %s',fullfile(outdir,['con_000' num2str(cp) '.img']),fullfile(outdir,['con_' coiNames{k} '.img']));
            unix(cmd);
            cmd=sprintf('mv %s %s',fullfile(outdir,['con_000' num2str(cp) '.hdr']),fullfile(outdir,['con_' coiNames{k} '.hdr']));
            unix(cmd);
            
            mapFiles{2*(cp-1)+1} = fullfile(outdir,['con_' coiNames{k} '.img']);
            mapFiles{2*(cp-1)+2} = fullfile(outdir,['spmT_' coiNames{k} '.img']);
        end
    end
    
    % Normalize to MNI template
    clear matlabbatch
    matlabbatch = {};
        
    a = which('spm_normalise');
    [path] = fileparts(a);
    
    f = spm_select('FPList', spmDir, '^epi_.*\.nii$');
    
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source       = editfilenames(f(1,:),'prefix','rmean');
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc        = '';
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample     = mapFiles;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {fullfile(path,'templates/EPI.nii')};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight   = '';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc   = 8;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref   = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype  = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff   = 25;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits     = 16;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg      = 1;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb       = [-78 -112 -50; 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox      = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp   = 3;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap     = [0 0 0];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix   = 'w';

    spm_jobman('run',matlabbatch);
    
end

