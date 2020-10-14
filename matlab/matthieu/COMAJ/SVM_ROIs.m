clear all; close all;

WD = '/NAS/tupac/matthieu/SVM/SignClustROIs';

%% Load xls file with label and features values
[num,txt,raw] = xlsread('/NAS/tupac/matthieu/SVM/SVM.PET.M0.SignClust.xlsx')

%% Load labels and features
labelBin = num(:,1);
labelAll = num(:,2);
% 
% % features = num(:,3:end);
% 
% % % Create LOO training/testing data sets
% % for i = 1:length(labelBin)
% %     labelBinTrain = [labelBin(1:i-1);labelBin(i+1:end)];
% %     labelAllTrain = [labelAll(1:i-1);labelAll(i+1:end)];
% %     featuresTrain = [features(1:i-1,:);features(i+1:end,:)];    
% %     % Format training data to SVM package
% %     libsvmwrite(fullfile(WD,['dataBinTrain' num2str(i) '.txt']),labelBinTrain,sparse(featuresTrain));
% %     libsvmwrite(fullfile(WD,['dataAllTrain' num2str(i) '.txt']),labelAllTrain,sparse(featuresTrain));
% % 
% %     labelBinTest = labelBin(i);
% %     labelAllTest = labelAll(i);
% %     featuresTest = features(i,:);
% %     % Format test data to SVM package
% %     libsvmwrite(fullfile(WD,['dataBinTest' num2str(i) '.txt']),labelBinTest,sparse(featuresTest));
% %     libsvmwrite(fullfile(WD,['dataAllTest' num2str(i) '.txt']),labelAllTest,sparse(featuresTest));
% % end
% 
%% Compute performance metrics of SVM

% Binary labels
labelBinP=zeros(length(labelBin),1);
 for i = 1:length(labelBin)
     labelBinP(i) = textread(fullfile(WD,['dataBinTrain' num2str(i) '.scale.predict']), '%d' );
 end
% [C, order] = confusionmat(labelBin,labelBinP);
Stats = confusionmatStats(labelBin,labelBinP);

% ROC curve and area under the curve
[X,Y,T,AUC] = perfcurve(labelBin,labelBinP,1);
% plot(X,Y)
% xlabel('False positive rate'); ylabel('True positive rate')
% title('ROC for classification by SVM')

% auc = plotroc(testing_label, testing_instance, model);

save(fullfile(WD,'Performance_metrics.mat'),'Stats','AUC','-v7.3');
% save(fullfile(WD,'Performance_metrics.txt'),'Stats.precision','AUC','-ascii');


% % Multi-class labels
% labelAllP=zeros(length(labelAll),1);
%  for i = 1:length(labelAll)
%      labelAllP(i) = textread(fullfile(WD,['dataAllTest' num2str(i) '.scale.predict']), '%d' );
%  end

% [C, order] = confusionmat(labelAll,labelAllP);
% stats = confusionmatStats(labelAll,labelAllP);

