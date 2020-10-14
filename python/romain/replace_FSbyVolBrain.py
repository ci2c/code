import nibabel as nib
import os, sys, re
import numpy as np
from dipy.io.image import load_nifti, save_nifti
from nipype.utils import NUMPY_MMAP

Path_VolBrain=sys.argv[1]
Path_FS=sys.argv[2]

#for
crisp=sys.argv[3]#Path_VolBrain+"native_crisp_mmni_fjob87232_conf_1mm.nii.gz"
hemi=sys.argv[4]#Path_VolBrain+"native_hemi_n_mmni_fjob87232_conf_1mm.nii.gz"
lab=sys.argv[5]#Path_VolBrain+"native_lab_n_mmni_fjob87232_conf_1mm.nii.gz"

if os.path.isfile(Path_FS+"aseg.mgz") :
	aseg=Path_FS+"aseg.mgz"
else :
	aseg=Path_FS+"aseg.auto.mgz"

wm=Path_FS+"wm.mgz"

if os.path.isfile(Path_FS+"ribbon.mgz") :
	ribbon=Path_FS+"ribbon.mgz"
else :
	ribbon=Path_FS+"aseg.auto.mgz"

crisp_nii, affine1 = load_nifti(crisp)
hemi_nii, affine1 = load_nifti(hemi)
lab_nii, affine1 = load_nifti(lab)

aseg_mgz = nib.load(aseg, mmap=NUMPY_MMAP)
old_aseg_mgz = aseg_mgz.get_data()
wm_mgz = nib.load(wm, mmap=NUMPY_MMAP)
old_wm_mgz = wm_mgz.get_data()
ribbon_mgz = nib.load(ribbon, mmap=NUMPY_MMAP)
old_ribbon_mgz = ribbon_mgz.get_data()

new_ribbon_nii = np.zeros_like(old_ribbon_mgz)
new_aseg_nii = np.zeros_like(old_aseg_mgz)
new_wm_nii = np.zeros_like(old_wm_mgz)

#
#Pour RIBBON
#
new_ribbon_nii[np.logical_and(hemi_nii==1,crisp_nii==3)]=2
new_ribbon_nii[np.logical_and(hemi_nii==2,crisp_nii==3)]=41

new_ribbon_nii[np.logical_and(hemi_nii==1,crisp_nii==2)]=3
new_ribbon_nii[np.logical_and(hemi_nii==2,crisp_nii==2)]=42

for i in [1,7,3,5,9,15] :
    new_ribbon_nii[lab_nii==i]=2

for i in [2,8,4,6,10,12,14,16] :
    new_ribbon_nii[lab_nii==i]=41

for i in [11,13] :
    new_ribbon_nii[lab_nii==i]=3

for i in [12,14] :
    new_ribbon_nii[lab_nii==i]=42

save_nifti(Path_VolBrain+"new_ribbon.nii.gz",new_ribbon_nii,affine1)
#
#Pour ASEG
#
new_aseg_nii[np.logical_and(hemi_nii==1,crisp_nii==3)]=2
new_aseg_nii[np.logical_and(hemi_nii==2,crisp_nii==3)]=41

new_aseg_nii[np.logical_and(hemi_nii==1,crisp_nii==2)]=3
new_aseg_nii[np.logical_and(hemi_nii==2,crisp_nii==2)]=42

#label non segmente par Volbrain donc pris dans Freesurfer
for i in [14,15,24,28,30,31,60,62,63,72,85,251,252,253,254,255] :
    new_aseg_nii[old_aseg_mgz==i]=i

new_aseg_nii[np.logical_and(hemi_nii==5,crisp_nii==3)]=16

#Ventricule
#new_aseg_nii[crisp_nii==1]=15 # 4th ventricule attention au 3th ventricule, pris dans l'ancien aseg
new_aseg_nii[np.logical_and(crisp_nii==1,lab_nii==1)]=4 #  left lateral Ventricule & 5 Left Inf Lat Vent
new_aseg_nii[np.logical_and(crisp_nii==1,lab_nii==2)]=43 # Right lateral Ventricule Right  & 44 Inf Lat Vent

#LEFT
new_aseg_nii[np.logical_and(hemi_nii==3,crisp_nii==3)]=7
new_aseg_nii[np.logical_and(hemi_nii==3,crisp_nii==2)]=8
new_aseg_nii[lab_nii==7]=10
new_aseg_nii[lab_nii==3]=11
new_aseg_nii[lab_nii==5]=12
new_aseg_nii[lab_nii==9]=13
new_aseg_nii[lab_nii==11]=17
new_aseg_nii[lab_nii==13]=18
new_aseg_nii[lab_nii==15]=26

#RIGHT
new_aseg_nii[np.logical_and(hemi_nii==4,crisp_nii==3)]=46
new_aseg_nii[np.logical_and(hemi_nii==4,crisp_nii==2)]=47
new_aseg_nii[lab_nii==8]=49
new_aseg_nii[lab_nii==4]=50
new_aseg_nii[lab_nii==6]=51
new_aseg_nii[lab_nii==10]=52
new_aseg_nii[lab_nii==12]=53
new_aseg_nii[lab_nii==14]=54
new_aseg_nii[lab_nii==16]=58

save_nifti(Path_VolBrain+"new_aseg.nii.gz",new_aseg_nii,affine1)
#
#Pour WM
#
new_wm_nii[np.logical_and(hemi_nii==1,crisp_nii==3)]=110
new_wm_nii[np.logical_and(hemi_nii==2,crisp_nii==3)]=110
new_wm_nii[np.logical_and(hemi_nii==5,crisp_nii==3)]=110
new_wm_nii[np.logical_and(crisp_nii==1,lab_nii==1)]=250
new_wm_nii[np.logical_and(crisp_nii==1,lab_nii==2)]=250

for i in [28,60,85,251,252,253,254,255] :
    new_wm_nii[old_aseg_mgz==i]=110

for i in [7,9,8,10,5,6] :
    new_wm_nii[lab_nii==i]=110

for i in [15,16,3,4] :
    new_wm_nii[lab_nii==i]=250

for i in [48,80] :
    new_wm_nii[old_aseg_mgz==i]=250

save_nifti(Path_VolBrain+"new_wm.nii.gz",new_wm_nii,affine1)
