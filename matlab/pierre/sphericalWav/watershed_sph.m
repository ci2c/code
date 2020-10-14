function Out = watershed_sph(Mat, filter_size, threshold, is_debug);
% Usage: function Out = watershed(prob_map, [filter_size], [threshold], [is_debug]);
% 
% Return the "clean" watershed transform of the probability map prob_map
% Options: 
%  - filter_sd : SD of the sobel operator along theta angle. The
% higher filter_size, the bigger the filter. Default: filter_size = 5
%  - threshold : value of the threshold to create the seeds
%  - is_debug : display all intermediate images for debugging task
%
% Author: Pierre Besson, v.0.1 September, 04 2008

% check args
if nargin < 1 | nargout ~= 1 | nargin > 4
    help watershed_sph
    error('Incorrect expression');
end

% Compute gradient of Mat
if nargin == 1
    filter_size = 5;
end
[phi, theta] = sphgrid(size(Mat,1), size(Mat,2));
Filt = sobelsph(phi, theta, filter_size);
fFilt = fst(Filt);
fMat = fst(Mat);
corr = softcorr(fMat, fFilt);
%gradmag = sqrt(real(corr(:,:,1)).^2 + real(corr(:,:,(round(90 * 360 / size(corr, 3))))).^2);
gradmag = sqrt(real(corr(:,:,1)).^2 + real(corr(:,:,66)).^2);

% Opening-closing of the map
se = strel('disk', 20);
Mato = imopen(Mat, se);
Mate = imerode(Mat, se);
Matobr = imreconstruct(Mate, Mat);
Matoc = imclose(Mato, se);
Matobrd = imdilate(Matobr, se);
Matobrcbr = imreconstruct(imcomplement(Matobrd), imcomplement(Matobr));
Matobrcbr = imcomplement(Matobrcbr);
fgm = imregionalmax(Matobrcbr);

Mat2 = Mat;
Mat2(fgm) = 1;

se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
fgm4 = bwareaopen(fgm3, 20);

Mat3 = Mat;
Mat3(fgm4) = 1;

bw = im2bw(Matobrcbr, graythresh(Matobrcbr));

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;

gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);

Mat4 = Mat;
Mat4(imdilate(L==0, ones(3,3)) | bgm | fgm4) = 1;

Out = L;

if is_debug
    figure; yashow(corr(:,:,1), 'spheric');
    title('Gradient at angle 0');
    figure; yashow(corr(:,:,66), 'spheric');
    title('Gradient at angle 90');
    figure; yashow(gradmag, 'spheric');
    title('Gradient magnitude');
    figure; yashow(Mato, 'spheric');
    title('Opening (Mato)');
    figure; yashow(Matobr, 'spheric');
    title('Opening-by-reconstruction');
    figure; yashow(Matoc, 'spheric');
    title('Opening-closing (Matoc)');
    figure; yashow(Matobrcbr, 'spheric');
    title('Opening-closing by reconstruction (Matobrcbr)');
    figure; yashow(fgm, 'spheric');
    title('Regional maxim of opening-closing by reconstruction (fgm)');
    figure; yashow(Mat2, 'spheric');
    title('Regional maxima superimposed on original image (Mat2)');
    figure; yashow(Mat3, 'spheric');
    title('Modified regional maxima superimposed on original image (fgm4)');
    figure; yashow(bw, 'spheric');
    title('Thresholded opening-closing by reconstruction (bw)');
    figure; yashow(bgm, 'spheric');
    title('Watershed ridge lines (bgm)');
    figure; yashow(Mat4, 'spheric');
    title('Markers and object boundaries superimposed on original image (Mat4)');
end
    
