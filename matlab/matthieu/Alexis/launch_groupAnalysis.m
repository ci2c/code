clear all; close all;

% fsdir     = '/home/fatmike/renaud/alexis/FS50_ju';
outdir    = '/home/matthieu/NAS/matthieu/Alexithymie';
subjs_nal = {'AR28' 'ED24' 'EH23' 'HB27' 'ID19' 'IS17' 'SL25' 'SM07'};
subjs_al  = {'CD15' 'DG21' 'GM13' 'HB20' 'JN26' 'LG10' 'NC12' 'NR22' 'SG18' 'SL29' 'VC04'};
subjs_pa  = {'AR28' 'ED24' 'EH23' 'HB27' 'ID19' 'IS17' 'SL25' 'SM07' 'CD15' 'DG21' 'GM13' 'HB20' 'JN26' 'LG10' 'NC12' 'NR22' 'SG18' 'SL29' 'VC04'};
subjs_co  = {'T_CB10' 'T_CS05' 'T_FD03' 'T_FH07' 'T_JP04' 'T_ML08' 'T_SH09' 'T_TM02'};
ContrastName = {'Words Left' 'Words Right' 'NoWords Left' 'NoWords Right' 'Damier' 'Left vs Right Words' 'Right vs Left Words' 'Left vs Right NoWords' 'Right vs Left NoWords' 'Left vs Right' 'Right vs Left'};

% hrf_type    = ['glove'; 'peak3'; 'peak5'; 'peak7'; 'peak9'];
% which_stats = '_ef _sd _t _sdratio _fwhm';

%%% Alexithymie Vs Controls
% 
%     mkdir(fullfile(outdir,'SecondLevel_SPM','AlVsControls'));
%     for con = 1 : length(ContrastName)
%         mkdir(fullfile(outdir,'SecondLevel_SPM','AlVsControls',ContrastName{con}));
%         Alexis_SecondLevelSPM(outdir,'AlVsControls',subjs_al,subjs_co,con,ContrastName);
%     end

%%% Controls Vs Alexithymie
% 
%     mkdir(fullfile(outdir,'SecondLevel_SPM','ControlsVsAl'));
%     for con = 1 : length(ContrastName)
%         mkdir(fullfile(outdir,'SecondLevel_SPM','ControlsVsAl',ContrastName{con}));
%         Alexis_SecondLevelSPM(outdir,'ControlsVsAl',subjs_co,subjs_al,con,ContrastName);
%     end    
%     
% %% Non-Alexithymie Vs Controls
% 
%     mkdir(fullfile(outdir,'SecondLevel_SPM','NalVsControls'));
%     for con = 1 : length(ContrastName)
%         mkdir(fullfile(outdir,'SecondLevel_SPM','NalVsControls',ContrastName{con}));
%         Alexis_SecondLevelSPM(outdir,'NalVsControls',subjs_nal,subjs_co,con,ContrastName);
%     end
%  
% %% Controls Vs Non-Alexithymie
% 
%     mkdir(fullfile(outdir,'SecondLevel_SPM','ControlsVsNal'));
%     for con = 1 : length(ContrastName)
%         mkdir(fullfile(outdir,'SecondLevel_SPM','ControlsVsNal',ContrastName{con}));
%         Alexis_SecondLevelSPM(outdir,'ControlsVsNal',subjs_co,subjs_nal,con,ContrastName);
%     end
%% Non-Alexithymie Vs Alexithymie

    mkdir(fullfile(outdir,'SecondLevel_SPM','NalVsAl'));
    for con = 1 : length(ContrastName)
        mkdir(fullfile(outdir,'SecondLevel_SPM','NalVsAl',ContrastName{con}));
        Alexis_SecondLevelSPM(outdir,'NalVsAl',subjs_nal,subjs_al,con,ContrastName);
    end
 
%% Alexithymie Vs Non-Alexithymie

    mkdir(fullfile(outdir,'SecondLevel_SPM','AlVsNal'));
    for con = 1 : length(ContrastName)
        mkdir(fullfile(outdir,'SecondLevel_SPM','AlVsNal',ContrastName{con}));
        Alexis_SecondLevelSPM(outdir,'AlVsNal',subjs_al,subjs_nal,con,ContrastName);
    end