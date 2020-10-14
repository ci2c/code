function RegressionOnSSCortical(fsdir,subj,mepi_file,epi_file,TR,clus_file,motion_file,roisc_file,outdir)

n_temporal = 3;

aparc_file  = fullfile(fsdir,subj,'mri/aparc.a2009s+aseg.mgz');

labels.name = {'hyppoL','hyppoR','AmygL','AmygR','ThalL','ThalR','PutaL','PutaR','CaudL','CaudR','CerebCL','CerebCR','CerebWL','CerebWR','PallidumL','PallidumR'};
labels.ind  = [17 53 18 54 10 49 12 51 11 50 8 47 7 46 13 52];

%% Create subcortical ROIs
if ~filexist(roisc_file)
    CreateSCRoiBySubject(aparc_file,mepi_file,roisc_file,labels);
end

%% Read mask
hdr_roi = spm_vol(roisc_file);
roi     = spm_read_vols(hdr_roi);

%% Read preprocessed fMRI data
hdr_epi = spm_vol(epi_file);
epi     = spm_read_vols(hdr_epi);

%% Read motion parameters
confounds = load(motion_file);

%% Read clustering results

load(clus_file);
COIs = resClust.cois;

%% TEMPORAL TRENDS

% Keep time points that are not excluded:
exclude         = [1 size(epi,4)];
allpts          = 1:size(epi,4);
allpts(exclude) = zeros(1,length(exclude));
keep            = allpts( find( allpts ) );
n               = length(keep);

% Create temporal trends:

n_spline=round(n_temporal*TR*length(keep)/360)
if n_spline>=0 
   trend=((2*keep-(max(keep)+min(keep)))./(max(keep)-min(keep)))';
   if n_spline<=3
      temporal_trend=(trend*ones(1,n_spline+1)).^(ones(n,1)*(0:n_spline));
   else
      temporal_trend=(trend*ones(1,4)).^(ones(n,1)*(0:3));
      knot=(1:(n_spline-3))/(n_spline-2)*(max(keep)-min(keep))+min(keep);
      for k=1:length(knot)
         cut=keep'-knot(k);
         temporal_trend=[temporal_trend (cut>0).*(cut./max(cut)).^3];
      end
   end
   % temporal_trend=temporal_trend*inv(chol(temporal_trend'*temporal_trend));
else
   temporal_trend = [];
end 

trend = [temporal_trend confounds(keep,:)];

%%  ICA SEED

taille = size(epi);
roi    = roi(:);
idx    = find(roi > 0);
epi    = reshape(epi,taille(1)*taille(2)*taille(3),taille(4));
epi    = epi(idx,keep)';
tica   = [];

mapFiles = {};

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
        seed = tica(:,cmp);

        % GLM

        X        = [seed(keep) trend];
        pinvX    = pinv(X);
        Df       = length(keep)-size(X,2);
        contrast = [1 zeros(1,size(trend,2))]; 

        betahat   = pinvX * epi;
        resid     = epi-X*betahat;
        SSE       = sum(resid.^2,1);
        sd        = sqrt(SSE/Df);
        V         = pinvX*pinvX';
        sdbetahat = sqrt(diag(V))*sd;
        T0        = betahat./(sdbetahat+(sdbetahat<=0)).*(sdbetahat>0);
        mag_ef    = contrast*betahat;
        mag_sd    = sqrt(diag(contrast*V*contrast'))*sd;
        effect    = mag_ef';
        sdeffect  = mag_sd';
        tstat     = (mag_ef./(mag_sd+(mag_sd<=0)).*(mag_sd>0))';

        results       = zeros(taille(1)*taille(2)*taille(3),1);
        results(idx)  = tstat;
        hdr_roi.fname = fullfile(outdir,['tMap_Sc_' num2str(COI) '.nii']);
        spm_write_vol(hdr_roi,reshape(results,taille(1),taille(2),taille(3)));
        mapFiles{end+1} = hdr_roi.fname;
    end
    
end

%% Normalize to MNI Template

% Template Normalization
spm('Defaults','fMRI');
spm_jobman('initcfg'); % SPM8 only

clear jobs
jobs = {};

a = which('spm_normalise');
[path] = fileparts(a);

jobs{1}.spm.spatial.normalise.estwrite.subj.source       = {mepi_file};
jobs{1}.spm.spatial.normalise.estwrite.subj.wtsrc        = '';
jobs{1}.spm.spatial.normalise.estwrite.subj.resample     = mapFiles;
jobs{1}.spm.spatial.normalise.estwrite.eoptions.template = {fullfile(path,'templates/EPI.nii')};
jobs{1}.spm.spatial.normalise.estwrite.eoptions.weight   = '';
jobs{1}.spm.spatial.normalise.estwrite.eoptions.smosrc   = 8;
jobs{1}.spm.spatial.normalise.estwrite.eoptions.smoref   = 0;
jobs{1}.spm.spatial.normalise.estwrite.eoptions.regtype  = 'mni';
jobs{1}.spm.spatial.normalise.estwrite.eoptions.cutoff   = 25;
jobs{1}.spm.spatial.normalise.estwrite.eoptions.nits     = 16;
jobs{1}.spm.spatial.normalise.estwrite.eoptions.reg      = 1;
jobs{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
jobs{1}.spm.spatial.normalise.estwrite.roptions.bb       = [-78 -112 -50
                                                             78 76 85];
jobs{1}.spm.spatial.normalise.estwrite.roptions.vox      = [3 3 3];
jobs{1}.spm.spatial.normalise.estwrite.roptions.interp   = 3;
jobs{1}.spm.spatial.normalise.estwrite.roptions.wrap     = [0 0 0];
jobs{1}.spm.spatial.normalise.estwrite.roptions.prefix   = 'w';

spm_jobman('run',jobs);
