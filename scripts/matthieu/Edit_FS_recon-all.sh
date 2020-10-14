#!/bin/bash

# InputSubjectsFile=/NAS/tupac/matthieu/PALM_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/V2/subjects_AMN_LANG_VISU_EXE
InputSubjectsFile=/NAS/tupac/matthieu/CAT/subjects
InputDir=/NAS/tupac/matthieu/CAT
# SUBJDIR=/NAS/tupac/matthieu/FS5.3
# SUBJDIR=/NAS/tupac/protocoles/healthy_volunteers/FS53

# Subject 207116: default in skull-stripping
recon-all  -skullstrip  -wsthresh 35  -clean-bm  -no-wsgcaatlas  -s 207116_M0_2014-01-06
recon-all   -s 207116_M0_2014-01-06   -autorecon2   -autorecon3

# Subject 207043: topological defect
recon-all -autorecon2-wm -autorecon3 -subjid 207043_M0_2010-10-07_me