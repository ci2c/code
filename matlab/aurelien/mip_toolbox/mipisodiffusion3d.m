function dimg = mipisodiffusion3d(img,pix_dim,fncname,NofI,tau,sigma,ksize,ftype,th)
% MIPISODIFFUSION3D  Anisotropic Diffusion
%
%   k = MIPISODIFFUSION3D(IMG,PIX_DIMS,FNCNAME,NOFI,TAU,SIGMA,KSIZE,FTYPE,TH)
%
% img       : input image
% pix_dim   : dimensions of the voxel; use [1 1 1] if it is isotropic
% fncname   : function name,e.g., 'wregion'
% NofI      : number of iterations
% tau       : stability constant 0-0.25
% sigma     : sigma for Gaussian filter
% ksize     : kernel size for median filter
% ftype     : filter type to be used, Gaussian, 'g', or median, 'm'
% th        : threshold for the contrast parameter K
%
% dimg      : output image
%
%   See also MIPISODIFFUSION2D 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

if (nargin <3)
    fprintf(1,'Not enough arguments');
    return;   
end;
if (tau > 1/6)
    fprintf(1,'wrong tau, enter a number in 0 < tau < 1/6');
    return;
end;

[row,col,zdim] = size(img);
% Set the grid sizes if it is an anisotropix voxel
% It assumes that x and y dimensions are equal and unit
% z dim is set to zdim/xdim 
if isempty(pix_dim)
    h3sqr = 1;
else
    h3 = pix_dim(3)/pix_dim(1);
    h3sqr = h3*h3;
end;
dimg = padarray(img,[1 1 1],'symmetric','both');
de  = zeros(row+2,col+2,zdim+2);
UE  = zeros(row+2,col+2,zdim+2);
UW  = UE;UN=UE;US=UE;
Uup = UE;Udwn=UE;Umnz=UE;
dw  = de;dn=de;ds=de;
dx  = de;dy=de;dup=de;ddwn=de;
nimg = dimg;
fncname1 = fncname(1:4);
% Calculate Gaussian kernel
gh = gauss3d(sigma);
for ii = 1:NofI  
    % Filter image if necessary
    switch (ftype)
        case 'g'
            fimg = imfilter(nimg,gh,'replicate');
        case 'm'
            fimg = mipmed3d(nimg,ksize);
        case 'n'
            fimg = nimg;
        otherwise, disp('Filter type is unknown'); dimg = 0; return;
    end;
    % Calculate the gradients of the filtered image
    % This is a second-order approximation because it uses central differences.
    % calculate the noise threshold
    dx = central_diff3d(fimg,'dx')/pix_dim(1);
    dy = central_diff3d(fimg,'dy')/pix_dim(2); 
    dz = central_diff3d(fimg,'dz')/pix_dim(3); 
    mgrad      = 0.5*sqrt(dx.*dx+dy.*dy+dz.*dz);
    [pdf,cbin] = hist(mgrad(:),8192);
    k = cbin(kfun(pdf/prod(size(mgrad)),th));
    
    dmn = feval(fncname,k,mgrad);
    
    % compute the gradients in N,S,W,E,Up,Down directions 
    de(:,2:col+1,:)   = nimg(:,3:col+2,:)  - nimg(:,2:col+1,:);
    dw(:,2:col+1,:)   = nimg(:,2:col+1,:)  - nimg(:,1:col,:);
    ds(2:row+1,:,:)   = nimg(3:row+2,:,:)  - nimg(2:row+1,:,:);
    dn(2:row+1,:,:)   = nimg(2:row+1,:,:)  - nimg(1:row,:,:);
    dup(:,:,2:zdim+1) = nimg(:,:,2:zdim+1) - nimg(:,:,1:zdim);
    ddwn(:,:,2:zdim+1)= nimg(:,:,3:zdim+2) - nimg(:,:,2:zdim+1);  
    UE(:,2:col+1,:)   = dmn(:,3:col+2,:) + dmn(:,2:col+1,:);
    UW(:,2:col+1,:)   = dmn(:,1:col,:)   + dmn(:,2:col+1,:);
    US(2:row+1,:,:)   = dmn(3:row+2,:,:) + dmn(2:row+1,:,:);
    UN(2:row+1,:,:)   = dmn(1:row,:,:)   + dmn(2:row+1,:,:);
    Uup(:,:,2:zdim+1) = dmn(:,:,1:zdim)  + dmn(:,:,2:zdim+1);
    Udwn(:,:,2:zdim+1)= dmn(:,:,3:zdim+2)+ dmn(:,:,2:zdim+1); 
    Umn  = 0.5*( (UE.*de - UW.*dw) + (US.*ds - UN.*dn) + ...
        (Udwn.*ddwn - Uup.*dup)/h3sqr);
    dimg = dimg + tau*Umn;
    nimg = dimg;
end;
dimg = dimg(2:row+1,2:col+1,2:zdim+1);


