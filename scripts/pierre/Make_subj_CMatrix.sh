#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Make_subj_CMatrix.sh  -fs  <SubjDir>  -subj  <SubjName>  -parcname  <parcellation.annot>  -fib  <MedINRIA_fibers>  -outdir  <outputDirectory>  -dti  <dti_eddy_corr>"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -parcname ParcName           : Name of the fsaverage parcellation to use"
	echo "  -fib MedINRIA_fibers         : Path to MedINIRIA fibers .fib"
	echo "  -outdir outputDirectory      : Output directory"
	echo "  -dti dti_eddy_corr           : DTI eddy corrected volume .nii or .nii.gz"
	echo ""
	echo "Usage: Make_subj_CMatrix.sh  -fs  <SubjDir>  -subj  <SubjName>  -parcname  <parcellation.annot>  -fib  <MedINRIA_fibers>  -outdir  <outputDirectory>  -dti  <dti_eddy_corr>"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Make_subj_CMatrix.sh  -fs  <SubjDir>  -subj  <SubjName>  -parcname  <parcellation.annot>  -fib  <MedINRIA_fibers>  -outdir  <outputDirectory>  -dti  <dti_eddy_corr>"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -parcname ParcName           : Name of the fsaverage parcellation to use"
		echo "  -fib MedINRIA_fibers         : Path to MedINIRIA fibers .fib"
		echo "  -outdir outputDirectory      : Output directory"
		echo "  -dti dti_eddy_corr           : DTI eddy corrected volume .nii or .nii.gz"
		echo ""
		echo "Usage: Make_subj_CMatrix.sh  -fs  <SubjDir>  -subj  <SubjName>  -parcname  <parcellation.annot>  -fib  <MedINRIA_fibers>  -outdir  <outputDirectory>  -dti  <dti_eddy_corr>"
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
	-fib)
		fib=`expr $index + 1`
		eval fib=\${$fib}
		echo "  |-------> Fibers File : ${fib}"
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

# if [ ! -e ${fsav}/label/${parcname}.ctab ]
# then
# 	echo "Can not find color table ${fsav}/label/${parcname}.ctab"
# 	exit 1
# fi

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
echo ""
echo "--------------------------------------------------"
echo "Align T1 on DTI"
echo "NlFit_t1_to_b0.sh -source ${T1} -target ${dti} -o ${NLdir}"
do_cmd 1 ${outdir}/t1_to_dti_nlin.touch NlFit_t1_to_b0.sh -source ${T1} -target ${dti} -o ${NLdir}

# Step 3. Register WM surface on DTI
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

% Save unshiffted surface
%T1_nii = load_nifti('${MDIR}/t1_to_dti_nlin.nii');
%Mat = inv(T1_nii.vox2ras);
%Mat = Mat(1:3, 4);
%Surf_nlin.coord(1,:) = Surf_nlin.coord(1,:) - Mat(1);
%Surf_nlin.coord(2,:) = Surf_nlin.coord(2,:) - Mat(2);
% Surf_nlin.coord(3,:) = Surf_nlin.coord(3,:) - Mat(3);
%Surf_nlin.coord(3,:) = Surf_nlin.coord(3,:) - T1_nii.quatern_z;
%save_surface_vtk(Surf_nlin, '${MDIR}/lh.white_nlin_centre.vtk', 'ASCII', Feat);

Surf = SurfStatReadSurf('${DIR}/surf/rh.white');
Surf_nlin = tag_to_surf(Surf, '${outdir}/rh_to_dti_nlin.tag');
SurfStatWriteSurf('${outdir}/rh.white_nlin.obj', Surf_nlin);
save_surface_vtk(Surf_nlin, '${outdir}/rh.white_nlin.vtk');

% Save unshiffted surface
%Surf_nlin.coord(1,:) = Surf_nlin.coord(1,:) - T1_nii.quatern_x + 128;
%Surf_nlin.coord(2,:) = Surf_nlin.coord(2,:) - T1_nii.quatern_y + 128;
%Surf_nlin.coord(3,:) = Surf_nlin.coord(3,:) - T1_nii.quatern_z + 128;
%save_surface_vtk(Surf_nlin, '${MDIR}/rh.white_nlin_centre.vtk', 'ASCII', Feat);

EOF
echo ""

rm -f ${outdir}/lh.tag ${outdir}/rh.tag ${outdir}/lh_to_dti_nlin.tag ${outdir}/rh_to_dti_nlin.tag

# Get parcellation stats
echo "mris_anatomical_stats -mgz -f ${outdir}/lh.${parcname%.annot}.stats -b -a ${DIR}/label/lh.${parcname} -c ${DIR}/label/${parcname}.ctab ${subj} lh"
mris_anatomical_stats -mgz -f ${outdir}/lh.${parcname%.annot}.stats -b -a ${DIR}/label/lh.${parcname} -c ${DIR}/label/${parcname}.ctab ${subj} lh

echo "mris_anatomical_stats -mgz -f ${outdir}/rh.${parcname%.annot}.stats -b -a ${DIR}/label/rh.${parcname} -c ${DIR}/label/${parcname}.ctab ${subj} rh"
mris_anatomical_stats -mgz -f ${outdir}/rh.${parcname%.annot}.stats -b -a ${DIR}/label/rh.${parcname} -c ${DIR}/label/${parcname}.ctab ${subj} rh

# Construct connectivity Matrix !! :o)
echo " "
echo "---------------------------------"
echo "Construct connectivity matrix"
echo "Connectome = getSurfaceConnectMatrix(${outdir}/lh.white_nlin.obj, ${outdir}/rh.white_nlin.obj, ${DIR}/label/lh.${parcname}, ${DIR}/label/rh.${parcname}, ${outdir}/lh.${parcname%.annot}.stats, ${outdir}/rh.${parcname%.annot}.stats, ${fib});"
matlab -nodisplay <<EOF
cd ${HOME}
p = pathdef;
addpath(p);
cd ${outdir}
Connectome = getSurfaceConnectMatrix('${outdir}/lh.white_nlin.obj', '${outdir}/rh.white_nlin.obj', '${DIR}/label/lh.${parcname}', '${DIR}/label/rh.${parcname}', '${outdir}/lh.${parcname%.annot}.stats', '${outdir}/rh.${parcname%.annot}.stats', '${fib}');
[Connectome.M, Connectome.distance, Connectome.areas] = connectome2matrix(Connectome);
save Connectome_${subj} Connectome
EOF
