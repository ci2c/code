#!/bin/bash

SUBJECTS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
WD=/NAS/tupac/matthieu/SVM/SignClustROIs
LIBSVM=/home/global/matlab_toolbox/libsvm-3.22
liblinear=/home/global/matlab_toolbox/liblinear-2.1

# WD=/Users/mattvan83/Desktop/SVM/SignClustROIs_bis
# LIBSVM=/Users/mattvan83/matlab/libsvm-3.22

pathROIFile=/NAS/tupac/matthieu/SVM/SVM.PET.M0.SignClust.xlsx
roiFeatures=1
NbInstances=81


# #### 1. Import features/labels and write these into a file in LIBSVM format ####
# 
# if [ ${roiFeatures} -eq 1 ]
# then
# 	## 1a. Import ROIs features and labels ##
# 	matlab -nodisplay <<EOF
# 	WD = '/Users/mattvan83/Desktop/SVM/SignClustROIs_bis';
# 
# 	%% Load xls file with label and features values
# 	[num,txt,raw] = xlsread('${pathROIFile}')
# 
# 	%% Load labels and features for binary/multi-class classification
# 	labelBin = num(:,1);
# 	labelAll = num(:,2);
# 
# 	features = num(:,3:end);
# 
# 	%% Create LOO training/testing data sets
# 	for i = 1:length(labelBin)
# 	    labelBinTrain = [labelBin(1:i-1);labelBin(i+1:end)];
# 	    labelAllTrain = [labelAll(1:i-1);labelAll(i+1:end)];
# 	    featuresTrain = [features(1:i-1,:);features(i+1:end,:)];
# 	    
# 	    % Format training data to SVM package
# 	    libsvmwrite(fullfile('${WD}',['dataBinTrain' num2str(i) '.txt']),labelBinTrain,sparse(featuresTrain));
# 	    libsvmwrite(fullfile('${WD}',['dataAllTrain' num2str(i) '.txt']),labelAllTrain,sparse(featuresTrain));
# 
# 	    labelBinTest = labelBin(i);
# 	    labelAllTest = labelAll(i);
# 	    featuresTest = features(i,:);
# 	    
# 	    % Format test data to SVM package
# 	    libsvmwrite(fullfile('${WD}',['dataBinTest' num2str(i) '.txt']),labelBinTest,sparse(featuresTest));
# 	    libsvmwrite(fullfile('${WD}',['dataAllTest' num2str(i) '.txt']),labelAllTest,sparse(featuresTest));
# 	end
# EOF
# 
# elif [ ${roiFeatures} -eq 0 ]
# then
# 	## 1b. Import vertex-wise features and labels ##
# 	matlab -nodisplay <<EOF
# 
# 	%% Load Matlab Path: Matlab 14 and SPM12 version
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
# 
# 	%% Load fsaverage medial wall
# 	load('/NAS/tupac/matthieu/Masks/medial_wall_fsaverage.mat');
# 	lhcortex = fs_read_label(fullfile(FS_HOME, 'subjects/fsaverage/label/lh.cortex.label'));
# 	rhcortex = fs_read_label(fullfile(FS_HOME, 'subjects/fsaverage/label/rh.cortex.label'));
# 
# 	%% Load PET data from file "glim.MGRousset.gn.fwhm10.txt" and clear medial wall columns in surface data and create sparse instance matrix
# 	[PETfileleft, PETfileright] = textread(fullfile('${WD}','glim.MGRousset.gn.fwhm10.txt'), '%s %s' );
# 	Y= double(SurfStatReadData([PETfileleft, PETfileright]));
# 	Y_net = Y(:,~Mask);
# 
# 	%% Load corresponding labels
# 	label_bin = textread(fullfile('${WD}','SVM_TYPvsATYP_labels'), '%d' );
# 	label_All = textread(fullfile('${WD}','SVM_All_labels'), '%d' );
# 
# 	%% Randomly partitions observations into a training set and a test set with stratification (Training: 70% ; Test: 30%)
# 	cv_bin = cvpartition(label_bin,'HoldOut',0.3);
# 	cv_All = cvpartition(label_All,'HoldOut',0.3);SVM.PET.M0.SignClust.NoEXE
# 
# 	%% Create training and test data sets
# 	label_bin_train = label_bin(cv_bin.training);
# 	Y_net_bin_train = Y_net(cv_bin.training,:);
# 	label_bin_test = label_bin(cv_bin.test);
# 	Y_net_bin_test = Y_net(cv_bin.test,:);
# 
# 	label_All_train = label_All(cv_All.training);
# 	Y_net_All_train = Y_net(cv_All.training,:);
# 	label_All_test = label_All(cv_All.test);
# 	Y_net_All_test = Y_net(cv_All.test,:);
# 
# 	%% Transform data to the format of an SVM package
# 	libsvmwrite(fullfile('${WD}','data_bin_train.txt'),label_bin_train,sparse(Y_net_bin_train));
# 	libsvmwrite(fullfile('${WD}','data_All_train.txt'),label_All_train,sparse(Y_net_All_train));
# 
# 	libsvmwrite(fullfile('${WD}','data_bin_test.txt'),label_bin_test,sparse(Y_net_bin_test));
# 	libsvmwrite(fullfile('${WD}','data_All_test.txt'),label_All_test,sparse(Y_net_All_test));
# EOF
# fi
# 
# #### 2. Conduct simple scaling on the data: scaling training then test data into [-1,1] ####
# 
# for (( i=1; i<=${NbInstances}; i++ ))
# do
#         ${LIBSVM}/svm-scale -l -1 -u 1 -s ${WD}/range.bin ${WD}/dataBinTrain${i}.txt > ${WD}/dataBinTrain${i}.scale
#         ${LIBSVM}/svm-scale -r ${WD}/range.bin ${WD}/dataBinTest${i}.txt > ${WD}/dataBinTest${i}.scale
# 
#         ${LIBSVM}/svm-scale -l -1 -u 1 -s ${WD}/range.All ${WD}/dataAllTrain${i}.txt > ${WD}/dataAllTrain${i}.scale
#         ${LIBSVM}/svm-scale -r ${WD}/range.All ${WD}/dataAllTest${i}.txt > ${WD}/dataAllTest${i}.scale
# done

