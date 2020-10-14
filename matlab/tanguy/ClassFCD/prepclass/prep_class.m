%%
% 
% Prep_class prepares data for classification
%
% start initvar and generate_variables
% verification of data
% Normalization (template + normalization) for control & patients
% zscore (template + zscore) for control & patients
%
%
% usage : prep_class;
% 
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012


%%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012


%%

clear all; close all; clc


%% Loading and verifying data

% start initvar

if exist('initvar')~=2
    warning('WarnTests:convertTest','Need a M-File on MATLAB''s search path named initvar.m')
    warning('WarnTests:convertTest','you cannot use this function whitout initvar.m')
    return
else
    initvar
end

% start generate_variables

if exist('generate_variables')~=2
    warning('WarnTests:convertTest','Need a M-File on MATLAB''s search path named generate_variables.m')
    warning('WarnTests:convertTest','you cannot use this function whitout generate_variables.m')
    return
else
    generate_variables
end

% verification

verif_ok=verif(init);

if ~verif_ok
    warning('WarnTests:convertTest','problem with files or initvar.m')
    return
end



%% Data preparation

% Normalization of control subjects
% Normalization to a random subject (generated in generate_variables)
% Creating a template for normalization
% Normalization of patients (including training and validation sets)

% Creating template and control normalization
if exist('normalizationcontrol')==0
    warning('WarnTests:convertTest','need the function ''normalizationcontrol'' ')
    return
else
    disp('running normalizationcontrol')
    normalizationcontrol(init)
end

% Patients normalization
if exist('normalizefs')==0
    warning('WarnTests:convertTest','need the function ''normalizefs'' ')
    return
else
    disp('running normalizefs')
    normalizefs(init)
end


% Creating zscore template
if exist('zscoretemplate')==0
    warning('WarnTests:convertTest','need the function ''zscoretemplate'' ')
    return
else
    disp('running zscoretemplate')
    zscoretemplate(init)
end


% Zscore for data
if exist('zscorefs')==0
    warning('WarnTests:convertTest','need the function ''zscorefs'' ')
    return
else
    
    disp('running zscorefs')
    
    % Zscore for control data
    zscorefs(init.cont_SD, init.cont, init);
    
    % Zscore for patients data
    
    zscorefs(init.pat_SD, init.pat, init);
    
end