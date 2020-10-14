#! /bin/bash

SUBJ=$1

## Input parameters
SD=/NAS/dumbo/gadeline/memoire
T1=${SD}/${SUBJ}/FreeSurfer/mri/T1.mgz
T2map=${SD}/${SUBJ}/PRIDE/*T2MAP_FFECL*.nii
T2echo=${SD}/${SUBJ}/RECPAR/new/*T2MAP_FFECL*x1.nii
OUTDIR=${SD}/${SUBJ}/T2_Analyses

if [ ! -d ${SD}/${SUBJ}/T2_Analyses ]
then
	mkdir ${SD}/${SUBJ}/T2_Analyses
else
	rm -f ${SD}/${SUBJ}/T2_Analyses/*
fi

## Reorient volumes
mri_convert ${T1} ${OUTDIR}/T1_ras.nii.gz --out_orientation RAS
# mri_convert ${T2map} ${OUTDIR}/T2map_ras.nii.gz --out_orientation RAS
# mri_convert ${T2echo} ${OUTDIR}/T2echo_ras.nii.gz --out_orientation RAS
cp ${T2map} ${OUTDIR}/T2map_ras.nii.gz
cp ${T2echo} ${OUTDIR}/T2echo_ras.nii.gz

## Rigid body registration of T2echo on T1 map + Apply transformation to T2echo and T2map
ANTS 3 -m MI[${OUTDIR}/T1_ras.nii.gz,${OUTDIR}/T2echo_ras.nii.gz,1,32] -o ${OUTDIR}/T2toT1 -i 0 --rigid-affine true
WarpImageMultiTransform 3 ${OUTDIR}/T2echo_ras.nii.gz ${OUTDIR}/T2echo_ras2T1.nii.gz ${OUTDIR}/T2toT1Affine.txt -R ${OUTDIR}/T1_ras.nii.gz
WarpImageMultiTransform 3 ${OUTDIR}/T2map_ras.nii.gz ${OUTDIR}/T2map_ras2T1.nii.gz ${OUTDIR}/T2toT1Affine.txt -R ${OUTDIR}/T1_ras.nii.gz

# Binarize ROIs from shape analysis
# for file in $(ls -F /NAS/dumbo/gadeline/memoire/shape/pallidum_l | grep -v '/$')
# do
# 	target=${file%.nii~*}
# 	mv -f /NAS/dumbo/gadeline/memoire/shape/pallidum_l/${file} /NAS/dumbo/gadeline/memoire/shape/pallidum_l/${target}.nii
# done

mri_binarize --i ${SD}/shape/caudate_l/caudate_l_${SUBJ}.nii --min 0.1 --o ${OUTDIR}/b_caudate_l_${SUBJ}.nii.gz
mri_convert ${OUTDIR}/b_caudate_l_${SUBJ}.nii.gz ${OUTDIR}/b_caudate_l_${SUBJ}.nii.gz --out_orientation RAS
mri_binarize --i ${SD}/shape/caudate_r/caudate_r_${SUBJ}.nii --min 0.1 --o ${OUTDIR}/b_caudate_r_${SUBJ}.nii.gz
mri_convert ${OUTDIR}/b_caudate_r_${SUBJ}.nii.gz ${OUTDIR}/b_caudate_r_${SUBJ}.nii.gz --out_orientation RAS

mri_binarize --i ${SD}/shape/pallidum_l/pallidum_l_${SUBJ}.nii --min 0.1 --o ${OUTDIR}/b_pallidum_l_${SUBJ}.nii.gz
mri_convert ${OUTDIR}/b_pallidum_l_${SUBJ}.nii.gz ${OUTDIR}/b_pallidum_l_${SUBJ}.nii.gz --out_orientation RAS
mri_binarize --i ${SD}/shape/pallidum_r/pallidum_r_${SUBJ}.nii --min 0.1 --o ${OUTDIR}/b_pallidum_r_${SUBJ}.nii.gz
mri_convert ${OUTDIR}/b_pallidum_r_${SUBJ}.nii.gz ${OUTDIR}/b_pallidum_r_${SUBJ}.nii.gz --out_orientation RAS

mri_binarize --i ${SD}/shape/putamen_l/putamen_l_${SUBJ}.nii --min 0.1 --o ${OUTDIR}/b_putamen_l_${SUBJ}.nii.gz
mri_convert ${OUTDIR}/b_putamen_l_${SUBJ}.nii.gz ${OUTDIR}/b_putamen_l_${SUBJ}.nii.gz --out_orientation RAS
mri_binarize --i ${SD}/shape/putamen_r/putamen_r_${SUBJ}.nii --min 0.1 --o ${OUTDIR}/b_putamen_r_${SUBJ}.nii.gz
mri_convert ${OUTDIR}/b_putamen_r_${SUBJ}.nii.gz ${OUTDIR}/b_putamen_r_${SUBJ}.nii.gz --out_orientation RAS

gunzip ${OUTDIR}/b_*.nii.gz ${OUTDIR}/T2map_ras2T1.nii.gz

## Compute statistics
matlab -nodisplay <<EOF

	cd /home/lucie/memoire/code/new

	list=dir(['${OUTDIR}' '/' 'b_' '*.nii']);
	size(list)
	for i = 1 : size(list,1)
	    roilist{i}=list(i).name;
	end

	roilist

	stats=T_ComputeStatsOnT2Map('${OUTDIR}/T2map_ras2T1.nii','${OUTDIR}',roilist);

	T_write_results_stats_lucie('${OUTDIR}','${SUBJ}',stats)

	save(fullfile('${OUTDIR}','results_fs.mat'),'stats');

EOF

gzip ${OUTDIR}/*.nii