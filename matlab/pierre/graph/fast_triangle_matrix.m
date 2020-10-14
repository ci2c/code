function [i,j,X,Y,Z] = fast_triangle_matrix(surf_coord, triangles, fib_coord, ids, n_tracts)
% 
% usage : [i,j,X,Y,Z] = fast_triangle_matrix(SURF_COORD, TRIANGLES, FIB_COORD, IDS, N_TRACTS)
%
% Input :
%      SURF_COORD      : Coordinates of surface vertices. Usually the coord field as
%           returned by SurfStatReadSurf. Format : single
%      TRIANGLES       : Triangles list of the cortical mesh, as the tri
%           field returned by SurfStatReadSurf. Format : int32
%      FIB_COORD       : Concatenation of the fiber coordinates. Format : single
%      IDS             : Concatenation of the fiber IDs. Format : int32
%      N_TRACTS        : Number of tracts in total. Format : int32
%
%
% Output :
%      i,j             : i and j indices of non-zero elements
%      X,Y,Z           : contact direction between fiber i and triangle j
% 
% Pierre Besson @ CHRU Lille, Mar. 2013

error('fast_triangle_matrix.c not compiled')