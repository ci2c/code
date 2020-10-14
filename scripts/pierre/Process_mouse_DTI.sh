#!/bin/bash

# Pierre Besson @ CHRU Lille, 2010 - 2011
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Modified: Choice between linear or nonlinear registration (Renaud Lopes)


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Process_mouse_DTI.sh  -dti <dti_path>  -bvec <bvecs>  -bval <bvals>  [-nb0 <NB0>  -lmax <lmax>]"
	echo ""
	echo "  -dti <dti_path>                      : Path to DTI volume"
	echo "  -bvec <bvecs>                        : Path to bvecs file to use"
	echo "  -bval <bvals>                        : Path to bvals file to use"
	echo ""
	echo "Option :"
	echo "  -nb0  <NB0>                          : Number of B0s. Default = 12"
	echo "  -lmax <lmax>                         : lmax for mrtrix. Default = 8"
	echo " "
	echo "Usage: Process_mouse_DTI.sh  -dti <dti_path>  -bvec <bvecs>  -bval <bvals>  [-nb0 <NB0>  -lmax <lmax>]"
	echo ""
	exit 1
fi


index=1
lmax=8
NB0=12

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Process_mouse_DTI.sh  -dti <dti_path>  -bvec <bvecs>  -bval <bvals>  [-nb0 <NB0>  -lmax <lmax>]"
		echo ""
		echo "  -dti <dti_path>                      : Path to DTI volume"
		echo "  -bvec <bvecs>                        : Path to bvecs file to use"
		echo "  -bval <bvals>                        : Path to bvals file to use"
		echo ""
		echo "Option :"
		echo "  -nb0  <NB0>                          : Number of B0s. Default = 12"
		echo "  -lmax <lmax>                         : lmax for mrtrix. Default = 8"
		echo " "
		echo "Usage: Process_mouse_DTI.sh  -dti <dti_path>  -bvec <bvecs>  -bval <bvals>  [-lmax <lmax>]"
		echo ""
		exit 1
		;;
	-dti)
		dti=`expr $index + 1`
		eval dti=\${$dti}
		echo "DTI volume : $dti"
		;;
	-bvec)
		bvecs=`expr $index + 1`
		eval bvecs=\${$bvecs}
		echo "bvecs : $bvecs"
		;;
	-bval)
		bvals=`expr $index + 1`
		eval bvals=\${$bvals}
		echo "bvals : $bvals"
		;;
	-lmax)
		lmax=`expr $index + 1`
		eval lmax=\${$lmax}
		echo "lmax : $lmax"
		;;
	-nb0)
		NB0=`expr $index + 1`
		eval NB0=\${$NB0}
		echo "NB0 : $NB0"
		;;
	-*)
		Arg=`expr $index`
		eval Arg=\${$Arg}
		echo "Unknown argument ${Arg}"
		echo ""
		echo "Usage: Process_mouse_DTI.sh  -dti <dti_path>  -bvec <bvecs>  -bval <bvals>  [-nb0 <NB0>  -lmax <lmax>]"
		echo ""
		echo "  -dti <dti_path>                      : Path to DTI volume"
		echo "  -bvec <bvecs>                        : Path to bvecs file to use"
		echo "  -bval <bvals>                        : Path to bvals file to use"
		echo ""
		echo "Option :"
		echo "  -nb0  <NB0>                          : Number of B0s. Default = 12"
		echo "  -lmax <lmax>                         : lmax for mrtrix. Default = 8"
		echo " "
		echo "Usage: Process_mouse_DTI.sh  -dti <dti_path>  -bvec <bvecs>  -bval <bvals>  [-lmax <lmax>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


# Set some variables
outdir=`dirname ${dti}`


# Eddy correct
echo "eddy_correct ${dti} ${outdir}/raw_dti_eddycor 0"
eddy_correct ${dti} ${outdir}/raw_dti_eddycor 0

# Average B0s and suppress useless vols
echo "fslsplit ${outdir}/raw_dti_eddycor ${outdir}/temp_vols -t"
fslsplit ${outdir}/raw_dti_eddycor ${outdir}/temp_vols -t

command_line="fslmaths ${outdir}/temp_vols0000.nii.gz"
k=1
while [ $k -lt ${NB0} ]
do
	vol_n=`printf "%.4d" $k`
	command_line="${command_line} -add ${outdir}/temp_vols${vol_n}.nii.gz"
	k=$[${k}+1]
