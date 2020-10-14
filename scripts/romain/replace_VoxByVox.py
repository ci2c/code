#Fonction permettant de remplacer les voxels du volume in (premier argument) par les voxels > 0 du volume out (deuxième argument) 
#le troisième argument est le volume de sortie.

import nibabel as nib
import os, sys, re
import numpy as np
from dipy.io.image import load_nifti, save_nifti
import matplotlib.pyplot as plt

data1, affine1 = load_nifti(sys.argv[1])
data2, affine2 = load_nifti(sys.argv[2])
data3=data1

data3[data2.nonzero()]=data2[data2.nonzero()]

save_nifti(sys.argv[3],data3,affine1)
