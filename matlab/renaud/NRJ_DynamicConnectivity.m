function varargout = NRJ_DynamicConnectivity(epiFiles,motFiles,outDir,maskFiles,TR,window_size,types,step_after,markerFile,dataFile,dynFile)

% usage : WOI = NRJ_DynamicConnectivity(epiDir,outDir,prefepi,maskFiles,window_size,TR,markerFile,types,step_after)
%
% Inputs:
%    epiFiles      : epi files (*.nii)
%    motFiles      : motion files (*.txt)
%    outDir        : output folder
%    maskFiles     : mask files
%    TR            : time of repetition
%   window_size    : size of windows (Default: 8)
%   types          : types of events ("[]" means all events) (Default: [])
%   step_after     : begining of windows after events (in frames) (Default: 8)
%
% Options:
%   markerFile     : marker file
%   dataFile       : Concatenate EPI file
%   dynFile        : results of dynamic functional connectivity
%
% Output:
%    WOI           : windows of interest ("before events" - "during events"
%                       - "after events" - "without events")
%
% Renaud Lopes @ CHRU Lille, Jan 2014

%% ADD PATHS

addpath('/home/renaud/NAS/renaud/scripts/francois');
addpath(genpath('/home/renaud/NAS/renaud/scripts/francois/captain'));
addpath('/home/renaud/NAS/renaud/scripts/DynamicTimeWarp/WarpingTB');


%% INIT

if nargin < 9
    markerFile = '';
end
if nargin < 10
    dataFile = '';
end
if nargin < 11
    dynFile = '';
end

if size(epiFiles,1) ~= size(motFiles,1)
    disp('not the same number of epi files and motion files');
    return;
end


%% DYNAMIC FUNCTIONAL CONNECTIVITY

if isempty(dataFile)
    %[tseries_all,coord_rois,all_rois,all_mask,all_ind_roi,all_hdr] = FMRI_ConcatenateTimeCourses(epiFiles,outDir,TR,brainMask, motFiles,ventMask,wmMask,roiFiles,preproc);
    [tseries_all,coord_rois,data_all] = ConcatenateTimeCourses(maskFiles,epiFiles,motFiles,TR);
    save(fullfile(outDir,'tseries_all.mat'),'tseries_all','coord_rois','data_all');
else
    load(dataFile,'tseries_all','coord_rois','all_rois','all_mask','all_ind_roi','all_hdr','preproc');
    tseries = [];
    for k = 1:length(tseries_all)
        tseries = [tseries tseries_all{k}];
    end
    tseries = tseries';
end

if isempty(dynFile)
    [FNCdyn,windowTimes,blambda,tcwin,A] = DynamicFunctionalConnectivityAnalysis(tseries,'TR',TR,'wsize',window_size,'method','L1','allVoxels','no','detrending',true,'window_alpha',1);
    save(fullfile(outDir,['DynFunc_' num2str(window_size) '.mat']),'FNCdyn','windowTimes','blambda','tcwin','A','window_size');
else
    load(dynFile,'FNCdyn','windowTimes','blambda','tcwin','A','window_size','coord_rois');
end


%% STUDY AROUND EVENTS

if ~isempty(markerFile)
    
    load(markerFile);

    WOI = NRJ_WindowsOfInterest(epiFiles,markerFile,TR,window_size,types,step_after);
    types_name = [num2str(window_size)];
    for k = 1:length(types)
        types_name = [types_name '_' num2str(types(k))];
    end

    save(fullfile(outDir,['WOI_' types_name '_' num2str(step_after) '.mat']),'WOI','types','step_after','window_size','coord_rois');

    FNCdynres = zeros(length(windowTimes),size(FNCdyn,2));
    eventimes = zeros(1,length(windowTimes));

    deb = min(find(windowTimes==1));
    fin = max(find(windowTimes==1));

    FNCdynres(deb:fin,:) = FNCdyn;

    n     = size(tseries_all,1);
    temp  = ones(size(tseries_all,1));
    IND   = find((temp-triu(temp))>0);
    [I,J] = ind2sub([n n],IND);

    % STUDY AROUND SPIKES
    before_spike   = FNCdynres(WOI.beforeEvents_timing,:)';
    during_spike   = FNCdynres(WOI.duringEvents_timing,:)';
    after_spike    = FNCdynres(WOI.afterEvents_timing,:)';
    during_nospike = FNCdynres(WOI.noEvents_timing,:)';
    moyenne = [mean(during_nospike,2) mean(before_spike,2) mean(during_spike,2) mean(after_spike,2)];

    save(fullfile(outDir,['EventsStudy_' types_name '_' num2str(step_after) '.mat']),'before_spike','during_spike','after_spike','during_nospike','moyenne','coord_rois');
    
else
    
    WOI = [];
    
end

varargout = {WOI,FNCdyn,windowTimes,tseries,coord_rois,blambda,tcwin,A};
varargout = varargout(1:nargout);

