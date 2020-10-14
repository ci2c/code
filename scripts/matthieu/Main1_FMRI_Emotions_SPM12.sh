#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage:  Main1_FMRI_Emotions_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> -f <PathSubjects> [ -fwhm <value> -rmframe <value> -voxsize <value> ]"
	echo ""
	echo "  -epi                         : Path to epi data "
	echo "  -anat                        : Path to structural data "
	echo "  -fwhm                        : smoothing value "
	echo " 	-rmframe                     : frame for removal "
	echo "  -o                           : Output directory "
	echo "  -voxsize                     : Interpolation voxel size "
	echo "	-f  			      : path of the file subjects.txt"
	echo ""
	echo "Usage:  Main1_FMRI_Emotions_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> -f <PathSubjects> [ -fwhm <value> -rmframe <value> -voxsize <value> ]"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Jan 24, 2013"
	echo ""
	exit 1
fi

index=1
fwhm=6
remframe=2
voxelsize=3

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  Main1_FMRI_Emotions_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> -f <PathSubjects> [ -fwhm <value> -rmframe <value> -voxsize <value> ]"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -fwhm                        : smoothing value "
		echo " 	-rmframe                     : frame for removal "
		echo "  -o                           : Output directory "
		echo "  -voxsize                     : Interpolation voxel size "
		echo "	-f  			      : path of the file subjects.txt"
		echo ""
		echo "Usage:  Main1_FMRI_Emotions_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> -f <PathSubjects> [ -fwhm <value> -rmframe <value> -voxsize <value> ]"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Jan 24, 2013"
		echo ""
		exit 1
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "epi data : ${epi}"
		;;
	-anat)
		index=$[$index+1]
		eval anat=\${$index}
		echo "anat data : ${anat}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "fwhm : ${fwhm}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-voxsize)
		index=$[$index+1]
		eval voxelsize=\${$index}
		echo "interpolation voxel size : ${voxelsize}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-f) 
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path of the file subjects.txt : ${FILE_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  Main1_FMRI_Emotions_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> -f <PathSubjects> [ -fwhm <value> -rmframe <value> -voxsize <value> ]"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -fwhm                        : smoothing value "
		echo " 	-rmframe                     : frame for removal "
		echo "  -o                           : Output directory "
		echo "  -voxsize                     : Interpolation voxel size "
		echo "	-f  			      : path of the file subjects.txt"
		echo ""
		echo "Usage:  Main1_FMRI_Emotions_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> -f <PathSubjects> [ -fwhm <value> -rmframe <value> -voxsize <value> ]"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Jan 24, 2013"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${epi} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${anat} ]
then
	 echo "-anat argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${FILE_PATH} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi

## Prepare and copy FMRI and T1 files before SPM12 preprocessing
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
# 		while read subject  
# 		do 
# 			if [ -s ${epi}/${subject} ]
# 			then 
# 		  		if [ -f ${epi}/${subject}/IMA/*.nii ]				
# 		  		then
# 		  			if [ -f ${anat}/${subject}/3DT1/*3DT1*.nii ]				
# 		  			then
# 		  				qbatch -N FMRI_Pre_${subject} -q fs_q -oe ~/Logdir FMRI_EmotionsPreprocess_SPM12.sh  -epi ${epi}/${subject} -anat ${anat}/${subject} -fwhm ${fwhm} -o ${outdir}/${subject} -rmframe ${remframe} -voxsize ${voxelsize}   
# 		  				sleep 1
# 		  			else
# 		  				echo "Le fichier ${anat}/${subject}/3DT1/*3DT1*.nii n'existe pas" >> ${outdir}/LogEmotions
# 		  			fi
# 		  		else
# 	  				echo "Le fichier ${epi}/${subject}/IMA/*.nii n'existe pas" >> ${outdir}/LogEmotions
# 		  		fi
# 			else
# 				echo "Le répertoire ${epi}/${subject} est vide" >> ${outdir}/LogEmotions
# 			fi
# 		done < ${FILE_PATH}/subjects.txt
		while read subject  
		do 
			if [ -f ${outdir}/${subject}/spm/RawEPI/rp_*.txt ]
			then
# 				WaitForJobs.sh FMRI_Pre_${subject}
				qbatch -N FMRI_OI_${subject} -q fs_q -oe ~/Logdir FMRI_OutlierId_SPM12.sh -sd ${outdir}/${subject}
				sleep 1
			else
			      echo "Le fichier ${outdir}/${subject}/spm/RawEPI/rp_*.txt n'existe pas" >> ${outdir}/LogEmotions
			fi
		done < ${FILE_PATH}/subjects.txt
# 		iteration=1
# 		Mask_mean=""
# 		NbSubjects=$(cat /home/matthieu/NAS/matthieu/fMRI_Emotions/subjects.txt | wc -l)
# 		while read subject  
# 		do 
# 			if [ -f ${outdir}/${subject}/spm/RawEPI/wmeanepi_0003.nii ]
# 			then
# 				cd ${outdir}/${subject}/spm/RawEPI
# 				bet wmeanepi_0003.nii SL -m -n -f 0.25
# 				gunzip ${outdir}/${subject}/spm/RawEPI/SL_mask.nii.gz
# 				if [ ${iteration} -gt 1 ]
# 				then
# 					mri_and ${maskN1} ${outdir}/${subject}/spm/RawEPI/SL_mask.nii
# 				fi
# 				maskN1=${outdir}/${subject}/spm/RawEPI/SL_mask.nii
# 				iteration=$[${iteration}+1]
# 			else
# 			      echo "Le fichier ${outdir}/${subject}/spm/RawEPI/wmeanepi_0003.nii n'existe pas" >> ${outdir}/LogEmotions
# 			fi
# 			rm -f ${outdir}/${subject}/spm/RawEPI/epi_mask.nii
# 		done < ${FILE_PATH}/subjects.txt
# 		cp ${maskN1} ${outdir}/mean_SL_mask.nii
	else
		echo "Le fichier subjects.txt est vide" >> ${outdir}/LogEmotions
		exit 1	
	fi	
else
	echo "Le fichier subjects.txt est n'existe pas" >> ${outdir}/LogEmotions
	exit 1	
fi