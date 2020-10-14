function f = savemnc(data,fname,voxelsize,origin)
%
% f = savemnc(data,fname,voxelsize,origin)
%
% data      :   3D matrix to be saved to mnc file.
% fname     :   File name of desired mnc file.
% voxelsize :   [x y z] vector of voxel dimensions.
% origin    :   Origin of image volume (default = [0 0 0]).
% 
% f         :   The function returns the file name.
%
% See also: readmnc
% Luis Concha. BIC MNI McGill. January, 2008.


if nargin<4
   origin = [0 0 0]; 
end

% Check if there's already a file with the same name
fdir = dir(fname);
if length(fdir) ~= 0
   disp([fname ' already exists. Overwriting!'])
   eval(['!rm ' fname])
end


% Reshape the data. If it looks OK in matlab, it should look OK in mnc
data = permute(data,[2 1 3]);
data = flipdim(data,2);

% First we need to temporarily save a nii file
temp = make_nii(data,voxelsize,origin);
temp = rri_orient(temp,[2 1 3]);
tmpFileName = ['tmp_' date '.nii'];
save_nii(temp,tmpFileName);

% Convert nii to minc and delete temporary nii.
eval(['!nii2mnc -quiet ' tmpFileName ' ' fname ' > /tmp/nii2mnc.txt'])
eval(['!rm ' tmpFileName])

f = fname;