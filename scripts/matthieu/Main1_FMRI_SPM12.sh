#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage:  Main1_FMRI_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> [ -fwhm <value>  -refslice <value>  -acquis <name> -rmframe <value> -voxsize <value> ]"
	echo ""
	echo "  -epi                         : Path to epi data "
	echo "  -anat                        : Path to structural data "
	echo "  -fwhm                        : smoothing value "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo " 	-rmframe                     : frame for removal "
	echo "  -o                           : Output directory "
	echo "  -voxsize                      : Interpolation voxel size "
	echo ""
	echo "	-all 			      : treat all patients contained in input dir"
	echo "	-f  			      : path of the file subjects.txt"
	echo ""
	echo "Usage:  Main1_FMRI_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> [ -fwhm <value>  -refslice <value>  -acquis <name> -rmframe <value> -voxsize <value> ]"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 22, 2013"
	echo ""
	exit 1
fi

index=1
fwhm=6
refslice=1
acquis=interleaved
remframe=5
voxelsize=3

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  Main1_FMRI_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> [ -fwhm <value>  -refslice <value>  -acquis <name> -rmframe <value> -voxsize <value> ]"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo " 	-rmframe                     : frame for removal "
		echo "  -o                           : Output directory "
		echo "  -voxsize                      : Interpolation voxel size "
		echo ""
		echo "	-all 			      : treat all patients contained in input dir"
		echo "	-f  			      : path of the file subjects.txt"
		echo ""
		echo "Usage:  Main1_FMRI_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> [ -fwhm <value>  -refslice <value>  -acquis <name> -rmframe <value> -voxsize <value> ]"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 22, 2013"
		echo ""
		exit 1
		;;
	-all)
		echo "all patients in ${epi} are treated"
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
	-refslice)
		index=$[$index+1]
		eval refslice=\${$index}
		echo "slice of reference : ${refslice}"
		;;
	-acquis)
		index=$[$index+1]
		eval acquis=\${$index}
		echo "acquisition : ${acquis}"
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
		echo "Usage:  Main1_FMRI_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> [ -fwhm <value>  -refslice <value>  -acquis <name> -rmframe <value> -voxsize <value> ]"
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo " 	-rmframe                     : frame for removal "
		echo "  -o                           : Output directory "
		echo "  -voxsize                      : Interpolation voxel size "
		echo ""
		echo "	-all 			      : treat all patients contained in input dir"
		echo "	-f  			      : path of the file subjects.txt"
		echo ""
		echo "Usage:  Main1_FMRI_SPM12.sh  -epi <epi_path>  -anat <anat_path> -o <output_directory> [ -fwhm <value>  -refslice <value>  -acquis <name> -rmframe <value> -voxsize <value> ]"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 22, 2013"
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

## Prepare and copy FMRI and T1 files before SPM8 preprocessing
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
# 		while read subject  
# 		do 
# 			if [ -s ${epi}/${subject} ]
# 			then 
# 		  		if [ -f ${epi}/${subject}/run1.nii -a -f ${epi}/${subject}/run2.nii ]				
# 		  		then
# 		  			if [ -f ${anat}/${subject}/mri/orig.mgz ]				
# 		  			then
# 		  				qbatch -N ${subject}_FMRI_Pre -q fs_q -oe ~/Logdir FMRI_Preprocess_SPM12.sh  -epi ${epi}/${subject} -anat ${anat}/${subject} -fwhm ${fwhm}  -refslice ${refslice}  -acquis ${acquis}  -o ${outdir}/${subject} -rmframe ${remframe} -voxsize ${voxelsize}   
# 		  				sleep 2
# 		  			else
# 		  				echo "Le fichier ${anat}/${subject}/orig.mgz n'existe pas" >> ${outdir}/LogAlexis
# 		  			fi
# 		  		else
# 	  				echo "Le fichier ${epi}/${subject}/run1.nii ou ${epi}/${subject}/run2.nii n'existe pas" >> ${outdir}/LogAlexis
# 		  		fi
# 			else
# 				echo "Le répertoire ${epi}/${subject} est vide" >> ${outdir}/LogAlexis
# 			fi
# 		done < ${FILE_PATH}/subjects.txt
# 		while read subject  
# 		do 
# 			if [ -f ${outdir}/${subject}/spm/RawEPI/run1/raepi_0005.nii -a -f ${outdir}/${subject}/spm/RawEPI/run2/raepi_0005.nii ]
# 			then
# 				WaitForJobs.sh ${subject}_FMRI_Pre
# # 				qbatch -N ${subject}_FMRI_OI -q fs_q -oe ~/Logdir 
# 				FMRI_OutlierId_SPM12.sh -sd ${outdir}/${subject}
# # 				sleep 1
# 			else
# 			      echo "Le fichier ${subject}/spm/RawEPI/run1/raepi_0005.nii ou ${subject}/spm/RawEPI/run2/raepi_0005.nii n'existe pas" >> ${outdir}/LogAlexis
# 			fi
# 		done < ${FILE_PATH}/subjects.txt
# 		while read subject  
# 		do 			
# 			if [ -f `${epi}/${subject}/alex*.mat` -a -f `${epi}/${subject}/*.xls` ]
# 			then
# 				cd ${epi}/${subject};
# 				fxls=$(ls *.xls)
# 				fmat=$(ls alex*.mat)
# 				
# 				qbatch -N ${subject}_DESIGN -q fs_q -oe ~/Logdir Alexis_design_matrix.sh -o ${outdir} -s ${subject} -xls ${fxls} -mat ${fmat}
# 				sleep 1
# 			else
# 			      echo "Le fichier ${subject}.mat ou ${subject}.xls n'existe pas" >> ${outdir}/LogAlexis
# 			fi
# 		done < ${FILE_PATH}/subjects.txt
	else
		echo "Le fichier subjects.txt est vide" >> ${outdir}/LogAlexis
		exit 1	
	fi	
