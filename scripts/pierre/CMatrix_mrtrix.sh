#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: CMatrix_mrtrix.sh  -fs  <SubjDir>  -subj  <SubjName>  -parcname  <parcellation.annot>  -dti  <dti_eddy_corr>  -bvecs <bvecs>  -bvals <bvals>  -outdir  <outputDirectory>  [-lmax <lmax>  -vs <size_x> <size_y> <size_z>  -N <Nfiber> -no_CM]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -parcname ParcName           : Name of the fsaverage parcellation to use"
	echo "  -dti dti_eddy_corr           : DTI eddy corrected volume .nii or .nii.gz"
	echo "  -bvecs bvecs                 : Path to the bvecs file"
	echo "  -bvals bvals                 : Path to the bvals file"
	echo "  -outdir outputDirectory      : Output directory"
	echo " "
	echo "Options :"
	echo "  -lmax lmax                   : Maximum harmonic order (default : 8)"
	echo "  -vs size_x size_y size_z     : Voxel size of DWI supersampling (default : 1 1 1)"
	echo "  -N Nfiber                    : Number of fibers (default : 150000)"
	echo "  -no_CM                       : does not produce the connectivity matrix"
	echo ""
	echo "Usage: CMatrix_mrtrix.sh  -fs  <SubjDir>  -subj  <SubjName>  -parcname  <parcellation.annot>  -dti  <dti_eddy_corr>  -bvecs <bvecs>  -bvals <bvals>  -outdir  <outputDirectory>  [-lmax <lmax>  -vs <size_x> <size_y> <size_z>  -N <Nfiber> -no_CM]"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
lmax=8
size_x=1
size_y=1
size_z=1
Nfiber=150000
no_CM=0
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: CMatrix_mrtrix.sh  -fs  <SubjDir>  -subj  <SubjName>  -parcname  <parcellation.annot>  -dti  <dti_eddy_corr>  -bvecs <bvecs>  -bvals <bvals>  -outdir  <outputDirectory>  [-lmax <lmax>  -vs <size_x> <size_y> <size_z>  -N <Nfiber> -no_CM]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -parcname ParcName           : Name of the fsaverage parcellation to use"
		echo "  -dti dti_eddy_corr           : DTI eddy corrected volume .nii or .nii.gz"
		echo "  -bvecs bvecs                 : Path to the bvecs file"
		echo "  -bvals bvals                 : Path to the bvals file"
		echo "  -outdir outputDirectory      : Output directory"
		echo " "
		echo "Options :"
		echo "  -lmax lmax                   : Maximum harmonic order (default : 8)"
		echo "  -vs size_x size_y size_z     : Voxel size of DWI supersampling (default : 1 1 1)"
		echo "  -N Nfiber                    : Number of fibers (default : 150000)"
		echo "  -no_CM                       : does not produce the connectivity matrix"
		echo ""
		echo "Usage: CMatrix_mrtrix.sh  -fs  <SubjDir>  -subj  <SubjName>  -parcname  <parcellation.annot>  -dti  <dti_eddy_corr>  -bvecs <bvecs>  -bvals <bvals>  -outdir  <outputDirectory>  [-lmax <lmax>  -vs <size_x> <size_y> <size_z>  -N <Nfiber> -no_CM]"
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-parcname)
		parcname=`expr $index + 1`
		eval parcname=\${$parcname}
		echo "  |-------> Parcellation Name : ${parcname}"
		index=$[$index+1]
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-outdir)
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo "  |-------> Output directory : ${outdir}"
		index=$[$index+1]
		;;
	-dti)
		dti=`expr $index + 1`
		eval dti=\${$dti}
		echo "  |-------> DTI : ${dti}"
		index=$[$index+1]
		;;
	-bvecs)
		bvecs=`expr $index + 1`
		eval bvecs=\${$bvecs}
		echo "  |-------> bvecs : ${bvecs}"
		index=$[$index+1]
		;;
	-bvals)
		bvals=`expr $index + 1`
		eval bvals=\${$bvals}
		echo "  |-------> bvals : ${bvals}"
		index=$[$index+1]
		;;
	-lmax)
		lmax=`expr $index + 1`
		eval lmax=\${$lmax}
		echo "  |-------> Optional lmax : ${lmax}"
		index=$[$index+1]
		;;
	-vs)
		size_x=`expr $index + 1`
		eval size_x=\${$size_x}
		size_y=`expr $index + 2`
		eval size_y=\${$size_y}
		size_z=`expr $index + 3`
		eval size_z=\${$size_z}
		echo "  |-------> Optional vs : ${size_x} ${size_y} ${size_z}"
		index=$[$index+3]
		;;
	-N)
		Nfiber=`expr $index + 1`
		eval Nfiber=\${$Nfiber}
		echo "  |-------> Optional N : ${Nfiber}"
		index=$[$index+1]
		;;
	-no_CM)
		no_CM=1
		echo "  |-------> no_CM activated"
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


