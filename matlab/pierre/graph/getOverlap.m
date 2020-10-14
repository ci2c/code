function getOverlap(surf_src, surf_trg, olp_out, vec_in)
% usage : getOverlap(SURF_SRC, SURF_TRG, OLP_OUT, VEC_IN)
% Computes overlaping triangles between the source surface and the target
% surface
%
% Inputs :
%   SURF_SRC     : Path to the source surface 
%                   (F faces)
%   SURF_TRG     : Path to the target surface
%   OLP_OUT      : Path to the output overlap file
%   VEC_IN       : F x 1 attributes or path to a .mat file assigned to the source surface faces
%
% Pierre Besson @ CHRU Lille, Sep. 2013

if nargin ~= 4
    error('invalid usage');
end

if ~ischar(surf_src)
    error('SURF_SRC must be a path');
end

if ~ischar(surf_trg)
    error('SURF_TRG must be a path');
end

if ~ischar(olp_out)
    error('OLP_OUT must be a path');
end

if ischar(vec_in)
    Temp = load(vec_in);
    Temp2 = char(fieldnames(Temp));
    vec_in = Temp.(Temp2);
    clear Temp Temp2;
end

temp = srf2srf('areal', surf_src, surf_trg, olp_out, vec_in);