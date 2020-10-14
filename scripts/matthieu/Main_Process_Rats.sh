#! /bin/bash

if [ $# -lt 20 ]
then
	echo ""
	echo "Usage: Main_Process_Rats.sh -id <inputdir>  -od <outputdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z> -f <pathfilesubj>"
	echo ""
	echo "	-id	: input directory"
	echo "	-od	: output directory"
	echo "	-t	: path of the template file TemplateRat.nii"
	echo " 	-fx	: flip to apply along the x direction"
	echo " 	-fy	: flip to apply along the y direction"
	echo " 	-fz	: flip to apply along the z direction"
	echo " 	-rx	: resize to apply along the x direction"
	echo " 	-ry	: resize to apply along the y direction"
	echo " 	-rz	: resize to apply along the z direction"
	echo "	-f 	: path of the file subjects.txt"
	echo ""
	echo "Usage: Main_Process_Rats.sh -id <inputdir>  -od <outputdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z> -f <pathfilesubj>"
	echo ""
	exit 1
fi

index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "input subjects directory : ${INPUT_DIR}"
		;;
	-f) 
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path of the file subjects.txt : ${FILE_PATH}"
		;;

	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "output subjects directory : ${OUTPUT_DIR}"
		;;
	-t)
		index=$[$index+1]
		eval TEMP_PATH=\${$index}
		echo "path of the file TemplateRat.nii : ${TEMP_PATH}"
		;;
	-fx)
		index=$[$index+1]
		eval FX=\${$index}
		echo "flip to apply along the x direction : ${FX}"
		;;
	-fy)
		index=$[$index+1]
		eval FY=\${$index}
		echo "flip to apply along the y direction : ${FY}"
		;;
	-fz)
		index=$[$index+1]
		eval FZ=\${$index}
		echo "flip to apply along the z direction : ${FZ}"
		;;
	-rx)
		index=$[$index+1]
		eval RX=\${$index}
		echo "resize to apply along the x direction : ${RX}"
		;;
	-ry)
		index=$[$index+1]
		eval RY=\${$index}
		echo "resize to apply along the y direction : ${RY}"
		;;
	-rz)
		index=$[$index+1]
		eval RZ=\${$index}
		echo "resize to apply along the z direction : ${RZ}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Main_Process_Rats.sh -id <inputdir>  -od <outputdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z> -f <pathfilesubj>"
		echo ""
		echo "	-id	: input directory"
		echo "	-od	: output directory"
		echo "	-t	: path of the template file TemplateRat.nii"
		echo " 	-fx	: flip to apply along the x direction"
		echo " 	-fy	: flip to apply along the y direction"
		echo " 	-fz	: flip to apply along the z direction"
		echo " 	-rx	: resize to apply along the x direction"
		echo " 	-ry	: resize to apply along the y direction"
		echo " 	-rz	: resize to apply along the z direction"
		echo "	-f 	: path of the file subjects.txt"
		echo ""
		echo "Usage: Main_Process_Rats.sh -id <inputdir>  -od <outputdir> -t <templatepath> -fx <flip_x> -fy <flip_y> -fz <flip_z> -rx <resize_x> -ry <resize_y> -rz <resize_z> -f <pathfilesubj>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
elif [ -z ${TEMP_PATH} ]
then
	 echo "-t argument mandatory"
	 exit 1
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
elif [ -z ${FX} ]
then
	 echo "-fx argument mandatory"
	 exit 1
elif [ -z ${FY} ]
then
	 echo "-fy argument mandatory"
	 exit 1
elif [ -z ${FZ} ]
then
	 echo "-fz argument mandatory"
	 exit 1
elif [ -z ${RX} ]
then
	 echo "-rx argument mandatory"
	 exit 1
elif [ -z ${RY} ]
then
	 echo "-ry argument mandatory"
	 exit 1
elif [ -z ${RZ} ]
then
	 echo "-rz argument mandatory"
	 exit 1
elif [ -z ${FILE_PATH} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi

## Looping on subjects qbatch automatic registration of PET/MRI images on MRI Template
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
		nbsubj=$(cat ${FILE_PATH}/subjects.txt | wc -l)
		echo $nbsubj
		while read subject  
		do   
			if [ -d ${INPUT_DIR}/${subject} -a $(ls -A ${INPUT_DIR}/${subject} | wc -c) -ne 0 ]
			then 
# 				qbatch -N ${subject}_PR -q fs_q -oe ~/Logdir 
				Process_Rats.sh -id ${INPUT_DIR}/${subject} -od ${OUTPUT_DIR}/${subject} -t ${TEMP_PATH} -fx ${FX} -fy ${FY} -fz ${FZ} -rx ${RX} -ry ${RY} -rz ${RZ}
# 				sleep 5
			else
				echo "Le répertoire ${INPUT_DIR}/${subject} n'existe pas ou est vide" >> ${OUTPUT_DIR}/LogRats
			fi
		done < ${FILE_PATH}/subjects.txt
	else
		echo "Le fichier subjects.txt est vide" >> ${OUTPUT_DIR}/LogRats
		exit 1	
	fi	
fi