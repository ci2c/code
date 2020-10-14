function Generate_hippo(middle_line, slice_cut, filename, image_size, voxelsize)
% Usage: Generate_hippo(MIDDLE_LINE, SLICE_CUT, FILENAME, IMAGE_SIZE, VOXELSIZE)
%
% Inputs
% ------
% MIDDLE_LINE - array of the position of the hippocampal middle line
%              N x 3 matix : [x_point1, y_point1, z+point1;
%				 x_point2, y_point2, z_point2;
%				 ...
%				 x_pointN, y_pointN, z_pointN];
%
% SLICE_CUT - 3D array of the shape of a slice cut of the hippocampus along the middle line
%             J x K x L array.
%             For example: 
%		[1 1 1;
%		1 1 1;
%		1 1 1]; Is the array of a 3 x 3 square
%
% FILENAME - File to save the hippocampus *.mnc
%
% IMAGE_SIZE - Size (in mm) of output image. [x, y, z]
%
% VOXELSIZE - Set the size of voxels [sx, sy, sz]

if nargin ~= 5
	error('Wrong number of arguments');
end

if size(image_size) ~= [1 3]
	error('Unvalid image size');
end

n_points = size(middle_line, 1);
J = size(slice_cut, 1);
K = size(slice_cut, 2);
L = size(slice_cut, 3);

image_size_vox = round(image_size ./ voxelsize);
Image_out = zeros(image_size_vox);

for i = 1 : n_points
	X = floor(middle_line(i, 1) / voxelsize(1));
	Y = floor(middle_line(i, 2) / voxelsize(2));
	Z = floor(middle_line(i, 3) / voxelsize(3));
	for j = 1 : J
		for k = 1 : K
			for l = 1 : L
				Image_out(X+j, Y+k, Z+l) = max(slice_cut(j, k, l), Image_out(X+j, Y+k, Z+l));
			end
		end
	end
end

%Range = [min(find(Image_out ~= 0)); max(find(Image_out ~= 0))];

f = savemnc(Image_out, filename, voxelsize, [0, 0, 0]);

return