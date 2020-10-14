% clear all; close all;

SUBJECTS_DIR = '/NAS/tupac/protocoles/COMAJ/FS53';
WD = '/NAS/tupac/matthieu/SVM';

%% 1. Load fsaverage white surfaces and medial wall
[s,ab] = SurfStatReadSurf( {fullfile(SUBJECTS_DIR,'/fsaverage/surf/lh.white'),fullfile(SUBJECTS_DIR,'/fsaverage/surf/rh.white')} );
load('/NAS/tupac/matthieu/Masks/medial_wall_fsaverage.mat');

%% 2. Load PET data from file "glim.MGRousset.gn.fwhm10.txt"
[PETfileleft, PETfileright] = textread(fullfile(WD,'glim.MGRousset.gn.fwhm10.txt'), '%s %s' );
Y= double(SurfStatReadData([PETfileleft, PETfileright]));
Y_net = Y(:,~Mask);

%% Load corresponding labels
label_bin = textread(fullfile(WD,'SVM_TYPvsATYP_labels'), '%d' );
label_All = textread(fullfile(WD,'SVM_All_labels'), '%d' );
% 
% %% Randomly partitions observations into a training set and a test set with stratification (Training: 70% ; Test: 30%)
% cv_bin = cvpartition(label_bin,'HoldOut',0.3);
% cv_All = cvpartition(label_All,'HoldOut',0.3);
% 
% %% Create training and test data sets
% label_bin_train = label_bin(cv_bin.training);
% Y_net_bin_train = Y_net(cv_bin.training,:);
% label_bin_test = label_bin(cv_bin.test);
% Y_net_bin_test = Y_net(cv_bin.test,:);
% 
% label_All_train = label_All(cv_All.training);
% Y_net_All_train = Y_net(cv_All.training,:);
% label_All_test = label_All(cv_All.test);
% Y_net_All_test = Y_net(cv_All.test,:);
% 
% %% Transform data to the format of an SVM package
% libsvmwrite(fullfile(WD,'data_bin_train.txt'),label_bin_train,sparse(Y_net_bin_train));
% libsvmwrite(fullfile(WD,'data_All_train.txt'),label_All_train,sparse(Y_net_All_train));
% 
% libsvmwrite(fullfile(WD,'data_bin_test.txt'),label_bin_test,sparse(Y_net_bin_test));
% libsvmwrite(fullfile(WD,'data_All_test.txt'),label_All_test,sparse(Y_net_All_test));
% 
% % %% End. Reconstruct surface data with medial wall
% % tic
% % indexMW = find(Mask);
% % vecNul = zeros(size(Y,1),1);
% % Y_final = Y_net;
% % for i=1:length(indexMW)
% % %     Y_final=[Y_final(:,1:indexMW(i)-1) vecNul Y_final(:,indexMW(i):end)];
% %     Y_final=horzcat(Y_final(:,1:indexMW(i)-1),vecNul,Y_final(:,indexMW(i):end));
% % end
% % toc

% %% Read scaled data 
% [label_vector, instance_matrix] = libsvmread(fullfile(WD,'data_bin_train.scale'));
% 
% %% Launch SVM-RFE-CBR
% tic
% [ftRank,ftScore] = ftSel_SVMRFECBR_ori(instance_matrix,label_vector);
% toc