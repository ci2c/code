#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: ModelCaudate.sh  -fs <fs_dir>  -subj <subj_id> [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>]"
	echo ""
	echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
	echo "  -subj <subj_id>                      : Subject ID"
	echo ""
	echo "Options :"
	echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
	echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
	echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
	echo " "
	echo "Usage: ModelCaudate.sh  -fs <fs_dir>  -subj <subj_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>]"
	echo ""
	exit 1
fi

index=1
tmpdir=/tmp/
segvol="aparc.a2009s+aseg.mgz"
volres=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: ModelCaudate.sh  -fs <fs_dir>  -subj <subj_id> [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>]"
		echo ""
		echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
		echo "  -subj <subj_id>                      : Subject ID"
		echo ""
		echo "Options :"
		echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
		echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
		echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
		echo " "
		echo "Usage: ModelCaudate.sh  -fs <fs_dir>  -subj <subj_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>]"
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "|> FS dir           : $fs"
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "|> Subject          : $subj"
		;;
	-tmp)
		tmpdir=`expr $index + 1`
		eval tmpdir=\${$tmpdir}
		echo "|> Temp dir         : $tmpdir"
		;;
	-res)
		volres=`expr $index + 1`
		eval volres=\${$volres}
		echo "|> Image resolution  : $volres"
		;;
	-segvol)
		segvol=`expr $index + 1`
		eval segvol=\${$segvol}
		echo "|> Segmentation vol. : $segvol"
		;;
	-*)
		Arg=`expr $index`
		eval Arg=\${$Arg}
		echo "Unknown argument ${Arg}"
		echo ""
		echo "Usage: ModelCaudate.sh  -fs <fs_dir>  -subj <subj_id> [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>]"
		echo ""
		echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
		echo "  -subj <subj_id>                      : Subject ID"
		echo ""
		echo "Options :"
		echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
		echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
		echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
		echo " "
		echo "Usage: ModelCaudate.sh  -fs <fs_dir>  -subj <subj_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

# Set some cool variables
DIR=${fs}/${subj}
tmps=${tmpdir}/${subj}
leftC=${tmps}/Left-Caudate
rightC=${tmps}/Right-Caudate
SUBJECTS_DIR=${tmpdir}

if [ ! -d ${tmps} ]
then
	mkdir ${tmps}
	cp -R ${DIR}/mri ${tmps}/
else
	rm -rf ${tmps}
	mkdir ${tmps}
	cp -R ${DIR}/mri ${tmps}/
fi

# Create some cool dir & copy some cool data
if [ ! -d ${leftC} ]
then
	mkdir ${leftC}
	mkdir ${rightC}
else
	rm -rf ${leftC}
	rm -rf ${rightC}
	mkdir ${leftC}
	mkdir ${rightC}
fi

# Extract Caudate Nuclei
echo "mri_extract_label ${DIR}/mri/${segvol} 11 ${leftC}/label_orig.mgz"
mri_extract_label ${DIR}/mri/${segvol} 11 ${leftC}/label_orig.mgz

echo "mri_extract_label ${DIR}/mri/${segvol} 50 ${rightC}/label_orig.mgz"
mri_extract_label ${DIR}/mri/${segvol} 50 ${rightC}/label_orig.mgz

# Remove useless files
echo "**** Removing useless files ****"
rm -rf ${tmps}/surf ${tmps}/epilepsy ${tmps}/dti
mkdir ${tmps}/surf
rm -f ${tmps}/mri/aparc+aseg.mgz 
rm -f ${tmps}/mri/aparc.a2009s+aseg.mgz 
rm -f ${tmps}/mri/aseg.auto.mgz 
rm -f ${tmps}/mri/aseg.auto_noCCseg.label_intensities.txt 
rm -f ${tmps}/mri/aseg.auto_noCCseg.mgz 
rm -f ${tmps}/mri/brain.finalsurfs.mgz 
rm -f ${tmps}/mri/brainmask.auto.mgz 
rm -f ${tmps}/mri/brainmask.mgz 
rm -f ${tmps}/mri/ctrl_pts.mgz 
rm -f ${tmps}/mri/filled.mgz 
rm -f ${tmps}/mri/lh.dpial.ribbon.mgz 
rm -f ${tmps}/mri/lh.dwhite.ribbon.mgz 
rm -f ${tmps}/mri/lh.ribbon.mgz 
rm -f ${tmps}/mri/mri_nu_correct.mni.log 
rm -f ${tmps}/mri/rh.dpial.ribbon.mgz 
rm -f ${tmps}/mri/rh.dwhite.ribbon.mgz 
rm -f ${tmps}/mri/rh.ribbon.mgz 
rm -f ${tmps}/mri/ribbon.mgz 
rm -f ${tmps}/mri/segment.dat 
rm -f ${tmps}/mri/wm.asegedit.mgz 
rm -f ${tmps}/mri/wm.mgz 
rm -f ${tmps}/mri/wm.seg.mgz 
rm -f ${tmps}/mri/wmparc.mgz

