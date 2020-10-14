function bvecs_to_dtitool(bvecs_in, bvecs_out)
%
% usage : bvecs_to_dtitool(BVECS_IN, BVECS_OUT)
%
%   Input :
%        BVECS_IN        : input bvecs (i.e. '/path/to/your_bvecs')
%        BVECS_OUT       : output bvecs (i.e. '/path/to/your_bvecs_output')
%
% Swap and flip FSL bvecs to make them work for dti tool
%
% Pierre Besson @ CHRU Lille, May 2011

if nargin ~= 2
    error('invalid usage');
end

bvecs = dlmread(bvecs_in);
if size(bvecs, 1) > size(bvecs, 2)
    bvecs = bvecs';
end

output = zeros(size(bvecs));
output(1, :) = bvecs(2, :);
output(2, :) = -bvecs(1, :);
output(3, :) = -bvecs(3, :);

dlmwrite(bvecs_out, output', 'delimiter', ' ', 'precision', 6);