#!/bin/bash

# d'abord convertion en nifti dcm2nii

#Floflo
PATH_FILE="/NAS/dumbo/protocoles/PreClinique/yao_12m/APP_col_Camille_Potey_ED4_12mois__E3_P1_2.16.756.5.5.100.346844782.7674.1469542609.5/"
# ne pas prendre l'extension lors de la copie du nom du fichier 

NAME="20160726_133133TurboRARE3DRes125TR2500WBTacq27minutess196609a001"
EXTENSION=".nii.gz"

SCRIPT_PATH="/home/global/multi-atlas-segmentation-master/for_single_workstation"

#Normalisation/homogeneisation du signal, 
mri_nu_correct.mni --i ${PATH_FILE}${NAME}${EXTENSION} --o ${PATH_FILE}"_N_"${NAME}${EXTENSION}

#Modif orientation -> clinique
mri_convert --sphinx ${PATH_FILE}"_N_"${NAME}${EXTENSION} ${PATH_FILE}"_N_F_"${NAME}${EXTENSION}

cd ${PATH_FILE}

${SCRIPT_PATH}/mask.sh ${PATH_FILE}"_N_F_"${NAME}${EXTENSION} /home/global/multi-atlas-segmentation-master/Templates/in_vivo_MRM_NeAt_Original

#Floflo copier le nom du fichier mask _N_F_ creer lors de la realisation du masque
MASK="_N_F_20160406_090325TurboRARE3DRes125TR2500WBTacq27minutess131073a001_mask_in_vivo_MRM_NeAt_Original_STAPLE_d1.nii.gz"

#visu resultat du masque
freeview ${PATH_FILE}"_N_F_"${NAME}${EXTENSION} ${PATH_FILE}/mask/${MASK}

#Etape de parcelliciation
${SCRIPT_PATH}/parcellation.sh ${PATH_FILE}"_N_F_"${NAME}${EXTENSION} ${PATH_FILE}/mask/${MASK} /home/global/multi-atlas-segmentation-master/Templates/in_vivo_MRM_NeAt_Original

#Floflo copier le nom du fichier creer lors de la parcellation
RESU="_N_F_20160406_090325TurboRARE3DRes125TR2500WBTacq27minutess131073a001_label_A9.nii.gz"

#visu resultat de la parcellation
freeview ${PATH_FILE}"_N_F_"${NAME}${EXTENSION} ${PATH_FILE}/label/in_vivo_MRM_NeAt_Original/${RESU} 

mri_extract_label ${PATH_FILE}/label/in_vivo_MRM_NeAt_Original/${RESU} 1 ${PATH_FILE}/Hippocampe.nii.gz

3dBrickStat -count -non-zero  ${PATH_FILE}/Hippocampe.nii.gz 2>/dev/null

mri_extract_label ${PATH_FILE}/label/in_vivo_MRM_NeAt_Original/${RESU} 14 ${PATH_FILE}/Cortex.nii.gz
3dBrickStat -count -non-zero  ${PATH_FILE}/Cortex.nii.gz 2>/dev/null

freeview ${PATH_FILE}"_N_F_"${NAME}${EXTENSION} ${PATH_FILE}/Cortex.nii.gz ${PATH_FILE}/Hippocampe.nii.gz  
