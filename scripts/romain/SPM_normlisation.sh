        matlab -nodisplay <<EOF

        spm('defaults', 'FMRI');
        spm_jobman('initcfg');
        matlabbatch={};
        matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {'/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/$1/fmri/$2/T1_las.nii,1'};
        matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {
                                                                       '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/$1/fmri/$2/T1_las.nii,1'
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
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'N';
        spm_jobman('run',matlabbatch);
EOF
