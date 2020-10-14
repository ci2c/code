#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: NlFit_fmri.sh  -forw <FORWARD_IMAGE>  -back <BACKWARD_IMAGE>  -o <output_directory>  [-ite ITERATIONS -keeptmp]"
	echo ""
	echo "  -forw                            : Forward image, i.e. image from the fMRI acquisition (.nii or .nii.gz)"
	echo "  -back                            : Backward image, i.e. image from the fMRI correction acquisition (.nii or .nii.gz)"
	echo "                                        Make sure backward image is shift corrected with respect to forward image !!!"
	echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
	echo ""
	echo "Optional argument :"
	echo "  -keeptmp                         : Keep temporary files. Default : erase them."
	echo "  -ite                             : Number of non-linear registration iterations. Default = 20."
	echo ""
	echo "Usage: NlFit_fmri.sh  -forw <FORWARD_IMAGE>  -back <BACKWARD_IMAGE>  -o <output_directory>  [-ite ITERATIONS -keeptmp]"
	echo ""
	exit 1
fi


index=1
keeptmp=0
forw=""
back=""
obase=""
ite=20

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: NlFit_fmri.sh  -forw <FORWARD_IMAGE>  -back <BACKWARD_IMAGE>  -o <output_directory>  [-ite ITERATIONS -keeptmp]"
		echo ""
		echo "  -forw                            : Forward image, i.e. image from the fMRI acquisition (.nii or .nii.gz)"
		echo "  -back                            : Backward image, i.e. image from the fMRI correction acquisition (.nii or .nii.gz)"
		echo "                                        Make sure backward image is shift corrected with respect to forward image !!!"
		echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
		echo ""
		echo "Optional argument :"
		echo "  -keeptmp                         : Keep temporary files. Default : erase them."
		echo "  -ite                             : Number of non-linear registration iterations. Default = 20."
		echo ""
		echo "Usage: NlFit_fmri.sh  -forw <FORWARD_IMAGE>  -back <BACKWARD_IMAGE>  -o <output_directory>  [-ite ITERATIONS -keeptmp]"
		echo ""
		exit 1
		;;
	-forw)
		index=$[$index+1]
		eval forw=\${$index}
		echo "Forward image : $forw"
		;;
	-back)
		index=$[$index+1]
		eval back=\${$index}
		echo "Backward image : $back"
		;;
	-o)
		index=$[$index+1]
		eval obase=\${$index}
		echo "Output_directory : $obase"
		;;
	-keeptmp)
		keeptmp=1
		echo "Keep temp files"
		;;
	-ite)
		index=$[$index+1]
		eval ite=\${$index}
		echo "Number of iterations set to $ite"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage: NlFit_fmri.sh  -forw <FORWARD_IMAGE>  -back <BACKWARD_IMAGE>  -o <output_directory>  [-ite ITERATIONS -keeptmp]"
		echo ""
		echo "  -forw                            : Forward image, i.e. image from the fMRI acquisition (.nii or .nii.gz)"
		echo "  -back                            : Backward image, i.e. image from the fMRI correction acquisition (.nii or .nii.gz)"
		echo "                                        Make sure backward image is shift corrected with respect to forward image !!!"
		echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
		echo ""
		echo "Optional argument :"
		echo "  -keeptmp                         : Keep temporary files. Default : erase them."
		echo "  -ite                             : Number of non-linear registration iterations. Default = 20."
		echo ""
		echo "Usage: NlFit_fmri.sh  -forw <FORWARD_IMAGE>  -back <BACKWARD_IMAGE>  -o <output_directory>  [-ite ITERATIONS -keeptmp]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${forw} ]
then
	 echo "-forw argument mandatory"
	 exit 1
fi

if [ -z ${back} ]
then
	 echo "-back argument mandatory"
	 exit 1
fi

