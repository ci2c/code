function [data,V] = st_read_nifti(file_name,path_name,opt)

% read of analyze 4D series of images 
%
% [data,V] = st_read_nifti(file_name,path_name,opt)
%
% This function allows to read 3D volume in the nifti format (*.nii).
%
% INPUTS
% file_name    (String, example 'my_file*.nii') Filter of the images to read.
% path_name    (string, default: '.') path of the images to read.
%               (if the path is empty, then file_name is assumed to contain
%               the path).
% opt          (integer, default: 1) file names specification mode.
%              0:  every files fitting the filter will be read.
%              1: opens a dialog interface to interactively select the
%              images.
%
% OUTPUTS
% data         (4D or 3D array). data(:,:,:,i) is the data of the ith file.
% V           (structure). V(i) is a description of the .hdr and .mat
%              of each file. 
%

if nargin == 1
    path_name = '.';
end

if nargin < 3  
    opt = 1;
end

if opt == 0
    F = spm_select('List',path_name,file_name);
end
    
if opt == 1
    F= spm_select();
end
nbf = size(F,1);

%h = waitbar(0,'data loading...');
if exist('spm_vol.m')==2
    warning off
    V = spm_vol([path_name filesep F]);
    %waitbar(2/3,h)

    data = spm_read_vols(V);
    %waitbar(3/3,h)
    warning on
else
    disp('Need spm8');
    return;
end
% close(h)
