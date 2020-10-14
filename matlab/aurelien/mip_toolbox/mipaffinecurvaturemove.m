function dimg = mipaffinecurvaturemove(img,NofI,lambda);
% MIPAFFINECURVATUREMOVE  PDE based image diffusion
%
%   DIMG = MIPAFFINECURVATUREMOVE(IMG,NOFI, LAMBDA)
%
%   Diffuses images using Sapiro's affine invariant evolution equation
% img       : input image
% lambda     : (diffusion speed) assumes values in the range [0, 0.25]
%
% dimg      : output image
%
%   See also MIPISODIFFUSION2D MIPMIPTVDIFFUSION

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

[row,col]= size(img);
% zero padding around the image
dimg = padarray(img,[1 1 1],'symmetric','both');
dx   = zeros(size(dimg));
dy   = dx;
dxy  = dx;
dx2  = dx;
dy2  = dx;
epsilon = 0.01;
for i=1:NofI  
   nimg = dimg;  
   dx(:,2:col+1) = nimg(:,3:col+2)-nimg(:,1:col);
   dx  = dx./2;
   dy(2:row+1,:) = nimg(3:row+2,:)-nimg(1:row,:);
   dy  = dy./2;
   dxy(2:row+1,2:col+1) = nimg(3:row+2,3:col+2)+nimg(1:row,1:col)-nimg(3:row+2,1:col)-nimg(1:row,3:col+2);
   dxy = dxy./4;
   dx2(2:row+1,2:col+1) = nimg(2:row+1,3:col+2)+nimg(2:row+1,1:col)-2*nimg(2:row+1,2:col+1);
   dy2(2:row+1,2:col+1) = nimg(3:row+2,2:col+1)+nimg(1:row,2:col+1)-2*nimg(2:row+1,2:col+1);
   curv = dy2.*(dx.*dx) + dx2.*(dy.*dy) - 2*dx.*dy.*dxy;
%    curv = curv./((dx.*dx) + (dy.*dy)+ epsilon);
   curv(isnan(curv)) = 0;
   abs_curv = abs(curv);
   abs_curv = lambda*(abs_curv).^(1/3);
   flag_neg = curv < 0;
   flag_pos = curv >= 0;
   flag     = flag_pos - flag_neg;
   abs_curv = flag.*abs_curv;
   dimg     = dimg + abs_curv;
end;
dimg = dimg(2:row+1,2:col+1);