if [ -z ${obase} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi


outdir=${obase}

## Creates out dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi



## Gunzip .gz
if [ -n "`echo $forw | grep .gz`" ]
then
	gunzip ${forw}
	forw=${forw%.gz}
	cp ${forw} ${outdir}/forw_ite0.nii
	gzip ${forw}
else
	cp ${forw} ${outdir}/forw_ite0.nii
fi

if [ -n "`echo $back | grep .gz`" ]
then
	gunzip $back
	back=${back%.gz}
	cp ${back} ${outdir}/back_ite0.nii
	gzip ${back}
else
	cp ${back} ${outdir}/back_ite0.nii
fi

# Get initial affine transform
echo "ANTS 3 -m  CC[${outdir}/forw_ite0.nii,${outdir}/back_ite0.nii,1,4]  -t SyN[0.25]  -r Gauss[3,0] -o ${outdir}/init  -i 30x90x20   --use-Histogram-Matching --MI-option 32x16000 --number-of-affine-iterations -1x-1x-1"
ANTS 3 -m  CC[${outdir}/forw_ite0.nii,${outdir}/back_ite0.nii,1,4]  -t SyN[0.25]  -r Gauss[3,0] -o ${outdir}/init  -i 30x90x20   --use-Histogram-Matching --MI-option 32x16000 --number-of-affine-iterations -1x-1x-1

rm -f ${outdir}/initInverseWarp.nii.gz ${outdir}/initWarp.nii.gz

# Correct affine transformation
touch ${outdir}/initAffine_corrected.txt
nb_lines=`cat ${outdir}/initAffine.txt | wc -l`
i=1
while [ ${i} -le ${nb_lines} ]
do
	line_n=`sed -n "${i}{p;q}" ${outdir}/initAffine.txt`
	if [ $i -eq 4 ]
	then
		y_shift=`echo ${line_n} | awk '{print $12}'`
		# echo "Parameters: 1 0 0 0 1 0 0 0 1 0 ${y_shift} 0" >> ${outdir}/initAffine_corrected.txt
		echo "Parameters: 1 0 0 0 1 0 0 0 1 0 0 0" >> ${outdir}/initAffine_corrected.txt
	else
		echo ${line_n} >> ${outdir}/initAffine_corrected.txt
	fi
	i=$[$i+1]
done

## Get y voxel size
y_size=`fslsize ${forw} | grep pixdim2 | awk {'printf $2'}`

## Non-linear registration iterations
iteration=0
while [ $iteration -lt $ite ]
do
	echo " ******************************** "	
	echo " iteration ${iteration}"
	echo " ******************************** "
	
	# Launch syn non-linear registration
	# Original command line # ANTS $DIM -m  ${METRIC}${FIXED},${OUTPUTNAME}repaired.nii.gz,${METRICPARAMS}  -t $TRANSFORMATION  -r $REGULARIZATION -o ${OUTPUTNAME}   -i $MAXITERATIONS   --use-Histogram-Matching  --number-of-affine-iterations 10000x10000x10000x10000x10000 --MI-option 32x16000
	# ANTS 3 -m  CC[${outdir}/forw_ite${iteration}.nii,${outdir}/back_ite${iteration}.nii,1,4]  -t SyN[0.25]  -r Gauss[3,0] -o ${outdir}/ite${iteration}  -i 30x90x20   --use-Histogram-Matching --initial-affine ${outdir}/initAffine_corrected.txt --continue-affine false  --MI-option 32x16000
	if [ ${iteration} -lt 50 ]
	then
		ANTS 3 -m  MI[${outdir}/forw_ite${iteration}.nii,${outdir}/back_ite${iteration}.nii,1,100]  -t SyN[0.75]  -r Gauss[5,5] -o ${outdir}/ite${iteration}  -i 30x90x20   --use-Histogram-Matching --initial-affine ${outdir}/initAffine_corrected.txt --continue-affine false  --MI-option 32x16000
	else
		ANTS 3 -m  MI[${outdir}/forw_ite${iteration}.nii,${outdir}/back_ite${iteration}.nii,1,1000]  -t SyN[0.25]  -r Gauss[1,1] -o ${outdir}/ite${iteration}  -i 30x90x20   --use-Histogram-Matching --initial-affine ${outdir}/initAffine_corrected.txt --continue-affine false  --MI-option 32x16000
	fi
	
	# Extract vector y component and correct displacement field
	ImageMath 3 ${outdir}/vec_y_ite${iteration}.nii ExtractVectorComponent ${outdir}/ite${iteration}Warp.nii.gz 1
	
	# Extract vector y component and correct displacement field for inverse warp
	ImageMath 3 ${outdir}/inv_vec_y_ite${iteration}.nii ExtractVectorComponent ${outdir}/ite${iteration}InverseWarp.nii.gz 1
	
	# Divide by y voxel size and by 2
	fslmaths ${outdir}/vec_y_ite${iteration}.nii -div ${y_size} -div 2 ${outdir}/vec_y_ite${iteration}_vox.nii
	gunzip -f ${outdir}/vec_y_ite${iteration}_vox.nii.gz
	fslmaths ${outdir}/inv_vec_y_ite${iteration}.nii -div ${y_size} -div 2 ${outdir}/inv_vec_y_ite${iteration}_vox.nii
	gunzip -f ${outdir}/inv_vec_y_ite${iteration}_vox.nii.gz
	
	# Concatenate warps
	if [ ${iteration} -eq 0 ]
	then
		cp -f ${outdir}/vec_y_ite${iteration}_vox.nii ${outdir}/vec_y_vox.nii
		cp -f ${outdir}/inv_vec_y_ite${iteration}_vox.nii ${outdir}/inv_vec_y_vox.nii
	else
		fslmaths ${outdir}/vec_y_vox.nii -add ${outdir}/vec_y_ite${iteration}_vox.nii ${outdir}/temp.nii.gz
		gunzip ${outdir}/temp.nii.gz
		mv -f ${outdir}/temp.nii ${outdir}/vec_y_vox.nii
		
		fslmaths ${outdir}/inv_vec_y_vox.nii -add ${outdir}/inv_vec_y_ite${iteration}_vox.nii ${outdir}/temp.nii.gz
		gunzip ${outdir}/temp.nii.gz
		mv -f ${outdir}/temp.nii ${outdir}/inv_vec_y_vox.nii
	fi
	
	# Iterate
	iteration=$[$iteration+1]
	
	# Correct original images with current deformation field
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
Y_out = EPIresample('${outdir}/back_ite0.nii', '${outdir}/vec_y_vox.nii', 0, [], '${outdir}/back_ite${iteration}.nii');
Y_out = EPIresample('${outdir}/forw_ite0.nii', '${outdir}/vec_y_vox.nii', 1, [], '${outdir}/forw_ite${iteration}.nii');
EOF
		
done
