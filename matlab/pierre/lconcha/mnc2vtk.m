function mnc2vtk(infname,outfname,dims)
% function mnc2vtk(infname,outfname)
% 
% Save a mnc file in vtk format
%
% infname  : .mnc or .mnc.gz file name
% outfname : .vtk file name
% dims     : Voxel dimensions [x y z] if you want to change them. If
%            ommited, it defaults to whatever the mnc file has originally.
%            If it is not defined, then the origin of the mnc file (starts)
%            will be used. 
%
%
% Luis Concha. BIC. September, 2008.

[infomnc,volmnc] = readmnc_emma(infname);

origin = [1 1 1];
dims   = [1 1 1];
if nargin < 3
    dims = infomnc.Steps';
    origin = infomnc.Starts';
end


save_volume_vtk(volmnc,outfname,'BINARY',dims,origin);