function simg = mipsphereshell(psize,sthickness,R1,R2)
% MIPSPHERESHELL   
%
%   [HIMG,MIE] = MIPSPHERESHELL(PSIZE,STHICKNESS,R1,R2)
%
%  PSIZE     : pixel size
%  STHICK    : Slice thickness
%  R1, R2    : inner and outer radius R1< R2
%  SIMG      : output image

% This function creates a spherical shell
%   See also
% 
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

count = 1;
imsize = 2*R2/psize+2;
halfsize = imsize/2;
nslice = length(1:sthickness:R2);
simg = zeros(imsize,imsize,nslice);

for i=0:sthickness:R2
    if i < R1
        a1 = sqrt(R1*R1-i*i);
    else
        a1 = 0;
    end
    a2 = sqrt(R2*R2-i*i);
    tt = create_shell(imsize,a1,a2);
    simg(:,:,count) = tt;
    count = count+1;
end

sphere_half = simg(:,:,2:end);    
simg = simg(:,:,end:-1:1);
simg(:,:,end+1:2*end-1) = sphere_half;

function s = create_shell(imsize,R1,R2)
% R1< R2
halfsize = imsize/2;
if R1~=0
    c1= phantom([1 R1/halfsize R1/halfsize 0 0 0],imsize);
else
    c1 = zeros(imsize,imsize);
end

if R2~=0
    c2= phantom([1 R2/halfsize R2/halfsize 0 0 0],imsize);
else
    c2 = zeros(imsize,imsize);
end
s = (~c1&c2);