# Resample volumes to $volres if necessary
if [ ! "${volres}" == "1" ]
then
	echo "**** Resampling Volumes ****"
	# Brain volumes
#	mri_convert ${tmps}/mri/brain.mgz ${tmps}/mri/brain_${volres}.mgz -vs ${volres} ${volres} ${volres}
#	mri_convert ${tmps}/mri/norm.mgz ${tmps}/mri/norm_${volres}.mgz -vs ${volres} ${volres} ${volres}
#	mri_convert ${tmps}/mri/nu.mgz ${tmps}/mri/nu_${volres}.mgz -vs ${volres} ${volres} ${volres}
#	mri_convert ${tmps}/mri/orig.mgz ${tmps}/mri/orig_${volres}.mgz -vs ${volres} ${volres} ${volres}
#	mri_convert ${tmps}/mri/T1.mgz ${tmps}/mri/T1_${volres}.mgz -vs ${volres} ${volres} ${volres}
	
#	mv ${tmps}/mri/brain.mgz ${tmps}/mri/brain_orig.mgz
#	mv ${tmps}/mri/norm.mgz ${tmps}/mri/norm_orig.mgz
#	mv ${tmps}/mri/nu.mgz ${tmps}/mri/nu_orig.mgz
#	mv ${tmps}/mri/orig.mgz ${tmps}/mri/orig_orig.mgz
#	mv ${tmps}/mri/T1.mgz ${tmps}/mri/T1_orig.mgz
	
#	mv ${tmps}/mri/brain_${volres}.mgz ${tmps}/mri/brain.mgz
#	mv ${tmps}/mri/norm_${volres}.mgz ${tmps}/mri/norm.mgz
#	mv ${tmps}/mri/nu_${volres}.mgz ${tmps}/mri/nu.mgz
#	mv ${tmps}/mri/orig_${volres}.mgz ${tmps}/mri/orig.mgz
#	mv ${tmps}/mri/T1_${volres}.mgz ${tmps}/mri/T1.mgz
	
	# Extracted label
	mri_convert ${leftC}/label_orig.mgz ${leftC}/label_orig_${volres}.mgz -vs ${volres} ${volres} ${volres}
	mv ${leftC}/label_orig_${volres}.mgz ${leftC}/label.mgz
	
	mri_convert ${rightC}/label_orig.mgz ${rightC}/label_orig_${volres}.mgz -vs ${volres} ${volres} ${volres}
	mv ${rightC}/label_orig_${volres}.mgz ${rightC}/label.mgz
else
	mv ${leftC}/label_orig.mgz ${leftC}/label.mgz
	mv ${rightC}/label_orig.mgz ${rightC}/label.mgz
fi

echo "mri_fwhm --i ${leftC}/label.mgz --fwhm 4 --o ${leftC}/label_smooth_fwhm4.mgz --smooth-only"
mri_fwhm --i ${leftC}/label.mgz --fwhm 4 --o ${leftC}/label_smooth_fwhm4.mgz --smooth-only

echo "mri_fwhm --i ${rightC}/label.mgz --fwhm 4 --o ${rightC}/label_smooth_fwhm4.mgz --smooth-only"
mri_fwhm --i ${rightC}/label.mgz --fwhm 4 --o ${rightC}/label_smooth_fwhm4.mgz --smooth-only

echo "mri_binarize --i ${leftC}/label_smooth_fwhm4.mgz --o ${leftC}/label_close_bin.mgz --min 64 --max inf"
mri_binarize --i ${leftC}/label_smooth_fwhm4.mgz --o ${leftC}/label_close_bin.mgz --min 64 --max inf

echo "mri_binarize --i ${rightC}/label_smooth_fwhm4.mgz --o ${rightC}/label_close_bin.mgz --min 64 --max inf"
mri_binarize --i ${rightC}/label_smooth_fwhm4.mgz --o ${rightC}/label_close_bin.mgz --min 64 --max inf

cp ${leftC}/label_close_bin.mgz ${tmps}/mri/wm.asegedit.mgz
cp ${rightC}/label_close_bin.mgz ${tmps}/mri/wm.asegedit.mgz

