function dimg = mipisodiffusion2d(img,fncname,NofI,tau,sigma,ksize,ftype,th)
% MIPISODIFFUSION2D  Anisotropic Diffusion
%
%   DIMG = MIPISODIFFUSION2D(IMG,FNCNAME,NOFI,TAU,SIGMA,KSIZE,FTYPE,TH)
%
% img       : input image
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
%   See also MIPISODIFFUSION3D 

if (nargin <3)
    fprintf(1,'Not enough arguments');
    return;   
end;
if (tau > 0.25)
    fprintf(1,'wrong tau, enter a number in 0 < tau <0.25');
    return;
end;

ksize = floor(ksize);
if (iseven(ksize))
    ksize=ksize+1;
end;
    
[row,col] = size(img);
% Eliminate (-) intensities
img(img < 0) = 0;
dimg = padarray(img,[1 1],'symmetric','both');
nimg = dimg;
de   = zeros(size(dimg));
UW = de; UE = de; UN = de; US = de;
dw = de; dn = de; ds = de; 
dx = de; dy = de;

% Calculate Gaussian kernel size
gksize = mipgausskernelsize(sigma);
h      = fspecial('Gaussian',[gksize gksize],sigma);
alpha  = 0.25;
%start diffusing .......... 
for ii = 1:NofI
    if ii > NofI
        break;
    end; 
    switch (ftype)
    case {'Median','m'}
        fimg = medfilt2(nimg,[ksize ksize]); 
    case {'Gaussian','g'}
        fimg = imfilter(nimg,h,'conv');
    case {'none','n'}
        fimg = nimg;
    case 'tm'
        fimg = trimmed_mean(nimg,ksize,alpha);
    otherwise, disp('Filter type is unknown'); dimg = 0;
        return;
    end;
    
    % Calculate the gradients of the filtered image
    % This is a second-order approximation because it uses central
    % differences.
    dx = mipcentraldiff(fimg,'dx');
    dy = mipcentraldiff(fimg,'dy');
    mgrad = 0.5*(dx.*dx+dy.*dy).^(1/2); 
    % Calculate the threshold k
    [pdf,cbin] = hist(mgrad(:),8192);
    k   = cbin(kfun(pdf/prod(size(mgrad)),th));
    dmn = feval(fncname,k,mgrad);    
    % compute the gradients in N,S,W,E directions 
    de(:,2:col+1) = nimg(:,3:col+2) - nimg(:,2:col+1);
    dw(:,2:col+1) = nimg(:,2:col+1) - nimg(:,1:col);
    ds(2:row+1,:) = nimg(3:row+2,:) - nimg(2:row+1,:);
    dn(2:row+1,:) = nimg(2:row+1,:) - nimg(1:row,:);
  
    UE(:,2:col+1) = dmn(:,3:col+2) + dmn(:,2:col+1);
    UW(:,2:col+1) = dmn(:,1:col)   + dmn(:,2:col+1);
    US(2:row+1,:) = dmn(3:row+2,:) + dmn(2:row+1,:);
    UN(2:row+1,:) = dmn(1:row,:)   + dmn(2:row+1,:);
    dimg = dimg + tau*0.5*(UE.*de-UW.*dw + ds.*US-UN.*dn);
    nimg = dimg;  
end;
dimg = dimg(2:row+1,2:col+1);

%-------------------------
% This function computes k
%-------------------------
function k = kfun(pdf,threshold)
flag = 1;
temp_var = pdf(1);
psize = size(pdf,2);
for i = 2:psize;
   if (temp_var >= threshold & flag)
      k = i;
      flag = 0;
       break;
   end;
temp_var = temp_var + pdf(i);   
end;
return;

%--------------------------------
% Favors wider regions
%--------------------------------
function y = wregion(k,x)
y = 1./(1+(x/k).^2);
return;

%-------------------------------
% favors high-contrast regions
%-------------------------------
function y = hgrad(k,x)
y = exp(-(x/k).^2);
return;
%-------------------------------
% Tukey's biweight robust error norm
%-------------------------------
function y = tukey(k,x)
y = zeros(size(x));
id = (x<=k);
xid = x(id);
y(id) = xid.*((1-(xid/k).^2).^2);
return;
%-------------------------------
% Weickert's diffusivity function
%-------------------------------
function y = weickert(k,x)
y = ones(size(x));
ind = (x > 0);
xind = x(ind);
y(ind) = 1-exp(-3.15./((xind/k).^4));
return;