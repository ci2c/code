################
#Prép données conversion etc..
################
FIX_PATH_FILE="/NAS/dumbo/romain/PreClinque/wholeBrain_exvivo/"
VAR_PATH_FILE="s468/"
PATH_FILE="${FIX_PATH_FILE}${VAR_PATH_FILE}"
dcm2nii ${PATH_FILE}

FIX_PATH_FILE="/home/romain/Downloads/ct-SOURIS-DCM/1.2.826.0.1.3417726.3.1031400464/"
VAR_PATH_FILE="1.2.826.0.1.3417726.3.247050.20130906141859515/"
PATH_FILE="${FIX_PATH_FILE}${VAR_PATH_FILE}"
dcm2nii ${PATH_FILE}


#copy et renomage des fichiers

#reorientation des images 
#attention vérifier droite/gauche

#NAME="DTI/dti"
#EXTENSION=".nii.gz"
#cp ${PATH_FILE}${NAME}${EXTENSION} ${PATH_FILE}${NAME}"_F_"${EXTENSION}
#fslorient -deleteorient ${PATH_FILE}${NAME}"_F_"${EXTENSION} 
#fslswapdim ${PATH_FILE}${NAME}"_F_"${EXTENSION} x z y ${PATH_FILE}${NAME}"_F_"${EXTENSION}
#fslorient -setqformcode 1 ${PATH_FILE}${NAME}"_F_"${EXTENSION}

NAME="20130906_120152s000a000"
NAME="3DT2/3DT2"
EXTENSION=".nii.gz"

cp ${PATH_FILE}${NAME}${EXTENSION} ${PATH_FILE}${NAME}"_F_"${EXTENSION}
fslorient -deleteorient ${PATH_FILE}${NAME}"_F_"${EXTENSION} 
fslswapdim ${PATH_FILE}${NAME}"_F_"${EXTENSION} x z y ${PATH_FILE}${NAME}"_F_"${EXTENSION}
fslorient -setqformcode 1 ${PATH_FILE}${NAME}"_F_"${EXTENSION}
#Pour reorienter utiliser mri_convert --sphinx

#mri_convert --out_orientation RAS ${PATH_FILE}${NAME}"_F_"${EXTENSION} ${PATH_FILE}${NAME}"_F_JD"${EXTENSION}
#fslorient -forceradiological ${PATH_FILE}${NAME}"_F_JD"${EXTENSION}

freeview ${PATH_FILE}"3DT2/3DT2.nii.gz" ${PATH_FILE}"3DT2/3DT2_F_.nii.gz"

#correction des inhomogeneités
mri_nu_correct.mni --i ${PATH_FILE}${NAME}"_F_"${EXTENSION} --o ${PATH_FILE}${NAME}"_F_NU_"${EXTENSION}

################
#Segmentation T2
################
cd /home/romain/SVN/scripts/romain/multi-atlas-segmentation-master/for_single_workstation
#Premier atlas
#step 1 - brain extraction
./mask.sh ${PATH_FILE}${NAME}"_F_NU_"${EXTENSION} /home/romain/Downloads/Templates/in_vivo_MRM_NeAt_Original
mkdir mask/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}

#Verification visuelle
freeview "${PATH_FILE}${NAME}_F_NU_${EXTENSION}" "mask/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}3DT2_F__mask_in_vivo_MRM_NeAt_Original_STAPLE.nii.gz"

#Deuxième atlas 
#./mask.sh ${PATH_FILE}${NAME}"_P_"${EXTENSION} /home/romain/Downloads/Templates/ambmc

#Verification visuelle
#freeview ${PATH_FILE}${NAME}"_F_"${EXTENSION} ${PATH_FILE}${NAME}"_F_NU_"${EXTENSION} e

