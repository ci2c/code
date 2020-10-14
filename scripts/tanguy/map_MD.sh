
sd=$1
subj=$2
lmax=$3
Nfiber=$4

outdir=$sd/$subj/dti_connectome

tensor2ADC ${outdir}/dt.mif - | mrmult - ${mask_mif} ${outdir}/MD.mif
mrconvert ${outdir}/MD.mif ${outdir}/MD.nii


matlab -nodisplay <<EOF
cd ${outdir}
load Connectome_${subj}
Connectome.Mfa_back=Connectome.Mfa;
Connectome = computeMfa('${outdir}/whole_brain_${lmax}_${Nfiber}.tck', '${outdir}/MD.nii', Connectome, 30);
Connectome.MMD=Connectome.Mfa;
Connectome.Mfa=Connectome.Mfa_back;
Connectome=rmfield(Connectome,'Mfa_back')
save Connectome_${subj} Connectome -v7.3
EOF
