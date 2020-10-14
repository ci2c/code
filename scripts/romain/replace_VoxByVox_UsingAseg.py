import nibabel as nib
import os, sys, re
import numpy as np
from dipy.io.image import load_nifti, save_nifti
from nipype.utils import NUMPY_MMAP

data1, affine1 = load_nifti(sys.argv[1])
nii = nib.load(sys.argv[2], mmap=NUMPY_MMAP)
#hdr = nii.header
#voxdims = hdr.get_zooms()
#datadims = hdr.get_data_shape()
#print([(datadims[0]), (datadims[1]), (datadims[2])])
#print([float(voxdims[0]), float(voxdims[1]), float(voxdims[2])])

data2 = nii.get_data()
print(data2.dtype)
print(data1.dtype)
print(data2.shape)
print(data1.shape)

data3=data1
for i in [24,28,30,31,60,62,63,72,85,251,252,253,254,255] :
    data3[data2==i]=i

save_nifti(sys.argv[3],data3,affine1)
