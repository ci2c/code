function bimg = mipimbin(img,N,DIM)
% MIPIMBIN     Bins pixels
%
%   BIMG = MIPIMBIN(X,N,DIM)
%
%   This function will bin (sum)image pixels rowwise or columnwise to create a
%   smaller size image
% 
%   N is a scalar or a 2-value vector:
%  
%   DIM is the dimension along which the numbers will be added
%   DIM = 1: every N rows are added, 
%   DIM = 2: every N columns are added
%   DIM = 3: N is a vector, N(1) rows and N(2) columns are added
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

imS = size(img);
if  DIM == 1
    bimg = blkproc(img,[N 1],'sum');
 % remove the row if #rows is not divisible by N(1)
    if (rem(imS(1),N(1))) ~= 0
        bimg = bimg(1:end-1,:);
    end
elseif DIM == 2
    bimg = blkproc(img,[1 N],'sum');
    if (rem(imS(2),N(2))) ~= 0
        bimg = bimg(:,1:end-1);
    end
elseif DIM == 3
    tmpimg = blkproc(img,[N(1) 1],'sum');
    bimg   = blkproc(tmpimg,[1 N(2)],'sum');
    if (rem(imS(1),N(1))) ~= 0
        bimg = bimg(1:end-1,:);
    end
    if (rem(imS(2),N(2))) ~= 0
        bimg = bimg(:,1:end-1);
    end
else
    bimg = [];
end

