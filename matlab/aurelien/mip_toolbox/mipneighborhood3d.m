function Nimg = mipneighborhood3d(img,nhood)
% MIPNEIGHBORHOOD3D     3D Neighborhood calculations
%
%   NIMG = MIPNEIGHBORHOOD3D(IMG,NHOOD)
%
%   This function computes the neighborhood in 2d to be used 
%   in image processing that needs the neighborhood. NHOOD can
%   be 6,18, or 26. The output image NIMG will have the size of 
%   r*c*nhood  where r and c are the number of rows and columns
%
%   See also MIPNEIGHBORHOOD2D 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

[R,C,Z]=size(img);
Nimg = single(ones(R,C,Z,nhood));
r0=2:R-1;
c0=2:C-1;
z0=2:Z-1;
switch nhood
    case 6 % six faces
        % 4 neighboors on the middle plane
        Nimg(r0,c0,z0,1) = img(r0-1,c0,z0);
        Nimg(r0,c0,z0,2) = img(r0,c0+1,z0);
        Nimg(r0,c0,z0,3) = img(r0+1,c0,z0);
        Nimg(r0,c0,z0,4) = img(r0,c0-1,z0);
        % top voxel
        Nimg(r0,c0,z0,5) = img(r0,c0,z0-1);
        % bottom voxel
        Nimg(r0,c0,z0,6) = img(r0,c0,z0+1);
    case 18 % six faces and 12 edges
        Nimg = neighborhood18(Nimg);
    case 26 % six faces, 12 edges and 8 corners 
        Nimg = neighborhood18(Nimg);
        % four corners-top
        Nimg(r0,c0,z0,19) = img(r0-1,c0-1,z0-1);
        Nimg(r0,c0,z0,20) = img(r0-1,c0+1,z0-1);
        Nimg(r0,c0,z0,21) = img(r0+1,c0+1,z0-1);
        Nimg(r0,c0,z0,22) = img(r0+1,c0-1,z0-1);
        % four corners bottom
        Nimg(r0,c0,z0,23) = img(r0-1,c0-1,z0+1);
        Nimg(r0,c0,z0,24) = img(r0-1,c0+1,z0+1);
        Nimg(r0,c0,z0,25) = img(r0+1,c0+1,z0+1);
        Nimg(r0,c0,z0,26) = img(r0+1,c0-1,z0+1);
    otherwise
        errorgdlg('Neighborhood is unkown');
end
    function Nimg = neighborhood18(Nimg)
        % 8 neighbors on middle plane
        % from upper-left corner in clock-wise direction
        Nimg(r0,c0,z0,1) = img(r0-1,c0-1,z0);
        Nimg(r0,c0,z0,2) = img(r0-1,c0,z0);
        Nimg(r0,c0,z0,3) = img(r0-1,c0+1,z0);
        Nimg(r0,c0,z0,4) = img(r0,c0+1,z0);
        Nimg(r0,c0,z0,5) = img(r0+1,c0+1,z0);
        Nimg(r0,c0,z0,6) = img(r0+1,c0,z0);
        Nimg(r0,c0,z0,7) = img(r0+1,c0-1,z0);
        Nimg(r0,c0,z0,8) = img(r0,c0-1,z0);        
        % five voxels on top plane
        Nimg(r0,c0,z0,9) = img(r0,c0,z0-1); % center
        % 4-neighbors        
        Nimg(r0,c0,z0,10)= img(r0-1,c0,z0-1);
        Nimg(r0,c0,z0,11)= img(r0,c0+1,z0-1);
        Nimg(r0,c0,z0,12)= img(r0+1,c0,z0-1);
        Nimg(r0,c0,z0,13)= img(r0,c0-1,z0-1);
        % five voxels on bottom plane
        Nimg(r0,c0,z0,14)= img(r0,c0,z0+1); % center
        % 4-neighbors
        Nimg(r0,c0,z0,15)= img(r0-1,c0,z0+1);
        Nimg(r0,c0,z0,16)= img(r0,c0+1,z0+1);
        Nimg(r0,c0,z0,17)= img(r0+1,c0,z0+1);
        Nimg(r0,c0,z0,18)= img(r0,c0-1,z0+1);
    end
end

