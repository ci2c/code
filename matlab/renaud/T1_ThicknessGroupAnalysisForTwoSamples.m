function [pval, peak, clus, qval, slm] = T1_ThicknessGroupAnalysisForTwoSamples(g1Files,g2Files,contrast,outdir,outputname,dozscore,dispres)

if nargin < 6
    dozscore = 0;
end
if nargin < 7
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
    
    if dozscore
        
        disp(['z-score group 1 ; subject ' num2str(k)]);
        [p_lh,n_lh,e] = fileparts(g1Files{k,1});
        [p_rh,n_rh,e] = fileparts(g1Files{k,2});
        Surf_DataToZscore(g1Files{k,1},g1Files{k,2},1);
        
        Subjects     = [Subjects; {fullfile(p_lh,[n_lh '.zscore']),fullfile(p_rh,[n_rh '.zscore'])}];
        Subject_type = [Subject_type; {'group1'}];
        
    else
        
        Subjects     = [Subjects; {g1Files{k,1},g1Files{k,2}}];
        Subject_type = [Subject_type; {'group1'}];
        
    end
    
end

for k = 1:size(g2Files,1)
    
    if dozscore
        
        disp(['z-score group 2 ; subject ' num2str(k)]);
        [p_lh,n_lh,e] = fileparts(g2Files{k,1});
        [p_rh,n_rh,e] = fileparts(g2Files{k,2});
        Surf_DataToZscore(g2Files{k,1},g2Files{k,2},1);
        
        Subjects     = [Subjects; {fullfile(p_lh,[n_lh '.zscore']),fullfile(p_rh,[n_rh '.zscore'])}];
        Subject_type = [Subject_type; {'group2'}];
        
    else

        Subjects     = [Subjects; {g2Files{k,1},g2Files{k,2}}];
        Subject_type = [Subject_type; {'group2'}];
        
    end
    
end
        
Surf = SurfStatReadSurf({'/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.pial', '/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.pial'});

Data = SurfStatReadData(Subjects);

meanThick1 = mean(double(Data(1:26,:)));
meanThick2 = mean(double(Data(27:38,:)));

stdThick1 = std(double(Data(1:26,:)));
stdThick2 = std(double(Data(27:38,:)));


if dispres
    figure; SurfStatView (meanThick1,Surf,'Mean EOAD');
    figure; SurfStatView (stdThick1,Surf,'Std EOAD');  
    figure; SurfStatView (meanThick2,Surf,'Mean Controls');
    figure; SurfStatView (stdThick2,Surf,'Std Controls');
end

Group = term(Subject_type);

% Design Matrix
M = 1 + Group;
if dispres
    figure; image(M);
end

% GLM
slm = SurfStatLinMod(Data, M, Surf);

% Contrast
if contrast(1) == 1 && contrast(2) == -1
    C = Group.group1 - Group.group2;
elseif contrast(1) == -1 && contrast(2) == 1
    C = Group.group2 - Group.group1;
elseif contrast(1) == 1 && contrast(2) == 0
    C = Group.group1;
elseif contrast(1) == 0 && contrast(2) == 1
    C = Group.group2;
elseif contrast(1) == -1 && contrast(2) == 0
    C = -Group.group1;
elseif contrast(1) == 0 && contrast(2) == -1
    C = -Group.group2;
elseif contrast(1) == 1 && contrast(2) == 1
    C = Group.group1 + Group.group2;
elseif contrast(1) == -1 && contrast(2) == -1
    C = -Group.group1 - Group.group2;
else
    disp('no valid contrast');
    return;
end

% t-value
mask = ~Mask;
slm2 = SurfStatT(slm, C);
if dispres
    figure(1); SurfStatView( slm.t.*mask, Surf, 'T for contrast' );
    PicFileName = fullfile(outdir,[outputname '_tmap.tiff']);
    print(1,PicFileName,'-dtiff','-r150');
end

% % Find the threshold for P=0.05 corrected (RFT)
% resels   = SurfStatResels( slm, mask );
% thresVal = stat_threshold( resels, length(slm.t), 1, slm.df );

% P-value for each vertex
clusthresh = 0.05;
[ pval, peak, clus ] = SurfStatP( slm, mask, clusthresh );
pval.thresh = 0.05;

if isfield(pval,'P')
    signifpeak=pval.P<pval.thresh;
    signifpeak=sum(signifpeak);
else
    signifpeak=0;
end
if isfield(struct,'C')
    signifclus=pval.C<pval.thresh;
    signifclus=sum(signifclus);
else
    signifclus=0;
end
signifDisp=signifclus+signifpeak;

<<<<<<< .mine
if dispres && signifDisp>0
   figure(2); SurfStatView( pval.C, Surf, 'p-value for contrast' ); 
   PicFileName = fullfile(outdir,[outputname '_pvalRFE.tiff']);
   print(2,PicFileName,'-dtiff','-r150');
end
=======
figure(2); SurfStatView( pval, Surf, 'p-value for contrast' ); 
PicFileName = fullfile(outdir,[outputname '_pvalRFE.tiff']);
print(2,PicFileName,'-dtiff','-r150');
% if dispres && signifDisp>0
%     figure(2); SurfStatView( pval, Surf, 'p-value for contrast' ); 
%     PicFileName = fullfile(outdir,[outputname '_pvalRFE.tiff']);
%     print(2,PicFileName,'-dtiff','-r150');
% end
>>>>>>> .r92

% FDR
qval = SurfStatQ( slm, mask );
qval.thresh = 0.1;

signifFDR=(qval.Q<qval.thresh);
signifFDR=sum(signifFDR);

if dispres && signifFDR>0
    figure(3); SurfStatView( qval, Surf, 'FDR' );
    PicFileName = fullfile(outdir,[outputname '_pvalFDR.tiff']);
    print(3,PicFileName,'-dtiff','-r150');
end

% % Save t-map
% Data_lh = SurfStatReadData(Subjects{1,1});
% SurfStatWriteData(fullfile(outdir,['lh.' outputname '.tMap']),slm.t(1:length(Data_lh)),'b');
% SurfStatWriteData(fullfile(outdir,['rh.' outputname '.tMap']),slm.t(length(Data_lh)+1:end),'b');

 
