% function SVM_train_predict(WD,trainFile,C,G,testFile,i)

clear all; close all;
WD='/NAS/tupac/matthieu/SVM/SignClustROIs';
trainFile='dataBinTrain13.scale';
C=256;
G=0.00048828125;
testFile='dataBinTest13.scale';
i=13;

%% Read files in LIBSVM format
[training_label_vector, training_instance_matrix] = libsvmread(fullfile(WD,trainFile));
[testing_label_vector, testing_instance_matrix] = libsvmread(fullfile(WD,testFile));

%% Train model
model = svmtrain(training_label_vector, training_instance_matrix, ['-s 0 -t 0 -c ' num2str(C) ' -g ' num2str(G) ' -b 1']);

%% Predict test classes
[predicted_label, accuracy, prob_estimates] = svmpredict(testing_label_vector, testing_instance_matrix, model, '-b 1');
% [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, model);

%% Compute feature weights: orthogonal vector to the hyperplane
w=(model.sv_coef'*full(model.SVs));
% bias = -model.rho;
% predictions = sign(features * w' + bias);

%% Write predicted label in output file
fid = fopen(fullfile(WD,['testFile' num2str(i) '.scale.predict']),'w');
fprintf(fid,'%d\n',predicted_label);
fclose(fid);

%% Save model and output predicted data
save(fullfile(WD,'Model' num2str(i) '.mat'),'model','predicted_label','accuracy','prob_estimates','w','-v7.3');