# #### 3. Run SVM-RFE-CBR (Recursive Feature Elimination with Correlation Bias Reduction) ####
# 
# matlab -nodisplay <<EOF
# 
# %% Load Matlab Path: Matlab 14 and SPM12 version
# cd ${HOME}
# p = pathdef14_SPM12;
# addpath(p);
# 
# %% Read scaled data
# [label_vector, instance_matrix] = libsvmread(fullfile('${WD}','data_bin_train.scale'));
# 
# %% Launch SVM-RFE-CBR
# [ftRank,ftScore] = ftSel_SVMRFECBR_ori(instance_matrix,label_vector);
# 
# EOF

#### 4. Hyperparameters tuning: use of different sets of Cross-Validation methods (k-fold, LOO) ####

# ## 4a. Use of K-fold CV ##
# 
# # Combined training and testing data
# cat ${WD}/data_bin_train.scale ${WD}/data_bin_test.scale > ${WD}/data_bin_combined.scale
# cat ${WD}/data_All_train.scale ${WD}/data_All_test.scale > ${WD}/data_All_combined.scale
# 
# # Binary classification
# # for CV in 5 10 71
# for CV in 10 71
# do
# 	# Use of LIBSVM "grid.py" with "${LIBSVM}/svm-train" function
# # 	python ${LIBSVM}/tools/grid.py -log2c -15,15,1 -log2g null -v ${CV} -out ${WD}/data_bin_combined.scale.grid.libsvm.${CV}CV.out -svmtrain ${LIBSVM}/svm-train -t 0 -w-1 1 -w1 1.4483 ${WD}/data_bin_combined.scale
# 
# 	# Use of LIBSVM "grid.py" function with "${liblinear}/train" function
# 	python ${LIBSVM}/tools/grid.py -log2c -15,15,1 -log2g null -v ${CV} -out ${WD}/data_bin_combined.scale.grid.liblin.${CV}CV.out -svmtrain ${liblinear}/train -w-1 1 -w1 1.4483 ${WD}/data_bin_combined.scale
# 
# 	# Use of "${liblinear}/train -C" function
# 	${liblinear}/train -C -s 2 -v ${CV} -w-1 1 -w1 1.4483 ${WD}/data_bin_combined.scale > ${WD}/data_bin_combined.scale.liblin.${CV}CV.out
# done
# 
# # Multi-class classification
# CV=71
# # Use of "${liblinear}/train -C" function
# ${liblinear}/train -C -s 2 -v ${CV} -w1 1 -w2 6 -w3 4.6667 -w4 3.2308 ${WD}/data_All_combined.scale > ${WD}/data_All_combined.scale.liblin.${CV}CV.out


## 4b. Use of LOO CV: LIBSVM "grid.py" with "${LIBSVM}/svm-train" function (RBF: C & Gamma) ##

