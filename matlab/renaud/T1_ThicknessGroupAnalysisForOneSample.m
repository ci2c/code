function [pall,thresVal, pval, peak, clus, qval] = T1_ThicknessGroupAnalysisForOneSample(g1Files,contrast,outdir,outputname,dozscore,dispres,covar)

if nargin < 5
    dozscore = 0;
end
if nargin < 6
    dispres = false;
end
if nargin < 7
    covar = '';
end

if ~exist(outdir,'dir')
    cmd = sprintf('mkdir %s',outdir);
    unix(cmd);
end

load /home/renaud/SVN/medial_wall.mat

Subjects     = [];
Subject_type = [];

for k = 1:size(g1Files,1)
    
    if dozscore
        
        disp(['z-score group 1 ; subject ' num2str(k)]);
        [p_lh,n_lh,e] = fileparts(g1Files{k,1});
        [p_rh,n_rh,e] = fileparts(g1Files{k,2});
        Surf_DataToZscore(g1Files{k,1},g1Files{k,2},3);
        
        Subjects     = [Subjects; {fullfile(p_lh,[n_lh '.zscore']),fullfile(p_rh,[n_rh '.zscore'])}];
        Subject_type = [Subject_type; {'group1'}];
        
    else
        
        Subjects     = [Subjects; {g1Files{k,1},g1Files{k,2}}];
        Subject_type = [Subject_type; {'group1'}];
        
    end
    
end
        
Surf = SurfStatReadSurf({'/home/global/freesurfer/subjects/fsaverage/surf/lh.pial', '/home/global/freesurfer/subjects/fsaverage/surf/rh.pial'});

Data = SurfStatReadData(Subjects);
meanThick = mean(double(Data));
if dispres
    %figure; SurfStatView (meanThick, Surf, 'Mean thickness (mm)');
    %figure; SurfStatView (meanThick, Surf, 'Mean image');
end

Group = term(Subject_type);

% Design Matrix
M = 1 + Group;
if dispres
    %figure; image(M);
end

% GLM
slm = SurfStatLinMod(Data, M, Surf);

% Contrast
if contrast(1) == 1 
    C = Group.group1;
elseif contrast(1) == -1
    C = -Group.group1;
else
    disp('no valid contrast');
    return;
end

% t-value
mask = ~Mask;
slm = SurfStatT(slm, C);
if dispres
    figure(1); SurfStatView( slm.t.*mask, Surf, 'T for contrast' );
    PicFileName = fullfile(outdir,[outputname '_tMap.tiff']);
    print(1,PicFileName,'-dtiff','-r150');
end

% Find the threshold for P=0.05 corrected (RFT)
resels   = SurfStatResels( slm, mask );
thresVal = stat_threshold( resels, length(slm.t), 1, slm.df );

% P-value for each vertex
[ pval, peak, clus ] = SurfStatP( slm, mask );

if dispres
   figure(2); SurfStatView( pval, Surf, 'p-value for contrast' ); 
   PicFileName = fullfile(outdir,[outputname '_pval.tiff']);
   print(2,PicFileName,'-dtiff','-r150');
end

% FDR
qval = SurfStatQ( slm, mask );

if dispres
    %figure; SurfStatView( qval, Surf, 'FDR' );
end

pall = zeros(1,length(pval.P));
pclu = zeros(1,length(pval.P));
pfdr = zeros(1,length(pval.P));
ptmap = zeros(1,length(pval.P));
ptmapall = zeros(1,length(pval.P));

if isfield(pval,'C')
    pC = pval.C;
else
    pC = ones(1,length(pval.P));
end
for k = 1:length(pval.P)
    if mask(k)~=0
        pall(k) = 1-min([pval.P(k) pC(k) qval.Q(k)]);
        if pall(k)<0
            pall(k)=0;
        end
        pclu(k) = 1-min([pval.P(k) pC(k)]);
        if pclu(k)<0
            pclu(k)=0;
        end
        pfdr(k) = 1-qval.Q(k);
        if pfdr(k)<0
            pfdr(k)=0;
        end
        if pclu(k)>=0.95
            ptmap(k) = slm.t(k);
        end
        if pall(k)>=0.95
            ptmapall(k) = slm.t(k);
        end
    end
end

slm.t = contrast.*slm.t.*mask;
% slm.t = contrast*slm.t;
% ptmap = contrast*ptmap;
% ptmapall = contrast*ptmapall;

% Save t-map
Data_lh = SurfStatReadData(Subjects{1,1});
SurfStatWriteData(fullfile(outdir,['lh.' outputname '.Mean']),meanThick(1:length(Data_lh)),'b');
SurfStatWriteData(fullfile(outdir,['rh.' outputname '.Mean']),meanThick(length(Data_lh)+1:end),'b');
SurfStatWriteData(fullfile(outdir,['lh.' outputname '.tMap']),slm.t(1:length(Data_lh)),'b');
SurfStatWriteData(fullfile(outdir,['rh.' outputname '.tMap']),slm.t(length(Data_lh)+1:end),'b');
SurfStatWriteData(fullfile(outdir,['lh.' outputname '.pVal']),pall(1:length(Data_lh)),'b');
SurfStatWriteData(fullfile(outdir,['rh.' outputname '.pVal']),pall(length(Data_lh)+1:end),'b');
SurfStatWriteData(fullfile(outdir,['lh.' outputname '_cluster.pVal']),pclu(1:length(Data_lh)),'b');
SurfStatWriteData(fullfile(outdir,['rh.' outputname '_cluster.pVal']),pclu(length(Data_lh)+1:end),'b');
SurfStatWriteData(fullfile(outdir,['lh.' outputname '_fdr.pVal']),pfdr(1:length(Data_lh)),'b');
SurfStatWriteData(fullfile(outdir,['rh.' outputname '_fdr.pVal']),pfdr(length(Data_lh)+1:end),'b');
SurfStatWriteData(fullfile(outdir,['lh.' outputname '_tMapClu.pVal']),ptmap(1:length(Data_lh)),'b');
SurfStatWriteData(fullfile(outdir,['rh.' outputname '_tMapClu.pVal']),ptmap(length(Data_lh)+1:end),'b');
SurfStatWriteData(fullfile(outdir,['lh.' outputname '_tMapAll.pVal']),ptmapall(1:length(Data_lh)),'b');
SurfStatWriteData(fullfile(outdir,['rh.' outputname '_tMapAll.pVal']),ptmapall(length(Data_lh)+1:end),'b');

 