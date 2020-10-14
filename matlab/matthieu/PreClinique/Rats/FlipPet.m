function FlipPet(InputFile,Flipx,Flipy,Flipz)


%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'PET');

spm_jobman('initcfg');
matlabbatch={};

%% FLIP PET File
%-----------------------------------------------------------------------
matlabbatch{end+1}.spm.util.reorient.srcfiles = {InputFile};
matlabbatch{end}.spm.util.reorient.transform.transM = [Flipx 0 0 0
                                                       0 Flipy 0 0
                                                       0 0 Flipz 0
                                                       0 0 0 1];
matlabbatch{end}.spm.util.reorient.prefix = 'f';

fprintf('Flip PET file : OK');
fprintf('\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_jobman('run',matlabbatch);
