im=$1
ref=$2
output=$3
dim=3

outdir=`dirname $output`
im_b=`basename $im`
im_b=${im_b%%.*}
ref_b=`basename $ref`
ref_b=${ref_b%%.*}

echo "################################"
echo "###      recallage ANTS      "
echo "###    im to recal : $im     "
echo "###    reference : $ref      "
echo "###    output : $output      "
echo "################################"

echo ""
echo ""
echo "################################"
echo "###      instructions :      ###"
echo "ANTS ${dim} -m PR[${ref},${im},1,2] -i 100*100*10 -o ${outdir}/${im_b}_to_${ref_b}.nii"
echo "WarpImageMultiTransform ${dim} ${im} ${output} -R ${ref} ${outdir}/${im_b}_to_${ref_b}Warp.nii ${outdir}/${im_b}_to_${ref_b}Affine.txt"

echo "ANTS ${dim} -m PR[${ref},${im},1,2] -i 100*100*10 -o ${outdir}/${im_b}_to_${ref_b}.nii"
ANTS ${dim} -m PR[${ref},${im},1,2] -i 100*100*10 -o ${outdir}/${im_b}_to_${ref_b}.nii

echo "WarpImageMultiTransform ${dim} ${im} ${output} -R ${ref} ${outdir}/${im_b}_to_${ref_b}Warp.nii ${outdir}/${im_b}_to_${ref_b}Affine.txt"
WarpImageMultiTransform ${dim} ${im} ${output} -R ${ref} ${outdir}/${im_b}_to_${ref_b}Warp.nii ${outdir}/${im_b}_to_${ref_b}Affine.txt

