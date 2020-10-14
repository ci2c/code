#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: DTI_GetMNIConnectMatrix.sh  -a <atlas_ima>  -f <fiber_file>  -r <ref_ima>  [-n <loi_file>  -t <thresh_value>]"
	echo ""
	echo "  -a <atlas_ima>                     : Atlas image"
	echo "  -f <fiber_file>                    : Fiber file (.mat)"
	echo "  -r <ref_ima>                       : Reference image"
	echo "Options "
	echo "  -n <loi_file>                      : file of label names (Format: num name) (Default: "")"
	echo "  -t <thresh_value>                  : threshold value (Default: 30)"
	echo " "
	echo "Usage: DTI_GetMNIConnectMatrix.sh  -a <atlas_ima>  -f <fiber_file>  -r <ref_ima>  [-n <loi_file>  -t <thresh_value>]"
	echo ""
	exit 1
fi

index=1
LOI=""
thresh=30
output=""

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_GetMNIConnectMatrix.sh  -a <atlas_ima>  -f <fiber_file>  -r <ref_ima>  [-n <loi_file>  -t <thresh_value>]"
		echo ""
		echo "  -a <atlas_ima>                     : Atlas image"
		echo "  -f <fiber_file>                    : Fiber file (.mat)"
		echo "  -r <ref_ima>                       : Reference image"
		echo "Options "
		echo "  -n <loi_file>                      : file of label names (Format: num name) (Default: "")"
		echo "  -t <thresh_value>                  : threshold value (Default: 30)"
		echo " "
		echo "Usage: DTI_GetMNIConnectMatrix.sh  -a <atlas_ima>  -f <fiber_file>  -r <ref_ima>  [-n <loi_file>  -t <thresh_value>]"
		echo ""
		exit 1
		;;
	-a)
		atlas=`expr $index + 1`
		eval atlas=\${$atlas}
		echo "atlas file : $atlas"
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

if [ ! -e ${fiber} ]
then
	echo "Can not find ${fiber} file"
	exit 1
fi

if [ ! -e ${reference} ]
then
	echo "Can not find ${reference} file"
	exit 1
fi

if [ -z "$output" ]; then output=$(dirname "$fiber"); fi

# Check if you need to resample the atlas
dimax=`mri_info ${atlas} | grep "dimensions" | awk '{print $2}'`
dimay=`mri_info ${atlas} | grep "dimensions" | awk '{print $4}'`
dimaz=`mri_info ${atlas} | grep "dimensions" | awk '{print $6}'`
dimrx=`mri_info ${reference} | grep "dimensions" | awk '{print $2}'`
dimry=`mri_info ${reference} | grep "dimensions" | awk '{print $4}'`
dimrz=`mri_info ${reference} | grep "dimensions" | awk '{print $6}'`

#dima=$(( ${dimax} * ${dimay} * ${dimaz} ))
#dimr=$(( ${dimrx} * ${dimry} * ${dimrz} ))

resample=""
if [ ${dimax} -eq ${dimrx} ]; then 
	echo "dimension x ok"
else 
	echo "not the same dimension x"
	resample=todo 
fi
if [ ${dimay} -eq ${dimry} ]; then 
	echo "dimension y ok"
else 
	echo "not the same dimension y"
	resample=todo 
fi
if [ ${dimaz} -eq ${dimrz} ]; then 
	echo "dimension z ok"
else 
	echo "not the same dimension z"
	resample=todo 
fi


echo "resampling..."
atlasname=$(basename "$atlas")
extension=`echo "$atlasname" | cut -d'.' -f2`
if [ ${extension} -eq "nii" ]; then 
	cp -f ${atlas} ${output}/${atlasname}
	IMA=${output}/${atlasname}
	atlas=${output}/"$prefix""$atlasname"
else
	NAME=`echo "$atlasname" | cut -d'.' -f1`
	mri_convert $atlas ${output}/${NAME}.nii
	IMA=${output}/${NAME}.nii
	atlas=${output}/"$prefix""${NAME}"".nii"
fi
echo ${IMA}
echo ${reference}
if [ -z ${atlas} ]; then
	echo "atlas already exists"
else
	echo "do resampling"
	SPM_Resample.sh  -r ${reference} -s ${IMA} -i 0 -p "r"
fi

echo ${atlas}

matlab -nodisplay <<EOF

%Connectome = DTI_GetMNIConnectMatrix('${atlas}','${fiber}',[1 1 1],${LOI},30);
%save('${output}/Connectome.mat','Connectome','-v7.3');

EOF