echo "mri_convert ${leftC}/label_close_bin.mgz ${leftC}/label_close_bin_ras.nii --out_orientation LPS"
mri_convert ${leftC}/label_close_bin.mgz ${leftC}/label_close_bin_ras.nii --out_orientation LPS

echo "mri_convert ${rightC}/label_close_bin.mgz ${rightC}/label_close_bin_ras.nii --out_orientation LPS"
mri_convert ${rightC}/label_close_bin.mgz ${rightC}/label_close_bin_ras.nii --out_orientation LPS

echo "SegPostProcessCLP ${leftC}/label_close_bin_ras.nii ${leftC}/label_close_bin_ras.gipl --space ${volres},${volres},${volres} --label 1 --iter 500"
SegPostProcessCLP ${leftC}/label_close_bin_ras.nii ${leftC}/label_close_bin_ras.gipl --space ${volres},${volres},${volres} --label 1 --iter 500

echo "SegPostProcessCLP ${rightC}/label_close_bin_ras.nii ${rightC}/label_close_bin_ras.gipl --space ${volres},${volres},${volres} --label 1 --iter 500"
SegPostProcessCLP ${rightC}/label_close_bin_ras.nii ${rightC}/label_close_bin_ras.gipl --space ${volres},${volres},${volres} --label 1 --iter 500

echo "GenParaMeshCLP --label 1 --iter 1000 ${leftC}/label_close_bin_ras.gipl ${leftC}/label_close_bin_ras_para.vtk ${leftC}/label_close_bin_ras_surf.vtk"
GenParaMeshCLP --label 1 --iter 1000 ${leftC}/label_close_bin_ras.gipl ${leftC}/label_close_bin_ras_para.vtk ${leftC}/label_close_bin_ras_surf.vtk

echo "GenParaMeshCLP --label 1 --iter 1000 ${rightC}/label_close_bin_ras.gipl ${rightC}/label_close_bin_ras_para.vtk ${rightC}/label_close_bin_ras_surf.vtk"
GenParaMeshCLP --label 1 --iter 1000 ${rightC}/label_close_bin_ras.gipl ${rightC}/label_close_bin_ras_para.vtk ${rightC}/label_close_bin_ras_surf.vtk

echo "ParaToSPHARMMeshCLP ${leftC}/label_close_bin_ras_para.vtk ${leftC}/label_close_bin_ras_surf.vtk ${leftC}/left-caudate_ --subdivLevel 10 --spharmDegree 12"
ParaToSPHARMMeshCLP ${leftC}/label_close_bin_ras_para.vtk ${leftC}/label_close_bin_ras_surf.vtk ${leftC}/left-caudate_ --subdivLevel 10 --spharmDegree 12

echo "ParaToSPHARMMeshCLP ${rightC}/label_close_bin_ras_para.vtk ${rightC}/label_close_bin_ras_surf.vtk ${rightC}/right-caudate_ --subdivLevel 10 --spharmDegree 12"
ParaToSPHARMMeshCLP ${rightC}/label_close_bin_ras_para.vtk ${rightC}/label_close_bin_ras_surf.vtk ${rightC}/right-caudate_ --subdivLevel 10 --spharmDegree 12

VTK2Meta ${leftC}/label_close_bin_ras_surf.vtk ${leftC}/label_close_bin_ras_surf.meta # Mesh used to get the XYZ shift
VTK2Meta ${rightC}/label_close_bin_ras_surf.vtk ${rightC}/label_close_bin_ras_surf.meta

VTK2Meta ${leftC}/left-caudate_SPHARM.vtk ${leftC}/left-caudate_SPHARM.meta
VTK2Meta ${rightC}/right-caudate_SPHARM.vtk ${rightC}/right-caudate_SPHARM.meta

# Realign surface to T1
matlab -nodisplay <<EOF
Meta2Obj('${leftC}/label_close_bin_ras_surf.meta', '${leftC}/label_close_bin_ras_surf.obj');
Meta2Obj('${rightC}/label_close_bin_ras_surf.meta', '${rightC}/label_close_bin_ras_surf.obj');
V = spm_vol('${leftC}/label_close_bin_ras.nii');
[Y, XYZ] = spm_read_vols(V);
XYZ(:, Y(:) == 0) = [];
min_vol_X_left = min(XYZ(1, :));
max_vol_X_left = max(XYZ(1, :));
min_vol_Y_left = min(XYZ(2, :));
max_vol_Y_left = max(XYZ(2, :));
min_vol_Z_left = min(XYZ(3, :));
max_vol_Z_left = max(XYZ(3, :));

