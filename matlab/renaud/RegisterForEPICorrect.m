function RegisterForEPICorrect(refimage,corimage,outimage)

cmd            = sprintf('cp %s %s',corimage,outimage);
unix(cmd);
VG             = refimage;
VF             = outimage;
flags.params   = [0 0 0 0 0 0];
flags.cost_fun = 'nmi';
flags.sep      = [4 2];
flags.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
flags.fwhm     = [7 7];
x              = spm_coreg(VG,VF,flags);   % matrice de transformation
x(4:6)         = 0;                        % applique juste les translations
M              = spm_matrix(x);
PO             = [VF ',1'];
MM             = zeros(4,4);
MM(:,:)        = spm_get_space(PO);
spm_get_space(PO, M\MM(:,:));