function [thresVal, pval, peak, clus, qval] = T1_ThicknessGroupAnalysisForOneSampleOneHemi(g1Files,hemi,contrast,outdir,outputname,dispres)

if nargin < 6
    dispres = false;
end

if ~exist(outdir,'dir')
    cmd = sprintf('mkdir %s',outdir);
    unix(cmd);
end

load /home/renaud/SVN/medial_wall.mat

Subjects     = [];
Subject_type = [];

for k = 1:size(g1Files,1)
    
    Subjects     = [Subjects; {g1Files{k,1}}];
    Subject_type = [Subject_type; {'group1'}];
    
end

if strcmp(hemi,'lh')
    Surf = SurfStatReadSurf({'/home/global/freesurfer/subjects/fsaverage/surf/lh.pial'});
else
    Surf = SurfStatReadSurf({'/home/global/freesurfer/subjects/fsaverage/surf/rh.pial'});
end

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
if strcmp(hemi,'lh')
    mask = mask(1:size(Data,2));
else
    mask = mask(size(Data,2)+1:end);
end

slm = SurfStatT(slm, C);
if dispres
    figure(1); SurfStatView( slm.t.*mask, Surf, 'T for contrast' );
    PicFileName = fullfile(outdir,[outputname '_ipsi_tMap.tiff']);
    print(1,PicFileName,'-dtiff','-r150');
end

% Find the threshold for P=0.05 corrected (RFT)
resels   = SurfStatResels( slm, mask );
thresVal = stat_threshold( resels, length(slm.t), 1, slm.df );

% P-value for each vertex
[ pval, peak, clus ] = SurfStatP( slm, mask );

if dispres
   figure(2); SurfStatView( pval, Surf, 'p-value for contrast' ); 
   PicFileName = fullfile(outdir,[outputname '_ipsi_pval.tiff']);
   print(2,PicFileName,'-dtiff','-r150');
end

% FDR
qval = SurfStatQ( slm, mask );

if dispres
    %figure; SurfStatView( qval, Surf, 'FDR' );
end

% Save t-map
SurfStatWriteData(fullfile(outdir,[hemi '.' outputname '_ipsi.tMap']),slm.t,'b');
