#!/bin/bash

if [ $# -ne 4 ]
then
	echo ""
	echo "Usage: SubsampleSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-nosubc]"
	echo ""
	echo "  -fs  <SubjDir>               : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj  <SubjName>            : Subject ID"
	echo " "
	echo "This script processes the downsampling of the Connectomes associated with the following structures :"
	echo "   Cortex        : SubjDir/SubjName/dti/Connectome.mat"
	echo "   Accumbens     : SubjDir/SubjName/dti/Connectome_Accumbens-area.mat"
	echo "   Amygdala      : SubjDir/SubjName/dti/Connectome_Amygdala.mat"
	echo "   Caudate       : SubjDir/SubjName/dti/Connectome_Caudate.mat"
	echo "   Hippocampus   : SubjDir/SubjName/dti/Connectome_Hippocampus.mat"
	echo "   Pallidum      : SubjDir/SubjName/dti/Connectome_Pallidum.mat"
	echo "   Putamen       : SubjDir/SubjName/dti/Connectome_Putamen.mat"
	echo "   Thalamus      : SubjDir/SubjName/dti/Connectome_Thalamus-Proper.mat"
	echo " "
	echo "For the cortex, the source spherical registration used is SubjDir/SubjName/surf/*h.sphere.reg"
	echo "   whereas for subcortical structures it is SubjDir/SubjName/*-StructName/*h.sphere.reg"
	echo " "
	echo "For the cortex, the target spherical registration used is fsaverage5/surf/*h.sphere.reg"
	echo "   and for subcortical structures ~/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET/subcort.sphere.reg"
	echo " "
	echo "Downsampled connectomes are saved in SubjDir/SubjName/connectome/"
	echo ""
	echo "Usage: SubsampleSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-nosubc]"
	exit 1
fi


#### Inputs ####
index=1
doSUBC="1"
echo "------------------------"

# Set up some variables
struc_name="Accumbens-area Amygdala Caudate Hippocampus Pallidum Putamen Thalamus-Proper"
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: SubsampleSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-nosubc]"
		echo ""
		echo "  -fs  <SubjDir>               : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj  <SubjName>            : Subject ID"
		echo " "
		echo "This script processes the downsampling of the Connectomes associated with the following structures :"
		echo "   Cortex        : SubjDir/SubjName/dti/Connectome.mat"
		echo "   Accumbens     : SubjDir/SubjName/dti/Connectome_Accumbens-area.mat"
		echo "   Amygdala      : SubjDir/SubjName/dti/Connectome_Amygdala.mat"
		echo "   Caudate       : SubjDir/SubjName/dti/Connectome_Caudate.mat"
		echo "   Hippocampus   : SubjDir/SubjName/dti/Connectome_Hippocampus.mat"
		echo "   Pallidum      : SubjDir/SubjName/dti/Connectome_Pallidum.mat"
		echo "   Putamen       : SubjDir/SubjName/dti/Connectome_Putamen.mat"
		echo "   Thalamus      : SubjDir/SubjName/dti/Connectome_Thalamus-Proper.mat"
		echo " "
		echo "For the cortex, the source spherical registration used is SubjDir/SubjName/surf/*h.sphere.reg"
		echo "   whereas for subcortical structures it is SubjDir/SubjName/*-StructName/*h.sphere.reg"
		echo " "
		echo "For the cortex, the target spherical registration used is fsaverage5/surf/*h.sphere.reg"
		echo "   and for subcortical structures ~/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET/subcort.sphere.reg"
		echo " "
		echo "Downsampled connectomes are saved in SubjDir/SubjName/connectome/"
		echo ""
		echo "Usage: SubsampleSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-nosubc]"
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-nosubc)
		doSUBC="0"
		echo "Do not subcortical subsampling"
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
# Set some vars
out_dir=${fs}/${subj}/connectome
#ref_dir=/NAS/notorious/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET
ref_dir=/NAS/dumbo/renaud/templates/SUBSAMPLED_SURFACE_TARGET

# Check args
if [ ! -d ${out_dir} ]
then
	mkdir ${out_dir}
fi

# Launch matlab to downsample cortical connectome
if [ -e ${fs}/${subj}/dti/Connectome.mat -a ! -e ${out_dir}/Connectome_rsl.mat ]
then

echo "Processing Cortical Connectome"

matlab -nodisplay <<EOF

load ${fs}/${subj}/dti/Connectome.mat
surf_lh = SurfStatReadSurf('${fs}/${subj}/surf/lh.sphere.reg');
surf_rh = SurfStatReadSurf('${fs}/${subj}/surf/rh.sphere.reg');
n_lh = length(surf_lh.tri);

Connectome.n_tri_lh = length(surf_lh.tri);
Connectome.n_tri_rh = length(surf_rh.tri);

selected = sparse(Connectome.i+1, Connectome.j+1, ones(size(Connectome.i)), Connectome.nx, Connectome.ny);
selected = selected';
n_f      = size(selected, 2);

% compute overlaps
temp = srf2srf('areal', '${fs}/${subj}/surf/lh.sphere.reg', '${ref_dir}/lh.sphere.reg', '${out_dir}/lh.overlaps', selected(1:n_lh, 1));
clear temp;
temp = srf2srf('areal', '${fs}/${subj}/surf/rh.sphere.reg', '${ref_dir}/rh.sphere.reg', '${out_dir}/rh.overlaps', selected(n_lh+1:end, 1));
clear temp;

% Apply overlaps
temp  = applyolp_tmp('${out_dir}/lh.overlaps', '${ref_dir}/lh.sphere.reg', selected(1:n_lh, :));
temp  = temp(:, end-n_f+1 : end);
temp2 = applyolp_tmp('${out_dir}/rh.overlaps', '${ref_dir}/rh.sphere.reg', selected(n_lh+1:end, :));
temp2 = temp2(:, end-n_f+1 : end);

surf_lh = SurfStatReadSurf('${ref_dir}/lh.sphere.reg');
surf_rh = SurfStatReadSurf('${ref_dir}/rh.sphere.reg');

selected_rsl = [temp; temp2]';
Connectome.selected_rsl = selected_rsl;
Connectome.n_tri_rsl_lh = length(surf_lh.tri);
Connectome.n_tri_rsl_rh = length(surf_rh.tri);
save ${out_dir}/Connectome_rsl.mat Connectome -v7.3
EOF

else
	if [ ! -e ${fs}/${subj}/dti/Connectome.mat ]
	then
		echo "Connectome not found for Cortex"
	fi
	
	if [ -e ${out_dir}/Connectome_rsl.mat ]
	then
		echo "Cortical connectome already processed"
	fi
fi

# subcortical structures
if [ ${doSUBC} -eq "1" ]; then

echo "Do subcortical subsampling"

for struc in `echo ${struc_name}`
do
	if [ -e ${fs}/${subj}/dti/Connectome_${struc}.mat -a -e ${fs}/${subj}/Left-${struc}/lh.sphere.reg -a -e ${fs}/${subj}/Right-${struc}/lh.sphere.reg -a ! -e ${out_dir}/Connectome_rsl_${struc}.mat ]
	then
		echo "Processing Connectome for : ${struc}"
		left_surf=${fs}/${subj}/Left-${struc}/lh.sphere.reg
		right_surf=${fs}/${subj}/Right-${struc}/lh.sphere.reg
		targ_surf=${ref_dir}/subcort.sphere.reg
		c_sub=${fs}/${subj}/dti/Connectome_${struc}.mat
		lh_olp=${out_dir}/lh.overlaps.${struc}
		rh_olp=${out_dir}/rh.overlaps.${struc}
		
matlab -nodisplay <<EOF

load ${c_sub}
surf_lh = SurfStatReadSurf('${left_surf}');
surf_rh = SurfStatReadSurf('${right_surf}');
n_lh = length(surf_lh.tri);

Connectome.n_tri_lh = length(surf_lh.tri);
Connectome.n_tri_rh = length(surf_rh.tri);

selected = sparse(Connectome.i+1, Connectome.j+1, ones(size(Connectome.i)), Connectome.nx, Connectome.ny);
selected = selected';
n_f      = size(selected, 2);

% compute overlaps
temp = srf2srf('areal', '${left_surf}', '${targ_surf}', '${lh_olp}', selected(1:n_lh, 1));
clear temp;
temp = srf2srf('areal', '${right_surf}', '${targ_surf}', '${rh_olp}', selected(n_lh+1:end, 1));
clear temp;

% Apply overlaps
temp  = applyolp_tmp('${lh_olp}', '${targ_surf}', selected(1:n_lh, :));
temp  = temp(:, end-n_f+1 : end);
temp2 = applyolp_tmp('${rh_olp}', '${targ_surf}', selected(n_lh+1:end, :));
temp2 = temp2(:, end-n_f+1 : end);

surf_lh = SurfStatReadSurf('${targ_surf}');

selected_rsl = [temp; temp2]';
Connectome.selected_rsl = selected_rsl;
Connectome.n_tri_rsl_lh = length(surf_lh.tri);
Connectome.n_tri_rsl_rh = Connectome.n_tri_rsl_lh;
save ${out_dir}/Connectome_rsl_${struc}.mat Connectome -v7.3
EOF

		
	else
		if [ ! -e ${fs}/${subj}/dti/Connectome_${struc}.mat ]
		then
			echo "No Connectome found for : ${struc}"
		fi
		
		if [ -e ${out_dir}/Connectome_rsl_${struc}.mat ]
		then
			echo "Already processed Connectome for : ${struc}"
		fi
	fi
done

fi