# Check arguments
fsav=${fs}/fsaverage/
if [ ! -e ${fsav}/label/lh.${parcname} ]
then
	echo "Can not find parcellation file ${fsav}/label/lh.${parcname}"
	exit 1
fi
 
if [ ! -e ${fsav}/label/rh.${parcname} ]
then
	echo "Can not find parcellation file ${fsav}/label/rh.${parcname}"
	exit 1
fi

if [ ! -e ${fib} ]
then
	echo "Can not find ${fib}"
	exit 1
fi

if [ ! -e ${fs}/${subj} ]
then
	echo "Can not find ${fs}/${subj} directory"
	exit 1
fi

if [ ! -e ${dti} ]
then
	echo "Can not find ${dti}"
	exit 1
fi

if [ ! -e ${bvecs} ]
then
	echo "Can not find ${bvecs}"
	exit 1
fi

if [ ! -e ${bvals} ]
then
	echo "Can not find ${bvals}"
	exit 1
fi


# Set some paths
DIR=${fs}/${subj}/
SUBJECTS_DIR=${fs}
LOG=${outdir}/Get_matrix.log

# Creates output dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

if [ ! -d ${outdir}/nl_transform ]
then
	mkdir ${outdir}/nl_transform
fi

NLdir=${outdir}/nl_transform

# Remove Log file
if [ -e ${LOG} ]
then
	rm -f ${LOG}
fi

# Import T1
mri_convert ${DIR}/mri/T1.mgz ${outdir}/t1_ras.nii --out_orientation RAS >> ${LOG}
T1=${outdir}/t1_ras.nii


# Step 1. Subject's surface parcellation [matlab]
if [ ! -e ${DIR}/label/lh.${parcname} ]
then
	echo ""
	echo "--------------------------------------------------"
	echo "Parcellating surface"
	matlab -nodisplay <<EOF
	cd ${HOME}
	p = pathdef;
	addpath(p);
	Template2Indiv('${fs}', '${subj}', '${parcname}');
EOF
	echo ""
fi

# Step 2. Align T1 on DTI
# Supersample DWI vols
echo ""
echo "--------------------------------------------------"
echo "Supersample DWI"
echo "mri_convert ${dti} ${outdir}/dti_supersampled.nii -vs ${size_x} ${size_y} ${size_z} -rt cubic"
do_cmd 1 ${outdir}/dwi_supersampling.touch mri_convert ${dti} ${outdir}/dti_supersampled.nii -vs ${size_x} ${size_y} ${size_z} -rt cubic
dti=${outdir}/dti_supersampled.nii

# Step 2.2. Performs alignment
echo ""
echo "--------------------------------------------------"
echo "Align T1 on DTI"
echo "NlFit_t1_to_b0.sh -source ${T1} -target ${dti} -o ${NLdir}"
do_cmd 1 ${outdir}/t1_to_dti_nlin.touch NlFit_t1_to_b0.sh -source ${T1} -target ${dti} -o ${NLdir} -no16

# Step 3. Register WM surfaces on DTI
matlab -nodisplay <<EOF
cd ${HOME}
p = pathdef;
addpath(p);
cd ${MDIR}
T1_nii = load_nifti('${T1}');
Surf = SurfStatReadSurf('${DIR}/surf/lh.white');
Surf_RAS = surf_to_ras_nii(Surf, T1_nii);
surf_to_tag(Surf_RAS, '${outdir}/lh.tag');
Surf = SurfStatReadSurf('${DIR}/surf/rh.white');
Surf_RAS = surf_to_ras_nii(Surf, T1_nii);
surf_to_tag(Surf_RAS, '${outdir}/rh.tag');
EOF
echo ""

