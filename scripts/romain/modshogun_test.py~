import sys
import os
from modshogun import *
from scipy.io import loadmat, savemat
from os       import path, sep
import time
import pylab
import matplotlib
import numpy as np

mat  = loadmat('/NAS/dumbo/protocoles/CogPhenoPark/data/cogphenoparkCli3.mat')
mat2  = loadmat('/NAS/dumbo/protocoles/CogPhenoPark/data/cogphenopark_New.mat')
mat3 = loadmat('/NAS/dumbo/protocoles/CogPhenoPark/data/cogphenopark_anova.mat') 
Xall1 = mat['dataCli']
Xall2 = mat2['newData']
Yall = np.array(mat['label'].squeeze(),dtype='double')#
print Xall1.shape
print Xall2.shape
Yall = Yall - 1
print Yall
i = 40 
ind = range (len(Yall))
del ind[i]
Xtrain1 = Xall1[:,ind]
Xtrain2 = Xall2[:,ind]
Ytrain = Yall[ind]
labels = MulticlassLabels(Ytrain)

feats1  = RealFeatures(Xtrain1)
feats2  = RealFeatures(Xtrain2)

Xrem1 = Xall1[:, i:i+1]
Xrem2 = Xall2[:, i:i+1]

Yrem = Yall[i:i+1]

labels_rem = MulticlassLabels(Yrem)

feats_rem1 = RealFeatures(Xrem1)
feats_rem2 = RealFeatures(Xrem2)

feats_train = CombinedFeatures()
feats_test = CombinedFeatures()
combined_kernel = CombinedKernel()


subkernel = GaussianKernel(0.1)        
feats_train.append_feature_obj(feats1)
feats_test.append_feature_obj(feats_rem1)
combined_kernel.append_kernel(subkernel)

#append PolyKernel

subkernel = PolyKernel(5,3)            
feats_train.append_feature_obj(feats1)
feats_test.append_feature_obj(feats_rem1)
combined_kernel.append_kernel(subkernel)
    
#append Linear Kernel

subkernel = LinearKernel()            
feats_train.append_feature_obj(feats1)
feats_test.append_feature_obj(feats_rem1)
combined_kernel.append_kernel(subkernel)


combined_kernel.init(feats_train, feats_train)
mkl = MKLMulticlass(1.2, combined_kernel, labels)

mkl.set_mkl_norm(1)    
mkl.train()


combined_kernel.init(feats_train, feats_test)     

out =  mkl.apply()
evaluator = MulticlassAccuracy()

acc = evaluator.evaluate(out, labels_rem)
    
w = combined_kernel.get_subkernel_weights()
    
print w
    
print "Accuracy globale = %2.2f%%" % (100*acc)
