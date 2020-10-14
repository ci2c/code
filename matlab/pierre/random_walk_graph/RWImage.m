function Output = RWImage(Image, Min_selection, Kapa)
% Usage : Output = RWImage(IMAGE, [Min_selection, Kapa])
%
% Denoise an Image using RW method
%
% Inputs :
%       IMAGE          : nx x ny array; or path to image file
%       Min_selection  : Number of times each pixel must be selected at
%                         least. Default : 100
%       Kapa           : Smoothness parameter. Default : 5
%
% Output :
%       Output         : Structure containing original image and
%                         random-walk
%
% Pierre Besson, Nov. 2009

if nargin < 1 && nargin > 2
    error('Invalid usage');
end

if nargin < 2
    Min_selection = 100;
end

if nargin < 3
    Kapa = 5;
end

if isstr(Image)
    Image = double(imread(Image));
end

% Proceed random walk
Output.Image = Image;
[nx,ny] = size(Image);
[Output.rand_w, Output.rand_e, Output.M_select] = getRWImage(Image, Min_selection, Kapa);
Output.M_select = reshape(Output.M_select, nx, ny);
Output.rand_e = Output.rand_e + 1;
