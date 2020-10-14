clear all; close all;

%% Load fsaverage pial surfaces and CT data subject
[s,ab] = SurfStatReadSurf( {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/fsaverage/surf/lh.white','/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/fsaverage/surf/rh.white'} );

load('/home/matthieu/SVN/medial_wall.mat');

%% Load group data from file "glimf.txt"
% [CTfileleft, CTfileright, group, age, sex] = textread( '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Description_files/CorticalThickness/V3/glimf_fwhm10_Thick_all.txt', '%s %s %s %f %s' );
[CTfileleft, CTfileright] = textread( '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Description_files/rBPM/V7_bbr/LTLEvsRTLEvsCN/NC/glim_fwhm15_CT', '%s %s' );

%% Read group CT data and view meanCT
Y=SurfStatReadData(CTfileleft{1});
% Y=SurfStatReadData( [CTfileleft, CTfileright] );
% meanCT = mean(double(Y));
% figure(4)
% % SurfStatColLim( [1.5 3] );
% SurfStatView(meanCT, s, 'Mean CT NC');
% SurfStatColormap( 'jet' );
% SurfStatColLim( [2.5 3] );
% % 
% % meanCTsubj = mean(double(Y(:,~Mask)),2); 
% % figure(5)
% % SurfStatPlot(group,meanCTsubj);


% %% Fitting the linear model
% Group = term(group); 
% Age = term(age);
% Sex = term(sex);
% M=1+Group+Age+Sex;
% 
% % figure(6)
% % image(M);
% 
% slm = SurfStatLinMod( Y, M, s );
% 
% %% Main effect of Group
% 
% contrast = Group.control-Group.left;
% slm = SurfStatT( slm, contrast );
% 
% figure(12)
% SurfStatView( slm.t.*(~Mask), s, 'control vs left TLE' );
% 
% % Find the threshold for P=0.05, corrected
% resels = SurfStatResels(slm);
% stat_threshold(resels, length(slm.t), 1, slm.df);
% 
% % View the P-values for each vertex
% clusthresh = 0.075;
% [ pval, peak, clus ] = SurfStatP( slm , ~Mask , clusthresh );
% % pval.thresh = 0.1;
% figure(13)
% SurfStatView( pval, s, 'control vs left TLE' );
% 
% % avsurfinfl = SurfStatInflate( s, 0.75 );
% % figure(14)
% % SurfStatView( pval, avsurfinfl, 'temoin vs patient' );
% 
% % View the Q-values
% qval = SurfStatQ( slm, ~Mask );
% % qval.thresh = 0.1;
% figure(14); 
% SurfStatView( qval, s, 'fdr');
% 
% % Pval_thresh = double(zeros(1,length(pval.C)));
% % idx = find(pval.C <= 0.001);
% % Pval_thresh(idx) = (1-pval.C(idx));
% % Pval_thresh_lh = Pval_thresh(1:163842);
% % Pval_thresh_rh = Pval_thresh(163843:327684);
% % SurfStatWriteData('/NAS/dumbo/protocoles/ASL_Epilepsy/SurfaceAnalysis_SurfStat/lh.Pval_thresh001_fwhm6', Pval_thresh_lh , 'b');
% % SurfStatWriteData( '/NAS/dumbo/protocoles/ASL_Epilepsy/SurfaceAnalysis_SurfStat/rh.Pval_thresh001_fwhm6', Pval_thresh_rh , 'b' );
% 
% % Qval_thresh = double(zeros(1,length(qval.Q)));
% % idx = find(qval.Q <= 0.05);
% % Qval_thresh(idx) = (1-qval.Q(idx));
% % Qval_thresh_lh = Qval_thresh(1:163842);
% % Qval_thresh_rh = Qval_thresh(163843:327684);
% % SurfStatWriteData('/NAS/dumbo/protocoles/ASL_Epilepsy/SurfaceAnalysis_SurfStat/lh.Qval_thresh05_fwhm6', Qval_thresh_lh , 'b');
% % SurfStatWriteData( '/NAS/dumbo/protocoles/ASL_Epilepsy/SurfaceAnalysis_SurfStat/rh.Qval_thresh05_fwhm6', Qval_thresh_rh , 'b' );