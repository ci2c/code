import nibabel as nib
import os, sys, re
import numpy as np

Path_FS=sys.argv[1]
for str_item in 'lr':
    labVB,scalarVB = nib.freesurfer.io.read_label(Path_FS+"/label/"+str_item+"h.cortex.label",True)
    curv=nib.freesurfer.io.read_morph_data(Path_FS+"/surf/"+str_item+"h.curv")
    area=nib.freesurfer.io.read_morph_data(Path_FS+"/surf/"+str_item+"h.area")
    medial_all_set = set(range(np.max(labVB)+1)) - set(labVB.tolist())
    for item in medial_all_set:
        curv[item]=0
        area[item]=0
    nib.freesurfer.io.write_morph_data(Path_FS+"/surf/"+str_item+"h.curv",curv)
    nib.freesurfer.io.write_morph_data(Path_FS+"/surf/"+str_item+"h.area",area)
