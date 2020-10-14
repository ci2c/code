function ASL_MapGeneration(aslfolder,aslprefix,N,t1File,output)

% usage : ASL_MapGeneration(aslFile,output)
%
% Inputs :
%    aslfolder     : ASL folder (split data *.nii) 
%    aslprefix     : data prefix
%    N             : number of frames
%    t1File        : T1 file  (.nii or .nii.gz)
%    output        : out directory
%
% Renaud Lopes @ CHRU Lille, Apr 2013

if ~isdir(fullfile(output,'split'))
    mkdir(fullfile(output,'split'));
end

[n,p,e] = fileparts(t1File);
if strcmp(e,'.gz')
    cmd = sprintf('gunzip -f %s',t1File);
    system(cmd);
    t1File = fullfile(n,p);
end

ASL_Preprocessing(aslfolder,aslprefix,t1File);

cN   = num2str(N-1);
cN2  = num2str(N/2);
cN21 = num2str(N/2-1);

cmd = sprintf('fslmerge -t %s %s',fullfile(output,'label'),fullfile(aslfolder,['rasl_00{' cN2 '..' cN '}*']));
system(cmd);
cmd = sprintf('fslmerge -t %s %s',fullfile(output,'control'),fullfile(aslfolder,['rasl_00{00..' cN21 '}*']));
system(cmd);
cmd = sprintf('fslmaths %s -Tmean %s',fullfile(output,'label'),fullfile(output,'label_mean'));
system(cmd);
cmd = sprintf('fslmaths %s -Tmean %s',fullfile(output,'control'),fullfile(output,'control_mean'));
system(cmd);
cmd = sprintf('fslmaths %s -sub %s %s',fullfile(output,'label_mean'),fullfile(output,'control_mean'),fullfile(output,'asl_map'));
system(cmd);
cmd = sprintf('gunzip -f %s',fullfile(output,'asl_map.nii.gz'));
system(cmd);
cmd = sprintf('gunzip -f %s',fullfile(output,'control_mean.nii.gz'));
system(cmd);
cmd = sprintf('gunzip -f %s',fullfile(output,'label_mean.nii.gz'));
system(cmd);

disp('calcul carto CBF');
ASL_Map(fullfile(output,'control_mean.nii'),fullfile(output,'asl_map.nii'),fullfile(output,'CBF.nii'));

disp('reslice CBF.nii');
ASL_Reslice(t1File,fullfile(output,'CBF.nii'))

disp('correction volume partiel');

asl_path = fullfile(output,'rCBF.nii');
outdir   = fullfile(output,'pve_out');

ASL_RunPVE(t1File,asl_path,outdir);

file_to_copy = fullfile(output,'pve_out/rpet.hdr');
file_out     = fullfile(output,'pve_out/t1_MGRousset.hdr');
copyfile(file_to_copy,file_out,'f');
