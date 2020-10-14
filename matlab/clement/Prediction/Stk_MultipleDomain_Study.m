clear all
%% LOADING && CONFIG

Domains = ['L' 'A' 'P' 'M' 'E' 'G' 'V'];

% Connections of 1 altered domain
load('/NAS/tupac/protocoles/Strokdem/Prediction/Domains_Ridge_Projections','Proj_L','Proj_A','Proj_P','Proj_M','Proj_E','Proj_G','Proj_V');

%% BUILD MATRICES

% Gather Monotask projections

Domain_Proj = [];
Proj_L = niak_mat2vec(abs(Proj_L));
Proj_L(Proj_L < 5) = 0;
Proj_L(Proj_L >= 5) = 1;

Domain_Proj(end+1,:) = Proj_L;
% -
Proj_A = niak_mat2vec(abs(Proj_A));
Proj_A(Proj_A < 5) = 0;
Proj_A(Proj_A >= 5) = 1;

Domain_Proj(end+1,:) = Proj_A;
% -
Proj_P = niak_mat2vec(abs(Proj_P));
Proj_P(Proj_P < 5) = 0;
Proj_P(Proj_P >= 5) = 1;

Domain_Proj(end+1,:) = Proj_P;
% -
Proj_M = niak_mat2vec(abs(Proj_M));
Proj_M(Proj_M < 5) = 0;
Proj_M(Proj_M >= 5) = 1;

Domain_Proj(end+1,:) = Proj_M;
% - 
Proj_E = niak_mat2vec(abs(Proj_E));
Proj_E(Proj_E < 5) = 0;
Proj_E(Proj_E >= 5) = 1;

Domain_Proj(end+1,:) = Proj_E;
% -
Proj_G = niak_mat2vec(abs(Proj_G));
Proj_G(Proj_G < 5) = 0;
Proj_G(Proj_G >= 5) = 1;

Domain_Proj(end+1,:) = Proj_G;
% -
Proj_V = niak_mat2vec(abs(Proj_V));
Proj_V(Proj_V < 5) = 0;
Proj_V(Proj_V >= 5) = 1;

Domain_Proj(end+1,:) = Proj_V;


% -----
Domain_Matrix = zeros(7,7,178);

%Triu part of the matrix

for i = 1:length(Domains)
    
    for j= 1:length(Domains)
        
        if i < j 
            % Multitask 
            load( fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/Composite',[ 'Composite_FC_NoFazekas_PSCINetwork_' Domains(i) Domains(j) '.mat']), 'msbproj','var_expl');
            msbproj = niak_mat2vec(abs(msbproj));
            msbproj(msbproj < 5) = 0;
            msbproj(msbproj >= 5) = 1;

            Mult = find(msbproj == 1);

            Proj_Com = [Domain_Proj(i,:) + Domain_Proj(j,:)];
            ID_C = find(Proj_Com >= 1);
           
           % Find only connexions already found in the trouble
           tmp = [var_expl;Mult(ismember(Mult,ID_C))];
           %
           Domain_Matrix(i,j,1:length(tmp)) = tmp; 
        
        elseif i > j
            
            load( fullfile('/NAS/tupac/protocoles/Strokdem/Prediction/Composite',[ 'Composite_FC_NoFazekas_PSCINetwork_' Domains(j) Domains(i) '.mat']), 'msbproj','var_expl');
            msbproj = niak_mat2vec(abs(msbproj));
            msbproj(msbproj < 5) = 0;
            msbproj(msbproj >= 5) = 1;

            Mult = find(msbproj == 1);

            Proj_Com = [Domain_Proj(i,:) + Domain_Proj(j,:)];
            ID_C = find(Proj_Com >= 1);
           
           % Find only connexions already found in the trouble
           tmp = [var_expl;Mult(~ismember(Mult,ID_C))];
           %
           Domain_Matrix(i,j,1:length(tmp)) = tmp; 
     
        end   

    end
end

        
        
               
        

