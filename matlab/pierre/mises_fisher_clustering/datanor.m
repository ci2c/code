function datn = datanor(dat,norType,dim)
% datn = datanor(dat,norType,dim)
%
% This function normalizes dat along dimensin dim (default is 1). Possible normalization
% types are:
%
% 'scul': scale all vectors to have unit length
% 'norm': remove the mean and divide by standard deviation
% 'rmmn': remove the mean
%
% The default is 'scl'.

if nargin < 3
    dim =1;
end

sizeData = size(dat);

if dim > size(sizeData,2)
    fprintf('\nError: which dimension are you talking about?\n\n');
    return
end

perDims = ones(1,size(sizeData,2));
perDims(dim) = sizeData(dim);

if nargin < 2
    norType = 'scul';
end

if norType == 'scul'
    datn = dat ./ repmat(sqrt(sum(dat.^2,dim)),perDims);
elseif norType == 'norm'
    datn = dat-repmat(mean(dat,dim),perDims);
    datn = datn ./ repmat(sqrt(sum(datn.^2,dim)),perDims);
elseif norType == 'rmmn'
    datn = (dat-repmat(mean(dat,dim),perDims));
else
    fprintf('\nError: normalization type not recognized. \n\n');
end

end
