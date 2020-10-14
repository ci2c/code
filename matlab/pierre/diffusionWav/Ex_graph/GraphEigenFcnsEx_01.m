% Load image. It should work with all image files supported by Matlab.
% Each image is assumed to have white background, and every black pixel is converted to
% a vertex in the graph.
fprintf('Loading image...');
X = DataSetFromImage('DataSetFromImageEx_07.bmp');
fprintf('%d points found...',size(X,2));
fprintf('done.\n');

% Construct graph, connecting nearby vertices.
fprintf('Constructing the graph...');
% The parameters here construct a graph connecting each point to its 5 nearest neighbors (kNN=5), computes the
% normalized Laplacian ('Normalization'='smarkov'), symmetrizes the weight matrix (since connecting vertex i to its
% 5 nearest neighbors is not a symmetric operation, i.e. if j is among the 5 nn's of i, it is not necessarily the
% case that i is among the 5 nn's of j), the weights and edges are symmetrized by averaging with the transpose.
% Finally, compute the 30 bottom eigenvectors of the normalized Laplacian ('kEigenVecs'=30).
G = GraphDiffusion(X, 0, struct('Normalization','smarkov','kNN',5,'kEigenVecs',30,'Symmetrization','W+Wt'));%,'Epsilon',0));
% This line is commented out, but it construct a graph as above, but instead of connecting each vertex i to its
% 5 nearest neighbors, it connects it to all the vertices within Radius 0.05. Symmetrization is not needed in this case,
% it's there only for numerical purposes.
%G = GraphDiffusion(X, 0.05, struct('Normalization','smarkov','kEigenVecs',30,'Symmetrization','W+Wt'));
fprintf('\n');

% Find edges
fprintf('Drawing the graph and the edges...');
[i,j] = find(G.W~=0); 
% Display vertices and edges (quite slow, you may find it hard to plot and browse/zoom in the plots.)
figure;plot(X(1,:),X(2,:),'or');hold on; for lk=1:length(i);line([X(1,i(lk));X(1,j(lk))],[X(2,i(lk));X(2,j(lk))]);end;
fprintf('\n');
pause;

% Display the eigenvalues. GraphDiffusion really uses the matrix T=I-\mathcal{L} rather than \mathcal{L},
% so we plot 1-G.EigenVals, which are the eigenvalues of \mathcal{L}
figure;plot(1-G.EigenVals);axis tight;pause;

% Display the eigenfunctions
figure;
for lk = 1:size(G.EigenVecs,2),
    scatter(X(1,:),X(2,:),10,G.EigenVecs(:,lk));title(sprintf('EigenVector %d',lk));colorbar;pause;
end;

% Display the eigenembedding
figure;plot(G.EigenVecs(:,2),G.EigenVecs(:,3),'.');xlabel('\phi_2');ylabel('\phi_3');pause;
figure;plot3(G.EigenVecs(:,2),G.EigenVecs(:,3),G.EigenVecs(:,4),'.');xlabel('\phi_2');ylabel('\phi_3');zlabel('\phi_4');pause;
