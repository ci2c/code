#!/bin/bash
set -e


if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: DTI_TractographyProcessing.sh  -dtifolder <folder>  -reg <value>  -o <folder>  -t1folder <path>  [-bval <path>  -bvec <path>] "
	echo ""
	echo "  -dtifolder             : dti folder "
	echo "  -reg                   : registration matrix (structural to diffusion) "
	echo "  -o                     : output folder "
	echo "  -t1folder              : T1w folder "
	echo "  Options"
	echo "  -bval                  : bval file "
	echo "  -bvec                  : bvec file "
	echo ""
	echo ""
	echo "Usage: DTI_TractographyProcessing.sh  -dtifolder <folder>  -reg <value>  -o <folder>  -t1folder <path>  [-bval <path>  -bvec <path>] "
	echo ""
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

BVAL="NONE"
BVEC="NONE"
lmax="8"
Nfiber="1M"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_TractographyProcessing.sh  -dtifolder <folder>  -reg <value>  -o <folder>  -t1folder <path>  [-bval <path>  -bvec <path>] "
		echo ""
		echo "  -dtifolder             : dti folder "
		echo "  -reg                   : registration matrix (structural to diffusion) "
		echo "  -o                     : output folder "
		echo "  -t1folder              : T1w folder "
		echo "  Options"
		echo "  -bval                  : bval file "
		echo "  -bvec                  : bvec file "
		echo ""
		echo ""
		echo "Usage: DTI_TractographyProcessing.sh  -dtifolder <folder>  -reg <value>  -o <folder>  -t1folder <path>  [-bval <path>  -bvec <path>] "
		echo ""
		exit 1
		;;
	-dtifolder)
		DTIFolder=`expr $index + 1`
		eval DTIFolder=\${$DTIFolder}
		echo "  |-------> DTI folder : $DTIFolder"
		index=$[$index+1]
		;;
	-bval)
		BVAL=`expr $index + 1`
		eval BVAL=\${$BVAL}
		echo "  |-------> bval file : ${BVAL}"
		index=$[$index+1]
		;;
	-bvec)
		BVEC=`expr $index + 1`
		eval BVEC=\${$BVEC}
		echo "  |-------> bvec file : ${BVEC}"
		index=$[$index+1]
		;;
	-reg)
		STR2DIFF=`expr $index + 1`
		eval STR2DIFF=\${$STR2DIFF}
		echo "  |-------> registration matrix : ${STR2DIFF}"
		index=$[$index+1]
		;;
	-o)
		OUTDIR=`expr $index + 1`
		eval OUTDIR=\${$OUTDIR}
		echo "  |-------> output folder : ${OUTDIR}"
		index=$[$index+1]
		;;
	-t1folder)
		T1wFolder=`expr $index + 1`
		eval T1wFolder=\${$T1wFolder}
		echo "  |-------> T1w folder : ${T1wFolder}"
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

if [ -d ${OUTDIR} ]; then rm -rf ${OUTDIR}; fi
mkdir -p ${OUTDIR}

if [ $BVAL = "NONE" ] ; then echo BVAL=${DTIFolder}/data/bvals; fi
if [ $BVEC = "NONE" ] ; then echo BVEC=${DTIFolder}/data/bvecs; fi


echo ""
echo "===================================================================="
echo ""
echo "                      Diffusion tensor estimation                   "
echo ""
echo "===================================================================="

rm -f ${OUTDIR}/dt.mif
echo "dwi2tensor ${DTIFolder}/data/data.nii.gz -fslgrad ${BVEC} ${BVAL} ${OUTDIR}/dt.mif"
dwi2tensor ${DTIFolder}/data/data.nii.gz -fslgrad ${BVEC} ${BVAL} ${OUTDIR}/dt.mif



echo ""
echo "===================================================================="
echo ""
echo "               Generate maps of tensor-derived parameters           "
echo ""
echo "===================================================================="

echo "Generate mask"
if [ ! -f ${DTIFolder}/data/nodif.nii.gz ]; then $FSLDIR/bin/fslroi ${DTIFolder}/data ${DTIFolder}/data/nodif 0 1; fi
rm -f ${OUTDIR}/T1w_acpc_brain_mask
echo "${FSLDIR}/bin/applywarp --rel --interp=nn -i ${T1wFolder}/T1w_acpc_brain_mask -r ${DTIFolder}/data/nodif --premat=${STR2DIFF} -o ${OUTDIR}/T1w_acpc_brain_mask"
${FSLDIR}/bin/applywarp --rel --interp=nn -i ${T1wFolder}/T1w_acpc_brain_mask -r ${DTIFolder}/data/nodif --premat=${STR2DIFF} -o ${OUTDIR}/T1w_acpc_brain_mask

