% for fwhm = 0:5:25
clear all; close all;
fwhm = 20;
    %% Load fsaverage pial surfaces and CT data subject
    [s,ab] = SurfStatReadSurf( {'/NAS/dumbo/protocoles/ictus/Data/TEMOINS/fsaverage/surf/lh.pial','/NAS/dumbo/protocoles/ictus/Data/TEMOINS/fsaverage/surf/rh.pial'} );

    mask = SurfStatReadData( {'/NAS/dumbo/matthieu/lh.cortex_mask', '/NAS/dumbo/matthieu/rh.cortex_mask'} );
    mask = logical(mask);
%     load('/NAS/dumbo/matthieu/medial_wall_fsaverage.mat');

    %% Load group data from file "glimf.txt"
    % Two-sample t-test
%     [CTfileleft, CTfileright, group] = textread(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat', ['glimp_fwhm' num2str(fwhm) '_thickness_pats2_tem.txt']), '%s %s %s');
%     [CTfileleft, CTfileright, group, sex, age] = textread(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat', ['glimt_fwhm' num2str(fwhm) '_thickness_pats2_tem.txt']), '%s %s %s %s %f');
    % [Gradientleft, Gradientright, group, sex, age] = textread('/NAS/dumbo/protocoles/ictus/Data/dxyz/glimt_fwhm10_dxyz_pat64ds1_tem.txt', '%s %s %s %s %f');
    % [Complexityleft, Complexityright, group, sex, age] = textread('/NAS/dumbo/protocoles/ictus/Data/complexity/glimt_fwhm15_complexity_pat64ds1_tem.txt', '%s %s %s %s %f');
    
%     % Paired t-test
    [id, testtime, CTfileleft, CTfileright]=textread(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat', ['glim_rep_fwhm' num2str(fwhm) '_thickness_pats1_pats2.txt']), ' %s %s %s %s');
%     [id, testtime, sex, age, CTfileleft, CTfileright]=textread(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat', ['glim_rep_cov_fwhm' num2str(fwhm) '_thickness_pats1_pats2.txt']), ' %s %s %s %f %s %s');

    %% Read group CT data and view meanCT
    Y=SurfStatReadData( [CTfileleft, CTfileright] );
% %     Y=SurfStatReadData( [Complexityleft, Complexityright] );
%     meanCT = mean(double(Y));
%     figure
%     SurfStatView(meanCT, s, 'Mean CT');
%     
%     meanCTsubj = mean(double(Y(:,mask)),2); 
%     figure
%     SurfStatPlot(testtime,meanCTsubj);

%     %% MEANS & STDS
% 
%     %Mean cortical thickness for all
%     figure
%     SurfStatView( mean(double(Y)).*mask, s, 'mean cortical thickness');
% %     SurfStatColLim([0.5,5.5]);
% 
%     %Standard deviation of cortical thickness for all
%     figure
%     SurfStatView( std(double(Y)).*mask, s, 'std cortical thickness');
% %     SurfStatColLim([0,.7]);
% 
%     %Mean cortical thickness, per TestTime
%     figure
%     SurfStatView( mean(Y(1:9,:)).*mask, s, 'mean cortical thickness, time1');
% %     SurfStatColLim([0.5,5.5]);
% 
%     figure
%     SurfStatView( mean(Y(10:18,:)).*mask, s, 'mean cortical thickness, time2');
% %     SurfStatColLim([0.5,5.5]);
% 
%     %Standard deviation of cortical thickness, per TestTime
%     figure
%     SurfStatView( std(Y(1:9,:)).*mask, s, 'std cortical thickness, time1');
% %     SurfStatColLim([0,.7]);
% 
%     figure
%     SurfStatView( std(Y(10:18,:)).*mask, s, 'std cortical thickness, time2');
% %     SurfStatColLim([0,.7]);
    
    %% Create terms
%     % Two-sample t-test
%     Group = term(group);
%     Age = term (age);
%     Sex = term (sex);
%     %age_normalized = (age-mean(age))/std(age);  %if you want to
% %    normalize age
%     %Age = term(age_normalized);  %if you want to normalize age

    % Paired t-test
    TestTime = term (testtime);
%     Age = term (age);
%     Sex = term (sex);

    %% Create linear model and estimate it
%     % Two-sample t-test
% %     M=1+Group;
%     M=1+Group+Age+Sex;

    % Paired t-test
    M = 1 + TestTime + random(id) + I;
%     M = 1 + TestTime + Sex + Age + random(id) + I;
    
%     figure
%     image(M);
    slm = SurfStatLinMod( Y, M, s );

%     %% Main effect of Group
% 
%     contrast = Group.patient_s2-Group.temoin;
%     slm = SurfStatT( slm, contrast );
% 
% %     figure(12)
% %     SurfStatView( slm.t.*mask, s, 'temoin vs patient' );
% 
%     % Find the threshold for P=0.05, corrected
%     resels = SurfStatResels(slm);
%     stat_threshold(resels, length(slm.t), 1, slm.df);
% 
%     % View the P-values for each vertex
%     % clusthresh = 0.01;
%     [ pval, peak, clus ] = SurfStatP( slm , mask );
%     % pval.thresh = 0.1;
% %     figure(13)
% %     SurfStatView( pval, s, 'temoin vs patient : FWE correction' );
% 
%     % avsurfinfl = SurfStatInflate( s, 0.75 );
%     % figure(14)
%     % SurfStatView( pval, avsurfinfl, 'temoin vs patient' );
% 
%     % View the Q-values
%     qval = SurfStatQ( slm, mask );
%     % qval.thresh = 0.1;
% %     figure(14); 
% %     SurfStatView( qval, s, 'temoin vs patient : FDR correction');

    %% MAIN EFFECT OF TESTTIME, DIRECTION 1 (TIME3 > TIME1)

    %To get your t statistic for group
    contrast_testtime_direction1 = TestTime.Time3 - TestTime.Time2;
    slm_testtime_direction1 = SurfStatT ( slm, contrast_testtime_direction1);
%     figure
%     SurfStatView ( slm_testtime_direction1.t.*mask, s, 'tmap time1>time2, removing age, sex' );
%     SurfStatColLim([-4,4]);

    %To get thresholded p values using Random Field Theory
    [ pval, peak, clus ] = SurfStatP( slm_testtime_direction1, mask );
%     figure
%     SurfStatView( pval, s, 'RFT time1>time2, removing age, sex');

    %To get thresholded p values using False Discovery Rate
    qval = SurfStatQ( slm_testtime_direction1, mask );
%     figure
%     SurfStatView( qval, s, 'FDR time1>time2, removing age, sex');

%     Save Pval & Qval maps
    Pval_thresh = double(zeros(1,length(pval.P)));
    idx = find(pval.P <= 0.05);
    Pval_thresh(idx) = (1-pval.P(idx));
    Pval_thresh = Pval_thresh.*mask;
    Pval_thresh_lh = Pval_thresh(1:163842);
    Pval_thresh_rh = Pval_thresh(163843:327684);
    SurfStatWriteData(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat',['lh.Pval_p_ptt_S2vsS1_fwhm' num2str(fwhm)]), Pval_thresh_lh , 'b');
    SurfStatWriteData(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat',['rh.Pval_p_ptt_S2vsS1_fwhm' num2str(fwhm)]), Pval_thresh_rh , 'b' );

    clear idx;
    
    Qval_thresh = double(zeros(1,length(qval.Q)));
    idx = find(qval.Q <= 0.05);
    Qval_thresh(idx) = (1-qval.Q(idx));
    Qval_thresh = Qval_thresh.*mask;
    Qval_thresh_lh = Qval_thresh(1:163842);
    Qval_thresh_rh = Qval_thresh(163843:327684);
    SurfStatWriteData(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat',['lh.Qval_p_ptt_S2vsS1_fwhm' num2str(fwhm)]), Qval_thresh_lh , 'b');
    SurfStatWriteData(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat',['rh.Qval_p_ptt_S2vsS1_fwhm' num2str(fwhm)]), Qval_thresh_rh , 'b');
    
    clear Pval_thresh Qval_thresh idx;
    
     %% MAIN EFFECT OF TESTTIME, DIRECTION 2 (TIME2 > TIME1)

    %To get your t statistic for groupclear idx;
    contrast_testtime_direction2 = TestTime.Time2 - TestTime.Time3;
    slm_testtime_direction2 = SurfStatT ( slm, contrast_testtime_direction2);
%     figure
%     SurfStatView ( slm_testtime_direction2.t.*mask, s, 'tmap time2>time1, removing age, sex' );
%     SurfStatColLim([-4,4]);

    %To get thresholded p values using Random Field Theory
    [ pval, peak, clus ] = SurfStatP( slm_testtime_direction2, mask );
%     figure
%     SurfStatView( pval, s, 'RFT time2>time1, removing age, sex');

    %To get thresholded p values using False Discovery Rate
    qval = SurfStatQ( slm_testtime_direction2, mask );
%     figure
%     SurfStatView( qval, s, 'FDR time2>time1, removing age, sex');

    %Save Pval & Qval maps
    Pval_thresh = double(zeros(1,length(pval.P)));
    idx = find(pval.P <= 0.05);
    Pval_thresh(idx) = (1-pval.P(idx));
    Pval_thresh = Pval_thresh.*mask;
    Pval_thresh_lh = Pval_thresh(1:163842);
    Pval_thresh_rh = Pval_thresh(163843:327684);
    SurfStatWriteData(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat',['lh.Pval_p_ptt_S1vsS2_fwhm' num2str(fwhm)]), Pval_thresh_lh , 'b');
    SurfStatWriteData(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat',['rh.Pval_p_ptt_S1vsS2_fwhm' num2str(fwhm)]), Pval_thresh_rh , 'b' );

    clear idx;
    
    Qval_thresh = double(zeros(1,length(qval.Q)));
    idx = find(qval.Q <= 0.05);
    Qval_thresh(idx) = (1-qval.Q(idx));
    Qval_thresh = Qval_thresh.*mask;
    Qval_thresh_lh = Qval_thresh(1:163842);
    Qval_thresh_rh = Qval_thresh(163843:327684);
    SurfStatWriteData(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat',['lh.Qval_p_ptt_S1vsS2_fwhm' num2str(fwhm)]), Qval_thresh_lh , 'b');
    SurfStatWriteData(fullfile('/NAS/dumbo/protocoles/ictus/Data/CorticalThickness_SurfStat',['rh.Qval_p_ptt_S1vsS2_fwhm' num2str(fwhm)]), Qval_thresh_rh , 'b');
 
    clear Pval_thresh Qval_thresh idx;
    
%     clear all; close all;
% % end