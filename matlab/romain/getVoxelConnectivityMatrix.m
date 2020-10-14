function Connectome = getVoxelConnectivityMatrix(DTI_PATH,SEG_PATH,OUT_NAME, LOI, thresh)
% usage : Connectome = getVoxelConnectivityMatrix(DTI_PATH, SEG_PATH,OUT_NAME, [ LOI, thresh])
%
% INPUT :
% -------
%    DTI_PATH          : Path to fiber files (tck files)
%
%    SEG_PATH          : Path to segmented volume 
%
%    OUT_NAME          : Full path to the outputfile (without "mat" extension)
% 
%    LOI               : Path to text file containing ID and names of the labels of interest (option)
%
%    THRESHOLD         : Minimum fiber length required (default : 10) 
%
% OUTPUT :
% --------
%    CONNECTOME        : Connectome structure
%
% EXAMPLE :
% ---------
%   getVoxelConnectivityMatrix('/NAS/dumbo/HBC/Freesurfer5.0/100408/dti/whole_brain_10_2500000_part000',
%   '/NAS/dumbo/HBC/FS53/100408/mri/wOnMNI_aparc.a2009s+aseg.nii.gz','/NAS/dumbo/HBC/Freesurfer5.0/100408/connectome/Connectome_Struct_Voxel_testRV_todelete.mat')

% Romain VIARD @ CHRU Lille, Feb. 2016
Mat=sparse([]);
filelist = dir([DTI_PATH '*.tck']);
rep=fileparts(DTI_PATH);
for cpt=1:length(filelist)
	%disp([rep '/' filelist(cpt).name]);
	disp('getVolumeConnectMatrix_VoxelLevel(SEG_PATH,[rep filelist(cpt).name],LOI,thresh)')
	tmp = getVolumeConnectMatrix_VoxelLevel(SEG_PATH,[rep '/' filelist(cpt).name],LOI,thresh);
	Mat=cat(1,Mat,tmp); 
end

fid = fopen(LOI, 'r');
T = textscan(fid, '%d %s');
LOI_nb = T{1};

V = spm_vol(SEG_PATH);
[labels, XYZ] = spm_read_vols(V);
labels = round(labels);
Mat=spones(Mat);
Mat=Mat(:,find(ismember(labels,LOI_nb)));
Mat=Mat'*Mat;

Mask = logical(Mat);
Mask = triu(Mask, 1);
Mat = Mask .* Mat;
clear Mask;

disp('Save data...');
save(OUT_NAME, 'Mat', '-v7.3');
