function [info,vol] = readmnc_emma(fname)
% [info,vol] = readmnc_emma(fname)
%
% vol is returned in the same way it looks in Register or Display (right is
% right).
%
% Luis Concha. July, 2008.

handle = openimage(fname);

info.time           = getimageinfo(handle,'time');
info.zspace         = getimageinfo(handle,'zspace');
info.yspace         = getimageinfo(handle,'yspace');
info.xspace         = getimageinfo(handle,'xspace');
info.Filename       = getimageinfo(handle,'Filename');
info.NumFrames      = getimageinfo(handle,'NumFrames');
info.NumSlices      = getimageinfo(handle,'NumSlices');
info.ImageHeight    = getimageinfo(handle,'ImageHeight');
info.ImageWidth     = getimageinfo(handle,'ImageWidth');
info.ImageSize      = getimageinfo(handle,'ImageSize');
info.DimSizes       = getimageinfo(handle,'DimSizes');
info.Steps          = getimageinfo(handle,'Steps');
info.Starts         = getimageinfo(handle,'Starts');
info.dirCosines     = getimageinfo(handle,'dirCosines');
info.Permutation    = getimageinfo(handle,'Permutation');

vol = getimages(handle,1:info.NumSlices);
vol = reshape(vol,info.ImageWidth,info.ImageHeight,info.NumSlices);
vol = permute(vol,[2 1 3]);
vol = flipdim(vol,1);

closeimage(handle);