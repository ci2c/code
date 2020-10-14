function LSD = LeastSquareDistance(RefRes,SourceRes)
%
% This function computes the least square distance between two vectors of
% spatial resolution
%
% Matthieu Vanhoutte 14/02/17

% Check that both inputs are of size [1, 3]
dimRef = size(RefRes);
dimSource = size(SourceRes);
if ~isequal(dimRef,[1,3]) || ~isequal(dimSource,[1,3])
    error('input must be a 1 by 3 vector')
end

Diff = SourceRes-RefRes;
LSD = norm(Diff);