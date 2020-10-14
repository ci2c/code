import nibabel as nib
import os, sys, re
import numpy as np
from dipy.io.image import load_nifti, save_nifti
import matplotlib.pyplot as plt

#MASK="/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/true_clot/trueclot_12062018/clotmask_bin.nii"
#QSM="/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/true_clot/trueclot_12062018/clotmask_QSM.nii"
#R2="/NAS/tupac/protocoles/3DMULTIGRE_greg/martin/repertoiretravailQSM/true_clot/trueclot_12062018/clotmask_r2medfilt.nii"

R2_nii, affine1 = load_nifti(sys.argv[3])
QSM_nii, affine1 = load_nifti(sys.argv[2])
MASK_nii, affine1 = load_nifti(sys.argv[1])

R2_value = []
QSM_value =[]
for i in range(128) :
    for j in range(128) :
        for z in range(128) :
            if MASK_nii[i,j,z]>0 :
                R2_value.append(R2_nii[i,j,z])
                QSM_value.append(QSM_nii[i,j,z])
                
print(R2_value)
print(QSM_value)
            
plt.plot(QSM_value,R2_value,'b.')
plt.show()
