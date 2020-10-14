# Step 9. Save cortical surfaces in volume space
if [ ! -e ${1}/surf/lh.white.ras ]
then

mri_convert ${1}/mri/T1.mgz ${1}/mri/t1_ras.nii --out_orientation RAS

matlab -nodisplay <<EOF
surf = surf_to_ras_nii('${1}/surf/lh.white', '${1}/mri/t1_ras.nii');
SurfStatWriteSurf('${1}/surf/lh.white.ras', surf, 'b');

surf = surf_to_ras_nii('${1}/surf/rh.white', '${1}/mri/t1_ras.nii');
SurfStatWriteSurf('${1}/surf/rh.white.ras', surf, 'b');
EOF

rm -f ${1}/mri/t1_ras.nii
fi
