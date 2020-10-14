function G_new = copyGraph(G, Mat)
% Usage : G_new = copyGraph(G, MAT)
%
% Creates G_new with same structure as G and MAT as connectivity matrix or
% as measurements vector
%
% Inputs :
%           G          : Existent Graph Structure
%           MAT        : M x M Connectivity matrix or M x 1 vector of the
%                         new graph
%
% Output :
%           G_new      : New graph structure
%
% See also initGraphRW, saveGraphRW, loadGraphRW
%
% Pierre Besson, Nov. 2009

if nargin ~= 2
    error('Invalid usage');
end

if size(Mat, 1) < size(Mat, 2)
    Mat = Mat';
end

F = fieldnames(G);
F(strcmp(F,'g')) = [];
F(strcmp(F,'h')) = [];
for i = 1 : length(F)
    G_new.(char(F(i))) = G.(char(F(i)));
end

G_new.g = graph;
copy(G_new.g, G.g);

try S=size(G.h);
    G_new.h = graph;
    copy(G_new.h, G.h);
    if (size(Mat, 2) == 1) && (size(Mat, 1) == length(G_new.W))
        G_new.Mat = Weights2Mat(G_new.h, Mat);
        G_new.W = Mat;
    elseif (size(Mat, 1) == S(1)) && (size(Mat, 2) == S(1))
        G_new.Mat = Mat;
        G_new.W = getWeightsList(G.h, Mat);
    else
        error('size of MAT incompatible with G');
    end
    G_new.rand_w = G_new.W(G_new.rand_e);
catch
    if length(Mat) ~= length(G.W)
        error('Size of MAT incompatible with G');
    end
    G_new.Mat = G.Mat;
    G_new.W = Mat;
    G_new.rand_w = G_new.W(G_new.rand_e);
end
