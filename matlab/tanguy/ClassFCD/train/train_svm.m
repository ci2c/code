function S = train_svm(init, global_lesion, global_control)
% 
% train_svm trains SVM for FCD detection
% 
% usage :  train_svm(init, global_lesion, global_control))
% 
% INPUTS :
%       init : initialization structure - generated by initvar.m and
%       generate_variables.m
%       global_lesion : lesional tissue matrix
%       global_control : healthy tissue matrix
%
% OUTPUTS : 
%       T : Trained SVM
%
%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012



%%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012

h = waitbar(0,'Runing LibSVM');
steps = init.nbsvm;

for w = 1 : init.nbsvm
    
    waitbar(w / steps)
    
    vertex_alea=[];
    
    % tirage aléatoire de init.nbles vertex lésionels
    global_lesion=global_lesion(:,randperm(size(global_lesion,2)));
    vertex_alea=[vertex_alea global_lesion(:,1:init.nbles)];
    
    % tirage aléatoire de init.nbhea vertex sains
    global_control=global_control(:,randperm(size(global_control,2)));
    vertex_alea=[vertex_alea global_control(:,1:init.nbhea)];
    
    O(1:init.nbles)=1; O(init.nbles+1:init.nbles+init.nbhea)=0;
    
    model = svmtrain( double(O'), double(vertex_alea'), '-c 1 -g 0.07 -b 1 -h 0');
    
    S{w} = model;
    
end
close(h)