#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Process_DTI.sh  -fs <FS_dir>  -subj <subj1> <subj2> ... <subjN>"
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj <subj_ID>                    : Subjects ID"
	echo ""
	echo "Usage: Process_DTI.sh  -fs <FS_dir>  -subj <subj1> <subj2> ... <subjN>"
	echo ""
	exit 1
fi


index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Process_DTI.sh  -fs <FS_dir>  -subj <subj1> <subj2> ... <subjN>"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj <subj_ID>                    : Subjects ID"
		echo ""
		echo "Usage: Process_DTI.sh  -fs <FS_dir>  -subj <subj1> <subj2> ... <subjN>"
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "FS_dir : $fs"
		;;
	-subj)
		i=$[$index+1]
		eval infile=\${$i}
		subj=""
		while [ "$infile" != "-fs" -a $i -le $# ]
		do
		 	subj="${subj} ${infile}"
		 	i=$[$i+1]
		 	eval infile=\${$i}
		done
		index=$[$i-1]
		echo "subj : $subj"
		;;
	esac
	index=$[$index+1]
done


for Subject in ${subj}
do	
	DIR=${fs}/${Subject}
	cd ${DIR}/dti
# 	#####################
# 	# Step #0 : Make directory for reprocessing touch
# 	#####################
# 	if [ ! -d ${DIR}/dti/steps ]
# 	then
# 		mkdir ${DIR}/dti/steps
# 	fi
# 	
# 	#####################
# 	# Step #1 : Check volume size
# 	#####################
# 	if [ ! -f ${DIR}/dti/steps/check-data.touch ]
# 	then
# 		N_vol=`fslnvols ${DIR}/dti/orig/dti.nii.gz`
# 		N_dir=`cat ${DIR}/dti/orig/dti.bvec | wc -w`
# 		echo "N_dir = ${N_dir}  ; N_vol = ${N_vol}"
# 		N_vol=`echo "scale=0; ${N_vol} * 3" | bc -l`
# 		# if [ `echo "${N_dir} != 3 * ${N_vol}" | bc -l` ]
# 		if [ ! ${N_vol} -eq ${N_dir} ]
# 		then
# 			echo "Remove last volume"
# 			To_remove=`echo "scale=0; ${N_vol} / 3 - 1" | bc -l`
# 			cp ${DIR}/dti/orig/dti.nii.gz ${DIR}/dti/temp.nii.gz
# 			fslsplit ${DIR}/dti/temp.nii.gz ${DIR}/dti/vol
# 			rm -f ${DIR}/dti/temp.nii.gz ${DIR}/dti/vol00${To_remove}.nii.gz
# 			fslmerge -t ${DIR}/dti/temp ${DIR}/dti/vol00*
# 			rm -f ${DIR}/dti/vol00*
# 		else
# 			echo "Copy 4D volume"
# 			cp ${DIR}/dti/orig/dti.nii.gz ${DIR}/dti/temp.nii.gz
# 		fi
# 		echo "Copy bvec and bval"
# 		cp ${DIR}/dti/orig/dti.bval ${DIR}/dti/data.bval
# 		cp ${DIR}/dti/orig/dti.bvec ${DIR}/dti/data.bvec
# 		touch ${DIR}/dti/steps/check-data.touch
# 	fi
# 	
# 	#####################
# 	# Step #2 : Run eddy correct
# 	#####################
# 	echo "eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data_corr 0"
# 	do_cmd 2 ${DIR}/dti/steps/eddy_correct.touch eddy_correct ${DIR}/dti/temp.nii.gz ${DIR}/dti/data_corr 0
# 	rm -f ${DIR}/dti/temp.nii.gz
# 	
# 	#####################
# 	# Step #3 : Correct bvecs
# 	#####################
# 	echo "rotate_bvecs ${DIR}/dti/data_corr.ecclog ${DIR}/dti/data.bvec"
# 	do_cmd 2 ${DIR}/dti/steps/rotate_bvecs.touch rotate_bvecs data_corr.ecclog data.bvec
# 	
# 	#####################
# 	# Step #4 : Prepare for bedpostx
# 	#####################
# 	echo "bet ${DIR}/dti/data_corr ${DIR}/dti/data_corr_brain -F -f 0.5 -g 0 -m"
# 	do_cmd 2 ${DIR}/dti/steps/BET.touch bet ${DIR}/dti/data_corr ${DIR}/dti/data_corr_brain -F -f 0.5 -g 0 -m
# 	
# 	if [ ! -d ${DIR}/dti/DataBPX ]
# 	then
# 		mkdir ${DIR}/dti/DataBPX
# 	fi
# 	
# 	cp ${DIR}/dti/data_corr.nii.gz ${DIR}/dti/DataBPX/data.nii.gz
# 	cp ${DIR}/dti/data_corr_brain_mask.nii.gz ${DIR}/dti/DataBPX/nodif_brain_mask.nii.gz
# 	cp ${DIR}/dti/data.bval ${DIR}/dti/DataBPX/bvals
# 	cp ${DIR}/dti/data.bvec ${DIR}/dti/DataBPX/bvecs
# 	
# 	#####################
# 	# Step #5 : Run dtifit
# 	#####################
# 	echo "dtifit --data=${DIR}/dti/data_corr.nii.gz --out=${DIR}/dti/data_corr --mask=${DIR}/dti/data_corr_brain_mask.nii.gz --bvecs=${DIR}/dti/data.bvec --bvals=${DIR}/dti/data.bval"
# 	do_cmd 2 ${DIR}/dti/steps/dtifit.touch dtifit --data=${DIR}/dti/data_corr.nii.gz --out=${DIR}/dti/data_corr --mask=${DIR}/dti/data_corr_brain_mask.nii.gz --bvecs=${DIR}/dti/data.bvec --bvals=${DIR}/dti/data.bval
# 	
# 	#####################
# 	# Step #6 : Run bedpostx
# 	#####################
# 	echo "bedpostx ${DIR}/dti/DataBPX -n 2 -w 1  -b 1000"
# 	do_cmd 2 ${DIR}/dti/steps/bedpostx.touch bedpostx ${DIR}/dti/DataBPX -n 2 -w 1  -b 1000
# 	
# 	#####################
# 	# Step #7 : Coregister T1 to DTI
# 	#####################
# 	if [ ! -d ${DIR}/dti/ROI ]
# 	then
# 		mkdir ${DIR}/dti/ROI
# 	fi
# 	
# 	echo "mgz2FSLnii.sh ${DIR}/mri/T1.mgz ${DIR}/dti/data_corr.nii.gz ${DIR}/dti/ROI/FS_to_DTI.nii ${DIR}/dti/ROI/transform_FS_to_DTI.mat"
# 	do_cmd 2 ${DIR}/dti/steps/coregister_FS_to_DTI.touch mgz2FSLnii.sh ${DIR}/mri/T1.mgz ${DIR}/dti/data_corr.nii.gz ${DIR}/dti/ROI/FS_to_DTI.nii ${DIR}/dti/ROI/transform_FS_to_DTI.mat
	
	#####################
	# Step #8 : Align FS labels to DTI
	#####################
	if [ -n "`ls ${DIR}/dti/ROI/ | grep .txt`" ]
	then
		if [ -f ${DIR}/dti/ROI/dti_b0.nii.gz ]
		then
			gunzip -f ${DIR}/dti/ROI/dti_b0.nii.gz
		fi
		
		for Label in `ls ${DIR}/dti/ROI/*.txt`
		do
			label=`basename ${Label}`
			echo "Labels_to_dti.sh ${Label} ${DIR}/dti/ROI/dti_b0.nii ${DIR}/dti/ROI/transform_FS_to_DTI.mat ${DIR}"
			do_cmd 2 ${DIR}/dti/steps/${label%.txt}_to_dti.touch Labels_to_dti.sh ${Label} ${DIR}/dti/ROI/dti_b0.nii ${DIR}/dti/ROI/transform_FS_to_DTI.mat ${DIR}
		done
	fi
	
# 	#####################
# 	# Step #9 : Align manual T1 labels to DTI
# 	#####################
# 	if [ -n "`ls ${DIR}/dti/ROI/ | grep _t1.`" ]
# 	then
# 	
# 		if [ -f ${DIR}/dti/ROI/dti_b0.nii ]
# 		then
# 			gzip -f ${DIR}/dti/ROI/dti_b0.nii
# 		fi
# 	
# 		echo "flirt -in ${DIR}/dti/orig/t1.nii.gz -ref ${DIR}/dti/ROI/dti_b0.nii.gz -out ${DIR}/dti/ROI/T1_to_DTI.nii -omat ${DIR}/dti/ROI/transform_T1_to_DTI.mat"
# 		do_cmd 2 ${DIR}/dti/steps/coregister_T1_to_DTI.touch flirt -in ${DIR}/dti/orig/t1.nii.gz -ref ${DIR}/dti/ROI/dti_b0.nii.gz -out ${DIR}/dti/ROI/T1_to_DTI.nii -omat ${DIR}/dti/ROI/transform_T1_to_DTI.mat
# 	
# 		for Label in `ls ${DIR}/dti/ROI/*_t1.*`
# 		do	
# 			## Place label in T1 space
# 			if [ -n "`echo ${Label} | grep .gz`" ]
# 			then
# 				gunzip -f ${Label}
# 				Label=${Label%.gz}
# 			fi
# 			
# 			## Binarize Label
# 			fslmaths ${Label} -bin ${Label%.nii}_bin
# 			rm -f ${Label}
# 			mv ${Label%.nii}_bin.nii.gz ${Label}.gz
# 			gunzip ${Label}.gz
# 			
# 			label=`basename ${Label}`
# 			
# 			echo "flirt -in ${Label} -applyxfm -init ${DIR}/dti/ROI/transform_T1_to_DTI.mat -out ${DIR}/dti/ROI/${label%.nii}_dti.nii -paddingsize 0.0 -interp trilinear -ref ${DIR}/dti/ROI/dti_b0.nii.gz"
# 			do_cmd 2 ${DIR}/dti/steps/coregister_${label%.nii}_to_DTI.touch flirt -in ${Label} -applyxfm -init ${DIR}/dti/ROI/transform_T1_to_DTI.mat -out ${DIR}/dti/ROI/${label%.nii}_dti.nii -paddingsize 0.0 -interp trilinear -ref ${DIR}/dti/ROI/dti_b0.nii.gz
# 			
# 			fslmaths ${DIR}/dti/ROI/${label%.nii}_dti.nii -thr 0.5 -bin ${DIR}/dti/ROI/${label%.nii}_dti_bin.nii
# 			mv -f ${DIR}/dti/ROI/${label%.nii}_dti_bin.nii.gz ${DIR}/dti/ROI/${label%.nii}_dti.nii.gz
# 			
# 		done
# 	fi
	
# 	#####################
# 	# Step #10: Performs tracto
# 	#####################
# 	if [ ! -d ${DIR}/dti/Fibers ]
# 	then
# 		mkdir ${DIR}/dti/Fibers
# 	fi
# 	
# 	if [ -f ${DIR}/dti/ROI/putamen_dt_t1_dti.nii.gz ]
# 	then
# 		echo "${DIR}/dti/ROI/Associatif_g_dti.nii.gz" > ${DIR}/dti/ROI/Targets_putamen_dt.lab
# 		echo "${DIR}/dti/ROI/Limbique_g_dti.nii.gz" >> ${DIR}/dti/ROI/Targets_putamen_dt.lab
# 		echo "${DIR}/dti/ROI/Moteur_g_dti.nii.gz" >> ${DIR}/dti/ROI/Targets_putamen_dt.lab
# 		
# 		echo "probtrackx --mode=seedmask -x ${DIR}/dti/ROI/putamen_dt_t1_dti.nii.gz -l -c 0.2 -S 2000 --steplength=0.5 -P 20000 --forcedir --opd -s ${DIR}/dti/DataBPX.bedpostX/merged -m ${DIR}/dti/DataBPX.bedpostX/nodif_brain_mask  --dir=${DIR}/dti/Fibers/putamen_dt_to_areas --targetmasks=${DIR}/dti/ROI/Targets_putamen_dt.txt --os2t"
# 		do_cmd 2 ${DIR}/dti/steps/tracto_putamen_dt_to_areas.touch probtrackx --mode=seedmask -x ${DIR}/dti/ROI/putamen_dt_t1_dti.nii.gz -l -c 0.2 -S 2000 --steplength=0.5 -P 20000 --forcedir --opd -s ${DIR}/dti/DataBPX.bedpostX/merged -m ${DIR}/dti/DataBPX.bedpostX/nodif_brain_mask  --dir=${DIR}/dti/Fibers/putamen_dt_to_areas --targetmasks=${DIR}/dti/ROI/Targets_putamen_dt.lab --os2t
# 		
# 		echo "${DIR}/dti/ROI/Associatif_d_dti.nii.gz" > ${DIR}/dti/ROI/Targets_putamen_g.lab
# 		echo "${DIR}/dti/ROI/Limbique_d_dti.nii.gz" >> ${DIR}/dti/ROI/Targets_putamen_g.lab
# 		echo "${DIR}/dti/ROI/Moteur_d_dti.nii.gz" >> ${DIR}/dti/ROI/Targets_putamen_g.lab
# 		
# 		echo "probtrackx --mode=seedmask -x ${DIR}/dti/ROI/putamen_g_t1_dti.nii.gz -l -c 0.2 -S 2000 --steplength=0.5 -P 20000 --forcedir --opd -s ${DIR}/dti/DataBPX.bedpostX/merged -m ${DIR}/dti/DataBPX.bedpostX/nodif_brain_mask  --dir=${DIR}/dti/Fibers/putamen_g_to_areas --targetmasks=${DIR}/dti/ROI/Targets_putamen_g.txt --os2t"
# 		do_cmd 2 ${DIR}/dti/steps/tracto_putamen_g_to_areas.touch probtrackx --mode=seedmask -x ${DIR}/dti/ROI/putamen_g_t1_dti.nii.gz -l -c 0.2 -S 2000 --steplength=0.5 -P 20000 --forcedir --opd -s ${DIR}/dti/DataBPX.bedpostX/merged -m ${DIR}/dti/DataBPX.bedpostX/nodif_brain_mask  --dir=${DIR}/dti/Fibers/putamen_g_to_areas --targetmasks=${DIR}/dti/ROI/Targets_putamen_g.lab --os2t
# 
# 	fi
# 	
# 	#####################
# 	# Step #11: Find the Biggest + Stats
# 	#####################
# 	if [ -f ${DIR}/dti/ROI/putamen_dt_t1_dti.nii.gz ]
# 	then
# 		echo "find_the_biggest ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Associatif_g_dti.nii.gz ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Limbique_g_dti.nii.gz ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Moteur_g_dti.nii.gz ${DIR}/dti/Fibers/putamen_dt_to_areas/Biggest.nii.gz"
# 		do_cmd 2 ${DIR}/dti/steps/ftb_putamen_dt.touch find_the_biggest ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Associatif_g_dti.nii.gz ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Limbique_g_dti.nii.gz ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Moteur_g_dti.nii.gz ${DIR}/dti/Fibers/putamen_dt_to_areas/Biggest.nii.gz
# 		
# 		echo "find_the_biggest ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Associatif_d_dti.nii.gz ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Limbique_d_dti.nii.gz ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Moteur_dt_dti.nii.gz ${DIR}/dti/Fibers/putamen_g_to_areas/Biggest.nii.gz"
# 		do_cmd 2 ${DIR}/dti/steps/ftb_putamen_g.touch find_the_biggest ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Associatif_d_dti.nii.gz ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Limbique_d_dti.nii.gz ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Moteur_d_dti.nii.gz ${DIR}/dti/Fibers/putamen_g_to_areas/Biggest.nii.gz
# 		
# 		echo "ROI L1_mean L1_std Lr_mean Lr_std MD_mean MD_std FA_mean FA_std Connections_mean Connections_std" > ${DIR}/dti/Fibers/putamen_dt_to_areas/Stats.txt
# 		echo "ROI L1_mean L1_std Lr_mean Lr_std MD_mean MD_std FA_mean FA_std Connections_mean Connections_std" > ${DIR}/dti/Fibers/putamen_g_to_areas/Stats.txt
# 		echo "ROI L1_mean_g L1_std_g Lr_mean_g Lr_std_g MD_mean_g MD_std_g FA_mean_g FA_std_g Connections_mean_g Connections_std_g L1_mean_dt L1_std_dt Lr_mean_dt Lr_std_dt MD_mean_dt MD_std_dt FA_mean_dt FA_std_dt Connections_mean_dt Connections_std_dt ICV" > ${DIR}/dti/Fibers/${Subject}_stats.txt
# 		
# 		echo "fslmaths ${DIR}/dti/data_corr_L2.nii.gz -add ${DIR}/dti/data_corr_L3.nii.gz -div 2 ${DIR}/dti/data_corr_Lrad.nii.gz"
# 		fslmaths ${DIR}/dti/data_corr_L2.nii.gz -add ${DIR}/dti/data_corr_L3.nii.gz -div 2 ${DIR}/dti/data_corr_Lrad.nii.gz
# 		
# 		echo "fslmaths ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Associatif_g_dti.nii.gz -max ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Limbique_g_dti.nii.gz -max ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Moteur_g_dti.nii.gz ${DIR}/dti/Fibers/putamen_dt_to_areas/Max.nii.gz"
# 		fslmaths ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Associatif_g_dti.nii.gz -max ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Limbique_g_dti.nii.gz -max ${DIR}/dti/Fibers/putamen_dt_to_areas/seeds_to_Moteur_g_dti.nii.gz ${DIR}/dti/Fibers/putamen_dt_to_areas/Max.nii.gz
# 		
# 		echo "fslmaths ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Associatif_d_dti.nii.gz -max ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Limbique_d_dti.nii.gz -max ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Moteur_d_dti.nii.gz ${DIR}/dti/Fibers/putamen_g_to_areas/Max.nii.gz"
# 		fslmaths ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Associatif_d_dti.nii.gz -max ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Limbique_d_dti.nii.gz -max ${DIR}/dti/Fibers/putamen_g_to_areas/seeds_to_Moteur_d_dti.nii.gz ${DIR}/dti/Fibers/putamen_g_to_areas/Max.nii.gz
# 		
# 		for i in 1 2 3
# 		do
# 			echo "fslmaths ${DIR}/dti/Fibers/putamen_dt_to_areas/Biggest.nii.gz -thr ${i} -uthr ${i} ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz"
# 			fslmaths ${DIR}/dti/Fibers/putamen_dt_to_areas/Biggest.nii.gz -thr ${i} -uthr ${i} ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_L1.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M"
# 			L1_mean_d=`fslstats ${DIR}/dti/data_corr_L1.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_L1.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S"
# 			L1_std_d=`fslstats ${DIR}/dti/data_corr_L1.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_Lrad.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M"
# 			Lrad_mean_d=`fslstats ${DIR}/dti/data_corr_Lrad.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_Lrad.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S"
# 			Lrad_std_d=`fslstats ${DIR}/dti/data_corr_Lrad.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_MD.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M"
# 			MD_mean_d=`fslstats ${DIR}/dti/data_corr_MD.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_MD.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S"
# 			MD_std_d=`fslstats ${DIR}/dti/data_corr_MD.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_FA.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M"
# 			FA_mean_d=`fslstats ${DIR}/dti/data_corr_FA.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_FA.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S"
# 			FA_std_d=`fslstats ${DIR}/dti/data_corr_FA.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "fslmaths ${DIR}/dti/Fibers/putamen_dt_to_areas/Max.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M"
# 			C_mean_d=`fslstats ${DIR}/dti/Fibers/putamen_dt_to_areas/Max.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/Fibers/putamen_dt_to_areas/Max.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S"
# 			C_std_d=`fslstats ${DIR}/dti/Fibers/putamen_dt_to_areas/Max.nii.gz -k ${DIR}/dti/Fibers/putamen_dt_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "${i} ${L1_mean_d} ${L1_std_d} ${Lrad_mean_d} ${Lrad_std_d} ${MD_mean_d} ${MD_std_d} ${FA_mean_d} ${FA_std_d} ${C_mean_d} ${C_std_d}" >> ${DIR}/dti/Fibers/putamen_dt_to_areas/Stats.txt
# 			
# 			echo "fslmaths ${DIR}/dti/Fibers/putamen_g_to_areas/Biggest.nii.gz -thr ${i} -uthr ${i} ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz"
# 			fslmaths ${DIR}/dti/Fibers/putamen_g_to_areas/Biggest.nii.gz -thr ${i} -uthr ${i} ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_L1.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M"
# 			L1_mean_g=`fslstats ${DIR}/dti/data_corr_L1.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_L1.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S"
# 			L1_std_g=`fslstats ${DIR}/dti/data_corr_L1.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_Lrad.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M"
# 			Lrad_mean_g=`fslstats ${DIR}/dti/data_corr_Lrad.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_Lrad.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S"
# 			Lrad_std_g=`fslstats ${DIR}/dti/data_corr_Lrad.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_MD.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M"
# 			MD_mean_g=`fslstats ${DIR}/dti/data_corr_MD.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_MD.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S"
# 			MD_std_g=`fslstats ${DIR}/dti/data_corr_MD.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_FA.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M"
# 			FA_mean_g=`fslstats ${DIR}/dti/data_corr_FA.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/data_corr_FA.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S"
# 			FA_std_g=`fslstats ${DIR}/dti/data_corr_FA.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			echo "fslmaths ${DIR}/dti/Fibers/putamen_g_to_areas/Max.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M"
# 			C_mean_g=`fslstats ${DIR}/dti/Fibers/putamen_g_to_areas/Max.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -M`
# 			
# 			echo "fslmaths ${DIR}/dti/Fibers/putamen_g_to_areas/Max.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S"
# 			C_std_g=`fslstats ${DIR}/dti/Fibers/putamen_g_to_areas/Max.nii.gz -k ${DIR}/dti/Fibers/putamen_g_to_areas/ROI_${i}.nii.gz -S`
# 			
# 			if [ ${i} -eq 1 ]
# 			then
# 				Roi="Associatif"
# 			fi
# 			
# 			if [ ${i} -eq 2 ]
# 			then
# 				Roi="Limbique"
# 			fi
# 			
# 			if [ ${i} -eq 3 ]
# 			then
# 				Roi="Moteur"
# 			fi
# 			
# 			echo "${Roi} ${L1_mean_g} ${L1_std_g} ${Lrad_mean_g} ${Lrad_std_g} ${MD_mean_g} ${MD_std_g} ${FA_mean_g} ${FA_std_g} ${C_mean_g} ${C_std_g}" >> ${DIR}/dti/Fibers/putamen_g_to_areas/Stats.txt
# 			echo "${Roi} ${L1_mean_g} ${L1_std_g} ${Lrad_mean_g} ${Lrad_std_g} ${MD_mean_g} ${MD_std_g} ${FA_mean_g} ${FA_std_g} ${C_mean_g} ${C_std_g} ${L1_mean_d} ${L1_std_d} ${Lrad_mean_d} ${Lrad_std_d} ${MD_mean_d} ${MD_std_d} ${FA_mean_d} ${FA_std_d} ${C_mean_d} ${C_std_d}" >> ${DIR}/dti/Fibers/${Subject}_stats.txt
# 		done
# 		
# 		ICV=`cat ${DIR}/stats/aseg.stats | grep ICV | awk '{print $7}'`
# 		ICV=${ICV%,}
# 		echo "ICV(mm3) ${ICV}" >> ${DIR}/dti/Fibers/putamen_dt_to_areas/Stats.txt
# 		echo "ICV(mm3) ${ICV}" >> ${DIR}/dti/Fibers/putamen_g_to_areas/Stats.txt
# 		echo "ICV(mm3) ${ICV}" >> ${DIR}/dti/Fibers/${Subject}_stats.txt
# 		cp ${DIR}/dti/Fibers/putamen_dt_to_areas/Stats.txt ${DIR}/dti/Fibers/putamen_dt_to_areas/${Subject}_stats_dt.txt
# 		cp ${DIR}/dti/Fibers/putamen_g_to_areas/Stats.txt ${DIR}/dti/Fibers/putamen_g_to_areas/${Subject}_stats_g.txt
# 	fi
done