echo "transform_tags  ${outdir}/lh.tag  ${NLdir}/source_to_target_nlin.xfm  ${outdir}/lh_to_dti_nlin.tag"
transform_tags  ${outdir}/lh.tag  ${NLdir}/source_to_target_nlin.xfm  ${outdir}/lh_to_dti_nlin.tag
echo "transform_tags  ${outdir}/rh.tag  ${NLdir}/source_to_target_nlin.xfm  ${outdir}/rh_to_dti_nlin.tag"
transform_tags  ${outdir}/rh.tag  ${NLdir}/source_to_target_nlin.xfm  ${outdir}/rh_to_dti_nlin.tag

matlab -nodisplay <<EOF
cd ${HOME}
p = pathdef;
addpath(p);
cd ${outdir}
Surf = SurfStatReadSurf('${DIR}/surf/lh.white');
Surf_nlin = tag_to_surf(Surf, '${outdir}/lh_to_dti_nlin.tag');
SurfStatWriteSurf('${outdir}/lh.white_nlin.obj', Surf_nlin);
save_surface_vtk(Surf_nlin, '${outdir}/lh.white_nlin.vtk');

Surf = SurfStatReadSurf('${DIR}/surf/rh.white');
Surf_nlin = tag_to_surf(Surf, '${outdir}/rh_to_dti_nlin.tag');
SurfStatWriteSurf('${outdir}/rh.white_nlin.obj', Surf_nlin);
save_surface_vtk(Surf_nlin, '${outdir}/rh.white_nlin.vtk');

EOF
echo ""

rm -f ${outdir}/lh.tag ${outdir}/rh.tag ${outdir}/lh_to_dti_nlin.tag ${outdir}/rh_to_dti_nlin.tag

# Performs tractography
if [ ! -e ${outdir}/tractography.touch ]
then
	# WM mask
	echo "bet ${outdir}/dti_supersampled.nii ${outdir}/dti_supersampled_brain  -f 0.2 -g 0 -m"
	bet ${outdir}/dti_supersampled.nii ${outdir}/dti_supersampled_brain  -f 0.2 -g 0 -m
	
	rm -f ${outdir}/dti_supersampled_brain.nii.gz
	
	gunzip ${outdir}/dti_supersampled_brain_mask.nii.gz
	
	# Convert images to .mif
	dti_mif=${dti%.nii}.mif
	mask_mif=${outdir}/dti_supersampled_brain_mask.mif
	rm -f ${dti_mif} ${mask_mif}
	echo "mrconvert ${dti} ${dti_mif}"
	mrconvert ${dti} ${dti_mif}
	echo "mrconvert ${outdir}/dti_supersampled_brain_mask.nii ${mask_mif}"
	mrconvert ${outdir}/dti_supersampled_brain_mask.nii ${mask_mif}
	
	# Prepare bvecs
	cp ${bvecs} ${outdir}/temp.txt
	cat ${bvals} >> ${outdir}/temp.txt

matlab -nodisplay <<EOF
cd ${HOME}
p = pathdef;
addpath(p);
cd ${outdir}
bvecs_to_mrtrix('${outdir}/temp.txt', '${outdir}/bvecs_mrtrix');
EOF

	rm -f ${outdir}/temp.txt
	bvecs_mrtrix=${outdir}/bvecs_mrtrix
	
	# Calculate tensors
	rm -f ${outdir}/dt.mif
	echo "dwi2tensor ${dti_mif} -grad ${bvecs_mrtrix} ${outdir}/dt.mif"
	dwi2tensor ${dti_mif} -grad ${bvecs_mrtrix} ${outdir}/dt.mif
	
	# Calculate FA
	rm -f ${outdir}/fa.mif
	echo "tensor2FA ${outdir}/dt.mif - | mrmult - ${mask_mif} ${outdir}/fa.mif"
	tensor2FA ${outdir}/dt.mif - | mrmult - ${mask_mif} ${outdir}/fa.mif
	
	# Calculate highly anisotropic voxels
	rm -f ${outdir}/sf.mif
	echo "erode ${mask_mif} - | erode - - | mrmult ${outdir}/fa.mif - - | threshold - -abs 0.7 ${outdir}/sf.mif"
	erode ${mask_mif} - | erode - - | mrmult ${outdir}/fa.mif - - | threshold - -abs 0.7 ${outdir}/sf.mif
	
	# Estimate response function
	echo "estimate_response ${dti_mif} -grad ${bvecs_mrtrix} ${outdir}/sf.mif -lmax ${lmax} ${outdir}/response.txt"
	estimate_response ${dti_mif} -grad ${bvecs_mrtrix} ${outdir}/sf.mif -lmax ${lmax} ${outdir}/response.txt
	
	touch ${outdir}/tractography.touch
