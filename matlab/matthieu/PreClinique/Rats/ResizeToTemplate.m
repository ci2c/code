function ResizeToTemplate(OutputSubjDir,Resize_x,Resize_y,Resize_z)


%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

%% RESIZE MRI/PET File to MRI Template
%-----------------------------------------------------------------------
		rigid_coeff = [0 0 0 0 0 0];
		resize_coeff = [Resize_x Resize_y Resize_z];
		affine_coeff = [0 0 0];

		matlabbatch{end+1}.spm.util.reorient.srcfiles = { fullfile(OutputSubjDir,'Coregister','Mri.nii')
                                                      fullfile(OutputSubjDir,'Coregister','PetCoregMri.nii')
                                    			      };
		matlabbatch{end}.spm.util.reorient.transform.transprm = [rigid_coeff resize_coeff affine_coeff];
		matlabbatch{end}.spm.util.reorient.prefix = 'r';

		fprintf('Setup resize subject MRI/PET to template OK');
		fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_jobman('run',matlabbatch);
