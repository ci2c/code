function vX = DataSetFromImage( cFileName )

%
% function vX = DataSetFromImage( cFileName ) 
% 
%
% EXAMPLE:
%   X = DataSetFromImage('DataSetFromImageEx_01.bmp');
%   G = GraphDiffusion(X, 0, struct('Normalization','smarkov','kNN',5));
%   [i,j] = find(G.W~=0); 
%   figure;plot(X(1,:),X(2,:),'.');hold on; for lk=1:length(i);line([X(1,i(lk));X(1,j(lk))],[X(2,i(lk));X(2,j(lk))]);end;
%

try
    % Load the file containing the description of the rooms environment
    lImage = imread(cFileName);        
catch
    fprintf('\n Error: could not load the description file %s!',cFileName);
    return;
end;

lSumImage           = sum(lImage,3);
% Find the complement of the domain
[vX(2,:),vX(1,:)]   = find(lSumImage==0);

% Renormalize the coordinates
vX(1,:) = (vX(1,:)-min(vX(1,:)))/(max(vX(1,:))-min(vX(1,:)));
vX(2,:) = (vX(2,:)-min(vX(2,:)))/(max(vX(2,:))-min(vX(2,:)));
vX(2,:) = 1-vX(2,:);

return;