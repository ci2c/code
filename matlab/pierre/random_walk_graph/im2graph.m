function G = im2graph(Image, x0, y0, nx, ny)
% Usage : G = im2graph(IMAGE, [x0, y0, nx, ny])
%
% Converts IMAGE to a graph
%
% Inputs :
%       IMAGE   : nx x ny array or path to image file
%
% Options for image cropping :
%       x0, y0      : Origin of the cut
%       nx, ny      : Dimensions of the new image
%
%
% Output :
%       G           : Graph structure
%
% See also initGraphRW
%
% Pierre Besson, Nov. 2009

if (nargin ~= 1) && (nargin ~=3) && (nargin~=5)
    error('Invalid usage');
end

if isstr(Image)
    Image = double(imread(Image));
end

if nargin == 5
    Image = Image(y0:y0+ny, x0:x0+nx);
elseif nargin == 3
    Image = Image(y0:end, x0:end);
end

[nx, ny] = size(Image);
M_g = zeros(nx*ny);
[X, Y] = meshgrid(1:nx, 1:ny);

for i = 1 : nx * ny
    Neigh = sqrt((X-X(i)).^2 + (Y-Y(i)).^2) < 2;
    M_g(i*ones(size(Neigh)), Neigh) = 1;
end

M_g = M_g - eye(size(M_g, 1));
W = Image((1:nx*ny)');

G = initGraphRW(M_g, W);
% set_matrix(g, M_g);
embed(G.g, [X(:) ny-Y(:)]);