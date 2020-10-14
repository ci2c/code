function zscorefs(SD, data, init)

% compute zscore for patients (data) in SD
%
%
% usage : zscorefs(fs, data, init)
%
% Inputs :
%       SD : Subjects Dir : folder containing data
%       data : list of names
%       init : structure generated by initvar.m and generate_variables.m
%              patient list and other variables must be changed into these
%              scripts.
%       
%
%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012


%%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012
%%


for pat = data

    disp(strcat('running zscorepatient for : ', pat{1}))
    
    zscorepatient(SD, pat{1}, init) 
    
end