else
	echo "Tous les sujets contenus dans le répertoire d'entrée vont être traités"
# 	for subject in $(ls ${epi})  
# 	do   
# 		if [ -s ${epi}/${subject} ]
# 		then 
	# 		if [ -f ${epi}/${subject}/run1.nii -a -f ${epi}/${subject}/run2.nii ]				
	# 		then
	# 			if [ -f ${anat}/${subject}/mri/orig.mgz ]				
	# 			then
	# 				qbatch -N ${subject}_FMRI_Pre -q fs_q -oe ~/Logdir FMRI_Preprocess_SPM8.sh  -epi ${epi}/${subject} -anat ${anat}/${subject} -fwhm ${fwhm}  -refslice ${refslice}  -acquis ${acquis}  -coreg ${coreg}  -resampling ${resamp}  -o ${outdir}/${subject} -rmframe ${remframe}
	# 				sleep 2
	# 			else
	# 				echo "Le fichier ${anat}/${subject}/orig.mgz n'existe pas" >> ${outdir}/LogAlexis
	# 			fi
	# 		else
# 				echo "Le fichier ${epi}/${subject}/run1.nii ou ${epi}/${subject}/run2.nii n'existe pas" >> ${outdir}/LogAlexis
	# 		fi
	# 		if [ -f `${epi}/${subject}/alex*.mat` -a -f `${epi}/${subject}/*.xls` ]
	# 		then
	# 			cd ${epi}/${subject};
	# 			fxls=$(ls *.xls)
	# 			fmat=$(ls alex*.mat)
	# 			/usr/local/matlab11/bin/matlab -nodisplay <<EOF
	# 
	# 			Alexis_design_matrix('${subject}','${fmat}','${fxls}');
	# EOF
	# 		else
	# 		      echo "Le fichier ${subject}.mat ou ${subject}.xls n'existe pas" >> ${outdir}/LogAlexis
	# 		fi
# 			if [ -f ${outdir}/${subject}/sots_${subject}.mat ]
# 			then
# 	# 			WaitForJobs.sh ${subject}_FMRI_Pre
# 				TR=$(mri_info ${epi}/${subject}/run1.nii | grep TR | awk '{print $2}')
# 				TR=$(echo "$TR/1000" | bc -l)
# 				qbatch -N ${subject}_FMRI_FL -q fs_q -oe ~/Logdir Alexis_FirstLevelSPM.sh  -sp ${outdir}/${subject} -sub ${subject} -od ${outdir}/${subject} -TR ${TR} -rmframe ${remframe}
# 				sleep 2
# 			else
# 			      echo "Le fichier sots_${subject}.mat n'existe pas" >> ${outdir}/LogAlexis
# 			fi
# 		else
# 			echo "Le répertoire ${epi}/${subject} est vide" >> ${outdir}/LogAlexis
# 		fi
# 	done
fi