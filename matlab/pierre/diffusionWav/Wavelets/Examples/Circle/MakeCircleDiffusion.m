function T = MakeCircleDiffusion(N)
% function T = MakeCircleDiffusion(N)
%
% MAKECIRCLEDIFFUSION returns the 3-point diffusion operator on the circle.
%
% In:
%    N = number of points for the circle' discretization
%
% Out:
%    T = NxN sparse matrix representing the diffusion
%
% Dependencies:
%    gconv.dll
%
% Version History:
%    jcb       02/06/06       initial version
%

v = sparse([1 2 3], [1 1 1], [1/4 1/2 1/4], N, 1, N);
T = gconv(v, 2);