# A. Binary case #
# for (( i=1; i<=${NbInstances}; i++ ))
# do
  i=13
  # python3 ${LIBSVM}/tools/grid.py -log2c -5,15,1 -log2g 3,-15,-1 -v 81 -out ${WD}/dataBinTrain${i}.scale.LOOCV.out -png ${WD}/dataBinTrain${i}.scale.png ${WD}/dataBinTrain${i}.scale > ${WD}/dataBinTrain${i}.scale.grid.txt
#   python3 ${LIBSVM}/tools/grid.py -log2c -5,15,1 -log2g 3,-15,-1 -v 81 -out ${WD}/dataBinTrain${i}.scale.LOOCV.out -gnuplot "null" ${WD}/dataBinTrain${i}.scale > ${WD}/dataBinTrain${i}.scale.grid.txt
  python3 ${LIBSVM}/tools/grid.py -log2c -5,15,1 -log2g 3,-15,-1 -v 81 -gnuplot "null" ${WD}/dataBinTrain${i}.scale

  C=$(tail -1 ${WD}/dataBinTrain${i}.scale.grid.txt | awk {'print $1'})
  G=$(tail -1 ${WD}/dataBinTrain${i}.scale.grid.txt | awk {'print $2'})

#   echo "C: ${C} Gamma: ${G}" >> ${WD}/Optimal_C_Gamma_bin.txt

  echo "C: ${C} Gamma: ${G}"
  ${LIBSVM}/svm-train -s 0 -t 2 -c ${C} -g ${G} -b 1 ${WD}/dataBinTrain${i}.scale ${WD}/dataBinTrain${i}.scale.test
#   ${LIBSVM}/svm-predict ${WD}/dataBinTest${i}.scale ${WD}/dataBinTrain${i}.scale.model ${WD}/dataBinTest${i}.scale.predict

#   value_th=$(head -n 1 ${WD}/dataBinTest${i}.scale | awk {'print $1'})
#   value_pr=$(head -n 1 ${WD}/dataBinTest${i}.scale.predict | awk {'print $1'})
# 
#   if [ ${value_pr} -eq ${value_th} ]; then
#     echo "Prediction OK: ${value_pr}" >> ${WD}/PredictionBin.txt
#   else
#     echo "Prediction NOK -> theorical class: ${value_th} & predict class: ${value_pr}" >> ${WD}/PredictionBin.txt
#   fi
  
  #   qbatch -q two_job_q -oe /NAS/tupac/matthieu/SVM/Logdir -N SVM${i}_rbf_SignClustROIsNoRedEXE SVM_train_predict.sh ${WD} dataBinTrain${i}.scale ${C} ${G} dataBinTest${i}.scale ${i}
# done

# # B. Multi-classes case #
# for (( i=1; i<=${NbInstances}; i++ ))
# do
#   python3 ${LIBSVM}/tools/grid.py -log2c -5,15,1 -log2g 3,-15,-1 -v 81 -out ${WD}/dataAllTrain${i}.scale.LOOCV.out -gnuplot "null" ${WD}/dataAllTrain${i}.scale > ${WD}/dataAllTrain${i}.scale.grid.txt
# 
#   C=$(tail -1 ${WD}/dataAllTrain${i}.scale.grid.txt | awk {'print $1'})
#   G=$(tail -1 ${WD}/dataAllTrain${i}.scale.grid.txt | awk {'print $2'})
# 
#   echo "$C" >> ${WD}/Optimal_C_multi_k.txt
#   echo "$G" >> ${WD}/Optimal_Gamma_multi_k.txt
# 
#   ${LIBSVM}/svm-train -s 0 -t 2 -c ${C} -g ${G} ${WD}/dataAllTrain${i}.scale ${WD}/dataAllTrain${i}.scale.model
#   ${LIBSVM}/svm-predict ${WD}/dataAllTest${i}.scale ${WD}/dataAllTrain${i}.scale.model ${WD}/dataAllTest${i}.scale.predict
# 
#   value_th=$(head -n 1 ${WD}/dataAllTest${i}.scale | awk {'print $1'})
#   value_pr=$(head -n 1 ${WD}/dataAllTest${i}.scale.predict | awk {'print $1'})
# 
#   if [ ${value_pr} -eq ${value_th} ]; then
#     echo "Prediction OK: ${value_pr}" >> ${WD}/PredictionAll.txt
#   else
#     echo "Prediction NOK -> theorical class: ${value_th} & predict class: ${value_pr}" >> ${WD}/PredictionAll.txt
#   fi
# done