if [ ! -f ${DTIFolder}/data/data_mask.nii.gz ]; then
	dwi2mask -fslgrad ${BVEC} ${BVAL} ${DTIFolder}/data/data.nii.gz ${DTIFolder}/data/data_mask.nii.gz
fi

if [ ! -f ${DTIFolder}/data/data_mask_dil.nii.gz ]; then
	echo "mri_morphology ${DTIFolder}/data/data_mask.nii.gz dilate 1 ${DTIFolder}/data/data_mask_dil.nii.gz"
	mri_morphology ${DTIFolder}/data/data_mask.nii.gz dilate 1 ${DTIFolder}/data/data_mask_dil.nii.gz
fi

echo "tensor2metric -mask ${DTIFolder}/data/data_mask_dil.nii.gz -adc ${OUTDIR}/md.nii.gz -fa ${OUTDIR}/fa.nii.gz -ad ${OUTDIR}/ad.nii.gz -rd ${OUTDIR}/rd.nii.gz ${OUTDIR}/dt.mif"
tensor2metric -mask ${DTIFolder}/data/data_mask_dil.nii.gz -adc ${OUTDIR}/md.nii.gz -fa ${OUTDIR}/fa.nii.gz -ad ${OUTDIR}/ad.nii.gz -rd ${OUTDIR}/rd.nii.gz ${OUTDIR}/dt.mif


echo ""
echo "===================================================================="
echo ""
echo "       Estimate response function(s) for spherical deconvolution    "
echo ""
echo "===================================================================="

echo ""
echo "dwi2response tournier ${DTIFolder}/data/data.nii.gz -lmax ${lmax} -fslgrad ${BVEC} ${BVAL} -mask ${DTIFolder}/data/data_mask_dil.nii.gz ${OUTDIR}/dwi_response_${lmax}.txt "
dwi2response tournier ${DTIFolder}/data/data.nii.gz -lmax ${lmax} -fslgrad ${BVEC} ${BVAL} -mask ${DTIFolder}/data/data_mask_dil.nii.gz ${OUTDIR}/dwi_response_${lmax}.txt 


echo ""
echo "===================================================================="
echo ""
echo "Estimate fibre orientation distributions from diffusion data using spherical deconvolution"
echo ""
echo "===================================================================="

echo "dwi2fod csd ${DTIFolder}/data/data.nii.gz ${OUTDIR}/dwi_response_${lmax}.txt ${OUTDIR}/dwi_fod.nii.gz"
dwi2fod csd ${DTIFolder}/data/data.nii.gz ${OUTDIR}/dwi_response_${lmax}.txt ${OUTDIR}/dwi_fod_${lmax}.nii.gz -lmax ${lmax} -fslgrad ${BVEC} ${BVAL} -mask ${DTIFolder}/data/data_mask_dil.nii.gz



echo ""
echo "===================================================================="
echo ""
echo "                Generate a 5TT image suitable for ACT               "
echo ""
echo "===================================================================="

echo "${FSLDIR}/bin/applywarp --rel --interp=nn -i ${T1wFolder}/aparc.a2009s+aseg -r ${DTIFolder}/data/nodif --premat=${STR2DIFF} -o ${OUTDIR}/aparc.a2009s+aseg"
${FSLDIR}/bin/applywarp --rel --interp=nn -i ${T1wFolder}/aparc.a2009s+aseg -r ${DTIFolder}/data/nodif --premat=${STR2DIFF} -o ${OUTDIR}/aparc.a2009s+aseg

echo "5ttgen freesurfer ${OUTDIR}/aparc.a2009s+aseg.nii.gz ${OUTDIR}/aparc.a2009s+aseg_5TT.nii.gz -nocrop"
5ttgen freesurfer ${OUTDIR}/aparc.a2009s+aseg.nii.gz ${OUTDIR}/aparc.a2009s+aseg_5TT.nii.gz -nocrop