fi

# Constrained spherical deconvolution
do_cmd 1 ${outdir}/csdeconv${lmax}.touch csdeconv ${dti_mif} -grad ${bvecs_mrtrix} ${outdir}/response.txt -lmax ${lmax} -mask ${mask_mif} ${outdir}/CSD${lmax}.mif

# Whole brain tractography
# total_fiber=`fslstats ${dti%.nii}_brain_mask.nii -V | awk '{print $1}'`
# total_fiber=`echo "${Nfiber} * ${total_fiber}" | bc -l`
# total_fiber=`cat ${DIR}/stats/aseg.stats | grep "Total cortical white matter" | awk '{print $10}'`
# total_fiber=${total_fiber%,}
# total_fiber=`echo "int(${Nfiber} * ${total_fiber})" | bc2 -l`
do_cmd 1 ${outdir}/streamstack_${lmax}_${Nfiber}.touch streamtrack SD_PROB ${outdir}/CSD${lmax}.mif -seed ${mask_mif} -mask ${mask_mif} ${outdir}/whole_brain_${lmax}_${Nfiber}.tck -num ${Nfiber}


# Get parcellation stats
echo "mris_anatomical_stats -mgz -f ${outdir}/lh.${parcname%.annot}.stats -b -a ${DIR}/label/lh.${parcname} -c ${DIR}/label/${parcname}.ctab ${subj} lh"
mris_anatomical_stats -mgz -f ${outdir}/lh.${parcname%.annot}.stats -b -a ${DIR}/label/lh.${parcname} -c ${DIR}/label/${parcname}.ctab ${subj} lh

echo "mris_anatomical_stats -mgz -f ${outdir}/rh.${parcname%.annot}.stats -b -a ${DIR}/label/rh.${parcname} -c ${DIR}/label/${parcname}.ctab ${subj} rh"
mris_anatomical_stats -mgz -f ${outdir}/rh.${parcname%.annot}.stats -b -a ${DIR}/label/rh.${parcname} -c ${DIR}/label/${parcname}.ctab ${subj} rh

if [ ${no_CM} -eq 0 ]
then
# Construct connectivity Matrix !! :o)
echo " "
echo "---------------------------------"
echo "Construct connectivity matrix"
echo "Connectome = getSurfaceConnectMatrix(${outdir}/lh.white_nlin.obj, ${outdir}/rh.white_nlin.obj, ${DIR}/label/lh.${parcname}, ${DIR}/label/rh.${parcname}, ${outdir}/lh.${parcname%.annot}.stats, ${outdir}/rh.${parcname%.annot}.stats, ${outdir}/whole_brain_${lmax}_${Nfiber}.tck);"
matlab -nodisplay <<EOF
cd ${HOME}
p = pathdef;
addpath(p);
cd ${outdir}
Connectome = getSurfaceConnectMatrix('${outdir}/lh.white_nlin.obj', '${outdir}/rh.white_nlin.obj', '${DIR}/label/lh.${parcname}', '${DIR}/label/rh.${parcname}', '${outdir}/lh.${parcname%.annot}.stats', '${outdir}/rh.${parcname%.annot}.stats', '${outdir}/whole_brain_${lmax}_${Nfiber}.tck');
[Connectome.M, Connectome.distance, Connectome.areas] = connectome2matrix(Connectome);
save Connectome_${subj} Connectome -v7.3
EOF
fi
