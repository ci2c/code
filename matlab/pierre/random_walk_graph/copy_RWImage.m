function output = copy_RWImage(New_image, Ref_struct)
% Usage: Output = copy_RWImage(NEW_Image, REF_Struct)
%
% Output uses the same random walk path as REF_Struct with the new image
% New_Image
%
% Inputs:
%     NEW_Image          : nx x ny matrix or path to an image
%     REF_Struc          : Image structure. REF_Struct.Image must also be a
%                             nx x ny matrix
%
% Output:
%     Output             : New image structure
%
% See also: RWImage, denoise_RWImage
%
% Pierre Besson, Nov. 2009

if nargin ~= 2
    error('Invalid usage');
end

if isstr(New_image)
    New_image = double(imread(New_image));
end

[nx, ny] = size(Ref_struct.Image);
[nxn, nyn] = size(New_image);

if (nx ~= nxn) || (ny ~= nyn)
    error('Image sizes do not match');
end

output.Image = New_image;
output.rand_e = Ref_struct.rand_e;
output.M_select = Ref_struct.M_select;
output.rand_w = New_image(output.rand_e);