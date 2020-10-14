#!/bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: DTI_GetMNIConnectMatrixWithLesion.sh  -p <atlas_ima>  -f <fiber_file>  -r <ref_ima>  -m <lesion_mask>  -o <out_path>  -on <out_name>  [-n <loi_file>  -t <thresh_value>]"
	echo ""
	echo "  -p <atlas_ima>                     : Parcellation image"
	echo "  -f <fiber_file>                    : Fiber file (.mat)"
	echo "  -r <ref_ima>                       : Reference image"
	echo "  -m <lesion_mask>                   : Lesion mask (.nii)"
	echo "  -o <out_path>                      : output folder"
	echo "  -on <out_name>                     : output name (ex: Connectome)"
	echo "Options "
	echo "  -n <loi_file>                      : file of label names (Format: num name) (Default: "")"
	echo "  -t <thresh_value>                  : threshold value (Default: 30)"
	echo " "
	echo "Usage: DTI_GetMNIConnectMatrixWithLesion.sh  -p <atlas_ima>  -f <fiber_file>  -r <ref_ima>  -m <lesion_mask>  -o <out_path>  -on <out_name>  [-n <loi_file>  -t <thresh_value>]"
	echo ""
	exit 1
fi

index=1
LOI=""
thresh=30
output=""
prefix="r"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_GetMNIConnectMatrixWithLesion.sh  -p <atlas_ima>  -f <fiber_file>  -r <ref_ima>  [-n <loi_file>  -t <thresh_value>]"
		echo ""
		echo "  -p <atlas_ima>                     : Parcellation image"
		echo "  -f <fiber_file>                    : Fiber file (.mat)"
		echo "  -r <ref_ima>                       : Reference image"
		echo "  -m <lesion_mask>                   : Lesion mask (.nii)"
		echo "Options "
		echo "  -n <loi_file>                      : file of label names (Format: num name) (Default: "")"
		echo "  -t <thresh_value>                  : threshold value (Default: 30)"
		echo " "
		echo "Usage: DTI_GetMNIConnectMatrixWithLesion.sh  -p <atlas_ima>  -f <fiber_file>  -r <ref_ima>  [-n <loi_file>  -t <thresh_value>]"
		echo ""
		exit 1
		;;
	-p)
		atlas=`expr $index + 1`
		eval atlas=\${$atlas}
		echo "Parcellation file : $atlas"
		;;
	-f)
		fiber=`expr $index + 1`
		eval fiber=\${$fiber}
		echo "Fiber file : $fiber"
		;;
	-r)
		reference=`expr $index + 1`
		eval reference=\${$reference}
		echo "Reference image : $reference"
		;;
	-m)
		lesion=`expr $index + 1`
		eval lesion=\${$lesion}
		echo "Lesion mask : $lesion"
		;;
	-o)
		outfolder=`expr $index + 1`
		eval outfolder=\${$outfolder}
		echo "output folder : $outfolder"
		;;
	-on)
		outname=`expr $index + 1`
		eval outname=\${$outname}
		echo "output name : $outname"
		;;
	-n)
		LOI=`expr $index + 1`
		eval LOI=\${$LOI}
		echo "Label file : $LOI"
		;;
	-t)
		thresh=`expr $index + 1`
		eval thresh=\${$thresh}
		echo "Threshold value : $thresh"
		;;
	esac
	index=$[$index+1]
done

# Check inputs
if [ ! -e ${atlas} ]
then
	echo "Can not find ${atlas} file"
	exit 1
fi

if [ ! -f ${fiber} -a ! -f ${fiber%.mat}_part000001.mat ]
then
	echo "Can not find files ${fiber} or ${fiber%.mat}_part000001.mat"
	exit 1
fi

if [ ! -e ${reference} ]
then
	echo "Can not find ${reference} file"
	exit 1
fi

if [ ! -e ${lesion} ]
then
	echo "Can not find ${lesion} file"
	exit 1
fi

if [ -z "$output" ]; then output=$(dirname "$fiber"); fi

if [ ! -d "$outfolder" ]; then mkdir ${outfolder}; fi

# Check if you need to resample the atlas
dimax=`mri_info ${atlas} | grep "dimensions" | awk '{print $2}'`
dimay=`mri_info ${atlas} | grep "dimensions" | awk '{print $4}'`
dimaz=`mri_info ${atlas} | grep "dimensions" | awk '{print $6}'`
dimrx=`mri_info ${reference} | grep "dimensions" | awk '{print $2}'`
dimry=`mri_info ${reference} | grep "dimensions" | awk '{print $4}'`
dimrz=`mri_info ${reference} | grep "dimensions" | awk '{print $6}'`
dimmx=`mri_info ${lesion} | grep "dimensions" | awk '{print $2}'`
dimmy=`mri_info ${lesion} | grep "dimensions" | awk '{print $4}'`
dimmz=`mri_info ${lesion} | grep "dimensions" | awk '{print $6}'`

echo "resampling..."
atlasname=$(basename "$atlas")
NAME=`echo "$atlasname" | cut -d'.' -f1`
if [ ! -f ${output}/${NAME}.nii ]; then
	mri_convert $atlas ${output}/${NAME}.nii
fi
IMA=${output}/${NAME}.nii
atlas=${output}/"$prefix""${NAME}"".nii"

if [ -f ${atlas} ]; then
	echo "atlas already exists"
else
	echo "do resampling"
	SPM_Resample.sh  -r ${reference} -s ${IMA} -i 0 -p "r"
fi

echo "resampling lesion mask..."
lesionname=$(basename "$lesion")
NAME=`echo "$lesionname" | cut -d'.' -f1`

if [ ! -f ${outfolder}/${NAME}.nii ]; then
	mri_convert $lesion ${outfolder}/${NAME}.nii
fi
IMA=${outfolder}/${NAME}.nii
lesion=${outfolder}/"$prefix""${NAME}"".nii"

if [ -f ${lesion} ]; then
	echo "lesion already exists"
else
	echo "do resampling"
	SPM_Resample.sh  -r ${reference} -s ${IMA} -i 0 -p "r"
fi

echo "lesion mask: ${lesion}"
echo "atlas: ${atlas}"
echo "fiber: ${fiber}"
echo "LOI: $LOI"
echo "out folder: $outfolder"
echo "out name: $outname"
matlab -nodisplay <<EOF

[ConnectomeLesion,Connectome] = DTI_GetMNIConnectMatrixWithLesionFromPart('${lesion}', '${atlas}', '${fiber}', [1 1 1], '${LOI}', ${thresh});
save(fullfile('${outfolder}',['${outname}.mat']),'Connectome','ConnectomeLesion','-v7.3');

EOF


