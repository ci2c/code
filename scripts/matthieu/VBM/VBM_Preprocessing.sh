#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: VBM_Preprocessing.sh [options] -id <inputdir> -od <outputdir>"
	echo ""
	echo "	-id	: input subjects directory (mgz)"
	echo ""
	echo "  -od	: output subjects directory (nifti)"
	echo ""
	echo " options are"
	echo ""
	echo "	-all : treat all patients contained in input dir"
	echo "	-f <filepath> : path of the file patients.txt"
	echo ""
	echo "Usage: VBM_Preprocessing.sh [options] -id <inputdir> -od <outputdir>"
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
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "output subjects directory : ${OUTPUT_DIR}"
		;;
	-f)
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path of the file patients.txt : ${FILE_PATH}"
		;;
	-all)
		echo "all patients in ${INPUT_DIR} are treated"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: VBM_Preprocessing.sh [options] -id <inputdir> -od <outputdir>"
		echo ""
		echo "	-id	: input subjects directory (mgz)"
		echo ""
		echo "  -od	: output subjects directory (nifti)"
		echo ""
		echo " options are"
		echo ""
		echo "	-all : treat all patients contained in input dir"
		echo "	-f <filepath> : path of the file patients.txt"
		echo ""
		echo "Usage: VBM_Preprocessing.sh [options] -id <inputdir> -od <outputdir>"
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
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi

## Creation of mgz2nii function
mri_mgz2nii()
{
	echo -e "$1$3/mri/orig.mgz" 
   	mkdir $2$3
   	mri_convert --out_orientation RAS $1$3/mri/orig.mgz $2$3/orig_ras.nii
}

## Creation of DARTEL_arg function
mri_DARTEL_arg()
{
	if [ $1 -eq $2 ]
	then
		DARTEL_arg=${DARTEL_arg}\'$3$4/rc1orig_ras.nii\'","\'$3$4/rc2orig_ras.nii\'
	else
		DARTEL_arg=${DARTEL_arg}\'$3$4/rc1orig_ras.nii\'","\'$3$4/rc2orig_ras.nii\'","
	fi		
}

## Creation of FlowFields_arg function
mri_FlowFields_arg()
{
	if [ $1 -eq $2 ]
	then
		FlowFields_arg=${FlowFields_arg}\'$3$4/u_rc1orig_ras_Template.nii\'
	else
		FlowFields_arg=${FlowFields_arg}\'$3$4/u_rc1orig_ras_Template.nii\'","
	fi		
}

## Creation of MNI_Normalise_arg function
mri_MNI_Normalise_arg()
{
	if [ $1 -eq $2 ]
	then
		MNI_Normalise_arg=${MNI_Normalise_arg}\'$3$4/c1orig_ras.nii\'
	else
		MNI_Normalise_arg=${MNI_Normalise_arg}\'$3$4/c1orig_ras.nii\'","
	fi		
}

## Main function for one iteration or one subject
mri_main()
{
	mri_mgz2nii $1 $2 $3
	./SPM_NewSegment.sh -i $2$3/orig_ras.nii
	mri_DARTEL_arg $4 $5 $2 $3
	if [ $4 -eq 1 ]
	then
		TEMPLATE_PATH=\'$2$3/Template_6.nii\'
	fi
		mri_FlowFields_arg $4 $5 $2 $3
		mri_MNI_Normalise_arg $4 $5 $2 $3
		$4=$[$4+1]
}

## Conversion mgz to nii, segmentation, Creation of DARTEL, Flow Fields and MNI Normalise arguments
if [ -e ${FILE_PATH}/patients.txt ]
then
	if [ -s ${FILE_PATH}/patients.txt ]
	then	
		index=1	
		nblines=$(cat ${FILE_PATH}/patients.txt | wc -l)
		echo $nblines
		while read line  
		do   
  			mri_main ${INPUT_DIR} ${OUTPUT_DIR} $line $index $nblines
		done < ${FILE_PATH}/patients.txt
	else
		echo "the file patients.txt is empty"
		exit 1	
	fi	
else
	index=1	
	ls -F ${INPUT_DIR} | sed 's,/$,,g' > tempo.txt
	nblines=$(cat tempo.txt | wc -l)
	echo $nblines
 	while read line;
    	do
		echo "$line"
		mri_main ${INPUT_DIR} ${OUTPUT_DIR} $line $index $nblines
    	done < tempo.txt
	rm tempo.txt 
fi

## Creation of DARTEL Templates
./DARTEL_Templates.sh -i ${DARTEL_arg} 

## Normalisation to MNI Space
./MNI_Normalise.sh -t ${TEMPLATE_PATH} -f ${FlowFields_arg} -i ${MNI_Normalise_arg}