echo "5tt2vis ${OUTDIR}/aparc.a2009s+aseg_5TT.nii.gz ${OUTDIR}/aparc.a2009s+aseg_5TT_vis.nii.gz"
5tt2vis ${OUTDIR}/aparc.a2009s+aseg_5TT.nii.gz ${OUTDIR}/aparc.a2009s+aseg_5TT_vis.nii.gz

echo "labelconvert ${OUTDIR}/aparc.a2009s+aseg.nii.gz ${FREESURFER_HOME}/FreeSurferColorLUT.txt /home/global/mrtrix3_RC2/mrtrix3/share/mrtrix3/labelconvert/fs_a2009s.txt ${OUTDIR}/aparc.a2009s+aseg_nodes.nii.gz"
labelconvert ${OUTDIR}/aparc.a2009s+aseg.nii.gz ${FREESURFER_HOME}/FreeSurferColorLUT.txt /home/global/mrtrix3_RC2/mrtrix3/share/mrtrix3/labelconvert/fs_a2009s.txt ${OUTDIR}/aparc.a2009s+aseg_nodes.nii.gz


echo ""
echo "===================================================================="
echo ""
echo "                      Probabilistic tractography                    "
echo ""
echo "===================================================================="

echo ""
echo "tractography"
echo "tckgen ${OUTDIR}/dwi_fod_${lmax}.nii.gz ${OUTDIR}/tract_wholebrain_${lmax}_${Nfiber}.tck -act ${OUTDIR}/aparc.a2009s+aseg_5TT.nii.gz -backtrack -crop_at_gmwmi -seed_dynamic ${OUTDIR}/dwi_fod_${lmax}.nii.gz -select ${Nfiber} -maxlength 250 -algorithm iFOD2 -fslgrad ${BVEC} ${BVAL}"
tckgen ${OUTDIR}/dwi_fod_${lmax}.nii.gz ${OUTDIR}/tract_wholebrain_${lmax}_${Nfiber}.tck -act ${OUTDIR}/aparc.a2009s+aseg_5TT.nii.gz -backtrack -crop_at_gmwmi -seed_dynamic ${OUTDIR}/dwi_fod_${lmax}.nii.gz -select ${Nfiber} -maxlength 250 -algorithm iFOD2 -fslgrad ${BVEC} ${BVAL}


echo ""
echo "Perform SIFT"
echo "tcksift ${OUTDIR}/tract_wholebrain_${lmax}_${Nfiber}.tck ${OUTDIR}/dwi_fod_${lmax}.nii.gz ${OUTDIR}/tract_wholebrain_${lmax}_${Nfiber}_sift.tck -act ${OUTDIR}/aparc.a2009s+aseg_5TT.nii.gz -term_number 500000"
tcksift ${OUTDIR}/tract_wholebrain_${lmax}_${Nfiber}.tck ${OUTDIR}/dwi_fod_${lmax}.nii.gz ${OUTDIR}/tract_wholebrain_${lmax}_${Nfiber}_sift.tck -act ${OUTDIR}/aparc.a2009s+aseg_5TT.nii.gz -term_number 500000



echo ""
echo "===================================================================="
echo ""
echo "                             Connectome                             "
echo ""
echo "===================================================================="

echo ""
echo "tck2connectome ${OUTDIR}/tract_wholebrain_${lmax}_${Nfiber}_sift.tck ${OUTDIR}/aparc.a2009s+aseg_nodes.nii.gz ${OUTDIR}/aparc.a2009s+aseg_connectome.csv -zero_diagonal"
tck2connectome ${OUTDIR}/tract_wholebrain_${lmax}_${Nfiber}_sift.tck ${OUTDIR}/aparc.a2009s+aseg_nodes.nii.gz ${OUTDIR}/aparc.a2009s+aseg_connectome.csv -zero_diagonal


#mris_convert /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/T1w/100269SD100714/surf/lh.white /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/dti/process/lh.white.surf.gii

#wb_command -surface-apply-affine /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/dti/process/lh.white.surf.gii /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/T1w/100269SD100714/mri/c_ras.mat /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/dti/process/lh.white.surf.gii

#wb_command -surface-apply-affine /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/dti/process/lh.white.surf.gii /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/dti/reg/str2diff.mat /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/dti/process/lh.white2dti.surf.gii -flirt /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/dti/reg/T1w_acpc_brain.nii.gz /NAS/tupac/protocoles/cogphenopark/process/100269SD100714/dti/data/nodif.nii.gz


