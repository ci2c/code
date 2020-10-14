!/bin/bash
SUBJ=$1

mri_convert /NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/T01S01/mri/T1.mgz /NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/${SUBJ}/mri/wT1.nii
#cp -f /NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/T01S01/chiasmaOT_lh.nii /NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/${SUBJ}/wchiasmaOT_lh.nii
#cp -f /NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/T01S01/chiasmaOT_rh.nii /NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/${SUBJ}/wchiasmaOT_rh.nii

        matlab -nodisplay <<EOF
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {'/NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/${SUBJ}/mri/wT1.nii,1'};
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {
                                                               '/NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/${SUBJ}/mri/wT1.nii,1'
                                                               '/NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/${SUBJ}/chiasmaOT_lh.nii'
                                                               '/NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/${SUBJ}/chiasmaOT_rh.nii'
                                                               };
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii'};
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                             78 76 85];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'n';
spm_jobman('run',matlabbatch);
EOF
rm /NAS/tupac/protocoles/VWIMS/SujetsSains/FS53/${SUBJ}/mri/wT1.nii
