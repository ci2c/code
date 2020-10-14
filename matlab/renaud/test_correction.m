clear all;
close all;

datapath  = '/home/fatmike/renaud/tep_fog/g1/ALIB/correct/';
refimage  = '/home/fatmike/renaud/tep_fog/g1/ALIB/correct/epi_0249.nii';
corimage  = '/home/fatmike/renaud/tep_fog/g1/ALIB/correct/epicor.nii';
outimage  = '/home/fatmike/renaud/tep_fog/g1/ALIB/correct/epicor_al.nii';
transfmat = '/home/fatmike/renaud/tep_fog/g1/ALIB/correct/cor_to_ref.mat';
fctpath   = '/home/global//fsl/bin/flirt';
opt       = '-bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -schedule /home/global//fsl/etc/flirtsch/sch3Dtrans_3dof  -interp trilinear';

% FSL
cmd = sprintf(['%s -in %s -ref %s -out %s -omat %s %s'],fctpath,corimage,refimage,outimage,transfmat,opt);
unix(cmd);

% SPM
cmd            = sprintf('cp %s %s%s',corimage,datapath,'corspm.nii');
unix(cmd);
VG             = refimage;
VF             = [datapath 'corspm.nii'];
flags.params   = [0 0 0 0 0 0];
flags.cost_fun = 'nmi';
flags.sep      = [4 2];
flags.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
flags.fwhm     = [7 7];
x              = spm_coreg(VG,VF,flags);

x(4:6)  = 0;
M       = spm_matrix(x);
PO      = [VF ',1'];
MM      = zeros(4,4);
MM(:,:) = spm_get_space(PO);
spm_get_space(PO, M\MM(:,:));