Surf = SurfStatReadSurf('${leftC}/label_close_bin_ras_surf.obj');
min_surf_X_left = min(Surf.coord(1,:));
max_surf_X_left = max(Surf.coord(1,:));
min_surf_Y_left = min(Surf.coord(2,:));
max_surf_Y_left = max(Surf.coord(2,:));
min_surf_Z_left = min(Surf.coord(3,:));
max_surf_Z_left = max(Surf.coord(3,:));

delta_X_min_left = min_vol_X_left - min_surf_X_left;
delta_X_max_left = max_vol_X_left - max_surf_X_left;
delta_Y_min_left = min_vol_Y_left - min_surf_Y_left;
delta_Y_max_left = max_vol_Y_left - max_surf_Y_left;
delta_Z_min_left = min_vol_Z_left - min_surf_Z_left;
delta_Z_max_left = max_vol_Z_left - max_surf_Z_left;

delta_X = (delta_X_min_left + delta_X_max_left) ./ 2;
delta_Y = (delta_Y_min_left + delta_Y_max_left) ./ 2;
delta_Z = (delta_Z_min_left + delta_Z_max_left) ./ 2;


Meta2Obj('${leftC}/left-caudate_SPHARM.meta', '${leftC}/left-caudate_SPHARM.obj');
Meta2Obj('${rightC}/right-caudate_SPHARM.meta', '${rightC}/right-caudate_SPHARM.obj');

Surf = SurfStatReadSurf('${leftC}/left-caudate_SPHARM.obj');
Surf.coord(1, :) = Surf.coord(1, :) + delta_X;
Surf.coord(2, :) = Surf.coord(2, :) + delta_Y;
Surf.coord(3, :) = Surf.coord(3, :) + delta_Z;
Surf = supersampSurf(Surf);
SurfStatWriteSurf('${leftC}/lh.orig', Surf, 'b');

Surf = SurfStatReadSurf('${rightC}/right-caudate_SPHARM.obj');
Surf.coord(1, :) = Surf.coord(1, :) + delta_X;
Surf.coord(2, :) = Surf.coord(2, :) + delta_Y;
Surf.coord(3, :) = Surf.coord(3, :) + delta_Z;
Surf = supersampSurf(Surf);
SurfStatWriteSurf('${rightC}/lh.orig', Surf, 'b');
EOF

# Process lh.orig
echo "mris_remove_intersection ${leftC}/lh.orig ${leftC}/lh.white"
mris_remove_intersection ${leftC}/lh.orig ${leftC}/lh.white

echo "mris_remove_intersection ${rightC}/lh.orig ${rightC}/lh.white"
mris_remove_intersection ${rightC}/lh.orig ${rightC}/lh.white

echo "mris_smooth ${leftC}/lh.white ${leftC}/lh.smoothwm"
mris_smooth ${leftC}/lh.white ${leftC}/lh.smoothwm

echo "mris_smooth ${rightC}/lh.white ${rightC}/lh.smoothwm"
mris_smooth ${rightC}/lh.white ${rightC}/lh.smoothwm

echo "mris_inflate ${leftC}/lh.smoothwm ${leftC}/lh.inflated"
mris_inflate ${leftC}/lh.smoothwm ${leftC}/lh.inflated

echo "mris_inflate ${rightC}/lh.smoothwm ${rightC}/lh.inflated"
mris_inflate ${rightC}/lh.smoothwm ${rightC}/lh.inflated

echo "mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ${leftC}/lh.inflated"
mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ${leftC}/lh.inflated

echo "mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ${rightC}/lh.inflated"
mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ${rightC}/lh.inflated

echo "mris_sphere -seed 1234 ${leftC}/lh.inflated ${leftC}/lh.sphere"
mris_sphere -seed 1234 ${leftC}/lh.inflated ${leftC}/lh.sphere

echo "mris_sphere -seed 1234 ${rightC}/lh.inflated ${rightC}/lh.sphere"
mris_sphere -seed 1234 ${rightC}/lh.inflated ${rightC}/lh.sphere

# Copy final outputs to original directory
if [ -d ${DIR}/Left-Caudate ]
then
	rm -rf ${DIR}/Left-Caudate
fi

if [ -d ${DIR}/Right-Caudate ]
then
	rm -rf ${DIR}/Right-Caudate
fi

cp -Rf ${leftC} ${DIR}/Left-Caudate
cp -Rf ${rightC} ${DIR}/Right-Caudate
