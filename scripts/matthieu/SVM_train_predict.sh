#!/bin/bash

WD=$1
trainFile=$2
C=$3
G=$4
testFile=$5
i=$6

python3 ${LIBSVM}/tools/grid.py -log2c -5,15,1 -log2g 3,-15,-1 -v 81 -out ${WD}/dataBinTrain${i}.scale.LOOCV.out -gnuplot "null" ${WD}/dataBinTrain${i}.scale > ${WD}/dataBinTrain${i}.scale.grid.txt

C=$(tail -1 ${WD}/dataBinTrain${i}.scale.grid.txt | awk {'print $1'})
G=$(tail -1 ${WD}/dataBinTrain${i}.scale.grid.txt | awk {'print $2'})

echo "C: ${C}\t Gamma: ${G}\n" >> ${WD}/Optimal_C_Gamma_bin${i}.txt

matlab -nodisplay <<EOF

	%% Load Matlab Path: Matlab 14 and SPM12 needed
	cd ${HOME}
	p = pathdef14_SPM12;
	addpath(p);
	
	%% Launch SVM train & predict
	SVM_train_predict('${WD}','${trainFile}',C,G,'${testFile}',i);
EOF