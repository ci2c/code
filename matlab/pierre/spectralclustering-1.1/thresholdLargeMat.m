function Mat = thresholdLargeMat(Mat, threshold)
% usage : Mat = thresholdLargeMat(Mat, threshold)
%
% Zeros all values of Mat <= thresold
%
% Pierre Besson @ CHRU Lille, Apr. 2013

if nargin ~= 2
    error('invalid usage');
end

[nx ny] = size(Mat);

Delta = 50000;

for i = 1 : Delta : nx
    i_end = min(i + Delta - 1, nx);
    for j = 1 : Delta : ny
        j_end = min(j + Delta - 1, ny);
        Mat(i:i_end, j:j_end) = Mat(i:i_end, j:j_end) .* (Mat(i:i_end, j:j_end) > threshold);
    end
end