done

command_line="${command_line} -div ${NB0} ${outdir}/mean_b0"
echo "${command_line}"
eval ${command_line}

k=0
while [ $k -lt ${NB0} ]
do
	vol_n=`printf "%.4d" $k`
	echo "rm -f ${outdir}/temp_vols${vol_n}.nii.gz"
	rm -f ${outdir}/temp_vols${vol_n}.nii.gz
	k=$[${k}+1]
done

# Concat remaining vols
echo "fslmerge -t ${outdir}/dti_ready ${outdir}/mean_b0 ${outdir}/temp_vols*"
fslmerge -t ${outdir}/dti_ready ${outdir}/mean_b0 ${outdir}/temp_vols*

# Remove temp files
rm -f ${outdir}/temp_vols*

# Convert bvals & bvecs to mrtrix format
cp ${bvecs} ${outdir}/temp.txt
cat ${bvals} >> ${outdir}/temp.txt

matlab -nodisplay <<EOF
bvecs_to_mrtrix('${outdir}/temp.txt', '${outdir}/bvecs_mrtrix');
EOF

rm -f ${outdir}/temp.txt

# Create a fake brain mask
echo "fslroi ${outdir}/dti_ready ${outdir}/temp 0 1"
fslroi ${outdir}/dti_ready ${outdir}/temp 0 1

echo "fslmaths ${outdir}/temp -div ${outdir}/temp ${outdir}/dti_ready_mask"
fslmaths ${outdir}/temp -div ${outdir}/temp ${outdir}/dti_ready_mask

rm -f ${outdir}/temp.nii.gz

# gunzip & convert images
gunzip -f ${outdir}/dti_ready.nii.gz ${outdir}/dti_ready_mask.nii.gz

echo "mrconvert ${outdir}/dti_ready.nii ${outdir}/dti_ready.mif"
mrconvert ${outdir}/dti_ready.nii ${outdir}/dti_ready.mif

echo "mrconvert ${outdir}/dti_ready_mask.nii ${outdir}/dti_ready_mask.mif"
mrconvert ${outdir}/dti_ready_mask.nii ${outdir}/dti_ready_mask.mif

# gzip .nii
echo "gzip -f ${outdir}/*.nii"
gzip -f ${outdir}/*.nii

# Calculate tensors
echo "dwi2tensor ${outdir}/dti_ready.mif -grad ${outdir}/bvecs_mrtrix ${outdir}/dt.mif"
dwi2tensor ${outdir}/dti_ready.mif -grad ${outdir}/bvecs_mrtrix ${outdir}/dt.mif

# Calculate FA
echo "tensor2FA ${outdir}/dt.mif ${outdir}/fa.mif"
tensor2FA ${outdir}/dt.mif ${outdir}/fa.mif

# Extract highly anisotropic voxel to estimate the response
echo "erode ${outdir}/dti_ready_mask.mif - | erode - - | mrmult ${outdir}/fa.mif - - | threshold - -abs 0.7 ${outdir}/sf.mif"
erode ${outdir}/dti_ready_mask.mif - | erode - - | mrmult ${outdir}/fa.mif - - | threshold - -abs 0.7 ${outdir}/sf.mif

echo "estimate_response ${outdir}/dti_ready.mif -grad ${outdir}/bvecs_mrtrix ${outdir}/sf.mif -lmax ${lmax} ${outdir}/response.txt"
estimate_response ${outdir}/dti_ready.mif -grad ${outdir}/bvecs_mrtrix ${outdir}/sf.mif -lmax ${lmax} ${outdir}/response.txt

# Constrained spherical deconvolution
echo "csdeconv ${outdir}/dti_ready.mif -grad ${outdir}/bvecs_mrtrix ${outdir}/response.txt -lmax ${lmax} -mask ${outdir}/dti_ready_mask.mif ${outdir}/CSD${lmax}.mif"
csdeconv ${outdir}/dti_ready.mif -grad ${outdir}/bvecs_mrtrix ${outdir}/response.txt -lmax ${lmax} -mask ${outdir}/dti_ready_mask.mif ${outdir}/CSD${lmax}.mif
