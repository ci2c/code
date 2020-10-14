
# coding: utf-8

# In[1]:

import sys
import os
#shogun_path="/usr/local/lib/python2.7/site-packages/"
shogun_path="/home/global/anaconda2/lib/modshogun/"
sys.path.append(shogun_path)
print(sys.path)
from modshogun import *


# In[2]:

get_ipython().magic(u'pylab inline')
get_ipython().magic(u'matplotlib inline')
from scipy.io import loadmat, savemat
from os       import path, sep
import time


# In[3]:

mat  = loadmat('/NAS/dumbo/protocoles/CogPhenoPark/data/cogphenoparkCli3.mat')
mat2  = loadmat('/NAS/dumbo/protocoles/CogPhenoPark/data/cogphenopark_New.mat')
mat3 = loadmat('/NAS/dumbo/protocoles/CogPhenoPark/data/cogphenopark_anova.mat') 

Xall1 = mat['dataCli']
Xall2 = mat2['newData']
#Xall2 = mat3['data']

Yall = array(mat['label'].squeeze(), dtype=double)

print Xall1.shape
print Xall2.shape

Yall = Yall - 1

print Yall


# In[4]:

accuracy = []
prediction = []
accuracy_globale = 0

tic = time.time()

#LOO

for i in range(len(Yall)) :

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
    
# MKL training and output

    feats_train = CombinedFeatures()
    feats_test = CombinedFeatures()
    combined_kernel = CombinedKernel()


##### Pour le premier jeu de features ######    
       
#append gaussian kernel

    subkernel = GaussianKernel(0.1)        
    feats_train.append_feature_obj(feats1)
    feats_test.append_feature_obj(feats_rem1)
    combined_kernel.append_kernel(subkernel)

#append gaussian kernel

    subkernel = GaussianKernel(0.5)        
    feats_train.append_feature_obj(feats1)
    feats_test.append_feature_obj(feats_rem1)
    combined_kernel.append_kernel(subkernel)
    
#append gaussian kernel

    subkernel = GaussianKernel(1)        
    feats_train.append_feature_obj(feats1)
    feats_test.append_feature_obj(feats_rem1)
    combined_kernel.append_kernel(subkernel)

#append PolyKernel

    #subkernel = PolyKernel(10,3)            
    #feats_train.append_feature_obj(feats1)
    #feats_test.append_feature_obj(feats_rem1)
    #combined_kernel.append_kernel(subkernel)
    
#append Linear Kernel

    #subkernel = LinearKernel()            
    #feats_train.append_feature_obj(feats1)
    #feats_test.append_feature_obj(feats_rem1)
    #combined_kernel.append_kernel(subkernel)


##### Pour le deuxième jeu de features ######    
    
#append gaussian kernel

    #subkernel = GaussianKernel(0.5)        
    #feats_train.append_feature_obj(feats2)
    #feats_test.append_feature_obj(feats_rem2)
    #combined_kernel.append_kernel(subkernel) 
    
#append gaussian kernel

    #subkernel = GaussianKernel(1)        
    #feats_train.append_feature_obj(feats2)
    #feats_test.append_feature_obj(feats_rem2)
    #combined_kernel.append_kernel(subkernel)
    
#append gaussian kernel

    #subkernel = GaussianKernel(2)        
    #feats_train.append_feature_obj(feats2)
    #feats_test.append_feature_obj(feats_rem2)
    #combined_kernel.append_kernel(subkernel)
    
#append PolyKernel

    #subkernel = PolyKernel(10,3)            
    #feats_train.append_feature_obj(feats1)
    #feats_test.append_feature_obj(feats_rem1)
    #combined_kernel.append_kernel(subkernel)
    
#append Linear Kernel

    #subkernel = LinearKernel()            
    #feats_train.append_feature_obj(feats2)
    #feats_test.append_feature_obj(feats_rem2)
    #combined_kernel.append_kernel(subkernel)


    combined_kernel.init(feats_train, feats_train)
    #mkl = MKLMulticlass(1.2, combined_kernel, labels)
    mkl = MKLMulticlass(1.2, combined_kernel, labels)

    mkl.set_epsilon(1e-2)
    mkl.set_mkl_epsilon(0.001)
    mkl.set_mkl_norm(1)

    #Pour la classification binaire
    
    #mkl = MKLClassification()
    #mkl.set_C(1, 1)
    #mkl.set_kernel(kernel)
    #mkl.set_labels(labels)
    
    mkl.train()

#MKL Test
    
    combined_kernel.init(feats_train, feats_test)     

    out =  mkl.apply()
    evaluator = MulticlassAccuracy()

    acc = evaluator.evaluate(out, labels_rem)
    accuracy.append(acc)
    accuracy_globale = accuracy_globale + acc
    
    w = combined_kernel.get_subkernel_weights()
    
    prediction.append(out.get_labels().tolist())
    #z = out.get_values()
    
    print w
    
print "Accuracy globale = %2.2f%%" % (100*accuracy_globale/len(Yall))

toc = time.time()


# In[5]:

accuracy_0 = 0
accuracy_1 = 0
accuracy_2 = 0
accuracy_3 = 0
accuracy_4 = 0

print "Accuracy par classe :"

for j in range (41) :
    accuracy_0 = accuracy_0 + accuracy[j]

print "Classe 0 = %2.2f%%" % (100*accuracy_0/41)

for k in range (41, 47) :
    accuracy_1 = accuracy_1 + accuracy[k]

print "Classe 1 = %2.2f%%" % (100*accuracy_1/6)

for l in range (47, 76) :
    accuracy_2 = accuracy_2 + accuracy[l]

print "Classe 2 = %2.2f%%" % (100*accuracy_2/29)

for m in range (76,106) :
    accuracy_3 = accuracy_3 + accuracy[m]

print "Classe 3 = %2.2f%%" % (100*accuracy_3/30)

for n in range (106,112) :
    accuracy_4 = accuracy_4 + accuracy[n]

print "Classe 4 = %2.2f%%" % (100*accuracy_4/6)


# In[6]:

print prediction


# In[7]:

print "Temps écoulé = " 
print toc-tic

