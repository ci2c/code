#!/bin/bash

## Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

## Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

SUBJECTS_DIR=$1
# subject=$2

# FILE_PATH=/home/fatmike/sebastien/ASL_TEP
# SUBJECTS_DIR=/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3
# subject=Aboudou_Salim
# asl_l=${SUBJECTS_DIR}/${subject}/asl/lh.fsaverage.asl.mgh
# asl_r=${SUBJECTS_DIR}/${subject}/asl/rh.fsaverage.asl.mgh

# gunzip ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/fwhm3.MNI305.cbf_sz.nii.gz
# gunzip ${SUBJECTS_DIR}/${subject}/surf/fwhm10.MNI305.thickness.nii.gz

# # while read subject  
# # do 
# for map in perfusion cbf cbf_pvc perfusion_brain cbf_s
# do
# 	nb_mgh_l=$(ls ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/lh.*fsaverage.${map}.mgh | wc -l)
# 	nb_mgh_r=$(ls ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/rh.*fsaverage.${map}.mgh | wc -l)
# 	
# 	if [ ${nb_mgh_l} -eq ${nb_mgh_r} ]
# 	then
# 		for fich_l in $(ls ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/lh.*fsaverage.${map}.mgh)
# 		do
# 			DIR=`dirname ${fich_l}`
# 			base=`basename ${fich_l}`
# 			base=${base%.fsaverage.${map}.mgh}
# 			
# 			if [ "${base}" == "lh" ]
# 			then
# 				mri_surf2vol --surfval ${fich_l} --fillribbon --identity fsaverage --template ${SUBJECTS_DIR}/fsaverage/mri/T1.mgz --hemi lh --o ${DIR}/lh.MNI305.${map}.nii.gz 
# 			else
# 				FWHM=${base#lh.fwhm}
# 				mri_surf2vol --surfval ${fich_l} --fillribbon --identity fsaverage --template ${SUBJECTS_DIR}/fsaverage/mri/T1.mgz --hemi lh --o ${DIR}/lh.fwhm${FWHM}.MNI305.${map}.nii.gz
# 			fi
# 		
# 		done
# 		
# 		for fich_r in $(ls ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/rh.*fsaverage.${map}.mgh)
# 		do
# 			DIR=`dirname ${fich_r}`
# 			base=`basename ${fich_r}`
# 			base=${base%.fsaverage.${map}.mgh}
# 			
# 			if [ "${base}" == "rh" ]
# 			then
# 				mri_surf2vol --surfval ${fich_r} --fillribbon --identity fsaverage --merge ${DIR}/lh.MNI305.${map}.nii.gz --hemi rh --o ${DIR}/MNI305.${map}.nii.gz
# # 				mri_vol2vol --inv --targ ${SUBJECTS_DIR}/${subject}/asl/MNI305.${map}.nii.gz --mov ${FSL_DIR}/data/standard/MNI152_T1_2mm.nii.gz --o ${SUBJECTS_DIR}/${subject}/asl/MNI152.${map}.nii.gz --interp nearest --reg ${FREESURFER_HOME}/average/mni152.register.dat
# 			else
# 				FWHM=${base#rh.fwhm}
# 				mri_surf2vol --surfval ${fich_r} --fillribbon --identity fsaverage --merge ${DIR}/lh.fwhm${FWHM}.MNI305.${map}.nii.gz --hemi rh --o ${DIR}/fwhm${FWHM}.MNI305.${map}.nii.gz
# # 				mri_vol2vol --inv --targ ${SUBJECTS_DIR}/${subject}/asl/fwhm${FWHM}.MNI305.${map}.nii.gz --mov ${FSL_DIR}/data/standard/MNI152_T1_2mm.nii.gz --o ${SUBJECTS_DIR}/${subject}/asl/fwhm${FWHM}.MNI152.${map}.nii.gz --interp nearest --reg ${FREESURFER_HOME}/average/mni152.register.dat
# 			fi	
# 		done
# 	else
# 		echo "Mismatch between number of left and right hemisphere ${map} .mgh files"
# 	fi
# 	
# 	nb_zscore_l=$(ls ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/lh.*fsaverage.${map}.zscore | wc -l)
# 	nb_zscore_r=$(ls ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/rh.*fsaverage.${map}.zscore | wc -l)
# 	
# 	if [ ${nb_zscore_l} -eq ${nb_zscore_r} ]
# 	then
# 		for fichz_l in $(ls ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/lh.*fsaverage.${map}.zscore)
# 		do
# 			DIR=`dirname ${fichz_l}`
# 			base=`basename ${fichz_l}`
# 			base=${base%.fsaverage.${map}.zscore}
# 			
# 			if [ "${base}" == "lh" ]
# 			then
# 				mri_surf2vol --surfval ${fichz_l} --fillribbon --identity fsaverage --template ${SUBJECTS_DIR}/fsaverage/mri/T1.mgz --hemi lh --o ${DIR}/lh.MNI305.${map}z.nii.gz 
# 			else
# 				FWHM=${base#lh.fwhm}
# 				mri_surf2vol --surfval ${fichz_l} --fillribbon --identity fsaverage --template ${SUBJECTS_DIR}/fsaverage/mri/T1.mgz --hemi lh --o ${DIR}/lh.fwhm${FWHM}.MNI305.${map}z.nii.gz
# 			fi
# 		
# 		done
# 		
# 		for fichz_r in $(ls ${SUBJECTS_DIR}/${subject}/asl/Surface_Analyses/rh.*fsaverage.${map}.zscore)
# 		do
# 			DIR=`dirname ${fichz_r}`
# 			base=`basename ${fichz_r}`
# 			base=${base%.fsaverage.${map}.zscore}
# 			
# 			if [ "${base}" == "rh" ]
# 			then
# 				mri_surf2vol --surfval ${fichz_r} --fillribbon --identity fsaverage --merge ${DIR}/lh.MNI305.${map}z.nii.gz --hemi rh --o ${DIR}/MNI305.${map}z.nii.gz
# # 				mri_vol2vol --inv --targ ${SUBJECTS_DIR}/${subject}/asl/MNI305.${map}z.nii.gz --mov ${FSL_DIR}/data/standard/MNI152_T1_2mm.nii.gz --o ${SUBJECTS_DIR}/${subject}/asl/MNI152.${map}z.nii.gz --interp nearest --reg ${FREESURFER_HOME}/average/mni152.register.dat
# 			else
# 				FWHM=${base#rh.fwhm}
# 				mri_surf2vol --surfval ${fichz_r} --fillribbon --identity fsaverage --merge ${DIR}/lh.fwhm${FWHM}.MNI305.${map}z.nii.gz --hemi rh --o ${DIR}/fwhm${FWHM}.MNI305.${map}z.nii.gz
# # 				mri_vol2vol --inv --targ ${SUBJECTS_DIR}/${subject}/asl/fwhm${FWHM}.MNI305.${map}z.nii.gz --mov ${FSL_DIR}/data/standard/MNI152_T1_2mm.nii.gz --o ${SUBJECTS_DIR}/${subject}/asl/fwhm${FWHM}.MNI152.${map}z.nii.gz --interp nearest --reg ${FREESURFER_HOME}/average/mni152.register.dat
# 			fi	
# 		done
# 	else
# 		echo "Mismatch between number of left and right hemisphere ${map} .zscore files"
# 	fi
# done
# 
# 	nb_mgh_l=$(ls ${SUBJECTS_DIR}/${subject}/surf/lh.thickness.*fsaverage.mgh | wc -l)
# 	nb_mgh_r=$(ls ${SUBJECTS_DIR}/${subject}/surf/rh.thickness.*fsaverage.mgh | wc -l)
# 	
# 	if [ ${nb_mgh_l} -eq ${nb_mgh_r} ]
# 	then
# 		for fich_l in $(ls ${SUBJECTS_DIR}/${subject}/surf/lh.thickness.*fsaverage.mgh)
# 		do
# 			DIR=`dirname ${fich_l}`
# 			base=`basename ${fich_l}`
# 			base=${base%.fsaverage.mgh}
# 			
# 			if [ "${base}" == "lh.thickness" ]
# 			then
# 				mri_surf2vol --surfval ${fich_l} --fillribbon --identity fsaverage --template ${SUBJECTS_DIR}/fsaverage/mri/T1.mgz --hemi lh --o ${DIR}/lh.MNI305.thickness.nii.gz 
# 			else
# 				FWHM=${base#lh.thickness.fwhm}
# 				mri_surf2vol --surfval ${fich_l} --fillribbon --identity fsaverage --template ${SUBJECTS_DIR}/fsaverage/mri/T1.mgz --hemi lh --o ${DIR}/lh.fwhm${FWHM}.MNI305.thickness.nii.gz
# 			fi
# 		
# 		done
# 		
# 		for fich_r in $(ls ${SUBJECTS_DIR}/${subject}/surf/rh.thickness.*fsaverage.mgh)
# 		do
# 			DIR=`dirname ${fich_r}`
# 			base=`basename ${fich_r}`
# 			base=${base%.fsaverage.mgh}
# 			
# 			if [ "${base}" == "rh.thickness" ]
# 			then
# 				mri_surf2vol --surfval ${fich_r} --fillribbon --identity fsaverage --merge ${DIR}/lh.MNI305.thickness.nii.gz --hemi rh --o ${DIR}/MNI305.thickness.nii.gz
# # 				mri_vol2vol --inv --targ ${SUBJECTS_DIR}/${subject}/MNI305.thickness.nii.gz --mov ${FSL_DIR}/data/standard/MNI152_T1_2mm.nii.gz --o ${SUBJECTS_DIR}/${subject}/MNI152.thickness.nii.gz --interp nearest --reg ${FREESURFER_HOME}/average/mni152.register.dat
# 			else
# 				FWHM=${base#rh.thickness.fwhm}
# 				mri_surf2vol --surfval ${fich_r} --fillribbon --identity fsaverage --merge ${DIR}/lh.fwhm${FWHM}.MNI305.thickness.nii.gz --hemi rh --o ${DIR}/fwhm${FWHM}.MNI305.thickness.nii.gz
# # 				mri_vol2vol --inv --targ ${SUBJECTS_DIR}/${subject}/fwhm${FWHM}.MNI305.thickness.nii.gz --mov ${FSL_DIR}/data/standard/MNI152_T1_2mm.nii.gz --o ${SUBJECTS_DIR}/${subject}/fwhm${FWHM}.MNI152.thickness.nii.gz --interp nearest --reg ${FREESURFER_HOME}/average/mni152.register.dat
# 			fi	
# 		done
# 	else
# 		echo "Mismatch between number of left and right hemisphere thickness .mgh files"
# 	fi
# 	
# 	nb_zscore_l=$(ls ${SUBJECTS_DIR}/${subject}/surf/lh.thickness.*fsaverage.zscore | wc -l)
# 	nb_zscore_r=$(ls ${SUBJECTS_DIR}/${subject}/surf/rh.thickness.*fsaverage.zscore | wc -l)
# 	
# 	if [ ${nb_zscore_l} -eq ${nb_zscore_r} ]
# 	then
# 		for fichz_l in $(ls ${SUBJECTS_DIR}/${subject}/surf/lh.thickness.*fsaverage.zscore)
# 		do
# 			DIR=`dirname ${fichz_l}`
# 			base=`basename ${fichz_l}`
# 			base=${base%.fsaverage.zscore}
# 			
# 			if [ "${base}" == "lh.thickness" ]
# 			then
# 				mri_surf2vol --surfval ${fichz_l} --fillribbon --identity fsaverage --template ${SUBJECTS_DIR}/fsaverage/mri/T1.mgz --hemi lh --o ${DIR}/lh.MNI305.thicknessz.nii.gz 
# 			else
# 				FWHM=${base#lh.thickness.fwhm}
# 				mri_surf2vol --surfval ${fichz_l} --fillribbon --identity fsaverage --template ${SUBJECTS_DIR}/fsaverage/mri/T1.mgz --hemi lh --o ${DIR}/lh.fwhm${FWHM}.MNI305.thicknessz.nii.gz
# 			fi
# 		
# 		done
# 		
# 		for fichz_r in $(ls ${SUBJECTS_DIR}/${subject}/surf/rh.thickness.*fsaverage.zscore)
# 		do
# 			DIR=`dirname ${fichz_r}`
# 			base=`basename ${fichz_r}`
# 			base=${base%.fsaverage.zscore}
# 			
# 			if [ "${base}" == "rh.thickness" ]
# 			then
# 				mri_surf2vol --surfval ${fichz_r} --fillribbon --identity fsaverage --merge ${DIR}/lh.MNI305.thicknessz.nii.gz --hemi rh --o ${DIR}/MNI305.thicknessz.nii.gz
# # 				mri_vol2vol --inv --targ ${SUBJECTS_DIR}/${subject}/MNI305.thicknessz.nii.gz --mov ${FSL_DIR}/data/standard/MNI152_T1_2mm.nii.gz --o ${SUBJECTS_DIR}/${subject}/MNI152.thicknessz.nii.gz --interp nearest --reg ${FREESURFER_HOME}/average/mni152.register.dat
# 			else
# 				FWHM=${base#rh.thickness.fwhm}
# 				mri_surf2vol --surfval ${fichz_r} --fillribbon --identity fsaverage --merge ${DIR}/lh.fwhm${FWHM}.MNI305.thicknessz.nii.gz --hemi rh --o ${DIR}/fwhm${FWHM}.MNI305.thicknessz.nii.gz
# # 				mri_vol2vol --inv --targ ${SUBJECTS_DIR}/${subject}/fwhm${FWHM}.MNI305.thicknessz.nii.gz --mov ${FSL_DIR}/data/standard/MNI152_T1_2mm.nii.gz --o ${SUBJECTS_DIR}/${subject}/fwhm${FWHM}.MNI152.thicknessz.nii.gz --interp nearest --reg ${FREESURFER_HOME}/average/mni152.register.dat
# 			fi	
# 		done
# 	else
# 		echo "Mismatch between number of left and right hemisphere thickness .zscore files"
# 	fi
# # done < ${FILE_PATH}/subjectsList_ASL.txt

## Project Tmaps on fsaverage surface : Tmap1 (CS > LTLE) and Tmap2 (CS > RTLE)
# mri_vol2surf --mov ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/Tmap1.img --regheader fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/lh.Tmap1.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg
# mri_vol2surf --mov ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/Tmap1.img --regheader fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/rh.Tmap1.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg
# 
# mri_vol2surf --mov ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/Tmap2.img --regheader fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/lh.Tmap2.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg
# mri_vol2surf --mov ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/Tmap2.img --regheader fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/rh.Tmap2.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

mri_vol2surf --mov ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/spmT_0001.img --regheader fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/lh.spmT_0001.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg
mri_vol2surf --mov ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/spmT_0001.img --regheader fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/rh.spmT_0001.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

mri_vol2surf --mov ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/spmT_0002.img --regheader fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/lh.spmT_0002.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg
mri_vol2surf --mov ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/spmT_0002.img --regheader fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/BPM_analysis/ANCOVA/rh.spmT_0002.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg
