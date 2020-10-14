#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: CaudateMaskVentricle.sh  -sd <SUBJECTS_DIR> -subj <SUBJ_ID>"
	echo ""
	echo "  -sd <SUBJECTS_DIR>   : Path SUBJECTS_DIR"
	echo "  -subj <SUBJ_ID>      : Subject ID"
	echo ""
	echo "Required files :"
	echo "  SUBJECTS_DIR/SUBJ_ID/Left-Caudate/lh.white"
	echo "  SUBJECTS_DIR/SUBJ_ID/Left-Caudate/lh.sphere.reg"
	echo "  SUBJECTS_DIR/SUBJ_ID/Right-Caudate/lh.white"
	echo "  SUBJECTS_DIR/SUBJ_ID/Right-Caudate/lh.sphere.reg"
	echo ""
	echo "See also: ModelSubCorticalStruct.sh  RegisterSubCortSurface.sh"
	echo ""
	echo "Usage: CaudateMaskVentricle.sh  -sd <SUBJECTS_DIR> -subj <SUBJ_ID>"
	echo ""
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
		echo "Usage: CaudateMaskVentricle.sh  -sd <SUBJECTS_DIR> -subj <SUBJ_ID>"
		echo ""
		echo "  -sd <SUBJECTS_DIR>   : Path SUBJECTS_DIR"
		echo "  -subj <SUBJ_ID>      : Subject ID"
		echo ""
		echo "Required files :"
		echo "  SUBJECTS_DIR/SUBJ_ID/Left-Caudate/lh.white"
		echo "  SUBJECTS_DIR/SUBJ_ID/Left-Caudate/lh.sphere.reg"
		echo "  SUBJECTS_DIR/SUBJ_ID/Right-Caudate/lh.white"
		echo "  SUBJECTS_DIR/SUBJ_ID/Right-Caudate/lh.sphere.reg"
		echo ""
		echo "See also: ModelSubCorticalStruct.sh  RegisterSubCortSurface.sh"
		echo ""
		echo "Usage: CaudateMaskVentricle.sh  -sd <SUBJECTS_DIR> -subj <SUBJ_ID>"
		echo ""
		exit 1
		;;
	-sd)
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

# Check input files
DIR=${fs}/${subj}
if [ ! -e ${DIR} ]
then
	echo "Can not find ${DIR} directory"
	exit 1
fi

if [ ! -e ${DIR}/Left-Caudate/lh.white ]
then
	echo "Can not find ${DIR}/Left-Caudate/lh.white"
	exit 1
fi

if [ ! -e ${DIR}/Left-Caudate/lh.sphere.reg ]
then
	echo "Can not find ${DIR}/Left-Caudate/lh.sphere.reg"
	exit 1
fi

if [ ! -e ${DIR}/Right-Caudate/lh.white ]
then
	echo "Can not find ${DIR}/Right-Caudate/lh.white"
	exit 1
fi

if [ ! -e ${DIR}/Right-Caudate/lh.sphere.reg ]
then
	echo "Can not find ${DIR}/Right-Caudate/lh.sphere.reg"
	exit 1
fi

# Create /tmp dir and copy data
if [ -e /tmp/${subj} ]
then
	rm -rf /tmp/${subj}
fi

mkdir /tmp/${subj}
cp -R ${DIR}/mri /tmp/${subj}/

TMP=/tmp/${subj}
SUBJECTS_DIR=/tmp/

# Extract ventricles
echo "mri_extract_label ${TMP}/mri/aparc.a2009s+aseg.mgz 4 43 ${TMP}/ventricles.mgz"
mri_extract_label ${TMP}/mri/aparc.a2009s+aseg.mgz 4 43 ${TMP}/ventricles.mgz

echo "mri_convert ${TMP}/ventricles.mgz ${TMP}/ventricles_0.5.mgz -vs 0.5 0.5 0.5"
mri_convert ${TMP}/ventricles.mgz ${TMP}/ventricles_0.5.mgz -vs 0.5 0.5 0.5

echo "mri_morphology ${TMP}/ventricles_0.5.mgz dilate 1 ${TMP}/ventricles_0.5_dil.mgz"
mri_morphology ${TMP}/ventricles_0.5.mgz dilate 1 ${TMP}/ventricles_0.5_dil.mgz

echo "mri_binarize --i ${TMP}/ventricles_0.5_dil.mgz --o ${TMP}/ventricles_0.5_dil_bin.mgz --min 0.01 --max inf"
mri_binarize --i ${TMP}/ventricles_0.5_dil.mgz --o ${TMP}/ventricles_0.5_dil_bin.mgz --min 0.01 --max inf

echo "mri_convert ${TMP}/ventricles_0.5_dil_bin.mgz ${TMP}/ventricles_0.5_dil_bin_ras.nii --out_orientation RAS"
mri_convert ${TMP}/ventricles_0.5_dil_bin.mgz ${TMP}/ventricles_0.5_dil_bin_ras.nii --out_orientation RAS


# Project ventricle on left and right caudate surfaces using matlab
matlab -nodisplay <<EOF
F_lh = mapVolume2Surface('${TMP}/ventricles_0.5_dil_bin_ras.nii', '${DIR}/Left-Caudate/lh.white');
F_rh = mapVolume2Surface('${TMP}/ventricles_0.5_dil_bin_ras.nii', '${DIR}/Right-Caudate/lh.white');

SurfStatWriteData('${DIR}/Left-Caudate/lh.ventricle_v', F_lh, 'b');
SurfStatWriteData('${DIR}/Right-Caudate/lh.ventricle_v', F_rh, 'b');

% Convert vertex-wise data to triangle-wise data
Surf_lh = SurfStatReadSurf('${DIR}/Left-Caudate/lh.white');
Surf_rh = SurfStatReadSurf('${DIR}/Right-Caudate/lh.white');

TT = F_lh(Surf_lh.tri);
TT = mean(TT, 2);
F_lh = TT;
save ${DIR}/Left-Caudate/lh.ventricle_t.mat F_lh

TT = F_rh(Surf_rh.tri);
TT = mean(TT, 2);
F_rh = TT;
save ${DIR}/Right-Caudate/lh.ventricle_t.mat F_rh

EOF

ref_dir=${HOME}/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET

# Check if triangulation overlaps were not pre-computed
if [ ! -e ${DIR}/connectome ]
then
	mkdir ${DIR}/connectome
fi
out_dir=${DIR}/connectome

left_surf=${DIR}/Left-Caudate/lh.sphere.reg
right_surf=${DIR}/Right-Caudate/lh.sphere.reg
targ_surf=${ref_dir}/subcort.sphere.reg
lh_olp=${out_dir}/lh.overlaps.Caudate
rh_olp=${out_dir}/rh.overlaps.Caudate

if [ ! -e ${lh_olp} ]
then

matlab -nodisplay <<EOF
load ${DIR}/Left-Caudate/lh.ventricle_t.mat
temp = srf2srf('areal', '${left_surf}', '${targ_surf}', '${lh_olp}', F_lh);
EOF


fi


if [ ! -e ${rh_olp} ]
then

matlab -nodisplay <<EOF
load ${DIR}/Right-Caudate/lh.ventricle_t.mat
temp = srf2srf('areal', '${right_surf}', '${targ_surf}', '${rh_olp}', F_rh);
EOF

fi

# If overlaps previously computed, just apply it
matlab -nodisplay <<EOF
load ${DIR}/Left-Caudate/lh.ventricle_t.mat
load ${DIR}/Right-Caudate/lh.ventricle_t.mat

temp_lh  = applyolp('${lh_olp}', '${targ_surf}', F_lh);
temp_rh  = applyolp('${rh_olp}', '${targ_surf}', F_rh);

mask_lh = temp_lh(:,end);
mask_rh = temp_rh(:,end);

save ${DIR}/Left-Caudate/lh.rsl.ventricle_t.mat mask_lh
save ${DIR}/Right-Caudate/lh.rsl.ventricle_t.mat mask_rh

EOF

rm -rf /tmp/${subj}/surf

# [matlab]
# matlab -nodisplay <<EOF
# 
# EOF

