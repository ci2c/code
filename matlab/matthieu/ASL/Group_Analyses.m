clear all; close all;

%% Load fsaverage pial surfaces and test one asl data subject
[s,ab] = SurfStatReadSurf( {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/fsaverage/surf/lh.pial','/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/fsaverage/surf/rh.pial'} );

% t = SurfStatReadData( {'/home/matthieu/NAS/pierre/Epilepsy/FreeSurfer5.0/Patients_fmri_dti/Bourgeois_Aurelie/asl/lh.fsaverage.rCBF.zscore', '/home/matthieu/NAS/pierre/Epilepsy/FreeSurfer5.0/Patients_fmri_dti/Bourgeois_Aurelie/asl/rh.fsaverage.rCBF.zscore'} );
% figure(1)
% SurfStatView( t, s, 'CBF (mL/100 mL/min), FreeSurfer data' );
% SurfStatView( t, s, 'CBF (mL/100 mL/min), FreeSurfer data','black' )
% SurfStatColormap( 'jet' );

%% Read the surface data
% mask = SurfStatMaskCut(s); 
% figure(2)
% SurfStatView(mask,s, 'Masked average surface' );

load('/NAS/dumbo/matthieu/medial_wall.mat');

% maskb = mask & SurfStatROI( [0; -16; -8], 20, s ) == 0; 
% figure(3)
% SurfStatView(maskb,s, 'Masked average surface -brainstem' );

%% Load group data from file "glimf.txt"
[aslfileleft, aslfileright, local, age, sex] = textread('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/SurfaceAnalysis_SurfStat/V4/glimzf_fwhm3_cbf_s.txt', '%s %s %s %f %s');

%% Read group asl data and view meanasl
Y=SurfStatReadData( [aslfileleft, aslfileright] );
% meanasl = mean(double(Y));
% figure(4)
% SurfStatView(meanasl, s, 'Mean CBF (mL/100 mL/min), n=76');
% 
% meanaslsubj = mean(double(Y(:,~Mask)),2); 
% figure(5)
% SurfStatPlot(local,meanaslsubj);


%% Fitting the linear model
Local = term(local); 
Age = term(age);
Sex = term(sex);
M=1+Local+Age+Sex;

% figure(8)
% image(M);

slm = SurfStatLinMod( Y, M, s );

% % %% Main effect of Gender
% % 
% % contrast = Gender.male - Gender.female;
% % slm = SurfStatT( slm, contrast );
% % 
% % figure(9)
% % SurfStatView( slm.t, s, 'T (66 df) for males-females removing localization' );
% % 
% % % Find the threshold for P=0.05, corrected
% % resels = SurfStatResels(slm);
% % thres = stat_threshold(resels, length(slm.t), 1, slm.df );
% % 
% % % View the P-values for each vertex
% % [ pval, peak, clus ] = SurfStatP( slm );
% % figure(10)
% % SurfStatView( pval, s, 'Males-females removing localization' );
% % 
% % avsurfinfl = SurfStatInflate( s, 0.75 );
% % figure(11)
% % SurfStatView( pval, avsurfinfl, 'Males-females removing localization' );
% 
%% Main effect of Localization

contrast = Local.control-Local.left;
slm = SurfStatT( slm, contrast );

figure(12)
SurfStatView( slm.t.*(~Mask), s, 'T Control vs LTLE' );

% Find the threshold for P=0.05, corrected
resels = SurfStatResels(slm);
stat_threshold(resels, length(slm.t), 1, slm.df);

% View the P-values for each vertex
clusthresh = 0.1;
[ pval, peak, clus ] = SurfStatP( slm , ~Mask , clusthresh );
figure(13)
% pval.thresh = 0.5;
SurfStatView( pval, s, 'Contrast control - left' );

% avsurfinfl = SurfStatInflate( s, 0.75 );
% figure(14)
% SurfStatView( pval, avsurfinfl, 'localization removing males-females' );

% View the Q-values
qval = SurfStatQ( slm, ~Mask );
figure(15); 
% qval.thresh = 0.5;
SurfStatView( qval, s, 'fdr');

% Pval_thresh = double(zeros(1,length(pval.C)));
% idx = find(pval.C <= 0.05);
% Pval_thresh(idx) = (1-pval.C(idx));
% Pval_thresh_lh = Pval_thresh(1:163842);
% Pval_thresh_rh = Pval_thresh(163843:327684);
% SurfStatWriteData('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/SurfaceAnalysis_SurfStat/V4/lh.Pval_thresh0.05_fwhm6', Pval_thresh_lh , 'b');
% SurfStatWriteData('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/SurfaceAnalysis_SurfStat/V4/rh.Pval_thresh0.05_fwhm6', Pval_thresh_rh , 'b' );

% Qval_thresh = double(zeros(1,length(qval.Q)));
% idx = find(qval.Q <= 0.05);
% Qval_thresh(idx) = (1-qval.Q(idx));
% Qval_thresh_lh = Qval_thresh(1:163842);
% Qval_thresh_rh = Qval_thresh(163843:327684);
% SurfStatWriteData('/NAS/dumbo/protocoles/ASL_Epilepsy/SurfaceAnalysis_SurfStat/lh.Qval_thresh05_fwhm6', Qval_thresh_lh , 'b');
% SurfStatWriteData( '/NAS/dumbo/protocoles/ASL_Epilepsy/SurfaceAnalysis_SurfStat/rh.Qval_thresh05_fwhm6', Qval_thresh_rh , 'b' );