function savemnc_emma(vol,fname,DimSizes,ParentFile,clobber)
% savemnc_emma(vol,fname,DimSizes,ParentFile,clobber)
% 
% Function to save a mnc file (only 3D at this point)
% 
% vol        : The volume to save. Right is right, left is left. Should look just
%              like it does on Display or Register.
% DimSizes   : [time z y x]
% ParentFile : A file from which to obtain header information
% clobber    : true or false.
%
% Luis Concha. July, 2008.

D = dir(fname);
if ~isempty(D)
   if clobber
       disp(['Overwriting ' fname]);
       eval(['!rm -f ' fname ]);
   else
       disp([fname ' already exists and no clobber']);
       return
   end
end

vol = flipdim(vol,1);
vol = permute(vol,[2 1 3]);

images = reshape(vol,DimSizes(4)*DimSizes(3),DimSizes(2));

if nargin > 3
    handle = newimage(fname,DimSizes,ParentFile);
    putimages(handle,images,1:DimSizes(2));
else
    handle = newimage(fname,DimSizes);
end


closeimage(handle);