function RootMeanSquareError(FileRef,FileSource,FileWrite)
%
% This function computes the root mean square error between two vectors of
% spatial resolution
%
% Matthieu Vanhoutte 16/04/18

fileIDRef = fopen(FileRef,'r');
fileIDSource = fopen(FileSource,'r');

formatSpec = '%f';
format long

RefRes = fscanf(fileIDRef,formatSpec)';
SourceRes = fscanf(fileIDSource,formatSpec)';

fclose(fileIDRef);
fclose(fileIDSource);

% Check that both inputs are of size [1, 3]
dimRef = size(RefRes);
dimSource = size(SourceRes);
if ~isequal(dimRef,[1,3]) || ~isequal(dimSource,[1,3])
    error('input must be a 1 by 3 vector')
end

Diff = SourceRes-RefRes;
RMSE = sqrt(sum(abs(Diff).^2)/size(Diff,2));

fileID = fopen(FileWrite,'w');
fprintf(fileID,'%f',RMSE);
fclose(fileID);