#attention remplacer le mask de la ref par celui créé par mask.sh (deux lignes plus haut)
./parcellation.sh ${PATH_FILE}${NAME}"_F_NU_"${EXTENSION} /home/romain/SVN/scripts/romain/multi-atlas-segmentation-master/for_single_workstation/mask/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}3DT2_F__mask_in_vivo_MRM_NeAt_Original_STAPLE.nii.gz /home/romain/Downloads/Templates/in_vivo_MRM_NeAt_Original/

#Visu Resultat
freeview /home/romain/SVN/scripts/romain/multi-atlas-segmentation-master/for_single_workstation/label/in_vivo_MRM_NeAt_Original/"3DT2_F_NU__label_A9.nii.gz" /home/romain/SVN/scripts/romain/multi-atlas-segmentation-master/for_single_workstation/label/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}"3DT2_F_NU__label_A9.nii.gz"  freeview ${PATH_FILE}${NAME}"_F_NU_"${EXTENSION} ${PATH_FILE}${NAME}"_F_"${EXTENSION} freeview ${PATH_FILE}${NAME}${EXTENSION} /home/romain/SVN/scripts/romain/multi-atlas-segmentation-master/for_single_workstation/mask/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}3DT2_F__mask_in_vivo_MRM_NeAt_Original_STAPLE.nii.gz

#extraction des ROI labelissés 2 "Corps Calleux"
mri_extract_label label/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}3DT2_F_NU__label_A9.nii.gz 2 label/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}Corpus_Callosum.nii.gz
mri_extract_label label/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}3DT2_F_NU__label_A9.nii.gz 14 label/in_vivo_MRM_NeAt_Original/${VAR_PATH_FILE}Cortex.nii.gz

#reflip de la roi extraite
PATH_FILE2="/home/romain/SVN/scripts/romain/multi-atlas-segmentation-master/for_single_workstation/"
NAME2="ROI_1_1"
EXTENSION2=".nii.gz"

############
#DSI_STUDIO
############

#création du source => *.src.gz
# --b_table=c:\replacement_table.txt
#--bval=bvals --bvec=bvals 
PATH_DTI=/NAS/dumbo/romain/PreClinque/DTI_wholeBrain_exvivo/s468/DTI/pdata/1
dsi_studio --action=src --source=${PATH_DTI}/2dseq --output=${PATH_DTI}/dti.src.gz > ${PATH_DTI}/dsi_studio_src.txt

#Image Reconstruction => *.fib.gz
#Reconstruction Parameters
method=7          # 7 for QSDR
param0="1.25"
voxel_res="1"     # 1mm voxels
thread="16"
dsi_studio --action=rec --thread=${thread} --source=${PATH_DTI}/dti.src.gz --method=${method} --param0=${param0} --param1=${voxel_res} --output_jac=1 --output_map=1 --record_odf=1 --reg_method=2  > ${PATH_DTI}/dsi_studio_rec.txt

#Tractography => *.trk
#interpo_angle
smoothing=0.5
fa_threshold=0.6
step_size=0.085
turning_angle=30
min_length=0.2
max_length=4
dsi_studio --action=trk --source=${PATH_DTI}/dti.src.gz.odf8.f5rec.bal.reg2i2.qsdr.1.25.1mm.jac.map.R57.fib.gz --seed_count=10000 --turning_angle=${turning_angle} --step_size=${step_size} --smoothing=${smoothing} --min_length=${min_length} --max_length=${max_length} --thread_count=8 --export=stat,tdi,tdi2,qa,gfa --output=${PATH_DTI}/track.trk > ${PATH_DTI}/dsi_studio_trk.txt

#dsi_studio --action=trk --source=my.fib.gz --roi=aal:Precentral_L --roi2=aal:Precentral_R --fiber_count=1000 --thread_count=10

#ATLAS
#  dsi_studio --action=atl-

#Analyse
#  dsi_studio --action=ana --source=my.fib.gz --tract=Tracts2.trk --end=multiple_roi.nii --export=connectivity

#Export
# dsi_studio --action=exp 

