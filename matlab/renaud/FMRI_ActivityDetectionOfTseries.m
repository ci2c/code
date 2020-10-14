function [TC_OUT,TC_D_OUT,TC_D2_OUT,TCN,param] = FMRI_ActivityDetectionOfTseries(tseries,confounds,param,TApath)

% usage : FMRI_ActivityDetectionOfTseries(tseries,[confounds,param,TApath])
%
% Inputs :
%    tseries       : 4D volume or nii file
%
% Options :
%    confounds     : motion parameters or txt file (Default: [])
%    param         : structure
%                       TR  : TR value (Default: 2)
%                       HRF : hemodynamic function (Default: 'bold')
%                       METHOD_DETREND  (Default: 'DCT and normalize' or
%                       'normalize')
%                       DCT_TS (Default: 250)
%                       LambdaTempCoef : (Default: 1/0.8095)
%                       METHOD_TEMP (Default: SPIKE)
%                       METHOD_SPAT (Default: no)
%                       COST_SAVE (Default: 1)
%                       File_EXT (Default nii)
%                       Dimension (Default [64 64 40])
%    TApath         : path to TotalActivation toolbox
%
% Renaud Lopes @ CHRU Lille, Mar 2013

if nargin < 2
    RealignParam = [];
else
    if (ischar(confounds))
        RealignParam = load(confounds);
    else
        RealignParam = confounds;
    end
end

if nargin < 3
    param.TR = 2;
    param.HRF = 'bold';
    param.METHOD_DETREND = 'DCT and normalize';
    param.DCT_TS = 250;
    param.LambdaTempCoef = 1/0.8095;
    param.METHOD_TEMP = 'SPIKE';
    param.METHOD_SPAT = 'no';
    param.COST_SAVE = 1;
    param.File_EXT = 'nii';
    param.Dimension = [64 64 40];
end

% add TA path
if nargin < 4
    TApath = '/home/notorious/NAS/renaud/TotalActivation/TotalActivationTool';
end
addpath(genpath(TApath)); % change the path

param.NbrVoxels = size(tseries,2);

% DETREND
TCN = zeros(param.Dimension(4),param.NbrVoxels); % normalize by dividing to std (var=1).

if strcmpi(param.METHOD_DETREND,'DCT and normalize')
    
    for i = 1:param.NbrVoxels;
        [TCN(:,i), ~] = sol_dct(tseries(:,i),param.TR,param.DCT_TS,RealignParam); % subtract mean liner detrend + DCT
        TCN(:,i) = TCN(:,i)./std(TCN(:,i));
    end
    
elseif strcmpi(param.METHOD_DETREND,'normalize')
    
    for i = 1:nv
        TCN(:,i) = (tseries(:,i)-mean(tseries(:,i)))./std(tseries(:,i));
    end
    
else
    
    TCN = tseries;
    
end

% Regularization

switch param.METHOD_TEMP
    
    case 'SPIKE'
        [param.f_Analyze,param.f_Recons,param.MaxEig] = hrf_filters(param.TR,'spike',param.HRF);
        param.NitTemp = 200;
        fprintf('Temporal Regularization for SPIKES\n');
    case 'BLOCK'
        [param.f_Analyze,param.f_Recons,param.MaxEig] = hrf_filters(param.TR,'block',param.HRF);
        param.NitTemp = 500;
        fprintf('Temporal Regularization for BLOCKS\n');
    case'poss'
        disp('NOT YET IMPLEMENTED!');
    case 'WIENER'
        [param.f_Analyze,param.f_Recons,param.MaxEig] = hrf_filters(param.TR,'block',param.HRF);
        param.NitTemp = 1;
        fprintf('Temporal Regularization: WIENER FILTER for BLOCKS\n');
    otherwise
        disp('Unknown method.');
        
end

switch param.METHOD_SPAT
    
    case 'no'
        fprintf('No spatial regularization');
        
    case 'TIK'
        param.Nit=5;
        param.NitSpat=100;
        param.LambdaSpat=1;
        param.stepsize=0.01;
        param.weights = [0.5 0.5]; % weights for Gen Back-Forward
        param.dimTik=3; % Tikhonov in 3d (or 2d).
        
    case 'STRSPR'
        % Number of outer iterations
        param.Nit        = 10;
        param.NitSpat    = 100;
        % Here Adjust the weight(LambdaSpat) of spatial regularization...
        param.LambdaSpat = 5;
        % We assign equal weights for both solutions
        param.weights    = [0.5 0.5]; % equal weights for Gen Back-Forward
        param.OrderSpat  = 2; % use 2nd order derivative... for now
        param.dimStrSpr  = 3; %only 3 for now...
        
    otherwise
        disp('Unknown method!');
        
end

tic;
[TC_OUT,param] = TemporalRegularization(TCN,param);
time2 = toc;

disp(' ');
disp(['IT TOOK ', num2str(time2), ' SECONDS FOR TEMPORAL REGULARIZATION OF ', num2str(param.NbrVoxels), ' TIMECOURSES']);
disp(' ');
param.time = time2;

initial=1;

TC_D_OUT  = zeros(param.Dimension(4),param.NbrVoxels); % ACTIVITY-INDUCING SIGNAL
TC_D2_OUT = zeros(param.Dimension(4),param.NbrVoxels);

if strcmpi(param.METHOD_TEMP,'block') || strcmpi(param.METHOD_TEMP,'wiener')
    TC_D2_OUT = zeros(param.Dimension(4),param.NbrVoxels); % innovation signal
%    TC_D_OUT2 = zeros(param.Dimension(4),param.NbrVoxels);
end

for i=1:param.NbrVoxels,
	TC_D_OUT(:,i) = filter_boundary(param.f_Recons.num,param.f_Recons.den,TC_OUT(:,i),'normal');
    if strcmpi(param.METHOD_TEMP,'block') || strcmpi(param.METHOD_TEMP,'wiener')
        TC_D2_OUT(:,i) = [0;diff((TC_D_OUT(:,i)))];
%        TC_D_OUT2(:,i) = cumsum([zeros(5,1); TC_D2_OUT(6:end,i)]);  %Neglect the first 5 volumes?? sometimes shifts the response...
    end
end